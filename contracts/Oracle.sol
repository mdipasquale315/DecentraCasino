// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Oracle {
    uint256 private price;
    address public owner;
    uint256 public lastUpdateTimestamp;
    uint256 public constant PRICE_DECIMALS = 18; // For precision
    
    event PriceUpdated(uint256 newPrice, uint256 timestamp);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    error Unauthorized();
    error InvalidPrice();
    error PriceNotSet();
    
    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function getPrice() external view returns (uint256) {
        if (price == 0) revert PriceNotSet();
        return price;
    }
    
    function setPrice(uint256 newPrice) external onlyOwner {
        if (newPrice == 0) revert InvalidPrice();
        price = newPrice;
        lastUpdateTimestamp = block.timestamp;
        emit PriceUpdated(newPrice, block.timestamp);
    }
    
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Oracle: new owner is zero address");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
    function renounceOwnership() external onlyOwner {
        address oldOwner = owner;
        owner = address(0);
        emit OwnershipTransferred(oldOwner, address(0));
    }
}