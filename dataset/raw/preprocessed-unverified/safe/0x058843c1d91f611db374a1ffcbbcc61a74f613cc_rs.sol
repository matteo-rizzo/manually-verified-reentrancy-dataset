/**
 *Submitted for verification at Etherscan.io on 2020-10-21
*/

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;

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


// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: openzeppelin-solidity/contracts/GSN/Context.sol


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

// File: openzeppelin-solidity/contracts/utils/Address.sol


/**
 * @dev Collection of functions related to the address type
 */


// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol



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
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
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

// File: contracts/oracle/ILinearDividendOracle.sol


/**
 * @title ILinearDividendOracle
 * @notice provides dividend information and calculation strategies for linear dividends.
*/


// File: contracts/standardTokens/WrappingERC20WithLinearDividends.sol



/**
 * @title WrappingERC20WithLinearDividends
 * @dev a wrapped token from another ERC 20 token with linear dividends delegation
*/
contract WrappingERC20WithLinearDividends is ERC20 {
    using SafeMath for uint256;

    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    event DividendClaimed(address indexed from, uint256 value);

    /**
    * @dev records an address's dividend state
    **/
    struct DividendState {
        // amount of dividend that has been consolidated
        uint256 consolidatedAmount;

        // timestamp to start calculating newly accrued dividends from
        uint256 timestamp;

        // index of the dividend phase that the timestamp falls into
        uint256 index;
    }

    IERC20 public _backingToken;

    IERC20 public _dai;

    ILinearDividendOracle public _dividendOracle;

    // track account balances, only original holders of backing tokens can unlock their tokens
    mapping (address => uint256) public _lockedBalances;

    // track account dividend states
    mapping (address => DividendState) public _dividends;

    constructor(
        address backingTokenAddress,
        address daiAddress,
        address dividendOracleAddress,

        string memory name,
        string memory symbol
    ) public ERC20(name, symbol) {
        require(backingTokenAddress != address(0), "Backing token must be defined");
        require(dividendOracleAddress != address(0), "Dividend oracle must be defined");

        _backingToken = IERC20(backingTokenAddress);
        _dai = IERC20(daiAddress);
        _dividendOracle = ILinearDividendOracle(dividendOracleAddress);
    }

    /**
     * @notice deposit backing tokens to be locked, and generate wrapped tokens to sender
     * @param amount            amount of token to wrap
     * @return true if successful
     */
    function wrap(uint256 amount) external returns(bool) {
        return wrapTo(msg.sender, amount);
    }

    /**
     * @notice deposit backing tokens to be locked, and generate wrapped tokens to recipient
     * @param recipient         address to receive wrapped tokens
     * @param amount            amount of tokens to wrap
     * @return true if successful
     */
    function wrapTo(address recipient, uint256 amount) public returns(bool) {
        require(recipient != address(0), "Recipient cannot be zero address");

        // transfer backing token from sender to this contract to be locked
        _backingToken.transferFrom(msg.sender, address(this), amount);

        // update how many tokens the sender has locked in total
        _lockedBalances[msg.sender] = _lockedBalances[msg.sender].add(amount);

        // mint wTokens to recipient
        _mint(recipient, amount);

        emit Mint(recipient, amount);
        return true;
    }

    /**
     * @notice burn wrapped tokens to unlock backing tokens to sender
     * @param amount    amount of token to unlock
     * @return true if successful
     */
    function unwrap(uint256 amount) external returns(bool) {
        return unwrapTo(msg.sender, amount);
    }

    /**
     * @notice burn wrapped tokens to unlock backing tokens to recipient
     * @param recipient   address to receive backing tokens
     * @param amount      amount of tokens to unlock
     * @return true if successful
     */
    function unwrapTo(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "Recipient cannot be zero address");

        // burn wTokens from sender, burn should revert if not enough balance
        _burn(msg.sender, amount);

        // update how many tokens the sender has locked in total
        _lockedBalances[msg.sender] = _lockedBalances[msg.sender].sub(amount, "Cannot unlock more than the locked amount");

        // transfer backing token from this contract to recipient
        _backingToken.transfer(recipient, amount);

        emit Burn(msg.sender, amount);
        return true;
    }

    /**
     * @notice return locked balances of backing tokens for a given account
     * @param account      account to query for
     * @return balance of backing token being locked
     */
    function lockedBalance(address account) external view returns (uint256) {
        return _lockedBalances[account];
    }

    /**
     * @notice withdraw all accrued dividends by the sender to the sender
     * @return true if successful
     */
    function claimAllDividends() external returns (bool) {
        return claimAllDividendsTo(msg.sender);
    }

    /**
     * @notice withdraw all accrued dividends by the sender to the recipient
     * @param recipient     address to receive dividends
     * @return true if successful
     */
    function claimAllDividendsTo(address recipient) public returns (bool) {
        require(recipient != address(0), "Recipient cannot be zero address");

        consolidateDividends(msg.sender);

        uint256 dividends = _dividends[msg.sender].consolidatedAmount;

        _dividends[msg.sender].consolidatedAmount = 0;

        _dai.transfer(recipient, dividends);

        emit DividendClaimed(msg.sender, dividends);
        return true;
    }

    /**
     * @notice withdraw portion of dividends by the sender to the sender
     * @return true if successful
     */
    function claimDividends(uint256 amount) external returns (bool) {
        return claimDividendsTo(msg.sender, amount);
    }

    /**
     * @notice withdraw portion of dividends by the sender to the recipient
     * @param recipient     address to receive dividends
     * @param amount        amount of dividends to withdraw
     * @return true if successful
     */
    function claimDividendsTo(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "Recipient cannot be zero address");

        consolidateDividends(msg.sender);

        uint256 dividends = _dividends[msg.sender].consolidatedAmount;
        require(amount <= dividends, "Insufficient dividend balance");

        _dividends[msg.sender].consolidatedAmount = dividends.sub(amount);

        _dai.transfer(recipient, amount);

        emit DividendClaimed(msg.sender, amount);
        return true;
    }

    /**
     * @notice view total accrued dividends of a given account
     * @param account     address of the account to query for
     * @return total accrued dividends
     */
    function dividendsAvailable(address account) external view returns (uint256) {
        uint256 balance = balanceOf(account);

        // short circut if balance is 0 to avoid potentially looping from 0 dividend index
        if (balance == 0) {
            return _dividends[account].consolidatedAmount;
        }

        (uint256 dividends,) = _dividendOracle.calculateAccruedDividends(
                balance,
                _dividends[account].timestamp,
                _dividends[account].index
            );

        return _dividends[account].consolidatedAmount.add(dividends);
    }

    /**
     * @notice view dividend state of an account
     * @param account     address of the account to query for
     * @return consolidatedAmount, timestamp, and index
     */
    function getDividendState(address account) external view returns (uint256, uint256, uint256) {
        return (_dividends[account].consolidatedAmount, _dividends[account].timestamp, _dividends[account].index);
    }

    /**
     * @notice calculate all dividends accrued since the last consolidation, and add to the consolidated amount
     * @dev anybody can consolidation dividends for any account
     * @param account     account to perform dividend consolidation on
     * @return true if success
     */
    function consolidateDividends(address account) public returns (bool) {
        uint256 balance = balanceOf(account);

        // balance is at 0, re-initialize dividend state
        if (balance == 0) {
            initializeDividendState(account);
            return true;
        }

        (uint256 dividends, uint256 newIndex) = _dividendOracle.calculateAccruedDividends(
                balance,
                _dividends[account].timestamp,
                _dividends[account].index
            );

        _dividends[account].consolidatedAmount = _dividends[account].consolidatedAmount.add(dividends);
        _dividends[account].timestamp = block.timestamp;
        _dividends[account].index = newIndex;

        return true;
    }

    /**
     * @notice perform dividend consolidation to the given dividend index
     * @dev this function can be used if consolidateDividends fails due to running out of gas in an unbounded loop.
     *  In such case, dividend consolidation can be broken into several transactions.
     *  However, dividend rates do not change frequently,
     *  this function should not be needed unless account stays dormant for a long time, e.g. a decade.
     * @param account               account to perform dividend consolidation on
     * @param toDividendIndex       dividend index to stop consolidation at, inclusive
     * @return true if success
     */
    function consolidateDividendsToIndex(address account, uint256 toDividendIndex) external returns (bool) {
        uint256 balance = balanceOf(account);

        // balance is at 0, re-initialize dividend state
        if (balance == 0) {
            initializeDividendState(account);
            return true;
        }

        (uint256 dividends, uint256 newIndex, uint256 newTimestamp) = _dividendOracle.calculateAccruedDividendsBounded(
                balance,
                _dividends[account].timestamp,
                _dividends[account].index,
                toDividendIndex
            );

        _dividends[account].consolidatedAmount = _dividends[account].consolidatedAmount.add(dividends);
        _dividends[account].timestamp = newTimestamp;
        _dividends[account].index = newIndex;

        return true;
    }

    /**
     * @notice setups for parameters for dividend accrual calculations
     * @param account     account to setup for
     */
    function initializeDividendState(address account) internal {
        // initialize the time to start dividend accrual
        _dividends[account].timestamp = block.timestamp;
        // initialize the dividend index to start dividend accrual
        _dividends[account].index = _dividendOracle.getCurrentIndex();
    }


    /**
     * @notice consolidate dividends with the balance as is, the new balance will initiate dividend calculations from 0 again
     * @dev Hook that is called before any transfer of tokens. This includes minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfer(address from, address to, uint256) internal virtual override {
        if (from != address(0)) {
            consolidateDividends(from);
        }
        if (to != address(0) && to != from) {
            consolidateDividends(to);
        }
    }
}