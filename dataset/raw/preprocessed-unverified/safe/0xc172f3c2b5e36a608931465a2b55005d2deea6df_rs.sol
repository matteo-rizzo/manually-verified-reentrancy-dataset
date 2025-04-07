/**
 *Submitted for verification at Etherscan.io on 2021-06-29
*/

// SPDX-License-Identifier: MIT

// Developed By: Hypersign Core Team
// Vesting Contract For Team And Advisory

pragma solidity ^0.8.0;


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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
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
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

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

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

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
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
 * @title HID simple vesting contract.
 * @dev A token holder contract that can release its token balance periodically
 * to beneficiary
 */
contract HIDVesting is Ownable{
    
    using SafeERC20 for IERC20;

    // Hypersign identity token interface
    IERC20 private hidToken;

    // emit event when token is released
    event TokensReleased(uint256 amount, uint256 timestamp);
    
    // emit even when token is revoked by owner
    event TokensRevoked(uint256 amount, uint256 timestamp);

    // beneficiary account
    address private beneficiary;
    
    // cliff time
    uint256 private cliff;

    // start time
    uint256 private start;

    // interval at which token will be released
    uint256 private payOutInterval;

    // struct to keep info about each vesting schedule
    struct VestingSchedule {
        uint256 unlockTime;
        uint256 unlockPercentage;
    }

    // struct to keep information about vesting
    struct VestingInfo {
        VestingSchedule[] vestingSchedules;
        uint256 numberOfVestingPeriods;
        uint256 totalUnlockedAmount;
    }

    uint256 PERCENTAGE_MULTIPLIER = 100;
    uint256 totalReleasedAmount = 0;
    
    VestingInfo vestingInfo;
    
    // has the contract been revoked by owner
    bool private hasRevoked;
    
    
    /**
     * @notice Only allow calls from the beneficiary of the vesting contract
     */
    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary);
        _;
    }

    /**
    * @notice Initialises the contract with required parameters
    * @param  _token HID token contract address
    * @param  _beneficiary address of beneficiary
    * @param  _startTime start time in seconds
    * @param  _cliffDuration cliff duration in second    
    * @param  _payOutPercentage % (in multiple of 100 i.e 12.50% = 1250) funds released in each interval.
    * @param  _payOutInterval intervals (in seconds) at which funds will be released
    */
    constructor(
        IERC20  _token,
        address _beneficiary,
        uint256 _startTime,
        uint256 _cliffDuration,
        uint256 _payOutPercentage,
        uint256 _payOutInterval
    ) {
        
        require(_beneficiary != address(0), "HIDVesting: beneficiary is the zero address");
        
        require(_payOutInterval > 0, "HIDVesting: payout interval is 0");

        require(_payOutInterval > 0, "HIDVesting: payout interval is 0");

        require(_payOutPercentage > 0, "HIDVesting: payout percentage is 0");

        require(_payOutPercentage <= (100 * PERCENTAGE_MULTIPLIER), "HIDVesting: payout percentage is more than 100%");

        
        // Calcualting in how many intervals the tokens will be unlocked        
        uint256 numberOfPayouts = (100 * PERCENTAGE_MULTIPLIER) / _payOutPercentage;
        
        // Get total time before the unlock starts
        uint256 st = _startTime + _cliffDuration;

        // preparing vesting schedules
        for (uint256 i = 0; i < numberOfPayouts; i++) {
            vestingInfo.vestingSchedules.push(VestingSchedule({
                    unlockPercentage: (i + 1) * _payOutPercentage,
                    unlockTime: st + (i * _payOutInterval)
                }));
        }
        
        vestingInfo.numberOfVestingPeriods = numberOfPayouts;
        vestingInfo.totalUnlockedAmount = 0;        

        start = _startTime;
        cliff = start + _cliffDuration;
        hidToken = _token;
        beneficiary = _beneficiary;
        payOutInterval = _payOutInterval;
        hasRevoked = false;

    }

    /**
     * @return the beneficiary of the tokens.
     */
    function getBeneficiary() public view returns (address) {
        return beneficiary;
    }

    /**
     * @return cliff end date
     */
    function getCliff() public view returns (uint256) {
        return cliff;
    }

    /**
     * @return start time or TGE date
     */
    function getStart() public view returns (uint256) {
        return start;
    }

    /**
     * @notice Returns vesting schedule at each index
     * @param _index index of vestingSchedules array
     */
    function getVestingSchedule(
        uint256 _index
    ) public view returns (uint256, uint256) {
        return (
            vestingInfo
                .vestingSchedules[_index]
                .unlockTime,
            vestingInfo
                .vestingSchedules[_index]
                .unlockPercentage
        );
    }

    /**
     * @notice Returns info about current vesting period
     */
    function getCurrentVestingDetails()
        public
        view
        returns (
            uint256,
            uint256
        )
    {
        return (
            vestingInfo
                .numberOfVestingPeriods,
            vestingInfo
                .totalUnlockedAmount
        );
    }

    /**
     * @notice Returns current HID balance of this contract 
     */
    function getBalance() public view returns (uint256) {
        return hidToken.balanceOf(address(this));
    }

    /**
     * @notice Returns total vested amount
     */
    function getInitialBalance() public view returns (uint256) {
        uint256 currentBalance = getBalance();
        uint256 totalBalance = currentBalance + vestingInfo.totalUnlockedAmount; // this was the initial balance
        return totalBalance;
    }

    /**
     * @notice Releases funds to the beneficiary
     */
    function release() public onlyBeneficiary {
        require(
            block.timestamp > cliff,
            "HIDVesting: No funds can be released during cliff period"
        );
        
        require(!hasRevoked, "HIDVesting: has already been revoked");

        // calcualting installment number
        uint256 index =  (block.timestamp - cliff) / payOutInterval;
        
        uint256 unreleased = getReleasableAmount(index);

        require(unreleased > 0, "HIDVesting: no tokens are due");

        VestingInfo storage v = vestingInfo;
        v.totalUnlockedAmount += unreleased;
        
        totalReleasedAmount += unreleased;

        // Transfer tokens
        hidToken.safeTransfer(beneficiary, unreleased);

        // Raising event
        emit TokensReleased(unreleased, block.timestamp);
    }

    /**
     * @dev Calcualtes releasable amount for beneficiary
     * @param _index index of vestingSchedules array
     */
    function getReleasableAmount(uint256 _index)
        private
        view
        returns (uint256)
    {
        return getVestedAmount(_index) - vestingInfo.totalUnlockedAmount;
    }

    /**
     * @dev Calcualtes vestable amount for beneficiary for current time
     * @param _index index of vestingSchedules array
     */
    function getVestedAmount(uint256 _index)
        public
        view
        returns (uint256)
    {        
        uint256 totalBalance = getInitialBalance();

        return
            (totalBalance * vestingInfo.vestingSchedules[_index].unlockPercentage) /
            (100 * PERCENTAGE_MULTIPLIER);
    }
    
    function revoke() public onlyOwner {
        require(!hasRevoked, "HIDVesting: has already been revoked");
        
        uint256 currentBalance = getBalance();
        
        require(currentBalance > 0, "HIDVesting: No tokens left to revoke");
        
        hasRevoked = true;
        
        // Transfer to owner
        hidToken.safeTransfer(owner(), currentBalance);

        emit TokensRevoked(currentBalance, block.timestamp);
        
    }
    
}

/**
 * @title Vesting for team and advisory
 */
contract HIDTeamAndAdvisory is HIDVesting {
    constructor(
             IERC20  _token,
            address _beneficiary,
            uint256 _startTime,
            uint256 _cliffDuration,
            uint256 _payOutPercentage,
            uint256 _payOutInterval
        )   HIDVesting(
                _token,
                _beneficiary,
                _startTime,
                _cliffDuration,
                _payOutPercentage,
                _payOutInterval
            )
            {}
}