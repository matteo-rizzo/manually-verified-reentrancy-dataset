/**
 *Submitted for verification at Etherscan.io on 2020-12-18
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;





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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: contracts/utils/Address.sol
/**
 * @dev Collection of functions related to the address type
 */


// File: contracts/token/ERC20/ERC20.sol
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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


interface IVault is IERC20 {
    function underlying() external view returns (address);

    function strategy() external view returns (address);

    function decimals() external view returns (uint8);

    function earn() external;

    function deposit(uint256) external;

    function depositAll() external;

    function withdraw(uint256) external;

    function withdrawAll() external;

    function distribute() external;

    function salvage(address, uint256) external;

    function getRatio() external view returns (uint256);
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

contract YvsController is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // the project token
    IERC20 public token;

    // presale contract
    address public presale;

    // addresses for distribution
    address public staking_pool;
    address public liquidity_pool;
    address public vault_btc_pool;
    address public vault_stables_pool;

    // addresses for vaults
    address public vault_btc;
    address public vault_stables;

    // distribution of tokens
    uint256 public stakingPercentage = 20;
    uint256 public liquidityPercentage = 65;
    uint256 public baseRate = 100;
    // 15 % goes to vault pools

    // last distribution and harvest
    uint256 public last_distribution;
    uint256 public last_harvest;

    // start date of token
    uint256 public start;

    // grace period (20 months)
    uint256 public grace = 52600000;

    // interval after grace period (3 months)
    uint256 public interval = 7890000;

    // interval for harvesting
    uint256 public harvest_interval = 12 hours;

    // uniswap pair
    address public uniswap_pair;

    // are tokens distributed
    bool private ready = false;

    // is it the initial call from presale
    bool private first_run = true;

    /**
    * event for signaling token distribution
    * @param amount amount of distributed tokens
    */
    event Distributed(uint256 amount);

    /**
    * event for signaling rewards start
    */
    event NotifyRewards();

    /**
    * event for signaling salvaged non-token assets
    * @param token salvaged token address
    * @param amount amount of tokens salvaged
    */
    event Salvaged(address token, uint256 amount);

    constructor(
        address _token,
        address _presale,
        uint256 _start
    ) public {
        token = IERC20(_token);
        presale = _presale;
        start = _start;

        staking_pool = 0x5a055f79981C8338230E5199BA7e477cFE35D14f; // staking pool
        liquidity_pool = 0x613f654C7BBB948219f3952173518DEBCD963718; // liquidity pool
        vault_stables_pool = 0x435a28250BF5a2B453103FF0827C75d18094504d; // vault pool (stablecoins)
        vault_btc_pool = 0x19c13992C4aD618D461FB4Eae2cb896EE6fbC0fd; // vault pool (btc)

        vault_stables = 0x0B1b5C66B519BF7B586FFf0A7bacE89227aC5EAF; // vault stablecoins
        vault_btc = 0x981cc277841f06401B750a3c7dd42492ff962B9C; // vault btc
    }

    /**
    * Set Uniswap liquidity pair
    * @param pair address of token-weth liquidity pair
    */
    function set_pair(address pair) public restricted {
        require(uniswap_pair == address(0), "uniswap_pair");
        uniswap_pair = pair;
    }

    /**
    * Set ready attribute to allow rewards to start
    * @param _ready true/false value to signal start
    */
    function set_ready(bool _ready) public restricted {
        ready = _ready;
    }

    /**
    * Set harvest interval (how often rewards are collected)
    * @param _harvest_interval interval in seconds
    */
    function set_harvest_interval(uint256 _harvest_interval) public restricted {
        harvest_interval = _harvest_interval;
    }

    /**
    * Notify reward amounts to pools after presale distribution
    */
    function notify() external distributed restricted {
        require(first_run, "!first_run");

        // set liquidity pool token
        require(uniswap_pair != address(0), "!uniswap_pair");
        IPool(liquidity_pool).setStakingToken(uniswap_pair);

        // notify rewards
        _notify();

        // first run is complete
        first_run = false;
    }

