/**
 *Submitted for verification at Etherscan.io on 2021-09-23
*/

// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



// Part: BalancerMathLib



// Part: IAsset



// Part: ISymbol



// Part: IUniswapV2Router01



// Part: IWETH9



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/Context

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

// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/Math

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: IBalancerVault



// Part: IJointProvider



// Part: ILiquidityBootstrappingPool



// Part: ILiquidityBootstrappingPoolFactory



// Part: IUniswapV2Router02

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// Part: OpenZeppelin/[email protected]/ERC20

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

// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: Rebalancer.sol

/**
 * Maintains liquidity pool and dynamically rebalances pool weights to minimize impermanent loss
 */
contract Rebalancer {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    IERC20 public reward;
    IERC20 public tokenA;
    IERC20 public tokenB;
    IJointProvider public providerA;
    IJointProvider public providerB;
    IUniswapV2Router02 public uniswap;
    IWETH9 private constant weth = IWETH9(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    ILiquidityBootstrappingPoolFactory public lbpFactory;
    ILiquidityBootstrappingPool public lbp;
    IBalancerVault public bVault;
    IAsset[] public assets;
    uint[] private minAmountsOut;

    uint constant private max = type(uint).max;
    bool internal isOriginal = true;
    bool internal initJoin;
    uint public tendBuffer;

    modifier toOnlyAllowed(address _to){
        require(
            _to == address(providerA) ||
            _to == address(providerB) ||
            _to == providerA.getGovernance(), "!allowed");
        _;
    }

    modifier onlyAllowed{
        require(
            msg.sender == address(providerA) ||
            msg.sender == address(providerB) ||
            msg.sender == providerA.getGovernance(), "!allowed");
        _;
    }

    modifier onlyGov{
        require(msg.sender == providerA.getGovernance(), "!governance");
        _;
    }

    modifier onlyAuthorized() {
        require(msg.sender == providerA.strategist() || msg.sender == providerA.getGovernance(), "!authorized");
        _;
    }

    constructor(address _providerA, address _providerB, address _lbpFactory) public {
        _initialize(_providerA, _providerB, _lbpFactory);
    }

    function initialize(
        address _providerA,
        address _providerB,
        address _lbpFactory
    ) external {
        require(address(providerA) == address(0x0) && address(tokenA) == address(0x0), "Already initialized!");
        require(address(providerB) == address(0x0) && address(tokenB) == address(0x0), "Already initialized!");
        _initialize(_providerA, _providerB, _lbpFactory);
    }

    function _initialize(address _providerA, address _providerB, address _lbpFactory) internal {
        initJoin = true;
        uniswap = IUniswapV2Router02(address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D));
        reward = IERC20(address(0xba100000625a3754423978a60c9317c58a424e3D));
        reward.approve(address(uniswap), max);

        _setProviders(_providerA, _providerB);

        minAmountsOut = new uint[](2);
        tendBuffer = 0.001 * 1e18;

        IERC20[] memory tokens = new IERC20[](2);
        tokens[0] = tokenA;
        tokens[1] = tokenB;
        uint[] memory initialWeights = new uint[](2);
        initialWeights[0] = uint(0.5 * 1e18);
        initialWeights[1] = uint(0.5 * 1e18);

        lbpFactory = ILiquidityBootstrappingPoolFactory(_lbpFactory);
        lbp = ILiquidityBootstrappingPool(
            lbpFactory.create(
                string(abi.encodePacked(name()[0], name()[1])),
                string(abi.encodePacked(name()[1], " yBPT")),
                tokens,
                initialWeights,
                0.01 * 1e18,
                address(this),
                true)
        );
        bVault = IBalancerVault(lbp.getVault());
        tokenA.approve(address(bVault), max);
        tokenB.approve(address(bVault), max);

        assets = [IAsset(address(tokenA)), IAsset(address(tokenB))];
    }

    event Cloned(address indexed clone);

    function cloneRebalancer(address _providerA, address _providerB, address _lbpFactory) external returns (address payable newStrategy) {
        require(isOriginal);

        bytes20 addressBytes = bytes20(address(this));

        assembly {
        // EIP-1167 bytecode
            let clone_code := mload(0x40)
            mstore(clone_code, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone_code, 0x14), addressBytes)
            mstore(add(clone_code, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            newStrategy := create(0, clone_code, 0x37)
        }

        Rebalancer(newStrategy).initialize(_providerA, _providerB, _lbpFactory);

        emit Cloned(newStrategy);
    }

    function name() public view returns (string[] memory) {
        string[] memory names = new string[](2);
        names[0] = "Rebalancer ";
        names[1] = string(abi.encodePacked(ISymbol(address(tokenA)).symbol(), "-", ISymbol(address(tokenB)).symbol()));
        return names;
    }

    // collect profit from trading fees
    function collectTradingFees() public onlyAllowed {
        uint debtA = providerA.totalDebt();
        uint debtB = providerB.totalDebt();

        if (debtA == 0 || debtB == 0) return;

        uint pooledA = pooledBalanceA();
        uint pooledB = pooledBalanceB();
        uint lbpTotal = balanceOfLbp();

        // there's profit
        if (pooledA >= debtA && pooledB >= debtB) {
            uint gainA = pooledA.sub(debtA);
            uint gainB = pooledB.sub(debtB);
            uint looseABefore = looseBalanceA();
            uint looseBBefore = looseBalanceB();

            uint[] memory amountsOut = new uint[](2);
            amountsOut[0] = gainA;
            amountsOut[1] = gainB;
            _exitPool(abi.encode(IBalancerVault.ExitKind.BPT_IN_FOR_EXACT_TOKENS_OUT, amountsOut, balanceOfLbp()));

            if (gainA > 0) {
                tokenA.transfer(address(providerA), looseBalanceA().sub(looseABefore));
            }

            if (gainB > 0) {
                tokenB.transfer(address(providerB), looseBalanceB().sub(looseBBefore));
            }
        }
    }

    // sell reward and distribute evenly to each provider
    function sellRewards() public onlyAllowed {
        uint _rewards = balanceOfReward();
        if (_rewards > 0) {
            uint rewardsA = _rewards.mul(currentWeightA()).div(1e18);
            uint rewardsB = _rewards.sub(rewardsA);
            // TODO migrate to ySwapper when ready
            _swap(rewardsA, _getPath(reward, tokenA), address(providerA));
            _swap(rewardsB, _getPath(reward, tokenB), address(providerB));
        }
    }

    function shouldHarvest() public view returns (bool _shouldHarvest){
        uint debtA = providerA.totalDebt();
        uint debtB = providerB.totalDebt();
        uint totalA = totalBalanceOf(tokenA);
        uint totalB = totalBalanceOf(tokenB);
        return (totalA >= debtA && totalB > debtB) || (totalA > debtA && totalB >= debtB);
    }

    // If positive slippage caused by market movement is more than our swap fee, adjust position to erase positive slippage
    // since positive slippage for user = negative slippage for pool aka loss for strat
    function shouldTend() public view returns (bool _shouldTend){
        // 18 == decimals of USD
        uint debtAUsd = _adjustDecimals(providerA.totalDebt().mul(providerA.getPriceFeed()).div(10 ** providerA.getPriceFeedDecimals()), _decimals(tokenA), 18);
        uint debtBUsd = _adjustDecimals(providerB.totalDebt().mul(providerB.getPriceFeed()).div(10 ** providerA.getPriceFeedDecimals()), _decimals(tokenB), 18);
        uint debtTotalUsd = debtAUsd.add(debtBUsd);
        uint idealAUsd = debtAUsd.add(debtBUsd).mul(currentWeightA()).div(1e18);
        uint idealBUsd = debtAUsd.add(debtBUsd).sub(idealAUsd);

        uint weight = debtAUsd.mul(1e18).div(debtTotalUsd);
        if (weight > 0.95 * 1e18 || weight < 0.05 * 1e18) {
            return true;
        }

        uint amountIn = _adjustDecimals(idealAUsd.sub(debtAUsd).mul(10 ** providerA.getPriceFeedDecimals()).div(providerA.getPriceFeed()), 18, _decimals(tokenA));
        uint amountOutIfNoSlippage = _adjustDecimals(debtBUsd.sub(idealBUsd).mul(10 ** providerB.getPriceFeedDecimals()).div(providerB.getPriceFeed()), 18, _decimals(tokenB));
        uint amountOut;


        if (idealAUsd > debtAUsd) {
            amountOut = BalancerMathLib.calcOutGivenIn(pooledBalanceA(), currentWeightA(), pooledBalanceB(), currentWeightB(), amountIn, 0);
        } else {
            uint temp = amountIn;
            amountIn = amountOutIfNoSlippage;
            amountOutIfNoSlippage = temp;
            amountOut = BalancerMathLib.calcOutGivenIn(pooledBalanceB(), currentWeightB(), pooledBalanceA(), currentWeightA(), amountIn, 0);
        }

        // maximum positive slippage for user trading. Evaluate that against our fees.
        if (amountOut > amountOutIfNoSlippage) {
            uint slippage = amountOut.sub(amountOutIfNoSlippage).mul(10 ** (idealAUsd > debtAUsd ? _decimals(tokenB) : _decimals(tokenA))).div(amountOutIfNoSlippage);
            return slippage > lbp.getSwapFeePercentage().sub(tendBuffer);
        } else {
            return false;
        }
    }

    // pull from providers
    function adjustPosition() public onlyAllowed {
        if (providerA.totalDebt() == 0 || providerB.totalDebt() == 0) return;
        tokenA.transferFrom(address(providerA), address(this), providerA.balanceOfWant());
        tokenB.transferFrom(address(providerB), address(this), providerB.balanceOfWant());

        // exit entire position
        uint lbpBalance = balanceOfLbp();
        if (lbpBalance > 0) {
            _exitPool(abi.encode(IBalancerVault.ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT, lbpBalance));
        }

        // 18 == decimals of USD
        uint debtAUsd = _adjustDecimals(providerA.totalDebt().mul(providerA.getPriceFeed()), _decimals(tokenA), 18);
        uint debtBUsd = _adjustDecimals(providerB.totalDebt().mul(providerB.getPriceFeed()), _decimals(tokenB), 18);
        uint debtTotalUsd = debtAUsd.add(debtBUsd);

        // update weights to their appropriate priced balances
        uint[] memory newWeights = new uint[](2);
        newWeights[0] = Math.max(Math.min(debtAUsd.mul(1e18).div(debtTotalUsd), 0.9 * 1e18), 0.1 * 1e18);
        newWeights[1] = 1e18 - newWeights[0];
        lbp.updateWeightsGradually(now, now, newWeights);
        bool atLimit = newWeights[0] == 0.9 * 1e18 || newWeights[0] == 0.1 * 1e18;

        uint looseA = looseBalanceA();
        uint looseB = looseBalanceB();

        uint[] memory maxAmountsIn = new uint[](2);
        maxAmountsIn[0] = looseA;
        maxAmountsIn[1] = looseB;

        // re-enter pool with max funds at the appropriate weights
        uint[] memory amountsIn = new uint[](2);
        amountsIn[0] = looseA;
        amountsIn[1] = looseB;

        // 24 comes from 96%/4%. Limiting factor is the asset that hits the lower bound. Use that to calculate
        // what the other amount should be
        if (newWeights[0] == 0.1 * 1e18) {
            amountsIn[1] = _adjustDecimals(
                looseA.mul(24).mul(providerA.getPriceFeed()).div(providerB.getPriceFeed()),
                _decimals(tokenA),
                _decimals(tokenB)
            );
        } else if (newWeights[1] == 0.1 * 1e18) {
            amountsIn[0] = _adjustDecimals(
                looseB.mul(24).mul(providerB.getPriceFeed()).div(providerA.getPriceFeed()),
                _decimals(tokenB),
                _decimals(tokenA)
            );
        }

        bytes memory userData;
        if (initJoin) {
            userData = abi.encode(IBalancerVault.JoinKind.INIT, amountsIn);
            initJoin = false;
        } else {
            userData = abi.encode(IBalancerVault.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT, amountsIn, 0);
        }
        IBalancerVault.JoinPoolRequest memory request = IBalancerVault.JoinPoolRequest(assets, maxAmountsIn, userData, false);
        bVault.joinPool(lbp.getPoolId(), address(this), address(this), request);

    }

    function liquidatePosition(uint _amountNeeded, IERC20 _token, address _to) public toOnlyAllowed(_to) onlyAllowed returns (uint _liquidated, uint _short){
        uint index = tokenIndex(_token);
        uint loose = _token.balanceOf(address(this));

        if (_amountNeeded > loose) {
            uint _pooled = pooledBalance(index);
            uint _amountNeededMore = Math.min(_amountNeeded.sub(loose), _pooled);

            uint[] memory amountsOut = new uint[](2);
            amountsOut[index] = _amountNeededMore;
            _exitPool(abi.encode(IBalancerVault.ExitKind.BPT_IN_FOR_EXACT_TOKENS_OUT, amountsOut, balanceOfLbp()));
            _liquidated = Math.min(_amountNeeded, _token.balanceOf(address(this)));
        } else {
            _liquidated = _amountNeeded;
        }

        if (_liquidated > 0) {
            _token.transfer(_to, _liquidated);
        }
        _short = _amountNeeded.sub(_liquidated);
    }

    function liquidateAllPositions(IERC20 _token, address _to) public toOnlyAllowed(_to) onlyAllowed returns (uint _liquidatedAmount){
        uint lbpBalance = balanceOfLbp();
        if (lbpBalance > 0) {
            // exit entire position
            _exitPool(abi.encode(IBalancerVault.ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT, lbpBalance));
            evenOut();
        }
        _liquidatedAmount = _token.balanceOf(address(this));
        _token.transfer(_to, _liquidatedAmount);
    }

    // only applicable when pool is skewed and strat wants to completely pull out. Sells one token for another
    function evenOut() public onlyAllowed {
        uint looseA = looseBalanceA();
        uint looseB = looseBalanceB();
        uint debtA = providerA.totalDebt();
        uint debtB = providerB.totalDebt();
        uint amount;
        address[] memory path;

        if (looseA > debtA && looseB < debtB) {
            // we have more A than B, sell some A
            amount = looseA.sub(debtA);
            path = _getPath(tokenA, tokenB);
        } else if (looseB > debtB && looseA < debtA) {
            // we have more B than A, sell some B
            amount = looseB.sub(debtB);
            path = _getPath(tokenB, tokenA);
        }
        if (amount > 0) {
            _swap(amount, path, address(this));
        }
    }


    // Helpers //
    function _swap(uint _amount, address[] memory _path, address _to) internal {
        uint decIn = ERC20(_path[0]).decimals();
        uint decOut = ERC20(_path[_path.length - 1]).decimals();
        uint decDelta = decIn > decOut ? decIn.sub(decOut) : 0;
        if (_amount > 10 ** decDelta) {
            uniswap.swapExactTokensForTokens(_amount, 0, _path, _to, now);
        }
    }

    function _exitPool(bytes memory _userData) internal {
        IBalancerVault.ExitPoolRequest memory request = IBalancerVault.ExitPoolRequest(assets, minAmountsOut, _userData, false);
        bVault.exitPool(lbp.getPoolId(), address(this), address(this), request);
    }

    function _setProviders(address _providerA, address _providerB) internal {
        providerA = IJointProvider(_providerA);
        providerB = IJointProvider(_providerB);
        tokenA = providerA.want();
        tokenB = providerB.want();
        require(tokenA != tokenB);
        tokenA.approve(address(uniswap), max);
        tokenB.approve(address(uniswap), max);
    }

    function setReward(address _reward) public onlyGov {
        reward.approve(address(uniswap), 0);
        reward = IERC20(_reward);
        reward.approve(address(uniswap), max);
    }

    function _getPath(IERC20 _in, IERC20 _out) internal pure returns (address[] memory _path){
        bool isWeth = address(_in) == address(weth) || address(_out) == address(weth);
        _path = new address[](isWeth ? 2 : 3);
        _path[0] = address(_in);
        if (isWeth) {
            _path[1] = address(_out);
        } else {
            _path[1] = address(weth);
            _path[2] = address(_out);
        }
        return _path;
    }

    function setSwapFee(uint _fee) external onlyAuthorized {
        lbp.setSwapFeePercentage(_fee);
    }

    function setPublicSwap(bool _isPublic) external onlyGov {
        lbp.setSwapEnabled(_isPublic);
    }

    function setTendBuffer(uint _newBuffer) external onlyAuthorized {
        require(_newBuffer < lbp.getSwapFeePercentage());
        tendBuffer = _newBuffer;
    }

    //  called by providers
    function migrateProvider(address _newProvider) external onlyAllowed {
        IJointProvider newProvider = IJointProvider(_newProvider);
        if (newProvider.want() == tokenA) {
            providerA = newProvider;
        } else if (newProvider.want() == tokenB) {
            providerB = newProvider;
        } else {
            revert("Unsupported token");
        }
    }

    // TODO switch to ySwapper when ready
    function ethToWant(address _want, uint _amtInWei) external view returns (uint _wantAmount){
        if (_amtInWei > 0) {
            address[] memory path = new address[](2);
            if (_want == address(weth)) {
                return _amtInWei;
            } else {
                path[0] = address(weth);
                path[1] = _want;
            }
            return uniswap.getAmountsOut(_amtInWei, path)[1];
        } else {
            return 0;
        }
    }

    function balanceOfReward() public view returns (uint){
        return reward.balanceOf(address(this));
    }

    function balanceOfLbp() public view returns (uint) {
        return lbp.balanceOf(address(this));
    }

    function looseBalanceA() public view returns (uint) {
        return tokenA.balanceOf(address(this));
    }

    function looseBalanceB() public view returns (uint) {
        return tokenB.balanceOf(address(this));
    }

    function pooledBalanceA() public view returns (uint) {
        return pooledBalance(0);
    }

    function pooledBalanceB() public view returns (uint) {
        return pooledBalance(1);
    }

    function pooledBalance(uint index) public view returns (uint) {
        (, uint[] memory balances,) = bVault.getPoolTokens(lbp.getPoolId());
        return balances[index];
    }

    function totalBalanceOf(IERC20 _token) public view returns (uint){
        uint pooled = pooledBalance(tokenIndex(_token));
        uint loose = _token.balanceOf(address(this));
        return pooled.add(loose);
    }

    function currentWeightA() public view returns (uint) {
        return lbp.getNormalizedWeights()[0];
    }

    function currentWeightB() public view returns (uint) {
        return lbp.getNormalizedWeights()[1];
    }

    function _decimals(IERC20 _token) internal view returns (uint _decimals){
        return ERC20(address(_token)).decimals();
    }

    function tokenIndex(IERC20 _token) public view returns (uint _tokenIndex){
        (IERC20[] memory t,,) = bVault.getPoolTokens(lbp.getPoolId());
        if (t[0] == _token) {
            _tokenIndex = 0;
        } else if (t[1] == _token) {
            _tokenIndex = 1;
        } else {
            revert();
        }
        return _tokenIndex;
    }

    function _adjustDecimals(uint _amount, uint _decimalsFrom, uint _decimalsTo) internal pure returns (uint){
        if (_decimalsFrom > _decimalsTo) {
            return _amount.div(10 ** _decimalsFrom.sub(_decimalsTo));
        } else {
            return _amount.mul(10 ** _decimalsTo.sub(_decimalsFrom));
        }
    }

    receive() external payable {}
}