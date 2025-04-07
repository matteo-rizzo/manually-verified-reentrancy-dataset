pragma solidity =0.6.6;

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

// 
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

// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



contract TokenVesting {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public immutable beneficiary;

    uint256 public immutable cliff;
    uint256 public immutable start;
    uint256 public immutable duration;

    mapping (address => uint256) public released;

    event Released(uint256 amount);

    constructor(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration
    )
    public
    {
        require(_beneficiary != address(0));
        require(_cliff <= _duration);

        beneficiary = _beneficiary;
        duration = _duration;
        cliff = _start.add(_cliff);
        start = _start;
    }

    function release(IERC20 _token) external {
        uint256 unreleased = releasableAmount(_token);

        require(unreleased > 0);

        released[address(_token)] = released[address(_token)].add(unreleased);

        _token.safeTransfer(beneficiary, unreleased);

        emit Released(unreleased);
    }

    function releasableAmount(IERC20 _token) public view returns (uint256) {
        return vestedAmount(_token).sub(released[address(_token)]);
    }

    function vestedAmount(IERC20 _token) public view returns (uint256) {
        uint256 currentBalance = _token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(released[address(_token)]);

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start.add(duration)) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(start)).div(duration);
        }
    }
}


contract TokenTimelock {
    using SafeERC20 for IERC20;

    address public immutable beneficiary;

    uint256 public immutable releaseTime;

    constructor(
        address _beneficiary,
        uint256 _releaseTime
    )
    public
    {
        // solium-disable-next-line security/no-block-members
        require(_releaseTime > block.timestamp);
        beneficiary = _beneficiary;
        releaseTime = _releaseTime;
    }

    function release(IERC20 _token) public {
        // solium-disable-next-line security/no-block-members
        require(block.timestamp >= releaseTime);

        uint256 amount = _token.balanceOf(address(this));
        require(amount > 0);

        _token.safeTransfer(beneficiary, amount);
    }
}

// 
/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// 
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

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 internal _totalSupply;

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
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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



// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))


// library with helper methods for oracles that are concerned with computing average prices


//import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";