    /**
    * Internal notify function to signal rewards
    */
    function _notify() internal {
        // notify amounts
        uint256 _staking_pool = token.balanceOf(staking_pool);
        uint256 _liquidity_pool = token.balanceOf(liquidity_pool);
        uint256 _vault_btc_pool = token.balanceOf(vault_btc_pool);
        uint256 _vault_stables_pool = token.balanceOf(vault_stables_pool);

        if (_staking_pool > 0) {
            IPool(staking_pool).notifyRewardAmount(_staking_pool);
        }

        if (_liquidity_pool > 0) {
            IPool(liquidity_pool).notifyRewardAmount(_liquidity_pool);
        }

        if (_vault_btc_pool > 0) {
            IPool(vault_btc_pool).notifyRewardAmount(_vault_btc_pool);
        }

        if (_vault_stables_pool > 0) {
            IPool(vault_stables_pool).notifyRewardAmount(_vault_stables_pool);
        }

        emit NotifyRewards();
        ready = false;
    }

    /**
    * Distribute tokens after 20 months of grace period
    */
    function distribute() external {
        require(!first_run, "!first_run");
        require(block.timestamp >= start.add(grace), "!grace");

        if (last_distribution > 0) {
            require(block.timestamp >= last_distribution.add(interval), "!interval");
            _distribute();
        }
        else 
        {
            _distribute();
        }
    }

    /**
    * Internal distribution method that allocates tokens
    */
    function _distribute() internal {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "!balance");

        uint256 _staking = balance.mul(stakingPercentage).div(baseRate);
        uint256 _liquidity = balance.mul(liquidityPercentage).div(baseRate);
        uint256 _vaults = balance
            .sub(_staking)
            .sub(_liquidity);

        uint256 _vault_btc = _vaults.div(2);

        token.safeTransfer(staking_pool, _staking);
        token.safeTransfer(liquidity_pool, _liquidity);
        token.safeTransfer(vault_btc_pool, _vault_btc);
        token.safeTransfer(vault_stables_pool, _vaults.sub(_vault_btc));
        last_distribution = block.timestamp;

        if (!ready) {
            ready = true;
        }
        emit Distributed(balance);

        // set rewards duration to 3 months
        IPool(staking_pool).setRewardsDuration(interval);
        IPool(liquidity_pool).setRewardsDuration(interval);
        IPool(vault_btc_pool).setRewardsDuration(interval);
        IPool(vault_stables_pool).setRewardsDuration(interval);

        // notify rewards
        _notify();
    }

    /**
    * Public function to start earning rewards in vaults
    */
    function vaults_earn() public started {
        IVault(vault_btc).earn();
        IVault(vault_stables).earn();
    }

    /**
    * Public function to harvest rewards in vault
    */
    function vaults_harvest() public started {
        if (last_harvest > 0) {
            require(block.timestamp >= last_harvest.add(harvest_interval), "!harvest_interval");
        }

        address btc_strategy = IVault(vault_btc).strategy();
        address stables_strategy = IVault(vault_stables).strategy();

        if (btc_strategy != address(0)) {
            IStrategy(btc_strategy).harvest();
        }

        if (stables_strategy != address(0)) {
            IStrategy(stables_strategy).harvest();
        }

        last_harvest = block.timestamp;
    }

    /**
    * Public function to collect purchases in vault
    */
    function vaults_collect() public started {
        IVault(vault_btc).distribute();
        IVault(vault_stables).distribute();
    }

    /**
    * Salvage non-native tokens from the contract
    * @param _token address of the token
    * @param recipient address of the tokens recipient
    */
    function salvage(address _token, address recipient) external onlyOwner {
        require(_token != address(token), 'can not salvage token');

        uint256 balance = IERC20(_token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(_token).safeTransfer(recipient, balance);
            emit Salvaged(_token, balance);
        }
    }

    // *** VIEWS **** //

    /**
    * Returns the next distribution timestamp
    */
    function next() external view returns (uint256 timestamp) {
        if (last_distribution > 0) {
            timestamp = last_distribution.add(interval);
        }
        else
        {
            timestamp = start.add(grace);
        }
    }

    // *** MODIFIERS **** //

    modifier restricted {
        require(
            msg.sender == presale ||
            msg.sender == owner(),
            '!restricted'
        );

        _;
    }

    modifier distributed {
        require(
            ready == true,
            "!ready"
        );

        _;
    }

    modifier started {
        require(
            block.timestamp >= start, 
            "!start"
        );

        _;
    }
}