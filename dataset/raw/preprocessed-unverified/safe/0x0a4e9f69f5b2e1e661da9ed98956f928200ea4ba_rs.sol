// Octo.fi Interest Program
// Â© 2020 Decentralized Tentacles
// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



contract YieldRoles {
	using Roles for Roles.Role;

	constructor() internal {
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
    uint256 public threeMonthPercentage;
    uint256 public sixMonthPercentage;
    uint256 public twelveMonthPercentage;

    // Main struct for lockup
    struct LockBoxStruct {
        address beneficiary;
        uint balance;
        uint releaseTime;
    }

    LockBoxStruct[] public lockBoxStructs; // This could be a mapping by address, but these numbered lockBoxes support possibility of multiple tranches per address

    event LogLockupDeposit(address sender, address beneficiary, uint amount, uint releaseTime);   
    event LogLockupWithdrawal(address receiver, uint amount);

    constructor(address tokenContract, uint256 _endDepositTime, address _yieldWallet, uint256 _maxTokens) public {
        token = IERC20(tokenContract);
        endDepositTime = _endDepositTime;
        
        yieldWallet = _yieldWallet;
        maxTokens = _maxTokens;
    }
    
    function getLockBoxBeneficiary(uint256 lockBoxNumber) public view returns(address) {
        return lockBoxStructs[lockBoxNumber].beneficiary;
    }

    // Deposit for 3, 6 or 12 months
    function deposit3m(address beneficiary, uint256 amount) external {
        deposit(beneficiary, amount, 90 days);
    }
    
    function deposit6m(address beneficiary, uint256 amount) external {
        deposit(beneficiary, amount, 180 days);
    }
    
    function deposit12m(address beneficiary, uint256 amount) external {
        deposit(beneficiary, amount, 360 days);
    }

    function deposit(address beneficiary, uint256 amount, uint256 duration) internal {
        require(now < endDepositTime, "Deposit time has ended.");
        require(amount < maxTokens, "Token deposit too high, limit breached.");
        maxTokens -= amount;

        // Define and get amount of yield
        uint256 yieldAmount;
        if (duration == 90 days) {
            yieldAmount = (threeMonthPercentage * amount) / 1e20;
        } else if (duration == 180 days) {
            yieldAmount = (sixMonthPercentage * amount) / 1e20;
        } else if (duration == 360 days) {
            yieldAmount = (twelveMonthPercentage * amount) / 1e20;
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
        l.releaseTime = now + duration;
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
        require(l.releaseTime <= now);
        uint amount = l.balance;
        l.balance = 0;
        emit LogLockupWithdrawal(l.beneficiary, amount);
        require(token.transfer(l.beneficiary, amount));
    }

    // Helper function to release everything    
    function triggerWithdrawAll() public {
        for (uint256 i = 0; i < lockBoxStructs.length; ++i) {
            if (lockBoxStructs[i].releaseTime <= now && lockBoxStructs[i].balance > 0) {
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
    
    function updateYields(uint256 threeMonths, uint256 sixMonths, uint256 twelveMonths) public onlyOwner {
        threeMonthPercentage = threeMonths;
        sixMonthPercentage = sixMonths;
        twelveMonthPercentage = twelveMonths;
    }
    
    function updateMaxTokens(uint256 newMaxTokens) public onlyOwner {
        maxTokens = newMaxTokens;
    }
}