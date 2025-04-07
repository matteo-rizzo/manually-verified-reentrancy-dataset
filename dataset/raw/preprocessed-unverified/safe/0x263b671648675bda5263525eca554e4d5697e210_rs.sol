/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

/*
    ___            _       ___  _                          
    | .\ ___  _ _ <_> ___ | __><_>._ _  ___ ._ _  ___  ___ 
    |  _// ._>| '_>| ||___|| _> | || ' |<_> || ' |/ | '/ ._>
    |_|  \___.|_|  |_|     |_|  |_||_|_|<___||_|_|\_|_.\___.
    
* PeriFinance: StakingState.sol
*
* Latest source (may be newer): https://github.com/perifinance/peri-finance/blob/master/contracts/StakingState.sol
* Docs: Will be added in the future. 
* https://docs.peri.finance/contracts/source/contracts/StakingState
*
* Contract Dependencies: 
*	- Owned
*	- State
* Libraries: 
*	- SafeDecimalMath
*	- SafeMath
*
* MIT License
* ===========
*
* Copyright (c) 2021 PeriFinance
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/



pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */



// Libraries


// https://docs.peri.finance/contracts/source/libraries/safedecimalmath



// https://docs.peri.finance/contracts/source/contracts/owned



// Inheritance


// https://docs.peri.finance/contracts/source/contracts/state
contract State is Owned {
    // the address of the contract that can modify variables
    // this can only be changed by the owner of this contract
    address public associatedContract;

    constructor(address _associatedContract) internal {
        // This contract is abstract, and thus cannot be instantiated directly
        require(owner != address(0), "Owner must be set");

        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }

    /* ========== SETTERS ========== */

    // Change the associated contract to a new address
    function setAssociatedContract(address _associatedContract) external onlyOwner {
        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }

    /* ========== MODIFIERS ========== */

    modifier onlyAssociatedContract {
        require(msg.sender == associatedContract, "Only the associated contract can perform this action");
        _;
    }

    /* ========== EVENTS ========== */

    event AssociatedContractUpdated(address associatedContract);
}


// https://docs.peri.finance/contracts/source/interfaces/ierc20



contract StakingState is Owned, State {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    struct TargetToken {
        address tokenAddress;
        uint8 decimals;
        bool activated;
    }

    mapping(bytes32 => TargetToken) public targetTokens;

    mapping(bytes32 => mapping(address => uint)) public stakedAmountOf;

    mapping(bytes32 => uint) public totalStakedAmount;

    mapping(bytes32 => uint) public totalStakerCount;

    bytes32[] public tokenList;

    constructor(address _owner, address _associatedContract) public Owned(_owner) State(_associatedContract) {}

    /* ========== VIEWER FUNCTIONS ========== */

    function tokenInstance(bytes32 _currencyKey) internal view returns (IERC20) {
        require(targetTokens[_currencyKey].tokenAddress != address(0), "Target address is empty");

        return IERC20(targetTokens[_currencyKey].tokenAddress);
    }

    function tokenAddress(bytes32 _currencyKey) external view returns (address) {
        return targetTokens[_currencyKey].tokenAddress;
    }

    function tokenDecimals(bytes32 _currencyKey) external view returns (uint8) {
        return targetTokens[_currencyKey].decimals;
    }

    function tokenActivated(bytes32 _currencyKey) external view returns (bool) {
        return targetTokens[_currencyKey].activated;
    }

    function getTokenCurrencyKeys() external view returns (bytes32[] memory) {
        return tokenList;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function setTargetToken(
        bytes32 _currencyKey,
        address _tokenAddress,
        uint8 _decimals
    ) external onlyOwner {
        require(_tokenAddress != address(0), "Address cannot be empty");
        require(targetTokens[_currencyKey].tokenAddress == address(0), "Token is already registered");

        if (targetTokens[_currencyKey].tokenAddress == address(0)) {
            tokenList.push(_currencyKey);
        }

        targetTokens[_currencyKey] = TargetToken(_tokenAddress, _decimals, true);
    }

    function setTokenActivation(bytes32 _currencyKey, bool _activate) external onlyOwner {
        _requireTokenRegistered(_currencyKey);

        targetTokens[_currencyKey].activated = _activate;
    }

    function stake(
        bytes32 _currencyKey,
        address _account,
        uint _amount
    ) external onlyAssociatedContract {
        _requireTokenRegistered(_currencyKey);
        require(targetTokens[_currencyKey].activated, "Target token is not activated");

        if (stakedAmountOf[_currencyKey][_account] <= 0 && _amount > 0) {
            _incrementTotalStaker(_currencyKey);
        }

        stakedAmountOf[_currencyKey][_account] = stakedAmountOf[_currencyKey][_account].add(_amount);
        totalStakedAmount[_currencyKey] = totalStakedAmount[_currencyKey].add(_amount);

        emit Staking(_currencyKey, _account, _amount);
    }

    function unstake(
        bytes32 _currencyKey,
        address _account,
        uint _amount
    ) external onlyAssociatedContract {
        require(stakedAmountOf[_currencyKey][_account] >= _amount, "Account doesn't have enough staked amount");
        require(totalStakedAmount[_currencyKey] >= _amount, "Not enough staked amount to withdraw");

        if (stakedAmountOf[_currencyKey][_account].sub(_amount) == 0) {
            _decrementTotalStaker(_currencyKey);
        }

        stakedAmountOf[_currencyKey][_account] = stakedAmountOf[_currencyKey][_account].sub(_amount);
        totalStakedAmount[_currencyKey] = totalStakedAmount[_currencyKey].sub(_amount);

        emit Unstaking(_currencyKey, _account, _amount);
    }

    function refund(
        bytes32 _currencyKey,
        address _account,
        uint _amount
    ) external onlyAssociatedContract returns (bool) {
        uint decimalDiff = targetTokens[_currencyKey].decimals < 18 ? 18 - targetTokens[_currencyKey].decimals : 0;

        return tokenInstance(_currencyKey).transfer(_account, _amount.div(10**decimalDiff));
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function _requireTokenRegistered(bytes32 _currencyKey) internal view {
        require(targetTokens[_currencyKey].tokenAddress != address(0), "Target token is not registered");
    }

    function _incrementTotalStaker(bytes32 _currencyKey) internal {
        totalStakerCount[_currencyKey] = totalStakerCount[_currencyKey].add(1);
    }

    function _decrementTotalStaker(bytes32 _currencyKey) internal {
        totalStakerCount[_currencyKey] = totalStakerCount[_currencyKey].sub(1);
    }

    /* ========== EVENTS ========== */

    event Staking(bytes32 currencyKey, address account, uint amount);
    event Unstaking(bytes32 currencyKey, address account, uint amount);
}