/**
 *Submitted for verification at Etherscan.io on 2021-04-06
*/

// File: contracts\interfaces\IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts\ownable\Ownable.sol

abstract 

// File: contracts\libraries\SafeMath.sol

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


// File: contracts\timelock\TimeLock.sol


/// @author Jorge Gomes Dur├ín ([email protected])
/// @title A vesting contract to lock tokens for ZigCoin

contract TimeLock is Ownable {
    using SafeMath for uint256;

    enum LockType {
        PrivateSale,
        Advisor,
        LiquidityProviders,
        Campaigns,
        Reserves,
        ExchangeListings,
        Traders,
        Founder
    }

    struct LockAmount {
        uint8 lockType;
        uint256 amount;
    }

    uint32 internal constant _1_MONTH_IN_SECONDS = 2592000;
    uint8  internal constant _6_MONTHS = 6;

    uint8 internal constant _MONTH_1_PRIVATE_SALE_FIRST_UNLOCK = 0;
    uint8 internal constant _MONTH_2_PRIVATE_SALE_FIRST_UNLOCK = 3;
    uint8 internal constant _MONTH_3_PRIVATE_SALE_FIRST_UNLOCK = 6;    

    uint8 internal constant _PERCENTS_1_VESTING_PRIVATE_SALES = 30;
    uint8 internal constant _PERCENTS_2_VESTING_PRIVATE_SALES = 60;
    uint8 internal constant _PERCENTS_3_VESTING_PRIVATE_SALES = 100;

    address immutable private token;
    uint256 private tokenListedAt;
    
    mapping(address => LockAmount) private balances;
    mapping(address => uint256) private withdrawn;

    event TokenListed(address indexed from, uint256 datetime);
    event TokensLocked(address indexed wallet, uint256 balance, uint8 lockType);
    event TokensUnlocked(address indexed wallet);
    event Withdrawal(address indexed wallet, uint256 balance);
    event EmergencyWithdrawal(address indexed wallet, uint256 balance);

    constructor(address _token) {
        token = _token;  
    }

    /** 
     * @notice locks an amount of tokens to a wallet. Call only before listing the token
     * @param _user     --> wallet that will receive the tokens once unlocked
     * @param _balance  --> balance to lock
     * @param _lockType --> lock type to know what unlock rules apply
     */
    function lockTokens(address _user, uint256 _balance, uint8 _lockType) external onlyOwner {
        require(tokenListedAt == 0, "TokenAlreadyListed");
        require(balances[_user].amount == 0, "WalletExistsYet");  
        require(_lockType >= 0 && _lockType <= 7, "BadLockType");      

        balances[_user] = LockAmount(_lockType, _balance);

        emit TokensLocked(_user, _balance, _lockType);
    }

    /** 
     * @notice remove a token lock. Use if there's any mistake locking tokens
     * @param _user --> wallet to remove tokens
     */
    function unlockTokens(address _user) external onlyOwner {
        require(tokenListedAt == 0, "TokenAlreadyListed");
        require(balances[_user].amount > 0, "WalletNotFound");

        delete balances[_user];

        emit TokensUnlocked(_user);
    }

    /** 
     * @notice send available tokens to the wallet once are unlocked
     * @param _user    --> wallet that will receive the tokens
     * @param _amount  --> amount to withdraw
     */
    function withdraw(address _user, uint256 _amount) external onlyOwner {
        require(tokenListedAt > 0, "TokenNotListedYet");
        require(balances[_user].amount > 0, "WalletNotFound");
        require(_amount > 0, "BadAmount");

        uint256 canWithdrawAmount = _canWithdraw(_user);
        uint256 amountWithdrawn = withdrawn[_user];

        require(canWithdrawAmount > amountWithdrawn, "CantWithdrawYet");
        require(canWithdrawAmount - amountWithdrawn >= _amount, "AmountExceedsAllowance");

        withdrawn[_user] += _amount;
        IERC20(token).transfer(_user, _amount);

        emit Withdrawal(_user, _amount);
    }

    /** 
     * @notice unlock all the tokens. Only use if there's any emergency
     */
    function emergencyWithdraw() external onlyOwner {
        IERC20 erc20 = IERC20(token);
        
        uint256 balance = erc20.balanceOf(address(this));
        erc20.transfer(owner(), balance);

        emit EmergencyWithdrawal(msg.sender, balance);
    }

    /**
     * @notice set the listing date to start the count for unlock tokens
     */
    function setTokenListed() external onlyOwner {
        require(tokenListedAt == 0, "TokenAlreadyListed");
        tokenListedAt = block.timestamp;
        
        emit TokenListed(msg.sender, tokenListedAt);
    }

    /** 
     * @notice get the token listing date
     * @return listing date
     */ 
    function getTokenListedAt() external view returns (uint256) {
        return tokenListedAt;
    }

    /** 
     * @notice get the total locked balance of a wallet in the contract
     * @param _user --> wallet
     * @return amount locked amount
     * @return lockType wallet type
     */ 
    function balanceOf(address _user) external view returns(uint256 amount, uint8 lockType) {
        amount = balances[_user].amount;
        lockType = balances[_user].lockType;
    }

    /** 
     * @notice get the total locked balance of a wallet in the contract
     * @param _user --> wallet
     * @return locked amount and wallet type
     */ 
    function balanceOfWithdrawan(address _user) external view returns(uint256) {
        return withdrawn[_user];
    }

    /** 
     * @notice get the total of tokens in the contract
     * @return tokens amount
     */ 
    function getContractFunds() external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    /** 
     * @notice get the amount of tokens that a wallet can withdraw right now
     * @param _user --> wallet
     * @return tokens amount
     */ 
    function canWithdraw(address _user) external view returns (uint256) {
        uint256 canWithdrawAmount = _canWithdraw(_user);
        uint256 amountWithdrawn = withdrawn[_user];

        return canWithdrawAmount - amountWithdrawn;
    }

    /** 
     * @notice get the number of months from token listing
     * @return months
     */ 
    function _getMonthFromTokenListed() internal view returns(uint256) {
        if (tokenListedAt == 0) return 0;
        if (tokenListedAt > block.timestamp) return 0;

        return (block.timestamp - tokenListedAt).div(_1_MONTH_IN_SECONDS);
    }

    /** 
     * @notice get the amount of tokens that a wallet can withdraw by lock up rules
     * @param _user --> wallet
     * @return amount
     */ 
    function _canWithdraw(address _user) internal view returns (uint256 amount) {
        uint8 lockType = balances[_user].lockType;
        
        // Only if token has beed listed
        if (tokenListedAt > 0) {
            uint256 month = _getMonthFromTokenListed();
            if (LockType(lockType) == LockType.Founder) {
                // Founders have a linear 30 months unlock starting 6 months after listing
                if (month >= _6_MONTHS) {
                    uint monthAfterUnlock = month - _6_MONTHS + 1;
                    amount = balances[_user].amount.mul(monthAfterUnlock).div(30);
                    if (amount > balances[_user].amount) amount = balances[_user].amount;
                }
            } else if ((LockType(lockType) == LockType.PrivateSale) || (LockType(lockType) == LockType.Advisor)) {
                // Private sales and advisors can unlock 30% at listing token date, 30% after 3 months and 40% after 6 months
                if ((month >= _MONTH_1_PRIVATE_SALE_FIRST_UNLOCK) && (month < _MONTH_2_PRIVATE_SALE_FIRST_UNLOCK)) {
                    amount = balances[_user].amount.mul(_PERCENTS_1_VESTING_PRIVATE_SALES).div(100);
                } else if ((month >= _MONTH_2_PRIVATE_SALE_FIRST_UNLOCK) && (month < _MONTH_3_PRIVATE_SALE_FIRST_UNLOCK)) {
                    amount = balances[_user].amount.mul(_PERCENTS_2_VESTING_PRIVATE_SALES).div(100);
                } else if (month >= _MONTH_3_PRIVATE_SALE_FIRST_UNLOCK) {
                    amount = balances[_user].amount;
                }
            } else {
                // Other tokens can be withdrawn any time
                amount = balances[_user].amount;
            }
        }
    }
}