/**
 *Submitted for verification at Etherscan.io on 2021-07-07
*/

/*
    ___            _       ___  _                          
    | .\ ___  _ _ <_> ___ | __><_>._ _  ___ ._ _  ___  ___ 
    |  _// ._>| '_>| ||___|| _> | || ' |<_> || ' |/ | '/ ._>
    |_|  \___.|_|  |_|     |_|  |_||_|_|<___||_|_|\_|_.\___.
    
* PeriFinance: StakingStateUSDC.sol
*
* Latest source (may be newer): https://github.com/perifinance/peri-finance/blob/master/contracts/StakingStateUSDC.sol
* Docs: Will be added in the future. 
* https://docs.peri.finance/contracts/source/contracts/StakingStateUSDC
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



contract StakingStateUSDC is Owned, State {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    address public USDC_ADDRESS;

    mapping(address => uint) public stakedAmountOf;

    uint public totalStakerCount;

    uint public totalStakedAmount;

    mapping(address => bool) public registered;

    address[] public stakers; // for migration later

    constructor(
        address _owner,
        address _associatedContract,
        address _usdcAddress
    ) public Owned(_owner) State(_associatedContract) {
        USDC_ADDRESS = _usdcAddress;
    }

    /* ========== VIEWER FUNCTIONS ========== */

    function userStakingShare(address _account) public view returns (uint) {
        uint _percentage =
            stakedAmountOf[_account] == 0 || totalStakedAmount == 0
                ? 0
                : (stakedAmountOf[_account]).divideDecimalRound(totalStakedAmount);

        return _percentage;
    }

    function decimals() external pure returns (uint8) {
        return 6;
    }

    function hasStaked(address _account) external view returns (bool) {
        return stakedAmountOf[_account] > 0;
    }

    function usdc() internal view returns (IERC20) {
        require(USDC_ADDRESS != address(0), "USDC address is empty");

        return IERC20(USDC_ADDRESS);
    }

    function usdcAddress() internal view returns (address) {
        return USDC_ADDRESS;
    }

    function stakersLength() external view returns (uint) {
        return stakers.length;
    }

    function getStakersByRange(uint _index, uint _cnt) external view returns (address[] memory) {
        require(_index >= 0, "index should not be less than zero");
        require(stakers.length >= _index + _cnt, "requesting size is too big to query");

        address[] memory _addresses = new address[](_cnt);
        for (uint i = 0; i < _cnt; i++) {
            _addresses[i] = stakers[i + _index];
        }

        return _addresses;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stake(address _account, uint _amount) external onlyAssociatedContract {
        if (stakedAmountOf[_account] == 0 && _amount > 0) {
            _incrementTotalStaker();

            if (!registered[_account]) {
                registered[_account] = true;
                stakers.push(_account);
            }
        }

        stakedAmountOf[_account] = stakedAmountOf[_account].add(_amount);
        totalStakedAmount = totalStakedAmount.add(_amount);

        emit Staking(_account, _amount, userStakingShare(_account));
    }

    function unstake(address _account, uint _amount) external onlyAssociatedContract {
        require(stakedAmountOf[_account] >= _amount, "User doesn't have enough staked amount");
        require(totalStakedAmount >= _amount, "Not enough staked amount to withdraw");

        if (stakedAmountOf[_account].sub(_amount) == 0) {
            _decrementTotalStaker();
        }

        stakedAmountOf[_account] = stakedAmountOf[_account].sub(_amount);
        totalStakedAmount = totalStakedAmount.sub(_amount);

        emit Unstaking(_account, _amount, userStakingShare(_account));
    }

    function refund(address _account, uint _amount) external onlyAssociatedContract returns (bool) {
        return usdc().transfer(_account, _amount.div(10**12));
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function _incrementTotalStaker() internal {
        totalStakerCount = totalStakerCount.add(1);
    }

    function _decrementTotalStaker() internal {
        totalStakerCount = totalStakerCount.sub(1);
    }

    /* ========== EVENTS ========== */

    event Staking(address indexed account, uint amount, uint percentage);
    event Unstaking(address indexed account, uint amount, uint percentage);
}