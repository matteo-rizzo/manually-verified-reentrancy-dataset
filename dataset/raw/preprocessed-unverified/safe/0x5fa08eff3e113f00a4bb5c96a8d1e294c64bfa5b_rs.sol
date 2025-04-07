/*

    /     |  __    / ____|
   /      | |__) | | |
  / /    |  _  /  | |
 / ____   | |    | |____
/_/    _ |_|  _  _____|

* ARC: staking/AddressAccrual.sol
*
* Latest source (may be newer): https://github.com/arcxgame/contracts/blob/master/contracts/staking/AddressAccrual.sol
*
* Contract Dependencies: 
*	- Accrual
*	- Context
*	- Ownable
* Libraries: 
*	- Address
*	- SafeERC20
*	- SafeMath
*
* MIT License
* ===========
*
* Copyright (c) 2020 ARC
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

/* ===============================================
* Flattened with Solidifier by Coinage
* 
* https://solidifier.coina.ge
* ===============================================
*/


pragma solidity ^0.5.0;

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */



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



/**
 * @dev Collection of functions related to the address type
 */



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// SPDX-License-Identifier: MIT
// Modified from https://github.com/iearn-finance/audit/blob/master/contracts/yGov/YearnGovernanceBPT.sol


/**
 * @title Accrual is an abstract contract which allows users of some
 *        distribution to claim a portion of tokens based on their share.
 */
contract Accrual {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public accrualToken;

    uint256 public accruedIndex = 0; // previously accumulated index
    uint256 public accruedBalance = 0; // previous calculated balance

    mapping(address => uint256) public supplyIndex;

    constructor(
        address _accrualToken
    )
        public
    {
        accrualToken = IERC20(_accrualToken);
    }

    function getUserBalance(
        address owner
    )
        public
        view
        returns (uint256);

    function getTotalBalance()
        public
        view
        returns (uint256);

    function updateFees()
        public
    {
        if (getTotalBalance() == 0) {
            return;
        }

        uint256 contractBalance = accrualToken.balanceOf(address(this));

        if (contractBalance == 0) {
            return;
        }

        // Find the difference since the last balance stored in the contract
        uint256 difference = contractBalance.sub(accruedBalance);

        if (difference == 0) {
            return;
        }

        // Use the difference to calculate a ratio
        uint256 ratio = difference.mul(1e18).div(getTotalBalance());

        if (ratio == 0) {
            return;
        }

        // Update the index by adding the existing index to the ratio index
        accruedIndex = accruedIndex.add(ratio);

        // Update the accrued balance
        accruedBalance = contractBalance;
    }

    function claimFees()
        public
    {
        claimFor(msg.sender);
    }

    function claimFor(
        address recipient
    )
        public
    {
        updateFees();

        uint256 userBalance = getUserBalance(recipient);

        if (userBalance == 0) {
            supplyIndex[recipient] = accruedIndex;
            return;
        }

        // Store the existing user's index before updating it
        uint256 existingIndex = supplyIndex[recipient];

        // Update the user's index to the current one
        supplyIndex[recipient] = accruedIndex;

        // Calculate the difference between the current index and the old one
        // The difference here is what the user will be able to claim against
        uint256 delta = accruedIndex.sub(existingIndex);

        require(
            delta > 0,
            "TokenAccrual: no tokens available to claim"
        );

        // Get the user's current balance and multiply with their index delta
        uint256 share = userBalance.mul(delta).div(1e18);

        // Transfer the tokens to the user
        accrualToken.safeTransfer(recipient, share);

        // Update the accrued balance
        accruedBalance = accrualToken.balanceOf(address(this));
    }

}

// SPDX-License-Identifier: MIT


contract AddressAccrual is Ownable, Accrual {

    IERC20 public claimableToken;

    uint256 public _supply = 0;

    mapping(address => uint256) public balances;

    constructor(
        address _claimableToken
    )
        public
        Accrual(_claimableToken)
    {}

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _supply;
    }

    function balanceOf(
        address account
    )
        public
        view
        returns (uint256)
    {
        return balances[account];
    }

    function getTotalBalance()
        public
        view
        returns (uint256)
    {
        return totalSupply();
    }

    function getUserBalance(
        address owner
    )
        public
        view
        returns (uint256)
    {
        return balanceOf(owner);
    }

    function increaseShare(
        address to,
        uint256 value
    )
        public
        onlyOwner
    {
        require(to != address(0), "Cannot add zero address");

        balances[to] = balances[to].add(value);
        _supply = _supply.add(value);
    }

    function decreaseShare(
        address from,
        uint256 value
    )
        public
        onlyOwner
    {
        require(from != address(0), "Cannot remove zero address");

        balances[from] = balances[from].sub(value);
        _supply = _supply.sub(value);
    }

}