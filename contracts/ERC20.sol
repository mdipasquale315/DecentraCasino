// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract FriendshipBracelets is Ownable {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    string public name = "Friendship Bracelets Stablecoin";
    string public symbol = "FRND";
    uint8 public immutable decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    error InsufficientBalance(uint256 available, uint256 required);
    error InsufficientAllowance(uint256 available, uint256 required);
    error InvalidAddress();

    constructor() Ownable(msg.sender) {
        _mint(msg.sender, 1_000_000 * 10**18); // initial supply to deployer
    }

    function transfer(address to, uint256 value) external returns (bool) {
        return _transfer(msg.sender, to, value);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function approve(address spender, uint256 value) external returns (bool) {
        if (spender == address(0)) revert InvalidAddress();
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 currentAllowance = allowance[from][msg.sender];
        if (currentAllowance < value) revert InsufficientAllowance(currentAllowance, value);
        if (currentAllowance != type(uint256).max) {
            allowance[from][msg.sender] = currentAllowance - value;
            emit Approval(from, msg.sender, allowance[from][msg.sender]);
        }
        return _transfer(from, to, value);
    }

    function _mint(address to, uint256 value) internal {
        if (to == address(0)) revert InvalidAddress();
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        if (from == address(0)) revert InvalidAddress();
        uint256 balance = balanceOf[from];
        if (balance < value) revert InsufficientBalance(balance, value);
        balanceOf[from] = balance - value;
        totalSupply -= value;
        emit Transfer(from, address(0), value);
    }

    function _transfer(address from, address to, uint256 value) private returns (bool) {
        if (from == address(0) || to == address(0)) revert InvalidAddress();
        uint256 senderBalance = balanceOf[from];
        if (senderBalance < value) revert InsufficientBalance(senderBalance, value);
        balanceOf[from] = senderBalance - value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
        return true;
    }
}
