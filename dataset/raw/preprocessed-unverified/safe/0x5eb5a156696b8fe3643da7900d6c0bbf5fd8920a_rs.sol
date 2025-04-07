/**
 *Submitted for verification at Etherscan.io on 2020-11-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;


/**
 * @dev Collection of functions related to the address type
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


/// @title DIVStaking version 1.21 for DIV token - pays immediate staking rewards from contract funds.  
/// @author Nijitoki Labs; in collaboration with CommunityToken.io; original by KrippTorofu @ RiotOfTheBlock 
///
/// It does not redistribute user funds.  Contract must be owner funded.
///   Until the Ownership is rescinded, owner can modify the parameters of the contract (interest, staking periods, pause new staking).
contract DIV2Staking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    
    struct StakingLot {
        uint256 amount;
        uint256 unlockTime;
    }
    
    mapping (address => StakingLot[]) private _stakingBalances;
    uint256 internal totalInterestPaid = 0;
    uint256 internal totalCurrentlyStaked = 0;        // also total owed by contract
    address public immutable tokenContract;
    
    // administrative settings
    uint32 public dailyInterestRateInThousandths = 15;  // default is 15/1000 = 1.5%
    uint32 public minimumStakingPeriod = 1;
    uint32 public maximumStakingPeriod = 60;
    uint32 public maxAllowedStakingLots = 3;
    bool public isStakingPaused = false;
    
    event StakingEntered(address indexed addr, uint256 stakingAmount, uint256 interestAmount);
    event StakingWithdrawn(address indexed addr, uint256 totalWithdrawn);
    
    constructor(address tokenAddress) {
        tokenContract = tokenAddress;
    }
    
    // user data accessors
    function getStakingLotsOf(address account) external view returns (uint256) {
        return _stakingBalances[account].length;
    }
    
    function getStakingLotDetailOf(address account, uint32 index) external view returns (uint256 unlockTime, uint256 amount) {
        return (_stakingBalances[account][index].unlockTime, _stakingBalances[account][index].amount);
    }
    
    function getTotalStakingRewardsAvailable() public view returns (uint256) {
        // any amount in the contract balance, minus what is currently owed to stakers.
        return ERC20(tokenContract).balanceOf(address(this)).sub(totalCurrentlyStaked);
    }
    
    function getTotalCurrentlyStaked() external view returns (uint256) {
        return totalCurrentlyStaked;
    }
    
    function getTotalInterestPaid() external view returns (uint256) {
        return totalInterestPaid;
    }
    
    function getStakingParameters(address account) external view returns (
        uint32 minDays, 
        uint32 maxDays, 
        uint256 maximumAmountAllowedToStake,
        uint256 stakingAllowances, 
        uint256 dailyInterestRateThousandths,
        uint256 currentlyAvailableToWithdraw) {
            
        // @dev implement in UI - constraint 2: Fastest rate available of 1 day, deposit should not generate more rewards.
        // We cannot predict if user wants more days, if they enter more than 1 days, this case Stake function will prevent the user with a revert.
        // This is better handled in the UI by comparing the interest calculated then making sure it's less than available rewards.
        
        // @dev not implemented - constraint 3: burn is not accounted for.
        
        uint256 totalWithdrawable = 0;
        StakingLot[] storage accountLots = _stakingBalances[account];
        for(uint256 i=0; i<accountLots.length; i++)
            if(accountLots[i].unlockTime < block.timestamp)
                totalWithdrawable = totalWithdrawable.add(accountLots[i].amount);
                
        return (
            minimumStakingPeriod, 
            maximumStakingPeriod, 
            ERC20(tokenContract).balanceOf(account),
            (maxAllowedStakingLots - _stakingBalances[account].length),
            dailyInterestRateInThousandths,
            totalWithdrawable
        );
    }

    /// @notice For practical purposes, contract will not check whitelist status while calculating burn.
    /// @param stakingAmount Total Amount contract will attempt to retrieve from user (pre-burn)
    /// @param daysToStake Number of days to stake & lock.
    function stake(uint256 stakingAmount, uint256 daysToStake) external nonReentrant returns (uint256 interestPaid) {
        require(!isStakingPaused, "Staking: Currently Paused.");
        require(daysToStake >= minimumStakingPeriod && daysToStake <= maximumStakingPeriod, "Staking: Invalid Period.");
        require(_stakingBalances[msg.sender].length < maxAllowedStakingLots, "Staking: User Maximum Reached.");
        
        // Token with burn requires explicitly checking what we received.
        uint256 contractStartingBalance = ERC20(tokenContract).balanceOf(address(this));
        require(ERC20(tokenContract).transferFrom(msg.sender, address(this), stakingAmount), "Staking: Withdrawal failed.");  
        stakingAmount = ERC20(tokenContract).balanceOf(address(this)).sub(contractStartingBalance, "Staking: No Deposit Received.");
        
        uint256 interestAmount = stakingAmount.mul(dailyInterestRateInThousandths).mul(daysToStake).div(1000);

        require(interestAmount > 0, "Staking: No Rewards For This Amount.");
        require(getTotalStakingRewardsAvailable() >= interestAmount, "Staking: Not Enough Rewards Available.");

        // Everything checks out
        _stakingBalances[msg.sender].push(StakingLot({
            amount: stakingAmount,
            unlockTime: block.timestamp + (daysToStake * 1 days)
        }));
        
        totalCurrentlyStaked = totalCurrentlyStaked.add(stakingAmount);
        totalInterestPaid = totalInterestPaid.add(interestAmount);
        
        //TODO: success check most likely unnecessary and can be removed after testing

        require(ERC20(tokenContract).transfer(msg.sender, interestAmount), "Staking: Interest Payout failed.");
        
        emit StakingEntered(msg.sender, stakingAmount, interestAmount);
        return interestAmount;
    }
    
    function withdrawStakedTokens() external nonReentrant returns (uint totalWithdrawn) {
        uint256 totalWithdrawable = 0;
        
        StakingLot[] storage accountLots = _stakingBalances[msg.sender];

        for(uint256 i=0; i<accountLots.length; i++) {
            if(accountLots[i].unlockTime < block.timestamp) {
                totalWithdrawable = totalWithdrawable.add(accountLots[i].amount);
                
                // if not the last element, move last element into the current slot and pop the array.  otherwise just pop the array.
                if(i+1 == accountLots.length)
                    accountLots.pop();  // pop and reclaim
                else {
                    accountLots[i] = accountLots[accountLots.length-1];
                    accountLots.pop();
                    i--;
                }
            }
        }
        
        if(accountLots.length == 0)
            delete _stakingBalances[msg.sender];
        
        if(totalWithdrawable > 0) {
            totalCurrentlyStaked = totalCurrentlyStaked.sub(totalWithdrawable);
            require(ERC20(tokenContract).transfer(msg.sender, totalWithdrawable), "Withdraw: Unable to transfer.");
        
            emit StakingWithdrawn(msg.sender, totalWithdrawable);
        }
        
        return totalWithdrawable;
    }
    
    /* 
     *   Admin functions
     */
    function setDailyInterestRate(uint32 newRateInThousandths) external onlyOwner returns (bool success) {
        dailyInterestRateInThousandths = newRateInThousandths;
        return true;
    }
    
    function setMaximumStakingPeriod(uint32 numberOfDays) external onlyOwner returns (bool success) {
        maximumStakingPeriod = numberOfDays;
        return true;
    }
    
    function setMinimumStakingPeriod(uint32 numberOfDays) external onlyOwner returns (bool success) {
        minimumStakingPeriod = numberOfDays;
        return true;
    }
    
    function withdrawFromRewardPool(uint256 amount) external nonReentrant onlyOwner returns (bool success) {
        // requested amount must not return from staked balances == amount currently owed to stakers.
        require(amount <= getTotalStakingRewardsAvailable(), "Withdraw: Cannot withdraw that much.");

        ERC20(tokenContract).transfer(msg.sender, amount);
        return true;
    }
    
    function withdrawAllFromRewardPool() external nonReentrant onlyOwner returns (bool success) {
        // must not return amount currently staked == amount currently owed to stakers.
        ERC20(tokenContract).transfer(msg.sender, getTotalStakingRewardsAvailable());
        return true;
    }
    
    function setMaxAllowedDeposits(uint32 numberOfAllowedDeposits) external onlyOwner returns (bool success) {
        // having too large # of allowed deposits will cause gas issues at several calculations and could brick an account
        require(numberOfAllowedDeposits < 11, "Admin: Allowed range is 0-11");
        maxAllowedStakingLots = numberOfAllowedDeposits;
        return true;
    }
    
    function pauseStaking(bool isPaused) external onlyOwner returns (bool success) {
        isStakingPaused = isPaused;
        return true;
    }
    
    /// @notice Used for manual testing - uses owner's deposited funds to generate a small staked lot with short expiry time
    /// No interest is generated and contract state is updated to reduce the amount of available rewards.
    function generateTestLot(address testAccountAddress, uint256 minutesToExpiry) external onlyOwner {
        uint256 testAmount = 1000 * minutesToExpiry;
        require(getTotalStakingRewardsAvailable() >= testAmount, "genTestLot: Not Enough Funds.");

        _stakingBalances[testAccountAddress].push(StakingLot({
            amount: testAmount,
            unlockTime: block.timestamp + (minutesToExpiry * 1 minutes)
        }));
        
        totalCurrentlyStaked += testAmount;
    }
}