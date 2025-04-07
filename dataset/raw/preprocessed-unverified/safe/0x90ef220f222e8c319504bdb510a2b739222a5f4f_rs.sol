/**
 *Submitted for verification at Etherscan.io on 2021-04-23
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

/*
For libraries Roles, SafeMath, Address, SafeERC20 and interface IERC20:
The MIT License (MIT)

Copyright (c) 2016-2020 zOS Global Limited

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/



abstract contract YieldRoles {
	using Roles for Roles.Role;

	constructor() {
		_addOwner(msg.sender);
	}

	/*
	 * Owner functions
	 */
	event OwnerAdded(address indexed account);
	event OwnerRemoved(address indexed account);

	Roles.Role private _owners;

	modifier onlyOwner() {
		require(isOwner(msg.sender), "Sender is not owner");
		_;
	}

	function isOwner(address account) public view returns (bool) {
		return _owners.has(account);
	}

	function addOwner(address account) public onlyOwner {
		_addOwner(account);
	}

	function renounceOwner() public {
		_removeOwner(msg.sender);
	}

	function _addOwner(address account) internal {
		_owners.add(account);
		emit OwnerAdded(account);
	}

	function _removeOwner(address account) internal {
		_owners.remove(account);
		emit OwnerRemoved(account);
	}
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time.
 *
 * Useful for simple vesting schedules like "advisors get all of their tokens
 * after 1 year".
 */

contract YieldContract is YieldRoles {
    using SafeERC20 for IERC20;
    IERC20 token;
    
    // Timeframe in which it it possible to deposit tokens
    uint256 public endDepositTime;
    
    // Max tokens to be deposited
    uint256 internal maxTokens;
    
    // Originating wallet for yield payments
    address internal yieldWallet;
    
    // Yield rates in 1e18 granularity
    uint256 public nineMonthPercentage;
    uint256 public twelveMonthPercentage;
    uint256 public twentyfourMonthPercentage;

    // Main struct for lockup
    struct LockBoxStruct {
        address beneficiary;
        uint balance;
        uint releaseTime;
    }

    LockBoxStruct[] public lockBoxStructs; // This could be a mapping by address, but these numbered lockBoxes support possibility of multiple tranches per address

    event LogLockupDeposit(address sender, address beneficiary, uint amount, uint releaseTime);   
    event LogLockupWithdrawal(address receiver, uint amount);

    constructor(address tokenContract, uint256 _endDepositTime, address _yieldWallet, uint256 _maxTokens) {
        token = IERC20(tokenContract);
        endDepositTime = _endDepositTime;
        
        yieldWallet = _yieldWallet;
        maxTokens = _maxTokens;
    }
    
    function getLockBoxBeneficiary(uint256 lockBoxNumber) public view returns(address) {
        return lockBoxStructs[lockBoxNumber].beneficiary;
    }
    
    function getLockBoxesForAddress(address query) public view returns(uint256[] memory) {
        // Get length of return array
        uint256 arrayLength = 0;
        for (uint256 i = 0; i < lockBoxStructs.length; ++i) {
            if (lockBoxStructs[i].beneficiary == query) {
                arrayLength++;
            }
        }
        uint256[] memory output = new uint256[](arrayLength);
        uint256 j = 0;
        for (uint256 i = 0; i < lockBoxStructs.length; ++i) {
            if (lockBoxStructs[i].beneficiary == query) {
                output[j] = i;
                j++;
            }
        }
        return output;
    }

    // Deposit for 9, 12 or 24 months
    function deposit9m(address beneficiary, uint256 amount) external {
        deposit(beneficiary, amount, 270 days);
    }
    
    function deposit12m(address beneficiary, uint256 amount) external {
        deposit(beneficiary, amount, 360 days);
    }
    
    function deposit24m(address beneficiary, uint256 amount) external {
        deposit(beneficiary, amount, 720 days);
    }

    function deposit(address beneficiary, uint256 amount, uint256 duration) internal {
        require(block.timestamp < endDepositTime, "Deposit time has ended.");
        require(amount < maxTokens, "Token deposit too high, limit breached.");
        maxTokens -= amount;

        // Define and get amount of yield
        uint256 yieldAmount;
        if (duration == 270 days) {
            yieldAmount = (nineMonthPercentage * amount) / 1e20;
        } else if (duration == 360 days) {
            yieldAmount = (twelveMonthPercentage * amount) / 1e20;
        } else if (duration == 720 days) {
            yieldAmount = (twentyfourMonthPercentage * amount) / 1e20;
        } else {
            revert("Error: duration not allowed!");
        }
        require(token.transferFrom(yieldWallet, address(this), yieldAmount));
        
        // Get lockable tokens from user
        require(token.transferFrom(msg.sender, address(this), amount));
        
        // Build lockbox
        LockBoxStruct memory l;
        l.beneficiary = beneficiary;
        l.balance = amount + yieldAmount;
        l.releaseTime = block.timestamp + duration;
        lockBoxStructs.push(l);
        emit LogLockupDeposit(msg.sender, l.beneficiary, l.balance, l.releaseTime);
    }
    
    // Beneficiaries can update the receiver wallet
    function updateBeneficiary(uint256 lockBoxNumber, address newBeneficiary) public {
        LockBoxStruct storage l = lockBoxStructs[lockBoxNumber];
        require(msg.sender == l.beneficiary);
        l.beneficiary = newBeneficiary;
    }

    function withdraw(uint lockBoxNumber) public {
        LockBoxStruct storage l = lockBoxStructs[lockBoxNumber];
        require(l.releaseTime <= block.timestamp);
        uint amount = l.balance;
        l.balance = 0;
        emit LogLockupWithdrawal(l.beneficiary, amount);
        require(token.transfer(l.beneficiary, amount));
    }

    // Helper function to release everything    
    function triggerWithdrawAll() public {
        for (uint256 i = 0; i < lockBoxStructs.length; ++i) {
            if (lockBoxStructs[i].releaseTime <= block.timestamp && lockBoxStructs[i].balance > 0) {
                withdraw(i);
            }
        }
    }
    
    // Admin update functions
    function updateEndDepositTime (uint256 newEndTime) public onlyOwner {
        endDepositTime = newEndTime;
    }
    
    function updateYieldWallet(address newWallet) public onlyOwner {
        yieldWallet = newWallet;
    }
    
    function updateYields(uint256 nineMonths, uint256 twelveMonths, uint256 twentyfourMonths) public onlyOwner {
        nineMonthPercentage = nineMonths;
        twelveMonthPercentage = twelveMonths;
        twentyfourMonthPercentage = twentyfourMonths;
    }
    
    function updateMaxTokens(uint256 newMaxTokens) public onlyOwner {
        maxTokens = newMaxTokens;
    }
}