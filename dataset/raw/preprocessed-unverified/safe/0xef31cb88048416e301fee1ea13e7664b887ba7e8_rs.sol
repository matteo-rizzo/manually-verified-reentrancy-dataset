/**
 *Submitted for verification at Etherscan.io on 2020-11-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
 * @dev Collection of functions related to the address type
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

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

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
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

// YaxisBar is the coolest bar in town. You come in with some YAX, and leave with more! The longer you stay, the more YAX you get.
// This contract handles swapping to and from sYAX, Yaxis's staking token.
contract YaxisBar is ERC20("Staked yAxis", "sYAX"){
    using SafeMath for uint;

    IERC20 public yax;

    address public governance;

    uint public constant BLOCKS_PER_WEEK = 46500;

    // Block number when each epoch ends.
    uint[6] public epEndBlks;

    // Reward rate for each of 5 epoches:
    uint[6] public epRwdPerBlks = [129032258064516000, 96774193548387100, 64516129032258100, 32258064516129000, 16129032258064500, 0];

    uint[6] public accReleasedRwds;

    // Define the Yaxis token contract
    constructor(IERC20 _yax, uint _startBlock) public {
        require(block.number < _startBlock, "passed _startBlock");
        yax = _yax;
        epEndBlks[0] = _startBlock;
        epEndBlks[1] = epEndBlks[0] + BLOCKS_PER_WEEK * 2; // weeks 1-2
        epEndBlks[2] = epEndBlks[1] + BLOCKS_PER_WEEK * 2; // weeks 3-4
        epEndBlks[3] = epEndBlks[2] + BLOCKS_PER_WEEK * 4; // month 2
        epEndBlks[4] = epEndBlks[3] + BLOCKS_PER_WEEK * 8; // month 3-4
        epEndBlks[5] = epEndBlks[4] + BLOCKS_PER_WEEK * 8; // month 5-6
        accReleasedRwds[0] = 0;
        for (uint8 _epid = 1; _epid < 6; ++_epid) {
            // a[i] = (eb[i] - eb[i-1]) * r[i-1] + a[i-1]
            accReleasedRwds[_epid] = epEndBlks[_epid].sub(epEndBlks[_epid - 1]).mul(epRwdPerBlks[_epid - 1]).add(accReleasedRwds[_epid - 1]);
        }
        governance = msg.sender;
    }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function releasedRewards() public view returns (uint) {
        uint _block = block.number;
        if (_block >= epEndBlks[5]) return accReleasedRwds[5];
        for (uint8 _epid = 5; _epid >= 1; --_epid) {
            if (_block >= epEndBlks[_epid - 1]) {
                return _block.sub(epEndBlks[_epid - 1]).mul(epRwdPerBlks[_epid - 1]).add(accReleasedRwds[_epid - 1]);
            }
        }
        return 0;
    }

    // @dev Return balance (deposited YAX + MV earning + any external yeild) plus released rewards
    // Read YIP-03, YIP-04 and YIP-05 for more details.
    function availableBalance() public view returns (uint) {
        return yax.balanceOf(address(this)).add(releasedRewards()).sub(accReleasedRwds[5]);
    }

    // Enter the bar. Pay some YAXs. Earn some shares.
    // Locks Yaxis and mints sYAX
    function enter(uint _amount) public {
        require(_amount > 0, "!_amount");

        // Gets the amount of available YAX locked in the contract
        uint _totalYaxis = availableBalance();

        // Gets the amount of sYAX in existence
        uint _totalShares = totalSupply();

        if (_totalShares == 0 || _totalYaxis == 0) { // If no sYAX exists, mint it 1:1 to the amount put in
            _mint(msg.sender, _amount);
        }
        else { // Calculate and mint the amount of sYAX the YAX is worth. The ratio will change overtime, as sYAX is burned/minted and YAX deposited + gained from fees / withdrawn.
            uint what = _amount.mul(_totalShares).div(_totalYaxis);
            _mint(msg.sender, what);
        }

        // Lock the YAX in the contract
        yax.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your YAX.
    // Unlocks the staked + gained YAX and burns sYAX
    function leave(uint _share) public {
        require(_share > 0, "!_share");

        // Gets the amount of available YAX locked in the contract
        uint _totalYaxis = availableBalance();

        // Gets the amount of sYAX in existence
        uint _totalShares = totalSupply();

        // Calculates the amount of YAX the sYAX is worth
        uint what = _share.mul(_totalYaxis).div(_totalShares);

        _burn(msg.sender, _share);
        yax.transfer(msg.sender, what);
    }

    // @dev Burn all sYAX you have and get back YAX.
    function exit() public {
        leave(balanceOf(msg.sender));
    }

    // @dev price of 1 sYAX over YAX (should increase gradiently over time)
    function getPricePerFullShare() external view returns (uint) {
        uint _ts = totalSupply();
        return (_ts == 0) ? 1e18 : availableBalance().mul(1e18).div(_ts);
    }

    // @dev expected compounded APY mul 10000 (for decimal precision)
    function compounded_apy() external view returns (uint) {
        uint _ts = totalSupply();
        if (_ts == 0) return 0;
        uint _block = block.number;
        if (_block <= epEndBlks[0]) return 0;
        uint _released = releasedRewards();
        uint _ab = availableBalance();
        uint _extraYield = (_ab <= _ts) ? 0 : _ab.sub(_ts);
        uint _earnedPerYear = _released.add(_extraYield).mul(2400000).div(_block.sub(epEndBlks[0])); // approximately 2,400,000 blocks / year
        return _earnedPerYear.mul(10000).div(_ts);
    }

    // @dev expected incentive APY (unstable) mul 10000 (for decimal precision)
    function incentive_apy() external view returns (uint) {
        uint _ts = totalSupply();
        if (_ts == 0) return 0;
        return yaxPerBlock().mul(2400000).mul(10000).div(_ts); // approximately 2,400,000 blocks / year
    }

    // @dev return current reward (YAX) per block
    function yaxPerBlock() public view returns (uint) {
        uint _block = block.number;
        if (_block <= epEndBlks[0] || _block >= epEndBlks[5]) return 0;
        for (uint8 _epid = 1; _epid < 6; ++_epid) {
            if (_block < epEndBlks[_epid]) {
                return epRwdPerBlks[_epid - 1];
            }
        }
        return 0;
    }

    // This function allows governance to take unsupported tokens (non-core) out of the contract. This is in an effort to make someone whole, should they seriously mess up.
    // There is no guarantee governance will vote to return these. It also allows for removal of airdropped tokens.
    function governanceRecoverUnsupported(IERC20 _token, uint256 _amount, address _to) external {
        require(msg.sender == governance, "!governance");
        require(address(_token) != address(yax), "YAX");
        require(address(_token) != address(this), "sYAX");
        _token.transfer(_to, _amount);
    }
}