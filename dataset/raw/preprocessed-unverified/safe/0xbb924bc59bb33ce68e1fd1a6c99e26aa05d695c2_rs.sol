/**
 *Submitted for verification at Etherscan.io on 2021-05-29
*/

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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Collection of functions related to the address type
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


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


















// Strategy Contract Basics
abstract contract StrategyBase {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    // Perfomance fee 30% to buyback
    uint256 public performanceFee = 30000;
    uint256 public constant performanceMax = 100000;

    // Withdrawal fee 0.2% to buyback
    // - 0.14% to treasury
    // - 0.06% to dev fund
    uint256 public treasuryFee = 140;
    uint256 public constant treasuryMax = 100000;

    uint256 public devFundFee = 60;
    uint256 public constant devFundMax = 100000;

    // delay yield profit realization
    uint256 public delayBlockRequired = 1000;
    uint256 public lastHarvestBlock;
    uint256 public lastHarvestInWant;

    // buyback ready
    bool public buybackEnabled = true;
    address public mmToken = 0xa283aA7CfBB27EF0cfBcb2493dD9F4330E0fd304;
    address public masterChef = 0xf8873a6080e8dbF41ADa900498DE0951074af577;

    // Tokens
    address public want;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // buyback coins
    address public constant usdcBuyback = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    // User accounts
    address public governance;
    address public controller;
    address public strategist;
    address public timelock;

    // Dex
    address public univ2Router2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    //Sushi
    address public sushiRouter = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;

    constructor(
        address _want,
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    ) public {
        require(_want != address(0));
        require(_governance != address(0));
        require(_strategist != address(0));
        require(_controller != address(0));
        require(_timelock != address(0));

        want = _want;
        governance = _governance;
        strategist = _strategist;
        controller = _controller;
        timelock = _timelock;
    }

    // **** Modifiers **** //

    modifier onlyBenevolent {
        // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-3074.md#allowing-txorigin-as-signer
        require(msg.sender == tx.origin || msg.sender == governance || msg.sender == strategist);
        _;
    }

    // **** Views **** //

    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfPool() public virtual view returns (uint256);

    function balanceOf() public view returns (uint256) {
        uint256 delayReduction;
        uint256 currentBlock = block.number;
        if (delayBlockRequired > 0 && lastHarvestInWant > 0 && currentBlock.sub(lastHarvestBlock) < delayBlockRequired){
            uint256 diffBlock = lastHarvestBlock.add(delayBlockRequired).sub(currentBlock);
            delayReduction = lastHarvestInWant.mul(diffBlock).mul(1e18).div(delayBlockRequired).div(1e18);
        }
        return balanceOfWant().add(balanceOfPool()).sub(delayReduction);
    }

    function getName() external virtual pure returns (string memory);

    // **** Setters **** //

    function setDelayBlockRequired(uint256 _delayBlockRequired) external {
        require(msg.sender == governance, "!governance");
        delayBlockRequired = _delayBlockRequired;
    }

    function setDevFundFee(uint256 _devFundFee) external {
        require(msg.sender == timelock, "!timelock");
        devFundFee = _devFundFee;
    }

    function setTreasuryFee(uint256 _treasuryFee) external {
        require(msg.sender == timelock, "!timelock");
        treasuryFee = _treasuryFee;
    }

    function setPerformanceFee(uint256 _performanceFee) external {
        require(msg.sender == timelock, "!timelock");
        performanceFee = _performanceFee;
    }

    function setStrategist(address _strategist) external {
        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setTimelock(address _timelock) external {
        require(msg.sender == timelock, "!timelock");
        timelock = _timelock;
    }

    function setController(address _controller) external {
        require(msg.sender == timelock, "!timelock");
        controller = _controller;
    }

    function setMmToken(address _mmToken) external {
        require(msg.sender == governance, "!governance");
        mmToken = _mmToken;
    }

    function setBuybackEnabled(bool _buybackEnabled) external {
        require(msg.sender == governance, "!governance");
        buybackEnabled = _buybackEnabled;
    }

    function setMasterChef(address _masterChef) external {
        require(msg.sender == governance, "!governance");
        masterChef = _masterChef;
    }

    function setUniRoute(address _route) external {
        require(msg.sender == governance, "!governance");
        univ2Router2 = _route;
    }

    function setSushiRoute(address _route) external {
        require(msg.sender == governance, "!governance");
        sushiRouter = _route;
    }

    // **** State mutations **** //
    function deposit() public virtual;

    function withdraw(IERC20 _asset) external virtual returns (uint256 balance);

    // Controller only function for creating additional rewards from dust
    function _withdrawNonWantAsset(IERC20 _asset) internal returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint256 _amount) external {
        require(msg.sender == controller, "!controller");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
				
        uint256 _feeDev = _amount.mul(devFundFee).div(devFundMax);
        uint256 _feeTreasury = _amount.mul(treasuryFee).div(treasuryMax);

        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds

        if (buybackEnabled == true) {
            // we want buyback mm using LP token
            (address _buybackPrinciple, uint256 _buybackAmount) = _convertWantToBuyback(_feeDev.add(_feeTreasury));
            buybackAndNotify(_buybackPrinciple, _buybackAmount);
        } else {
            IERC20(want).safeTransfer(IController(controller).devfund(), _feeDev);
            IERC20(want).safeTransfer(IController(controller).treasury(), _feeTreasury);
        }

        IERC20(want).safeTransfer(_vault, _amount.sub(_feeDev).sub(_feeTreasury));
    }
	
    // buyback MM and notify MasterChef
    function buybackAndNotify(address _buybackPrinciple, uint256 _buybackAmount) internal {
        if (buybackEnabled == true) {
            _swapUniswap(_buybackPrinciple, mmToken, _buybackAmount);
            uint256 _mmBought = IERC20(mmToken).balanceOf(address(this));
            IERC20(mmToken).safeTransfer(masterChef, _mmBought);
            IMasterchef(masterChef).notifyBuybackReward(_mmBought);
        }
    }

    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();

        balance = IERC20(want).balanceOf(address(this));

        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }

    function _withdrawAll() internal {
        _withdrawSome(balanceOfPool());
    }

    function _withdrawSome(uint256 _amount) internal virtual returns (uint256);	
	
    // convert LP to buyback principle token
    function _convertWantToBuyback(uint256 _lpAmount) internal virtual returns (address, uint256);

    // each harvest need to update `lastHarvestBlock=block.number` and `lastHarvestInWant=yield profit converted to want for re-invest`
    function harvest() public virtual;

    // **** Emergency functions ****

    function execute(address _target, bytes memory _data)
        public
        payable
        returns (bytes memory response)
    {
        require(msg.sender == timelock, "!timelock");
        require(_target != address(0), "!target");

        // call contract in current context
        assembly {
            let succeeded := delegatecall(
                sub(gas(), 5000),
                _target,
                add(_data, 0x20),
                mload(_data),
                0,
                0
            )
            let size := returndatasize()

            response := mload(0x40)
            mstore(
                0x40,
                add(response, and(add(add(size, 0x20), 0x1f), not(0x1f)))
            )
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)

            switch iszero(succeeded)
                case 1 {
                    // throw if delegatecall failed
                    revert(add(response, 0x20), size)
                }
        }
    }

    // **** Internal functions ****
	
    function figureOutPath(address _from, address _to, uint256 _amount) public view returns (bool useSushi, address[] memory swapPath){
        address[] memory path;
        address[] memory sushipath;
		
        if (_to == mmToken && buybackEnabled == true) {
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
            
            sushipath = new address[](2);
            sushipath[0] = _from;
            sushipath[1] = _to;
        } else{
            if (_from == weth || _to == weth) {
                path = new address[](2);
                path[0] = _from;
                path[1] = _to;
            }else{
                path = new address[](3);
                path[0] = _from;
                path[1] = weth;
                path[2] = _to;
            }
        }

        uint256 _sushiOut = sushipath.length > 0? UniswapRouterV2(sushiRouter).getAmountsOut(_amount, sushipath)[sushipath.length - 1] : 0;
        uint256 _uniOut = sushipath.length > 0? UniswapRouterV2(univ2Router2).getAmountsOut(_amount, path)[path.length - 1] : 1;

        bool useSushi = _sushiOut > _uniOut? true : false;		
        address[] memory swapPath = useSushi ? sushipath : path;
		
        return (useSushi, swapPath);
    }
	
    function _swapUniswapWithRouterMinOut(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _amountOutMin,
        address _router
    ) internal {
        (, address[] memory swapPath) = figureOutPath(_from, _to, _amount);		
        _swapUniswapWithDetailConfig(_from, _to, _amount, _amountOutMin, swapPath, _router);
    }
	
    function _swapUniswapWithRouter(
        address _from,
        address _to,
        uint256 _amount,
        address _router
    ) internal {
        (, address[] memory swapPath) = figureOutPath(_from, _to, _amount);		
        _swapUniswapWithDetailConfig(_from, _to, _amount, 1, swapPath, _router);
    }
	
    function _swapUniswap(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        (bool useSushi, address[] memory swapPath) = figureOutPath(_from, _to, _amount);
        address _router = useSushi? sushiRouter : univ2Router2;
		
        _swapUniswapWithDetailConfig(_from, _to, _amount, 1, swapPath, _router);
    }
	
    function _swapUniswapWithDetailConfig(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _amountOutMin,
        address[] memory _swapPath,
        address _router
    ) internal {
        require(_to != address(0), '!invalidOutToken');
        require(_router != address(0), '!swapRouter');
        require(IERC20(_from).balanceOf(address(this)) >= _amount, '!notEnoughtAmountIn');

        if (_amount > 0){			
            IERC20(_from).safeApprove(_router, 0);
            IERC20(_from).safeApprove(_router, _amount);

            UniswapRouterV2(_router).swapExactTokensForTokens(
                _amount,
                _amountOutMin,
                _swapPath,
                address(this),
                now
            );
        }
    }

}




