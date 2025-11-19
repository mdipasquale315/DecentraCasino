// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.20;

type FixedPoint is uint256;

using {add as +} for FixedPoint global;
using {sub as -} for FixedPoint global;
using {mul as *} for FixedPoint global;
using {div as /} for FixedPoint global;
using {eq as ==} for FixedPoint global;
using {neq as !=} for FixedPoint global;
using {gt as >} for FixedPoint global;
using {lt as <} for FixedPoint global;
using {gte as >=} for FixedPoint global;
using {lte as <=} for FixedPoint global;

uint256 constant DECIMALS = 1e18;
uint256 constant MAX_UINT256 = type(uint256).max;

error DivisionByZero();
error Overflow();
error Underflow();

// Basic arithmetic operations
function add(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {
    return FixedPoint.wrap(FixedPoint.unwrap(a) + FixedPoint.unwrap(b));
}

function sub(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {
    uint256 aVal = FixedPoint.unwrap(a);
    uint256 bVal = FixedPoint.unwrap(b);
    if (bVal > aVal) revert Underflow();
    return FixedPoint.wrap(aVal - bVal);
}

function mul(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {
    uint256 aVal = FixedPoint.unwrap(a);
    uint256 bVal = FixedPoint.unwrap(b);
    
    // Check for overflow: if a * b > MAX_UINT256, then a > MAX_UINT256 / b
    if (aVal != 0 && bVal > MAX_UINT256 / aVal) revert Overflow();
    
    uint256 result = aVal * bVal / DECIMALS;
    return FixedPoint.wrap(result);
}

function div(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {
    uint256 aVal = FixedPoint.unwrap(a);
    uint256 bVal = FixedPoint.unwrap(b);
    
    if (bVal == 0) revert DivisionByZero();
    
    // Check for overflow: if a * DECIMALS > MAX_UINT256
    if (aVal > MAX_UINT256 / DECIMALS) revert Overflow();
    
    uint256 result = aVal * DECIMALS / bVal;
    return FixedPoint.wrap(result);
}

// Comparison operators
function eq(FixedPoint a, FixedPoint b) pure returns (bool) {
    return FixedPoint.unwrap(a) == FixedPoint.unwrap(b);
}

function neq(FixedPoint a, FixedPoint b) pure returns (bool) {
    return FixedPoint.unwrap(a) != FixedPoint.unwrap(b);
}

function gt(FixedPoint a, FixedPoint b) pure returns (bool) {
    return FixedPoint.unwrap(a) > FixedPoint.unwrap(b);
}

function lt(FixedPoint a, FixedPoint b) pure returns (bool) {
    return FixedPoint.unwrap(a) < FixedPoint.unwrap(b);
}

function gte(FixedPoint a, FixedPoint b) pure returns (bool) {
    return FixedPoint.unwrap(a) >= FixedPoint.unwrap(b);
}

function lte(FixedPoint a, FixedPoint b) pure returns (bool) {
    return FixedPoint.unwrap(a) <= FixedPoint.unwrap(b);
}

// Conversion functions
function fromFraction(uint256 numerator, uint256 denominator) pure returns (FixedPoint) {
    if (denominator == 0) revert DivisionByZero();
    
    // Check for overflow
    if (numerator > MAX_UINT256 / DECIMALS) revert Overflow();
    
    uint256 result = numerator * DECIMALS / denominator;
    return FixedPoint.wrap(result);
}

function fromUint(uint256 value) pure returns (FixedPoint) {
    if (value > MAX_UINT256 / DECIMALS) revert Overflow();
    return FixedPoint.wrap(value * DECIMALS);
}

function toUint(FixedPoint fp) pure returns (uint256) {
    return FixedPoint.unwrap(fp) / DECIMALS;
}

// Mixed operations with regular uint256
function mulFixedPoint(uint256 a, FixedPoint b) pure returns (uint256) {
    uint256 bVal = FixedPoint.unwrap(b);
    
    // Check for overflow
    if (a != 0 && bVal > MAX_UINT256 / a) revert Overflow();
    
    return a * bVal / DECIMALS;
}

function divFixedPoint(uint256 a, FixedPoint b) pure returns (uint256) {
    uint256 bVal = FixedPoint.unwrap(b);
    
    if (bVal == 0) revert DivisionByZero();
    
    // Check for overflow
    if (a > MAX_UINT256 / DECIMALS) revert Overflow();
    
    return a * DECIMALS / bVal;
}

// Utility functions
function min(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {
    return FixedPoint.unwrap(a) < FixedPoint.unwrap(b) ? a : b;
}

function max(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {
    return FixedPoint.unwrap(a) > FixedPoint.unwrap(b) ? a : b;
}

function abs(FixedPoint a, FixedPoint b) pure returns (FixedPoint) {
    uint256 aVal = FixedPoint.unwrap(a);
    uint256 bVal = FixedPoint.unwrap(b);
    return aVal >= bVal 
        ? FixedPoint.wrap(aVal - bVal) 
        : FixedPoint.wrap(bVal - aVal);
}

// Rounding functions
function floor(FixedPoint fp) pure returns (uint256) {
    return FixedPoint.unwrap(fp) / DECIMALS;
}

function ceil(FixedPoint fp) pure returns (uint256) {
    uint256 value = FixedPoint.unwrap(fp);
    uint256 remainder = value % DECIMALS;
    return remainder == 0 
        ? value / DECIMALS 
        : (value / DECIMALS) + 1;
}

function round(FixedPoint fp) pure returns (uint256) {
    uint256 value = FixedPoint.unwrap(fp);
    uint256 remainder = value % DECIMALS;
    return remainder >= DECIMALS / 2 
        ? (value / DECIMALS) + 1 
        : value / DECIMALS;
}

// Create common constants
function zero() pure returns (FixedPoint) {
    return FixedPoint.wrap(0);
}

function one() pure returns (FixedPoint) {
    return FixedPoint.wrap(DECIMALS);
}

function half() pure returns (FixedPoint) {
    return FixedPoint.wrap(DECIMALS / 2);
}