/**
 *Submitted for verification at Etherscan.io on 2020-10-30
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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

















/*

 A strategy must implement the following calls;

 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()

 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller

*/
contract StrategyPickle3Crv {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    Uni public unirouter = Uni(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    address public want = address(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490); // supposed to be 3CRV
    address public p3crv = address(0x1BB74b5DdC1f4fC91D6f9E7906cf68bc93538e33);

    // used for pickle -> weth -> [stableForAddLiquidity] -> 3crv route
    address public pickle = address(0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5);
    address public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public t3crv = address(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);

    // for add_liquidity via curve.fi to get back 3CRV (set stableForAddLiquidity for the best stable coin used in the route)
    address public dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address public usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    PickleJar public pickleJar;
    PickleMasterChef public pickleMasterChef = PickleMasterChef(0xbD17B1ce622d73bD438b9E658acA5996dc394b0d);
    uint public poolId = 14;

    uint public withdrawalFee = 50; // over 10000 - 0.5%

    address public governance;
    address public controller;
    address public strategist;
    IVaultManager public vaultManager;
    IStableSwap3Pool public stableSwap3Pool;
    address public stableForAddLiquidity;

    mapping(address => mapping(address => address[])) public uniswapPaths; // [input -> output] => uniswap_path
    mapping(address => mapping(address => address)) public balancerPools; // [input -> output] => balancer_pool

    constructor(address _want, address _p3crv, address _pickle, address _weth, address _t3crv,
        address _dai, address _usdc, address _usdt,
        IStableSwap3Pool _stableSwap3Pool, address _controller, IVaultManager _vaultManager) public {
        want = _want;
        p3crv = _p3crv;
        pickle = _pickle;
        weth = _weth;
        t3crv = _t3crv;
        dai = _dai;
        usdc = _usdc;
        usdt = _usdt;
        stableSwap3Pool = _stableSwap3Pool;
        pickleJar = PickleJar(_p3crv);
        controller = _controller;
        vaultManager = _vaultManager;
        governance = msg.sender;
        strategist = msg.sender;
        IERC20(want).safeApprove(address(pickleJar), type(uint256).max);
        IERC20(p3crv).safeApprove(address(pickleMasterChef), type(uint256).max);
        IERC20(weth).safeApprove(address(unirouter), type(uint256).max);
        IERC20(pickle).safeApprove(address(unirouter), type(uint256).max);
    }

    function getName() external pure returns (string memory) {
        return "StrategyPickle3Crv";
    }

    function setStrategist(address _strategist) external {
        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }

    function setWithdrawalFee(uint _withdrawalFee) external {
        require(msg.sender == governance, "!governance");
        withdrawalFee = _withdrawalFee;
    }

    function setStableForLiquidity(address _stableForAddLiquidity) external {
        require(msg.sender == governance || msg.sender == strategist, "!authorized");
        stableForAddLiquidity = _stableForAddLiquidity;
    }

    function setPickleMasterChef(PickleMasterChef _pickleMasterChef) external {
        require(msg.sender == governance, "!governance");
        pickleMasterChef = _pickleMasterChef;
        IERC20(p3crv).safeApprove(address(pickleMasterChef), type(uint256).max);
    }

    function setPoolId(uint _poolId) external {
        require(msg.sender == governance, "!governance");
        poolId = _poolId;
    }

    function approveForSpender(IERC20 _token, address _spender, uint _amount) external {
        require(msg.sender == controller || msg.sender == governance, "!authorized");
        _token.safeApprove(_spender, _amount);
    }

    function setUnirouter(Uni _unirouter) external {
        require(msg.sender == governance, "!governance");
        unirouter = _unirouter;
        IERC20(weth).safeApprove(address(unirouter), type(uint256).max);
        IERC20(pickle).safeApprove(address(unirouter), type(uint256).max);
    }

    function deposit() public {
        uint _wantBal = IERC20(want).balanceOf(address(this));
        if (_wantBal > 0) {
            // deposit 3crv to pickleJar
            pickleJar.depositAll();
        }

        uint _p3crvBal = IERC20(p3crv).balanceOf(address(this));
        if (_p3crvBal > 0) {
            // stake p3crv to pickleMasterChef
            pickleMasterChef.deposit(poolId, _p3crvBal);
        }
    }

    function skim() external {
        uint _balance = IERC20(want).balanceOf(address(this));
        IERC20(want).safeTransfer(controller, _balance);
    }

    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller || msg.sender == governance || msg.sender == strategist, "!authorized");

        require(want != address(_asset), "want");

        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint _amount) external {
        require(msg.sender == controller || msg.sender == governance || msg.sender == strategist, "!authorized");

        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds

        IERC20(want).safeTransfer(_vault, _amount);
    }

    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller || msg.sender == governance || msg.sender == strategist, "!authorized");
        _withdrawAll();

        balance = IERC20(want).balanceOf(address(this));

        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }

    function claimReward() public {
        pickleMasterChef.withdraw(poolId, 0);
    }

    function _withdrawAll() internal {
        (uint amount,) = pickleMasterChef.userInfo(poolId, address(this));
        pickleMasterChef.withdraw(poolId, amount);
        pickleJar.withdrawAll();
    }

    function setUnirouterPath(address _input, address _output, address [] memory _path) public {
        require(msg.sender == governance || msg.sender == strategist, "!authorized");
        uniswapPaths[_input][_output] = _path;
    }

    function setBalancerPools(address _input, address _output, address _pool) public {
        require(msg.sender == governance || msg.sender == strategist, "!authorized");
        balancerPools[_input][_output] = _pool;
        IERC20(_input).safeApprove(_pool, type(uint256).max);
    }

    function _swapTokens(address _input, address _output, uint256 _amount) internal {
        address _pool = balancerPools[_input][_output];
        if (_pool != address(0)) { // use ValueLiquid
            // swapExactAmountIn(tokenIn, tokenAmountIn, tokenOut, minAmountOut, maxPrice)
            Balancer(_pool).swapExactAmountIn(_input, _amount, _output, 1, type(uint256).max);
        } else { // use Uniswap
            address[] memory path = uniswapPaths[_input][_output];
            if (path.length == 0) {
                // path: _input -> _output
                path = new address[](2);
                path[0] = _input;
                path[1] = _output;
            }
            // swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline)
            unirouter.swapExactTokensForTokens(_amount, 1, path, address(this), now.add(1800));
        }
    }

    // to get back want (3CRV)
    function _addLiquidity() internal {
        // 0: DAI, 1: USDC, 2: USDT
        uint[3] memory amounts;
        amounts[0] = IERC20(dai).balanceOf(address(this));
        amounts[1] = IERC20(usdc).balanceOf(address(this));
        amounts[2] = IERC20(usdt).balanceOf(address(this));
        // add_liquidity(uint[3] calldata amounts, uint min_mint_amount)
        stableSwap3Pool.add_liquidity(amounts, 1);
    }

    function harvest() external {
        require(msg.sender == controller || msg.sender == strategist || msg.sender == governance, "!authorized");
        claimReward();
        uint _pickleBal = IERC20(pickle).balanceOf(address(this));

        _swapTokens(pickle, weth, _pickleBal);
        uint256 _wethBal = IERC20(weth).balanceOf(address(this));

        if (_wethBal > 0) {
            address stakingPool = vaultManager.stakingPool();
            address performanceReward = vaultManager.performanceReward();

            if (vaultManager.stakingPoolShareFee() > 0 && stakingPool != address(0)) {
                address _yax = vaultManager.yax();
                uint256 _stakingPoolShareFee = _wethBal.mul(vaultManager.stakingPoolShareFee()).div(10000);
                _swapTokens(weth, _yax, _stakingPoolShareFee);
                IERC20(_yax).safeTransfer(stakingPool, IERC20(_yax).balanceOf(address(this)));
            }

            if (vaultManager.gasFee() > 0 && performanceReward != address(0)) {
                uint256 _gasFee = _wethBal.mul(vaultManager.gasFee()).div(10000);
                IERC20(weth).safeTransfer(performanceReward, _gasFee);
            }

            _wethBal = IERC20(weth).balanceOf(address(this));
            _swapTokens(weth, stableForAddLiquidity, _wethBal);
            _addLiquidity();

            uint _want = IERC20(want).balanceOf(address(this));
            if (_want > 0) {
                deposit(); // auto re-invest
            }
        }
    }

    function _withdrawSome(uint _amount) internal returns (uint) {
        // unstake p3crv from pickleMasterChef
        uint _ratio = pickleJar.getRatio();
        _amount = _amount.mul(1e18).div(_ratio);
        (uint _stakedAmount,) = pickleMasterChef.userInfo(poolId, address(this));
        if (_amount > _stakedAmount) {
            _amount = _stakedAmount;
        }
        uint _before = pickleJar.balanceOf(address(this));
        pickleMasterChef.withdraw(poolId, _amount);
        uint _after = pickleJar.balanceOf(address(this));
        _amount = _after.sub(_before);

        // withdraw 3crv from pickleJar
        _before = IERC20(want).balanceOf(address(this));
        pickleJar.withdraw(_amount);
        _after = IERC20(want).balanceOf(address(this));
        _amount = _after.sub(_before);

        return _amount;
    }

    function balanceOfWant() public view returns (uint) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfPool() public view returns (uint) {
        uint p3crvBal = pickleJar.balanceOf(address(this));
        (uint amount,) = pickleMasterChef.userInfo(poolId, address(this));
        return p3crvBal.add(amount).mul(pickleJar.getRatio()).div(1e18);
    }

    function balanceOf() public view returns (uint) {
        return balanceOfWant()
               .add(balanceOfPool());
    }

    function withdrawFee(uint _amount) external view returns (uint) {
        return _amount.mul(withdrawalFee).div(10000);
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
}