contract StratYvBOOSTPickle is StrategyBase {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant yveCRV = 0xc5bDdf9843308380375a611c18B50Fb9341f502A;
    address public constant yvBOOST = 0x9d409a0A012CFbA9B15F6D4B36Ac57A46966Ab9a;
    address public constant pickle = 0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5;
    address public constant pickleJar = 0xCeD67a187b923F0E5ebcc77C7f2F7da20099e378;
    address public constant pickleGauge = 0xDA481b277dCe305B97F4091bD66595d57CF31634;
    address public constant yvBOOSTSLP = 0x9461173740D27311b176476FA27e94C681b1Ea6b;
    address public constant ethusdChainlink = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    address public constant crvusdChainlink = 0xCd627aA160A6fA45Eb793D19Ef54f5062F20f33f;
	
    uint256 public yvBOOSTWithdrawFee = 200;
    uint256 public yvBOOSTSwapSlippage = 2000;
    uint256 public yvBOOSTAddLpSlippage = 1000;
    uint256 public yvBOOSTRemoveLpSlippage = 1000;
    uint256 public constant MAX_BPS = 10000;	
    uint256 public constant yvBOOSTDecimalMultiplier = 1e18;	

    mapping(address => bool) public keepers;

    modifier onlyKeepers {
        require(keepers[msg.sender] || msg.sender == governance, "!keepers");
        _;
    }
	
    modifier onlyGovernance {
        require(msg.sender == governance, "!governance");
        _;
    }

    constructor(
        address _want,
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        StrategyBase(_want, _governance, _strategist, _controller, _timelock)
    {				
        require(_want == yveCRV, '!invalidWant');
        IERC20(yveCRV).approve(yvBOOST, uint256(-1));
		
        IERC20(yvBOOSTSLP).approve(pickleJar, uint256(-1));
        IERC20(pickleJar).approve(pickleGauge, uint256(-1));
		
        IERC20(yvBOOSTSLP).approve(sushiRouter, uint256(-1));	
    }

    function setYvBOOSTRemoveLpSlippage(uint256 _val) public onlyGovernance{
        yvBOOSTRemoveLpSlippage = _val;
    }

    function setYvBOOSTSwapSlippage(uint256 _val) public onlyGovernance{
        yvBOOSTSwapSlippage = _val;
    }

    function setYvBOOSTAddLpSlippage(uint256 _val) public onlyGovernance{
        yvBOOSTAddLpSlippage = _val;
    }

    function setYvBOOSTWithdrawFee(uint256 _val) public onlyGovernance{
        yvBOOSTWithdrawFee = _val;
    }

    function setKeeper(address _keeper, bool _enable) public onlyGovernance{
        keepers[_keeper] = _enable;
    }

    // return earned but not claimed $PICKLE
    function getHarvestable() external returns (uint256) {
        return IPickleFarmingGauge(pickleGauge).earned(address(this));
    }
	
    // return estimate of yvCRV 
    // from Sushiswap LP position 
    // and PickleJar & yvBOOST ratio
    function balanceOfPool() public override view returns (uint256){
        uint256 pjarInGauge = IPickleFarmingGauge(pickleGauge).balanceOf(address(this));
        uint256 slpInPickle = pjarInGauge.add(IERC20(pickleJar).balanceOf(address(this))).mul(IPickleJar(pickleJar).getRatio()).div(1e18);		
        uint256 slpInPool = slpInPickle.add(IERC20(yvBOOSTSLP).balanceOf(address(this)));
		
        uint256 slpTotalSupply = IUniswapV2Pair(yvBOOSTSLP).totalSupply();
        uint256 _yvBOOSTPriceInETH = estimateYvBOOSTPriceInETH();
        (uint256 yvBOOSTRes, uint256 ethRes) = fairYvBOOSTSLPReserves(_yvBOOSTPriceInETH);
        uint256 yvBOOSTEstimate = slpInPool.mul(yvBOOSTRes).div(slpTotalSupply);
        uint256 ethEstimate = slpInPool.mul(ethRes).div(slpTotalSupply);
		
        uint256 yvBOOSTInPool = yvBOOSTEstimate.add(ethEstimate.mul(MAX_BPS).div(_yvBOOSTPriceInETH));
        return yvBOOSTInPool.mul(IYvBOOSTVault(yvBOOST).pricePerShare()).div(yvBOOSTDecimalMultiplier);	
    }
	
    // deposit into yvBOOST and 
    // gain LP in Sushiswap then 
    // deposit into PickleJar & PickleGauge 
    function deposit() public override{
        uint256 _yveCRV = IERC20(yveCRV).balanceOf(address(this));
        
        if (_yveCRV > 0){
            IYvBOOSTVault(yvBOOST).deposit(_yveCRV, address(this));
            uint256 _yvBOOST = IERC20(yvBOOST).balanceOf(address(this));
			
            // swap some yvBOOST for WETH pairing
            uint256 _yvBOOSTPriceInETH = estimateYvBOOSTPriceInETH();
            (uint256 _yvBOOSTRes, ) = fairYvBOOSTSLPReserves(_yvBOOSTPriceInETH);
            uint256 _swapAmt = UniswapV2SingleSided.calculateSingleSidedAmt(_yvBOOST, _yvBOOSTRes);	
			
            uint256 _weth = IERC20(weth).balanceOf(address(this));
            _swapUniswapWithRouterMinOut(yvBOOST, weth, _swapAmt, _swapAmt.mul(_yvBOOSTPriceInETH).div(MAX_BPS).mul(MAX_BPS.sub(yvBOOSTSwapSlippage)).div(MAX_BPS), sushiRouter);			
            uint256 _wethAfter = IERC20(weth).balanceOf(address(this));
			
            uint256 _pairedYvBOOST = _yvBOOST.sub(_swapAmt);	
            uint256 _pairedWETH = _wethAfter.sub(_weth);
		
            IERC20(yvBOOST).approve(sushiRouter, 0);
            IERC20(yvBOOST).approve(sushiRouter, _pairedYvBOOST);
            IERC20(weth).approve(sushiRouter, 0);
            IERC20(weth).approve(sushiRouter, _pairedWETH);
		
            UniswapRouterV2(sushiRouter).addLiquidity(yvBOOST, weth, _pairedYvBOOST, _pairedWETH, 
                                                      _pairedYvBOOST.mul(MAX_BPS.sub(yvBOOSTAddLpSlippage)).div(MAX_BPS),
                                                      _pairedWETH.mul(MAX_BPS.sub(yvBOOSTAddLpSlippage)).div(MAX_BPS), 
                                                      address(this), now);
																	 
            IPickleJar(pickleJar).depositAll();
            IERC20(pickleJar).balanceOf(address(this));		
            IPickleFarmingGauge(pickleGauge).depositAll();		
        }			
    }
	
    function _withdrawAllAsset(uint256 yvBOOSTRes, uint256 wethRes, uint256 slpTotalSupply, uint256 _wantBefore, uint256 _yvBOOSTPriceInETH) internal {
        IPickleFarmingGauge(pickleGauge).withdrawAll();
        IPickleJar(pickleJar).withdrawAll();
			
        _removeSLPAndGetYvBOOST(IERC20(yvBOOSTSLP).balanceOf(address(this)), yvBOOSTRes, wethRes, slpTotalSupply, _yvBOOSTPriceInETH);

        IYvBOOSTVault(yvBOOST).withdraw(IERC20(yvBOOST).balanceOf(address(this)), address(this), yvBOOSTWithdrawFee);
    }
	
    function _removeSLPAndGetYvBOOST(uint256 _diSLP, uint256 yvBOOSTRes, uint256 wethRes, uint256 slpTotalSupply, uint256 _yvBOOSTPriceInETH) internal returns (uint256, uint256){
        uint256 _removeSLPSlippageMultiplier = MAX_BPS.sub(yvBOOSTRemoveLpSlippage); 
        uint256 _yvBOOSTMinReceived = _diSLP.mul(yvBOOSTRes).div(slpTotalSupply);
        uint256 _wethMinReceived = _diSLP.mul(wethRes).div(slpTotalSupply);
        (uint256 _divestedYvBOOST, uint256 _divestedETH) = UniswapRouterV2(sushiRouter).removeLiquidity(yvBOOST, weth, _diSLP, 
                                                                                                        _yvBOOSTMinReceived.mul(_removeSLPSlippageMultiplier).div(MAX_BPS),
                                                                                                        _wethMinReceived.mul(_removeSLPSlippageMultiplier).div(MAX_BPS),
                                                                                                        address(this), now);

        uint256 _slippageMultiplier = MAX_BPS.sub(yvBOOSTSwapSlippage); 
        uint256 _minOut = _divestedETH.mul(MAX_BPS).div(_yvBOOSTPriceInETH);
        _minOut = _minOut.mul(_slippageMultiplier).div(MAX_BPS);
        _swapUniswapWithRouterMinOut(weth, yvBOOST, _divestedETH, _minOut, sushiRouter);

        return (_divestedYvBOOST, _divestedETH);		
    }
	
    function _withdrawFromPickle(uint256 _slpRequired, uint256 _slp) internal {
        uint256 _diffSlp = _slpRequired.sub(_slp);
					
        // https://etherscan.io/address/0xCeD67a187b923F0E5ebcc77C7f2F7da20099e378#code#F5#L129
        uint256 _requiredPJar = _diffSlp.mul(1e18).div(IPickleJar(pickleJar).getRatio());					
        uint256 _pickleJar = IERC20(pickleJar).balanceOf(address(this));
					
        if (_pickleJar < _requiredPJar){
            uint256 _diffPJar = _requiredPJar.sub(_pickleJar);
						
            uint256 _maxStaked = IPickleFarmingGauge(pickleGauge).balanceOf(address(this));
            _diffPJar = _diffPJar > _maxStaked? _maxStaked : _diffPJar;
            IPickleFarmingGauge(pickleGauge).withdraw(_diffPJar);
        }		

        IPickleJar(pickleJar).withdraw(IERC20(pickleJar).balanceOf(address(this)));
    }
	
    // withdraw from PickleGauge & PicleJar then 
    // remove liquidity from Sushiswap to swap back for yvBOOST
    // and lastly withdraw from yvBOOST to get back yveCRV
    function _withdrawSome(uint256 _amount) internal override returns (uint256){
        if (_amount == 0){
            return 0;
        }
		
        uint256 _yvBOOSTPriceInETH = estimateYvBOOSTPriceInETH();
        (uint256 yvBOOSTRes, uint256 wethRes) = fairYvBOOSTSLPReserves(_yvBOOSTPriceInETH);
        uint256 slpTotalSupply = IUniswapV2Pair(yvBOOSTSLP).totalSupply();	
		
        uint256 _wantBefore = IERC20(want).balanceOf(address(this));
		
        if (_amount >= balanceOfPool()){
            _withdrawAllAsset(yvBOOSTRes, wethRes, slpTotalSupply, _wantBefore, _yvBOOSTPriceInETH);																						
        }else if (_wantBefore < _amount){				
            uint256 _requiredYvBOOST = _amount.sub(_wantBefore).mul(yvBOOSTDecimalMultiplier).div(IYvBOOSTVault(yvBOOST).pricePerShare());				
            uint256 _yvBOOST = IERC20(yvBOOST).balanceOf(address(this));
            if (_yvBOOST < _requiredYvBOOST){
                uint256 _slpRequired = _requiredYvBOOST.sub(_yvBOOST).mul(slpTotalSupply).div(yvBOOSTRes);
                uint256 _slpRmoveMultiplier = MAX_BPS.add(yvBOOSTAddLpSlippage);
                _slpRequired = _slpRequired.mul(_slpRmoveMultiplier).div(MAX_BPS);//try to remove a bit more						
                uint256 _slp = IERC20(yvBOOSTSLP).balanceOf(address(this));
				
                if (_slp < _slpRequired){
                    _withdrawFromPickle(_slpRequired, _slp);
                }	
				
                uint256 _diSLP = IERC20(yvBOOSTSLP).balanceOf(address(this));
                _removeSLPAndGetYvBOOST(_diSLP, yvBOOSTRes, wethRes, slpTotalSupply, _yvBOOSTPriceInETH);															
            }
			
            IYvBOOSTVault(yvBOOST).withdraw(IERC20(yvBOOST).balanceOf(address(this)), address(this), yvBOOSTWithdrawFee);			
        }
					
        uint256 _divested = IERC20(want).balanceOf(address(this)).sub(_wantBefore);				
        return _divested > _amount? _amount : _divested;
    }	
	
    // convert yveCRV to ETH
    function _convertWantToBuyback(uint256 _lpAmount) internal override returns (address, uint256){
        uint256 _weth = IERC20(weth).balanceOf(address(this));
        uint256 _yveCRVPriceInETH = estimateYveCRVPriceInETH();
        
        uint256 _slippageMultiplier = MAX_BPS.sub(yvBOOSTSwapSlippage);
        uint256 _minOut = _lpAmount.mul(_yveCRVPriceInETH).div(MAX_BPS);
        _minOut = _minOut.mul(_slippageMultiplier).div(MAX_BPS);
        
        _swapUniswapWithRouterMinOut(yveCRV, weth, _lpAmount, _minOut, sushiRouter);
        uint256 _wethAfter = IERC20(weth).balanceOf(address(this));
		
        require(_wethAfter >= _weth, '!mismatchAfterSwapWant');		
        return (weth, _wethAfter.sub(_weth));
    }

    // each harvest need to update `lastHarvestBlock=block.number` and `lastHarvestInWant=yield profit converted to want for re-invest`
    function harvest() public override onlyKeepers{
	
        IPickleFarmingGauge(pickleGauge).getReward();
        uint256 _pickle = IERC20(pickle).balanceOf(address(this));
        if (_pickle > 0){
            _swapUniswapWithRouter(pickle, weth, _pickle, univ2Router2);
            uint256 _weth = IERC20(weth).balanceOf(address(this));
		    
            uint256 _buybackLpAmount = _weth.mul(performanceFee).div(performanceMax);			
            if (buybackEnabled == true && _buybackLpAmount > 0){
                buybackAndNotify(weth, _buybackLpAmount);
            }
            
            uint256 _restETH = _weth.sub(_buybackLpAmount);
            uint256 _yveCRVPriceInETH = estimateYveCRVPriceInETH();
            _swapUniswapWithRouterMinOut(weth, yveCRV, _restETH, _restETH.mul(MAX_BPS).div(_yveCRVPriceInETH).mul(MAX_BPS.sub(yvBOOSTSwapSlippage)).div(MAX_BPS), sushiRouter);
            uint256 _want = IERC20(want).balanceOf(address(this));
            if (_want > 0){
                lastHarvestBlock = block.number;
                lastHarvestInWant = _want;
                deposit();		
            }
        }		
    }

    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external override returns (uint256 balance) {
        require(yvBOOST != address(_asset), "!yvBOOST");
        require(pickleJar != address(_asset), "!pickleJar");
        require(yvBOOSTSLP != address(_asset), "!yvBOOSTSLP");
        balance = _withdrawNonWantAsset(_asset);
    }	

    function getName() public override pure returns(string memory){
        return "StratYvBOOSTPickle";
    }
	
    function fairYvBOOSTSLPReserves(uint256 _yvBOOSTPriceInETH) public view returns(uint256, uint256){
        (uint resA, uint resB, ) = IUniswapV2Pair(yvBOOSTSLP).getReserves();
        return UniswapV2SingleSided.calcFairReserves(resA.mul(resB), _yvBOOSTPriceInETH);	
    }
	
    function fairYvBOOSTSLPReserves() public view returns(uint256, uint256){
        return fairYvBOOSTSLPReserves(estimateYvBOOSTPriceInETH());	
    }
	
    function estimateYvBOOSTPriceInETH() public view returns(uint256){
        (,int ethprice,,,) = AggregatorV3Interface(ethusdChainlink).latestRoundData();
        (,int crvprice,,,) = AggregatorV3Interface(crvusdChainlink).latestRoundData();// assuming 1 crv = 1 yveCRV
        uint256 pps = IYvBOOSTVault(yvBOOST).pricePerShare();
        // https://etherscan.io/address/0x9d409a0A012CFbA9B15F6D4B36Ac57A46966Ab9a#code#L1119
        uint256 yvBOOSTPrice = uint256(crvprice).mul(yvBOOSTDecimalMultiplier).div(pps);
        return yvBOOSTPrice.mul(MAX_BPS).div(uint256(ethprice));
    }
	
    function estimateYveCRVPriceInETH() public view returns(uint256){
        (,int ethprice,,,) = AggregatorV3Interface(ethusdChainlink).latestRoundData();
        (,int crvprice,,,) = AggregatorV3Interface(crvusdChainlink).latestRoundData();// assuming 1 crv = 1 yveCRV
        return uint256(crvprice).mul(MAX_BPS).div(uint256(ethprice));
    }

}