/**
 *Submitted for verification at Etherscan.io on 2020-10-04
*/

pragma solidity ^0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Docs: https://docs.synthetix.io/
*
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
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



contract CritSupplySchedule is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint;
    using SafeDecimal for uint;
    uint256[157] public weeklySupplies = [
    // week 0
    0,
    // 1st year, week 1 ~ 52
    358025, 250600, 175420, 122794, 112970, 103932, 95618, 87968, 80931, 74456, 68500, 63020, 57978,
    53340, 49073, 45147, 41535, 38212, 35155, 32343, 29755, 27375, 25185, 23170, 21316, 19611,
    18042, 16599, 15271, 14049, 12925, 11891, 10940, 10064, 9259, 8518, 7837, 7210, 6633,
    6102, 5614, 5165, 4752, 4372, 4022, 3700, 3404, 3132, 2881, 2651, 2438, 2244,
    // 2nd year, week 53 ~ 104
    2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244,
    2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244,
    2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244,
    2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244, 2244,
    // 3rd year, week 105 ~ 156
    1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734,
    1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734,
    1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734,
    1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734, 1734
    ];
    uint public constant MINT_PERIOD_DURATION = 1 weeks;
    uint public constant SUPPLY_START_DATE = 1601258400; // 2020-09-28T02:00:00+00:00

    uint public constant MAX_OPERATION_SHARES = 20e16;

    address public rewardsToken;
    uint public lastMintEvent;
    uint public weekCounter;
    uint public operationShares = 2e16; // 2%

    event OperationSharesUpdated(uint newShares);
    event SupplyMinted(uint supplyMinted, uint numberOfWeeksIssued, uint lastMintEvent, uint timestamp);

    modifier onlyRewardsToken() {
        require(msg.sender == address(rewardsToken), "onlyRewardsToken");
        _;
    }

    constructor(address _rewardsToken, uint _lastMintEvent, uint _currentWeek) public {
        rewardsToken = _rewardsToken;
        lastMintEvent = _lastMintEvent;
        weekCounter = _currentWeek;
    }

    function mintableSupply() external view returns (uint) {
        uint totalAmount;
        if (!isMintable()) {
            return 0;
        }

        uint currentWeek = weekCounter;
        uint remainingWeeksToMint = weeksSinceLastIssuance();
        while (remainingWeeksToMint > 0) {
            currentWeek++;
            remainingWeeksToMint--;
            if (currentWeek >= weeklySupplies.length) {
                break;
            }
            totalAmount = totalAmount.add(weeklySupplies[currentWeek]);
        }
        return totalAmount.mul(1e18);
    }

    function weeksSinceLastIssuance() public view returns (uint) {
        uint timeDiff = lastMintEvent > 0 ? now.sub(lastMintEvent) : now.sub(SUPPLY_START_DATE);
        return timeDiff.div(MINT_PERIOD_DURATION);
    }

    function isMintable() public view returns (bool) {
        if (now - lastMintEvent > MINT_PERIOD_DURATION && weekCounter < weeklySupplies.length) {
            return true;
        }
        return false;
    }

    function recordMintEvent(uint _supplyMinted) external onlyRewardsToken returns (bool) {
        uint numberOfWeeksIssued = weeksSinceLastIssuance();
        weekCounter = weekCounter.add(numberOfWeeksIssued);
        lastMintEvent = SUPPLY_START_DATE.add(weekCounter.mul(MINT_PERIOD_DURATION));

        emit SupplyMinted(_supplyMinted, numberOfWeeksIssued, lastMintEvent, now);
        return true;
    }

    function setOperationShares(uint _shares) external onlyOwner {
        require(_shares <= MAX_OPERATION_SHARES, "shares");
        operationShares = _shares;
        emit OperationSharesUpdated(_shares);
    }

    function rewardOfOperation(uint _supplyMinted) public view returns (uint) {
        return _supplyMinted.mul(operationShares).div(SafeDecimal.unit());
    }

    function currentWeekSupply() external view returns(uint) {
        if (weekCounter < weeklySupplies.length) {
            return weeklySupplies[weekCounter];
        }
        return 0;
    }
}