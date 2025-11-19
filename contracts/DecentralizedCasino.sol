// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract DecentralizedCasino {
    address public immutable owner;
    
    mapping(address => uint256) public gameWeiValues;
    mapping(address => uint256) public blockNumbersToBeUsed;
    address[] public lastThreeWinners;
    
    uint256 public constant MIN_BET = 0.01 ether;
    uint256 public constant MAX_BET = 1 ether;
    uint256 public constant HOUSE_EDGE = 5;
    
    event GameStarted(address indexed player, uint256 amount, uint256 revealBlock);
    event GameResult(address indexed player, bool won, uint256 amount);
    
    error InsufficientContractBalance();
    error InvalidBetAmount();
    error GameAlreadyActive();
    error NoActiveGame();
    error TooEarly();
    error TooLate();
    error TransferFailed();
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    function playGame() public payable {
        uint256 blockNumberToBeUsed = blockNumbersToBeUsed[msg.sender];
        if (blockNumberToBeUsed == 0) {
            if (msg.value < MIN_BET || msg.value > MAX_BET) revert InvalidBetAmount();
            uint256 potentialPayout = (msg.value * 2 * (100 - HOUSE_EDGE)) / 100;
            if (address(this).balance < potentialPayout) revert InsufficientContractBalance();
            blockNumbersToBeUsed[msg.sender] = block.number + 1;
            gameWeiValues[msg.sender] = msg.value;
            emit GameStarted(msg.sender, msg.value, block.number + 1);
            return;
        }
        if (msg.value > 0) revert GameAlreadyActive();
        if (block.number <= blockNumberToBeUsed) revert TooEarly();
        if (block.number > blockNumberToBeUsed + 256) revert TooLate();
        uint256 betAmount = gameWeiValues[msg.sender];
        bytes32 blockHash = blockhash(blockNumberToBeUsed);
        if (blockHash == bytes32(0)) {
            blockNumbersToBeUsed[msg.sender] = 0;
            gameWeiValues[msg.sender] = 0;
            (bool refundSuccess, ) = msg.sender.call{value: betAmount}("");
            if (!refundSuccess) revert TransferFailed();
            emit GameResult(msg.sender, false, 0);
            return;
        }
        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(blockHash, msg.sender, betAmount))
        );
        bool won = randomNumber % 2 == 0;
        blockNumbersToBeUsed[msg.sender] = 0;
        gameWeiValues[msg.sender] = 0;
        if (won) {
            uint256 winningAmount = (betAmount * 2 * (100 - HOUSE_EDGE)) / 100;
            (bool success, ) = msg.sender.call{value: winningAmount}("");
            if (!success) revert TransferFailed();
            _updateWinners(msg.sender);
            emit GameResult(msg.sender, true, winningAmount);
        } else {
            emit GameResult(msg.sender, false, 0);
        }
    }
    
    function _updateWinners(address winner) private {
        if (lastThreeWinners.length < 3) {
            lastThreeWinners.push(winner);
        } else {
            lastThreeWinners[0] = lastThreeWinners[1];
            lastThreeWinners[1] = lastThreeWinners[2];
            lastThreeWinners[2] = winner;
        }
    }
    
    function getLastThreeWinners() external view returns (address[] memory) {
        return lastThreeWinners;
    }
    
    receive() external payable {
        revert("Use playGame() function");
    }
    
    function withdraw(uint256 amount) external onlyOwner {
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();
    }
    
    function fundCasino() external payable {
        // Allow funding the casino
    }
}