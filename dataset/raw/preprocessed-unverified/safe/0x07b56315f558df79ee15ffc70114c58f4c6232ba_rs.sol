/**
 *Submitted for verification at Etherscan.io on 2021-09-24
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;



// Part: AggregatorV3Interface



// Part: ICToken



// Part: IComptroller



// Part: IFund



// Part: IGovernable



// Part: IStrategy



// Part: IStrategyUnderOptimizer



// Part: IUniswapV2Router01



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


// Part: WhitePaperInterestRateModel



// Part: IUniswapV2Router02

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
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
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint8) {
        return _decimals;
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
     * Requirements:
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
     * Requirements:
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
    function _setupDecimals(uint8 decimals_) internal virtual {
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


// Part: PriceFeedLibrary



// Part: SwapTokensLibrary



// Part: CompoundLendingStrategyBase

/**
 * @title Lending strategy for Compound
 * @author Mesh Finance
 * @notice This strategy lends asset to compound
 */
abstract contract CompoundLendingStrategyBase is
    IStrategy,
    IStrategyUnderOptimizer
{
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    uint256 internal constant PRECISION = 10**18;

    uint256 internal constant MAX_BPS = 10000;
    uint256 internal constant APR_BASE = 10**6;

    uint256 internal constant BLOCKS_PER_YEAR = 2371428;

    address public immutable override underlying;
    address public immutable override fund;
    address public immutable override creator;

    // the c-token corresponding to the underlying asset
    address public immutable cToken;

    // Reward Token
    address public immutable rewardToken;

    // Comptroller to claim reward tokens
    address public immutable comptroller;

    // Price feed for reward token
    address internal immutable _rewardTokenPriceFeed;

    // DEX router to liquidate rewards to underlying
    address internal immutable _dEXRouter;

    // base currency serves as path to convert rewards to underlying
    address internal immutable _baseCurrency;

    uint256 internal allowedSlippage = 500; // In BPS, can be changed

    // these tokens cannot be claimed by the governance
    mapping(address => bool) public canNotSweep;

    bool public investActivated;

    constructor(
        address _fund,
        address _cToken,
        address _rewardToken,
        address _comptroller,
        address rewardTokenPriceFeed_,
        address dEXRouter_,
        address baseCurrency_
    ) public {
        require(_fund != address(0), "Fund cannot be empty");
        require(_cToken != address(0), "cToken cannot be empty");
        fund = _fund;
        address _underlying = IFund(_fund).underlying();
        require(
            _underlying == ICToken(_cToken).underlying(),
            "Underlying do not match"
        );
        underlying = _underlying;
        cToken = _cToken;
        rewardToken = _rewardToken;
        comptroller = _comptroller;
        _rewardTokenPriceFeed = rewardTokenPriceFeed_;
        _dEXRouter = dEXRouter_;
        _baseCurrency = baseCurrency_;
        creator = msg.sender;

        // restricted tokens, can not be swept
        canNotSweep[_underlying] = true;
        canNotSweep[_cToken] = true;
        canNotSweep[_rewardToken] = true;

        investActivated = true;
    }

    function _governance() internal view returns (address) {
        return IGovernable(fund).governance();
    }

    function _fundManager() internal view returns (address) {
        return IFund(fund).fundManager();
    }

    function _relayer() internal view returns (address) {
        return IFund(fund).relayer();
    }

    modifier onlyFund() {
        require(msg.sender == fund, "The sender has to be the fund");
        _;
    }

    modifier onlyFundOrGovernance() {
        require(
            msg.sender == fund || msg.sender == _governance(),
            "The sender has to be the governance or fund"
        );
        _;
    }

    modifier onlyFundManagerOrGovernance() {
        require(
            msg.sender == _fundManager() || msg.sender == _governance(),
            "The sender has to be the governance or fund manager"
        );
        _;
    }

    modifier onlyFundManagerOrRelayer() {
        require(
            msg.sender == _fundManager() || msg.sender == _relayer(),
            "The sender has to be the relayer or fund manager"
        );
        _;
    }

    /**
     * @notice Allows Governance/Fund manager to withdraw partial shares to reduce slippage incurred
     * and facilitate migration / withdrawal / strategy switch
     * @param shares cTokens to withdraw
     */
    function withdrawPartialShares(uint256 shares)
        external
        onlyFundManagerOrGovernance
    {
        require(shares > 0, "Shares should be greater than 0");
        uint256 redeemResult = ICToken(cToken).redeem(shares);
        require(redeemResult == 0, "Error calling redeem on Compound");
    }

    /**
     * @notice Allows Governance/Fund Manager to stop/start lending assets from this strategy to Compound
     * @dev Used for emergencies
     * @param _investActivated Set investment to True/False
     */
    function setInvestActivated(bool _investActivated)
        external
        onlyFundManagerOrGovernance
    {
        investActivated = _investActivated;
    }

    /**
     * @notice Withdraws an underlying asset from the strategy to the fund in the specified amount.
     * It tries to withdraw from the strategy contract if this has enough balance.
     * Otherwise, we redeem cToken. Transfer the required underlying amount to fund.
     * Reinvest any remaining underlying.
     * @param underlyingAmount Underlying amount to withdraw to fund
     */
    function withdrawToFund(uint256 underlyingAmount)
        external
        override
        onlyFund
    {
        uint256 underlyingBalanceBefore =
            IERC20(underlying).balanceOf(address(this));

        if (underlyingBalanceBefore >= underlyingAmount) {
            IERC20(underlying).safeTransfer(fund, underlyingAmount);
            return;
        }

        uint256 redeemResult =
            ICToken(cToken).redeemUnderlying(
                underlyingAmount.sub(underlyingBalanceBefore)
            );

        require(
            redeemResult == 0,
            "Error calling redeemUnderlying on Compound"
        );

        // we can transfer the asset to the fund
        uint256 underlyingBalance = IERC20(underlying).balanceOf(address(this));
        if (underlyingBalance > 0) {
            if (underlyingAmount < underlyingBalance) {
                IERC20(underlying).safeTransfer(fund, underlyingAmount);
                _investAllUnderlying();
            } else {
                IERC20(underlying).safeTransfer(fund, underlyingBalance);
            }
        }
    }

    /**
     * @notice Withdraws all assets from compound and transfers all underlying to fund.
     */
    function withdrawAllToFund() external override onlyFund {
        uint256 cTokenBalance = ICToken(cToken).balanceOf(address(this));
        uint256 redeemResult = ICToken(cToken).redeem(cTokenBalance);
        require(redeemResult == 0, "Error calling redeem on Compound");
        uint256 underlyingBalance = IERC20(underlying).balanceOf(address(this));
        if (underlyingBalance > 0) {
            IERC20(underlying).safeTransfer(fund, underlyingBalance);
        }
    }

    /**
     * @notice Invests all underlying assets into compound.
     */
    function _investAllUnderlying() internal {
        if (!investActivated) {
            return;
        }

        uint256 underlyingBalance = IERC20(underlying).balanceOf(address(this));
        if (underlyingBalance > 0) {
            // approve amount per transaction
            IERC20(underlying).safeApprove(cToken, 0);
            IERC20(underlying).safeApprove(cToken, underlyingBalance);
            // deposits the entire balance to compound
            uint256 mintResult = ICToken(cToken).mint(underlyingBalance);
            require(mintResult == 0, "Error calling mint on Compound");
        }
    }

    /**
     * @notice This claims and liquidates all comp rewards.
     * Then invests all the underlying balance to Compound.
     */
    function doHardWork() external override onlyFund {
        _claimRewards();
        _liquidateRewards();
        _investAllUnderlying();
    }

    /**
     * @notice Returns the underlying invested balance. This is the underlying amount in cToken, plus the current balance of the underlying asset.
     * @return Total balance invested in the strategy
     */
    function investedUnderlyingBalance()
        external
        view
        override
        returns (uint256)
    {
        uint256 cTokenBalance = ICToken(cToken).balanceOf(address(this));
        uint256 exchangeRate = ICToken(cToken).exchangeRateStored();
        uint256 underlyingBalanceinCToken =
            cTokenBalance.mul(exchangeRate).div(PRECISION);
        return
            underlyingBalanceinCToken.add(
                IERC20(underlying).balanceOf(address(this))
            );
    }

    /**
     * Returns the value of the underlying token in cToken
     */
    function _shareValueFromUnderlying(uint256 underlyingAmount)
        internal
        view
        returns (uint256)
    {
        
        uint256 exchangeRate = ICToken(cToken).exchangeRateStored();
        return underlyingAmount.mul(PRECISION).div(exchangeRate);
    }

    
    function _getRewardsBalance() internal view returns (uint256) {
        uint256 rewardsBalance =
            IComptroller(comptroller).compAccrued(address(this));
        return rewardsBalance;
    }

    /**
     * @notice This returns unclaimed comp rewards.
     * @dev Used for testing.
     */
    function getRewardsBalance() external view returns (uint256) {
        return _getRewardsBalance();
    }

    function _claimRewards() internal {
        address[] memory markets = new address[](1);
        markets[0] = cToken;
        IComptroller(comptroller).claimComp(address(this), markets);
    }

    /**
     * @notice This claims comp rewards.
     * @dev Usually claimLiquidateAndReinvestRewards should be called instead of this. This is used for testing or if for any reason we don't want to liquidate right now.
     */
    function claimRewards() external {
        _claimRewards();
    }

    function _getRewardPriceInUnderlying() internal view returns (uint256) {
        return uint256(PriceFeedLibrary._getPrice(_rewardTokenPriceFeed));
    }

    /**
     * @notice This updates the slippage used to calculate liquidation price. This can be set by fund manager or governance.
     * @param newSlippage New slippage in BPS
     */
    function updateSlippage(uint256 newSlippage)
        external
        onlyFundManagerOrGovernance
    {
        require(newSlippage > 0, "The slippage should be greater than 0");
        require(
            newSlippage < MAX_BPS,
            "The slippage should be less than 10000"
        );
        allowedSlippage = newSlippage;
    }

    /**
     * @notice This uses price feed to get minimum balance of underlying expected during liquidation of rewards.
     * @dev The slippage can be set by fund manager or governance.
     * @return Minimum underlying expected when liquidating rewards.
     */
    function _getMinUnderlyingExpectedFromRewards()
        internal
        view
        returns (uint256)
    {
        uint256 rewardPriceInUnderlying = _getRewardPriceInUnderlying();
        uint256 rewardAmount = IERC20(rewardToken).balanceOf(address(this));
        uint256 minUnderlyingExpected =
            rewardPriceInUnderlying
                .mul(
                rewardAmount.sub(rewardAmount.mul(allowedSlippage).div(MAX_BPS))
            )
                .mul(10**uint256(ERC20(underlying).decimals()))
                .div(
                10 **
                    uint256(
                        PriceFeedLibrary._getDecimals(_rewardTokenPriceFeed)
                    )
            )
                .div(10**uint256(ERC20(rewardToken).decimals()));
        return minUnderlyingExpected;
    }

    /**
     * @notice This liquidates all the reward token to underlying and reinvests.
     * @dev This does not claim the rewards.
     */
    function _liquidateRewards() internal {
        uint256 minUnderlyingExpected = _getMinUnderlyingExpectedFromRewards();
        SwapTokensLibrary._liquidateRewards(
            rewardToken,
            underlying,
            _dEXRouter,
            _baseCurrency,
            minUnderlyingExpected
        );
    }

    /**
     * @notice This claims the rewards, liquidates all the reward token to underlying and reinvests.
     * @dev This is same as hardwork, but can be called externally (without fund)
     */
    function claimLiquidateAndReinvestRewards()
        external
        onlyFundManagerOrRelayer
    {
        _claimRewards();
        _liquidateRewards();
        _investAllUnderlying();
    }

    /**
     * @notice This gives expected base(supply) APR after depositing more amount to the strategy.
     * This is used in the optimizer strategy to decide where to invest.
     * @param depositAmount New amount to deposit in the strategy
     * @return Yearly net rate multiplied by 10**6
     */
    function baseAprAfterDeposit(uint256 depositAmount)
        public
        view
        returns (uint256)
    {
        WhitePaperInterestRateModel white =
            WhitePaperInterestRateModel(ICToken(cToken).interestRateModel());
        uint256 ratePerBlock =
            white.getSupplyRate(
                ICToken(cToken).getCash().add(depositAmount),
                ICToken(cToken).totalBorrows(),
                ICToken(cToken).totalReserves(),
                ICToken(cToken).reserveFactorMantissa()
            );
        return ratePerBlock.mul(BLOCKS_PER_YEAR).mul(APR_BASE).div(PRECISION);
    }

    /**
     * @notice This gives expected reward APR after depositing more amount to the strategy.
     * This is used in the optimizer strategy to decide where to invest.
     * @param depositAmount New amount to deposit in the strategy
     * @return Yearly net rate multiplied by 10**6
     */
    function rewardAprAfterDeposit(uint256 depositAmount)
        public
        view
        returns (uint256)
    {
        uint256 compSpeed = IComptroller(comptroller).compSpeeds(cToken); // Will divide by PRECISION at last step to keep calculations reliable
        uint256 cTokenSupply = IERC20(cToken).totalSupply().add(_shareValueFromUnderlying(depositAmount)); // Divided by decimals at next step
        uint256 compPerUnderlyingPerBlock =
            compSpeed
                .mul(PRECISION) // Scaling factor for exchangeRateStored
                .mul(10**uint256(ERC20(underlying).decimals()))
                .div(cTokenSupply)
                .div(ICToken(cToken).exchangeRateStored());
        uint256 rewardRatePerBlock =
            _getRewardPriceInUnderlying().mul(compPerUnderlyingPerBlock).div(
                10 **
                    uint256(
                        PriceFeedLibrary._getDecimals(_rewardTokenPriceFeed)
                    )
            );
        return (
            rewardRatePerBlock.mul(BLOCKS_PER_YEAR).mul(APR_BASE).div(PRECISION)
        );
    }

    /**
     * @notice This gives expected APR after depositing more amount to the strategy.
     * This is used in the optimizer strategy to decide where to invest.
     * @param depositAmount New amount to deposit in the strategy
     * @return Yearly net rate multiplied by 10**6
     */
    function aprAfterDeposit(uint256 depositAmount)
        public
        view
        override
        returns (uint256)
    {
        return baseAprAfterDeposit(depositAmount).add(rewardAprAfterDeposit(depositAmount));
    }

    /**
     * @notice This gives current base(supply) APR of the strategy
     * @return Yearly net rate mulltiplied by 10**6
     */
    function baseApr() external view returns (uint256) {
        return baseAprAfterDeposit(0);
    }

    /**
     * @notice This gives current COMP APR of the strategy.
     * @return Yearly net rate multiplied by 10**6
     */
    function rewardApr() external view returns (uint256) {
        return rewardAprAfterDeposit(0);
    }

    /**
     * @notice This gives current APR of the strategy including supply apr and rewards apr
     * @return Yearly net rate mulltiplied by 10**6
     */
    function apr() external view override returns (uint256) {
        return aprAfterDeposit(0);
    }

    /**
     * @notice No tokens apart from underlying assets, shares and rewards should ever be stored on this contract.
     * Any tokens that are sent here by mistake are recoverable by owner.
     * @dev Not applicable for ETH, different function needs to be written
     * @param  _token  Token address that needs to be recovered
     * @param  _sweepTo  Address to which tokens are sent
     */
    function sweep(address _token, address _sweepTo) external {
        require(_governance() == msg.sender, "Not governance");
        require(!canNotSweep[_token], "Token is restricted");
        require(_sweepTo != address(0), "can not sweep to zero");
        IERC20(_token).safeTransfer(
            _sweepTo,
            IERC20(_token).balanceOf(address(this))
        );
    }
}

