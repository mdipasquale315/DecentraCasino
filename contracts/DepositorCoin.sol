// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DepositorCoin is ERC20 {
    address public owner;
    uint256 public unlockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event UnlockTimeUpdated(uint256 newUnlockTime);

    error Unauthorized();
    error StillLocked(uint256 currentTime, uint256 unlockTime);
    error InvalidAddress();
    error InvalidLockTime();

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier isUnlocked() {
        if (block.timestamp < unlockTime) {
            revert StillLocked(block.timestamp, unlockTime);
        }
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _lockTime,
        address _initialOwner,
        uint256 _initialSupply
    ) ERC20(_name, _symbol) {
        if (_initialOwner == address(0)) revert InvalidAddress();

        owner = msg.sender; // Owner is the Stablecoin contract
        unlockTime = block.timestamp + _lockTime;

        _mint(_initialOwner, _initialSupply);
    }

    function mint(address to, uint256 value) external onlyOwner isUnlocked {
        if (to == address(0)) revert InvalidAddress();
        _mint(to, value);
    }

    function burn(address from, uint256 value) external onlyOwner isUnlocked {
        if (from == address(0)) revert InvalidAddress();
        _burn(from, value);
    }

    function transfer(address to, uint256 value) public override isUnlocked returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value)
        public
        override
        isUnlocked
        returns (bool)
    {
        return super.transferFrom(from, to, value);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert InvalidAddress();
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function extendLockTime(uint256 additionalTime) external onlyOwner {
        if (additionalTime == 0) revert InvalidLockTime();
        unlockTime += additionalTime;
        emit UnlockTimeUpdated(unlockTime);
    }

    function getTimeUntilUnlock() external view returns (uint256) {
        if (block.timestamp >= unlockTime) {
            return 0;
        }
        return unlockTime - block.timestamp;
    }
}