contract AChadsToken is ERC20, Ownable, Pausable {
    using SafeMath for uint256;

    /// @notice uniswap listing rate
    uint256 public constant INITIAL_TOKENS_PER_ETH = 133_333 * 1 ether;

    /// @notice max burn percentage to teach virgins what happens when they sell too early
    uint256 public constant BURN_PCT = 60;

    /// @notice min burn percentage
    uint256 public constant MIN_BURN_PCT = 6;

    /// @notice reserve percentage of the burn percentage for rewarding true chads
    uint256 public constant BURN_RESERVE_PCT = 49;

    /// @notice WETH token address
    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    /// @notice self-explanatory
    address public constant uniswapV2Factory = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    address public immutable burnReservesAddress;

    address public immutable initialDistributionAddress;    

    TokenTimelock public burnReservesVault;

    TokenVesting public teamVault;

    TokenVesting public devVault;

    /// @notice liquidity sources (e.g. UniswapV2Router) 
    mapping(address => bool) public whitelistedSenders;

    /// @notice uniswap pair for CHADS/ETH
    address public uniswapPair;

    /// @notice Whether or not this token is first in uniswap CHADS<>ETH pair
    bool public isThisToken0;

    /// @notice last TWAP update time
    uint32 public blockTimestampLast;

    /// @notice last TWAP cumulative price
    uint256 public priceCumulativeLast;

    /// @notice last TWAP average price
    uint256 public priceAverageLast;

    /// @notice TWAP min delta (10-min)
    uint256 public minDeltaTwap;

    event TwapUpdated(uint256 priceCumulativeLast, uint256 blockTimestampLast, uint256 priceAverageLast);

    constructor(
        uint256 _minDeltaTwap,
        address _burnReservesAddress
    ) 
    public
    Ownable()
    ERC20("ALPHA CHAD", "ACHD")
    {   
        setMinDeltaTwap(_minDeltaTwap);
        initialDistributionAddress = 0x5c4b8935051c2C0E190Ef30359DC56625C2028AB;
        burnReservesAddress = _burnReservesAddress;
        _createBurnReservesVault(_burnReservesAddress);
        _distributeTokens(0x5c4b8935051c2C0E190Ef30359DC56625C2028AB);
        _initializePair();
        _pause();
    }

    modifier whenNotPausedOrInitialDistribution() {
        require(!paused() || msg.sender == initialDistributionAddress, "!paused && !initialDistributionAddress");
        _;
    }

    modifier onlyInitialDistributionAddress() {
        require(msg.sender == initialDistributionAddress, "!initialDistributionAddress");
        _;
    }

    /**
     * @dev Unpauses all transfers from the distribution address (initial liquidity pool).
     */
    function unpause() external virtual onlyInitialDistributionAddress {
        super._unpause();
    }
    
     function mint(address account, uint256 amount) public  onlyOwner{
        _mint(account, amount);
    }

    /**
     * @dev Min time elapsed before twap is updated.
     */
    function setMinDeltaTwap(uint256 _minDeltaTwap) public onlyOwner {
        minDeltaTwap = _minDeltaTwap;
    }

    /**
     * @dev Initializes the TWAP cumulative values for the burn curve.
     */
    function initializeTwap() external onlyInitialDistributionAddress {
        require(blockTimestampLast == 0, "twap already initialized");
        (uint256 price0Cumulative, uint256 price1Cumulative, uint32 blockTimestamp) = 
            UniswapV2OracleLibrary.currentCumulativePrices(uniswapPair);

        uint256 priceCumulative = isThisToken0 ? price1Cumulative : price0Cumulative;
        
        blockTimestampLast = blockTimestamp;
        priceCumulativeLast = priceCumulative;
        priceAverageLast = INITIAL_TOKENS_PER_ETH;
    }

    /**
     * @dev Sets a whitelisted sender (liquidity sources mostly).
     */
    function setWhitelistedSender(address _address, bool _whitelisted) public onlyOwner {
        whitelistedSenders[_address] = _whitelisted;
    }

    function _distributeTokens(
        address _initialDistributionAddress
    ) 
    internal
    {

        _mint(address(0x5c4b8935051c2C0E190Ef30359DC56625C2028AB),735000 * 1e18);
        setWhitelistedSender(0x5c4b8935051c2C0E190Ef30359DC56625C2028AB, true);
       // transferOwnership(0x5c4b8935051c2C0E190Ef30359DC56625C2028AB);

    }

    function _createBurnReservesVault(address _burnReservesAddress) internal {
        burnReservesVault = new TokenTimelock(_burnReservesAddress, block.timestamp + 2 weeks);
        setWhitelistedSender(address(burnReservesVault), true);
    }

    function _initializePair() internal {
        (address token0, address token1) = UniswapV2Library.sortTokens(address(this), address(WETH));
        isThisToken0 = (token0 == address(this));
        uniswapPair = UniswapV2Library.pairFor(uniswapV2Factory, token0, token1);
        setWhitelistedSender(uniswapPair, true);
    }

    function _isWhitelistedSender(address _sender) internal view returns (bool) {
        return whitelistedSenders[_sender];
    }    

    function _updateTwap() internal virtual returns (uint256) {
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) = 
            UniswapV2OracleLibrary.currentCumulativePrices(uniswapPair);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        if (timeElapsed > minDeltaTwap) {
            uint256 priceCumulative = isThisToken0 ? price1Cumulative : price0Cumulative;

            // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
            FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
                uint224((priceCumulative - priceCumulativeLast) / timeElapsed)
            );

            priceCumulativeLast = priceCumulative;
            blockTimestampLast = blockTimestamp;

            priceAverageLast = FixedPoint.decode144(FixedPoint.mul(priceAverage, 1 ether));

            emit TwapUpdated(priceCumulativeLast, blockTimestampLast, priceAverageLast);
        }

        return priceAverageLast;
    }

    function _transfer(address sender, address recipient, uint256 amount)
        internal
        virtual
        override
        whenNotPausedOrInitialDistribution()
    {
        if (!_isWhitelistedSender(sender)) {
            uint256 scaleFactor = 1e18;
            uint256 currentAmountOutPerEth = _updateTwap();
            uint256 currentBurnPct = BURN_PCT.mul(scaleFactor);
            if (currentAmountOutPerEth < INITIAL_TOKENS_PER_ETH) {
                // 50 / (INITIAL_TOKENS_PER_ETH / currentAmountOutPerEth)
                scaleFactor = 1e9;
                currentBurnPct = currentBurnPct.mul(scaleFactor)
                    .div(INITIAL_TOKENS_PER_ETH.mul(1e18)
                        .div(currentAmountOutPerEth));
                uint256 minBurnPct = MIN_BURN_PCT * scaleFactor / 10;
                currentBurnPct = currentBurnPct > minBurnPct ? currentBurnPct : minBurnPct;
            }

            uint256 totalBurnAmount = amount.mul(currentBurnPct).div(100).div(scaleFactor);
            uint256 burnReserveAmount = totalBurnAmount.mul(BURN_RESERVE_PCT).div(100);
            uint256 burnAmount = totalBurnAmount.sub(burnReserveAmount);
            
            super._transfer(sender, address(burnReservesVault), burnReserveAmount);
            super._burn(sender, burnAmount);

            amount = amount.sub(totalBurnAmount);
        }
        super._transfer(sender, recipient, amount);
    }

    function getCurrentTwap() public view returns (uint256) {
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) = 
            UniswapV2OracleLibrary.currentCumulativePrices(uniswapPair);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast;

        uint256 priceCumulative = isThisToken0 ? price1Cumulative : price0Cumulative;

        FixedPoint.uq112x112 memory priceAverage = FixedPoint.uq112x112(
            uint224((priceCumulative - priceCumulativeLast) / timeElapsed)
        );

        return FixedPoint.decode144(FixedPoint.mul(priceAverage, 1 ether));
    }

    function getLastTwap() public view returns (uint256) {
        return priceAverageLast;
    }
}