// File: CompoundLendingStrategyMainnetUSDC.sol

/**
 * Adds the mainnet usdc addresses to the CompoundLendingStrategyBase
 */
contract CompoundLendingStrategyMainnetUSDC is CompoundLendingStrategyBase {
    string public constant override name = "CompoundLendingStrategyMainnetUSDC";
    string public constant override version = "V1";

    address internal constant _cToken =
        address(0x39AA39c021dfbaE8faC545936693aC917d5E7563);

    // COMP token as reward
    address internal constant _rewardToken =
        address(0xc00e94Cb662C3520282E6f5717214004A7f26888);

    // Comptroller to claim reward
    address internal constant _comptroller =
        address(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);

    // Reward token price feed
    address internal constant rewardTokenPriceFeed_ =
        address(0xdbd020CAeF83eFd542f4De03e3cF0C28A4428bd5);

    // Uniswap V2s router to liquidate COMP rewards to underlying
    address internal constant _uniswapRouter =
        address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    // WETH serves as path to convert rewards to underlying
    address internal constant WETH =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor(address _fund)
        public
        CompoundLendingStrategyBase(
            _fund,
            _cToken,
            _rewardToken,
            _comptroller,
            rewardTokenPriceFeed_,
            _uniswapRouter,
            WETH
        )
    // solhint-disable-next-line no-empty-blocks
    {

    }
}