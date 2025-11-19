// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./DepositorCoin.sol";
import "./Oracle.sol";
import "./FixedPoint.sol";

contract Stablecoin is ERC20 {
    DepositorCoin public depositorCoin;
    Oracle public oracle;
    uint256 public feeRatePercentage;
    uint256 public initialCollateralRatioPercentage;
    uint256 public depositorCoinLockTime;

    error InitialCollateralRatioError(string message, uint256 minimumDepositAmount);

    constructor(
        string memory _name,
        string memory _symbol,
        Oracle _oracle,
        uint256 _feeRatePercentage,
        uint256 _initialCollateralRatioPercentage,
        uint256 _depositorCoinLockTime
    ) ERC20(_name, _symbol) {
        oracle = _oracle;
        feeRatePercentage = _feeRatePercentage;
        initialCollateralRatioPercentage = _initialCollateralRatioPercentage;
        depositorCoinLockTime = _depositorCoinLockTime;
    }

    function _getDeficitOrSurplusInContractInUsd() private view returns (int256) {
        uint256 ethContractBalanceInUsd = address(this).balance * oracle.getPrice();
        uint256 totalStableCoinBalanceInUsd = totalSupply();
        return int256(ethContractBalanceInUsd) - int256(totalStableCoinBalanceInUsd);
    }

    // ... rest of your functions with the fixes applied
}
