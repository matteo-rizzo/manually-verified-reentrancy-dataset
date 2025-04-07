/**
 *Submitted for verification at Etherscan.io on 2021-05-27
*/

// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

// Global Enums and Structs






struct StrategyParams {
    uint256 performanceFee;
    uint256 activation;
    uint256 debtRatio;
    uint256 minDebtPerHarvest;
    uint256 maxDebtPerHarvest;
    uint256 lastReport;
    uint256 totalDebt;
    uint256 totalGain;
    uint256 totalLoss;
}

// Part: IAaveIncentivesController



// Part: ILendingPoolAddressesProvider

/**
 * @title LendingPoolAddressesProvider contract
 * @dev Main registry of addresses part of or connected to the protocol, including permissioned roles
 * - Acting also as factory of proxies and admin of those, so with right to change its implementations
 * - Owned by the Aave Governance
 * @author Aave
 **/


// Part: IOptionalERC20



// Part: IPriceOracle



// Part: IReserveInterestRateStrategy

/**
 * @title IReserveInterestRateStrategyInterface interface
 * @dev Interface for the calculation of the interest rates
 * @author Aave
 */


// Part: IScaledBalanceToken



// Part: IStakedAave



// Part: ISwap



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


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


// Part: WadRayMath

/**
 * @title WadRayMath library
 * @author Aave
 * @dev Provides mul and div function for wads (decimal numbers with 18 digits precision) and rays (decimals with 27 digits)
 **/



// Part: ILendingPool



// Part: IProtocolDataProvider



// Part: IVariableDebtToken

/**
 * @title IVariableDebtToken
 * @author Aave
 * @notice Defines the basic interface for a variable debt token.
 **/
interface IVariableDebtToken is IERC20, IScaledBalanceToken {
    /**
     * @dev Emitted after the mint action
     * @param from The address performing the mint
     * @param onBehalfOf The address of the user on which behalf minting has been performed
     * @param value The amount to be minted
     * @param index The last index of the reserve
     **/
    event Mint(
        address indexed from,
        address indexed onBehalfOf,
        uint256 value,
        uint256 index
    );

    /**
     * @dev Mints debt token to the `onBehalfOf` address
     * @param user The address receiving the borrowed underlying, being the delegatee in case
     * of credit delegate, or same as `onBehalfOf` otherwise
     * @param onBehalfOf The address receiving the debt tokens
     * @param amount The amount of debt being minted
     * @param index The variable debt index of the reserve
     * @return `true` if the the previous balance of the user is 0
     **/
    function mint(
        address user,
        address onBehalfOf,
        uint256 amount,
        uint256 index
    ) external returns (bool);

    /**
     * @dev Emitted when variable debt is burnt
     * @param user The user which debt has been burned
     * @param amount The amount of debt being burned
     * @param index The index of the user
     **/
    event Burn(address indexed user, uint256 amount, uint256 index);

    /**
     * @dev Burns user variable debt
     * @param user The user which debt is burnt
     * @param index The variable debt index of the reserve
     **/
    function burn(
        address user,
        uint256 amount,
        uint256 index
    ) external;

    /**
     * @dev Returns the address of the incentives controller contract
     **/
    function getIncentivesController()
        external
        view
        returns (IAaveIncentivesController);
}

// Part: IVault

interface IVault is IERC20 {
    function token() external view returns (address);

    function decimals() external view returns (uint256);

    function deposit() external;

    function pricePerShare() external view returns (uint256);

    function withdraw() external returns (uint256);

    function withdraw(uint256 amount) external returns (uint256);

    function withdraw(
        uint256 amount,
        address account,
        uint256 maxLoss
    ) external returns (uint256);

    function availableDepositLimit() external view returns (uint256);
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


// Part: iearn-finance/[email protected]/VaultAPI

interface VaultAPI is IERC20 {
    function name() external view returns (string calldata);

    function symbol() external view returns (string calldata);

    function decimals() external view returns (uint256);

    function apiVersion() external pure returns (string memory);

    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 expiry,
        bytes calldata signature
    ) external returns (bool);

    // NOTE: Vyper produces multiple signatures for a given function with "default" args
    function deposit() external returns (uint256);

    function deposit(uint256 amount) external returns (uint256);

    function deposit(uint256 amount, address recipient) external returns (uint256);

    // NOTE: Vyper produces multiple signatures for a given function with "default" args
    function withdraw() external returns (uint256);

    function withdraw(uint256 maxShares) external returns (uint256);

    function withdraw(uint256 maxShares, address recipient) external returns (uint256);

    function token() external view returns (address);

    function strategies(address _strategy) external view returns (StrategyParams memory);

    function pricePerShare() external view returns (uint256);

    function totalAssets() external view returns (uint256);

    function depositLimit() external view returns (uint256);

    function maxAvailableShares() external view returns (uint256);

    /**
     * View how much the Vault would increase this Strategy's borrow limit,
     * based on its present performance (since its last report). Can be used to
     * determine expectedReturn in your Strategy.
     */
    function creditAvailable() external view returns (uint256);

    /**
     * View how much the Vault would like to pull back from the Strategy,
     * based on its present performance (since its last report). Can be used to
     * determine expectedReturn in your Strategy.
     */
    function debtOutstanding() external view returns (uint256);

    /**
     * View how much the Vault expect this Strategy to return at the current
     * block, based on its present performance (since its last report). Can be
     * used to determine expectedReturn in your Strategy.
     */
    function expectedReturn() external view returns (uint256);

    /**
     * This is the main contact point where the Strategy interacts with the
     * Vault. It is critical that this call is handled as intended by the
     * Strategy. Therefore, this function will be called by BaseStrategy to
     * make sure the integration is correct.
     */
    function report(
        uint256 _gain,
        uint256 _loss,
        uint256 _debtPayment
    ) external returns (uint256);

    /**
     * This function should only be used in the scenario where the Strategy is
     * being retired but no migration of the positions are possible, or in the
     * extreme scenario that the Strategy needs to be put into "Emergency Exit"
     * mode in order for it to exit as quickly as possible. The latter scenario
     * could be for any reason that is considered "critical" that the Strategy
     * exits its position as fast as possible, such as a sudden change in
     * market conditions leading to losses, or an imminent failure in an
     * external dependency.
     */
    function revokeStrategy() external;

    /**
     * View the governance address of the Vault to assert privileged functions
     * can only be called by governance. The Strategy serves the Vault, so it
     * is subject to governance defined by the Vault.
     */
    function governance() external view returns (address);

    /**
     * View the management address of the Vault to assert privileged functions
     * can only be called by management. The Strategy serves the Vault, so it
     * is subject to management defined by the Vault.
     */
    function management() external view returns (address);

    /**
     * View the guardian address of the Vault to assert privileged functions
     * can only be called by guardian. The Strategy serves the Vault, so it
     * is subject to guardian defined by the Vault.
     */
    function guardian() external view returns (address);
}

// Part: IInitializableAToken

/**
 * @title IInitializableAToken
 * @notice Interface for the initialize function on AToken
 * @author Aave
 **/


// Part: iearn-finance/[email protected]/BaseStrategy

/**
 * @title Yearn Base Strategy
 * @author yearn.finance
 * @notice
 *  BaseStrategy implements all of the required functionality to interoperate
 *  closely with the Vault contract. This contract should be inherited and the
 *  abstract methods implemented to adapt the Strategy to the particular needs
 *  it has to create a return.
 *
 *  Of special interest is the relationship between `harvest()` and
 *  `vault.report()'. `harvest()` may be called simply because enough time has
 *  elapsed since the last report, and not because any funds need to be moved
 *  or positions adjusted. This is critical so that the Vault may maintain an
 *  accurate picture of the Strategy's performance. See  `vault.report()`,
 *  `harvest()`, and `harvestTrigger()` for further details.
 */
abstract contract BaseStrategy {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    string public metadataURI;

    /**
     * @notice
     *  Used to track which version of `StrategyAPI` this Strategy
     *  implements.
     * @dev The Strategy's version must match the Vault's `API_VERSION`.
     * @return A string which holds the current API version of this contract.
     */
    function apiVersion() public pure returns (string memory) {
        return "0.3.5";
    }

    /**
     * @notice This Strategy's name.
     * @dev
     *  You can use this field to manage the "version" of this Strategy, e.g.
     *  `StrategySomethingOrOtherV1`. However, "API Version" is managed by
     *  `apiVersion()` function above.
     * @return This Strategy's name.
     */
    function name() external virtual view returns (string memory);

    /**
     * @notice
     *  The amount (priced in want) of the total assets managed by this strategy should not count
     *  towards Yearn's TVL calculations.
     * @dev
     *  You can override this field to set it to a non-zero value if some of the assets of this
     *  Strategy is somehow delegated inside another part of of Yearn's ecosystem e.g. another Vault.
     *  Note that this value must be strictly less than or equal to the amount provided by
     *  `estimatedTotalAssets()` below, as the TVL calc will be total assets minus delegated assets.
     *  Also note that this value is used to determine the total assets under management by this
     *  strategy, for the purposes of computing the management fee in `Vault`
     * @return
     *  The amount of assets this strategy manages that should not be included in Yearn's Total Value
     *  Locked (TVL) calculation across it's ecosystem.
     */
    function delegatedAssets() external virtual view returns (uint256) {
        return 0;
    }

    VaultAPI public vault;
    address public strategist;
    address public rewards;
    address public keeper;

    IERC20 public want;

    // So indexers can keep track of this
    event Harvested(uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding);

    event UpdatedStrategist(address newStrategist);

    event UpdatedKeeper(address newKeeper);

    event UpdatedRewards(address rewards);

    event UpdatedMinReportDelay(uint256 delay);

    event UpdatedMaxReportDelay(uint256 delay);

    event UpdatedProfitFactor(uint256 profitFactor);

    event UpdatedDebtThreshold(uint256 debtThreshold);

    event EmergencyExitEnabled();

    event UpdatedMetadataURI(string metadataURI);

    // The minimum number of seconds between harvest calls. See
    // `setMinReportDelay()` for more details.
    uint256 public minReportDelay;

    // The maximum number of seconds between harvest calls. See
    // `setMaxReportDelay()` for more details.
    uint256 public maxReportDelay;

    // The minimum multiple that `callCost` must be above the credit/profit to
    // be "justifiable". See `setProfitFactor()` for more details.
    uint256 public profitFactor;

    // Use this to adjust the threshold at which running a debt causes a
    // harvest trigger. See `setDebtThreshold()` for more details.
    uint256 public debtThreshold;

    // See note on `setEmergencyExit()`.
    bool public emergencyExit;

    // modifiers
    modifier onlyAuthorized() {
        require(msg.sender == strategist || msg.sender == governance(), "!authorized");
        _;
    }

    modifier onlyStrategist() {
        require(msg.sender == strategist, "!strategist");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance(), "!authorized");
        _;
    }

    modifier onlyKeepers() {
        require(
            msg.sender == keeper ||
                msg.sender == strategist ||
                msg.sender == governance() ||
                msg.sender == vault.guardian() ||
                msg.sender == vault.management(),
            "!authorized"
        );
        _;
    }

    constructor(address _vault) public {
        _initialize(_vault, msg.sender, msg.sender, msg.sender);
    }

    /**
     * @notice
     *  Initializes the Strategy, this is called only once, when the
     *  contract is deployed.
     * @dev `_vault` should implement `VaultAPI`.
     * @param _vault The address of the Vault responsible for this Strategy.
     */
    function _initialize(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper
    ) internal {
        require(address(want) == address(0), "Strategy already initialized");

        vault = VaultAPI(_vault);
        want = IERC20(vault.token());
        want.safeApprove(_vault, uint256(-1)); // Give Vault unlimited access (might save gas)
        strategist = _strategist;
        rewards = _rewards;
        keeper = _keeper;

        // initialize variables
        minReportDelay = 0;
        maxReportDelay = 86400;
        profitFactor = 100;
        debtThreshold = 0;

        vault.approve(rewards, uint256(-1)); // Allow rewards to be pulled
    }

    /**
     * @notice
     *  Used to change `strategist`.
     *
     *  This may only be called by governance or the existing strategist.
     * @param _strategist The new address to assign as `strategist`.
     */
    function setStrategist(address _strategist) external onlyAuthorized {
        require(_strategist != address(0));
        strategist = _strategist;
        emit UpdatedStrategist(_strategist);
    }

    /**
     * @notice
     *  Used to change `keeper`.
     *
     *  `keeper` is the only address that may call `tend()` or `harvest()`,
     *  other than `governance()` or `strategist`. However, unlike
     *  `governance()` or `strategist`, `keeper` may *only* call `tend()`
     *  and `harvest()`, and no other authorized functions, following the
     *  principle of least privilege.
     *
     *  This may only be called by governance or the strategist.
     * @param _keeper The new address to assign as `keeper`.
     */
    function setKeeper(address _keeper) external onlyAuthorized {
        require(_keeper != address(0));
        keeper = _keeper;
        emit UpdatedKeeper(_keeper);
    }

    /**
     * @notice
     *  Used to change `rewards`. EOA or smart contract which has the permission
     *  to pull rewards from the vault.
     *
     *  This may only be called by the strategist.
     * @param _rewards The address to use for pulling rewards.
     */
    function setRewards(address _rewards) external onlyStrategist {
        require(_rewards != address(0));
        vault.approve(rewards, 0);
        rewards = _rewards;
        vault.approve(rewards, uint256(-1));
        emit UpdatedRewards(_rewards);
    }

    /**
     * @notice
     *  Used to change `minReportDelay`. `minReportDelay` is the minimum number
     *  of blocks that should pass for `harvest()` to be called.
     *
     *  For external keepers (such as the Keep3r network), this is the minimum
     *  time between jobs to wait. (see `harvestTrigger()`
     *  for more details.)
     *
     *  This may only be called by governance or the strategist.
     * @param _delay The minimum number of seconds to wait between harvests.
     */
    function setMinReportDelay(uint256 _delay) external onlyAuthorized {
        minReportDelay = _delay;
        emit UpdatedMinReportDelay(_delay);
    }

    /**
     * @notice
     *  Used to change `maxReportDelay`. `maxReportDelay` is the maximum number
     *  of blocks that should pass for `harvest()` to be called.
     *
     *  For external keepers (such as the Keep3r network), this is the maximum
     *  time between jobs to wait. (see `harvestTrigger()`
     *  for more details.)
     *
     *  This may only be called by governance or the strategist.
     * @param _delay The maximum number of seconds to wait between harvests.
     */
    function setMaxReportDelay(uint256 _delay) external onlyAuthorized {
        maxReportDelay = _delay;
        emit UpdatedMaxReportDelay(_delay);
    }

    /**
     * @notice
     *  Used to change `profitFactor`. `profitFactor` is used to determine
     *  if it's worthwhile to harvest, given gas costs. (See `harvestTrigger()`
     *  for more details.)
     *
     *  This may only be called by governance or the strategist.
     * @param _profitFactor A ratio to multiply anticipated
     * `harvest()` gas cost against.
     */
    function setProfitFactor(uint256 _profitFactor) external onlyAuthorized {
        profitFactor = _profitFactor;
        emit UpdatedProfitFactor(_profitFactor);
    }

    /**
     * @notice
     *  Sets how far the Strategy can go into loss without a harvest and report
     *  being required.
     *
     *  By default this is 0, meaning any losses would cause a harvest which
     *  will subsequently report the loss to the Vault for tracking. (See
     *  `harvestTrigger()` for more details.)
     *
     *  This may only be called by governance or the strategist.
     * @param _debtThreshold How big of a loss this Strategy may carry without
     * being required to report to the Vault.
     */
    function setDebtThreshold(uint256 _debtThreshold) external onlyAuthorized {
        debtThreshold = _debtThreshold;
        emit UpdatedDebtThreshold(_debtThreshold);
    }

    /**
     * @notice
     *  Used to change `metadataURI`. `metadataURI` is used to store the URI
     * of the file describing the strategy.
     *
     *  This may only be called by governance or the strategist.
     * @param _metadataURI The URI that describe the strategy.
     */
    function setMetadataURI(string calldata _metadataURI) external onlyAuthorized {
        metadataURI = _metadataURI;
        emit UpdatedMetadataURI(_metadataURI);
    }

    /**
     * Resolve governance address from Vault contract, used to make assertions
     * on protected functions in the Strategy.
     */
    function governance() internal view returns (address) {
        return vault.governance();
    }

    /**
     * @notice
     *  Provide an accurate estimate for the total amount of assets
     *  (principle + return) that this Strategy is currently managing,
     *  denominated in terms of `want` tokens.
     *
     *  This total should be "realizable" e.g. the total value that could
     *  *actually* be obtained from this Strategy if it were to divest its
     *  entire position based on current on-chain conditions.
     * @dev
     *  Care must be taken in using this function, since it relies on external
     *  systems, which could be manipulated by the attacker to give an inflated
     *  (or reduced) value produced by this function, based on current on-chain
     *  conditions (e.g. this function is possible to influence through
     *  flashloan attacks, oracle manipulations, or other DeFi attack
     *  mechanisms).
     *
     *  It is up to governance to use this function to correctly order this
     *  Strategy relative to its peers in the withdrawal queue to minimize
     *  losses for the Vault based on sudden withdrawals. This value should be
     *  higher than the total debt of the Strategy and higher than its expected
     *  value to be "safe".
     * @return The estimated total assets in this Strategy.
     */
    function estimatedTotalAssets() public virtual view returns (uint256);

    /*
     * @notice
     *  Provide an indication of whether this strategy is currently "active"
     *  in that it is managing an active position, or will manage a position in
     *  the future. This should correlate to `harvest()` activity, so that Harvest
     *  events can be tracked externally by indexing agents.
     * @return True if the strategy is actively managing a position.
     */
    function isActive() public view returns (bool) {
        return vault.strategies(address(this)).debtRatio > 0 || estimatedTotalAssets() > 0;
    }

    /**
     * Perform any Strategy unwinding or other calls necessary to capture the
     * "free return" this Strategy has generated since the last time its core
     * position(s) were adjusted. Examples include unwrapping extra rewards.
     * This call is only used during "normal operation" of a Strategy, and
     * should be optimized to minimize losses as much as possible.
     *
     * This method returns any realized profits and/or realized losses
     * incurred, and should return the total amounts of profits/losses/debt
     * payments (in `want` tokens) for the Vault's accounting (e.g.
     * `want.balanceOf(this) >= _debtPayment + _profit - _loss`).
     *
     * `_debtOutstanding` will be 0 if the Strategy is not past the configured
     * debt limit, otherwise its value will be how far past the debt limit
     * the Strategy is. The Strategy's debt limit is configured in the Vault.
     *
     * NOTE: `_debtPayment` should be less than or equal to `_debtOutstanding`.
     *       It is okay for it to be less than `_debtOutstanding`, as that
     *       should only used as a guide for how much is left to pay back.
     *       Payments should be made to minimize loss from slippage, debt,
     *       withdrawal fees, etc.
     *
     * See `vault.debtOutstanding()`.
     */
    function prepareReturn(uint256 _debtOutstanding)
        internal
        virtual
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        );

    /**
     * Perform any adjustments to the core position(s) of this Strategy given
     * what change the Vault made in the "investable capital" available to the
     * Strategy. Note that all "free capital" in the Strategy after the report
     * was made is available for reinvestment. Also note that this number
     * could be 0, and you should handle that scenario accordingly.
     *
     * See comments regarding `_debtOutstanding` on `prepareReturn()`.
     */
    function adjustPosition(uint256 _debtOutstanding) internal virtual;

    /**
     * Liquidate up to `_amountNeeded` of `want` of this strategy's positions,
     * irregardless of slippage. Any excess will be re-invested with `adjustPosition()`.
     * This function should return the amount of `want` tokens made available by the
     * liquidation. If there is a difference between them, `_loss` indicates whether the
     * difference is due to a realized loss, or if there is some other sitution at play
     * (e.g. locked funds) where the amount made available is less than what is needed.
     * This function is used during emergency exit instead of `prepareReturn()` to
     * liquidate all of the Strategy's positions back to the Vault.
     *
     * NOTE: The invariant `_liquidatedAmount + _loss <= _amountNeeded` should always be maintained
     */
    function liquidatePosition(uint256 _amountNeeded) internal virtual returns (uint256 _liquidatedAmount, uint256 _loss);

    /**
     * @notice
     *  Provide a signal to the keeper that `tend()` should be called. The
     *  keeper will provide the estimated gas cost that they would pay to call
     *  `tend()`, and this function should use that estimate to make a
     *  determination if calling it is "worth it" for the keeper. This is not
     *  the only consideration into issuing this trigger, for example if the
     *  position would be negatively affected if `tend()` is not called
     *  shortly, then this can return `true` even if the keeper might be
     *  "at a loss" (keepers are always reimbursed by Yearn).
     * @dev
     *  `callCost` must be priced in terms of `want`.
     *
     *  This call and `harvestTrigger()` should never return `true` at the same
     *  time.
     * @param callCost The keeper's estimated cast cost to call `tend()`.
     * @return `true` if `tend()` should be called, `false` otherwise.
     */
    function tendTrigger(uint256 callCost) public virtual view returns (bool) {
        // We usually don't need tend, but if there are positions that need
        // active maintainence, overriding this function is how you would
        // signal for that.
        return false;
    }

    /**
     * @notice
     *  Adjust the Strategy's position. The purpose of tending isn't to
     *  realize gains, but to maximize yield by reinvesting any returns.
     *
     *  See comments on `adjustPosition()`.
     *
     *  This may only be called by governance, the strategist, or the keeper.
     */
    function tend() external onlyKeepers {
        // Don't take profits with this call, but adjust for better gains
        adjustPosition(vault.debtOutstanding());
    }

    /**
     * @notice
     *  Provide a signal to the keeper that `harvest()` should be called. The
     *  keeper will provide the estimated gas cost that they would pay to call
     *  `harvest()`, and this function should use that estimate to make a
     *  determination if calling it is "worth it" for the keeper. This is not
     *  the only consideration into issuing this trigger, for example if the
     *  position would be negatively affected if `harvest()` is not called
     *  shortly, then this can return `true` even if the keeper might be "at a
     *  loss" (keepers are always reimbursed by Yearn).
     * @dev
     *  `callCost` must be priced in terms of `want`.
     *
     *  This call and `tendTrigger` should never return `true` at the
     *  same time.
     *
     *  See `min/maxReportDelay`, `profitFactor`, `debtThreshold` to adjust the
     *  strategist-controlled parameters that will influence whether this call
     *  returns `true` or not. These parameters will be used in conjunction
     *  with the parameters reported to the Vault (see `params`) to determine
     *  if calling `harvest()` is merited.
     *
     *  It is expected that an external system will check `harvestTrigger()`.
     *  This could be a script run off a desktop or cloud bot (e.g.
     *  https://github.com/iearn-finance/yearn-vaults/blob/master/scripts/keep.py),
     *  or via an integration with the Keep3r network (e.g.
     *  https://github.com/Macarse/GenericKeep3rV2/blob/master/contracts/keep3r/GenericKeep3rV2.sol).
     * @param callCost The keeper's estimated cast cost to call `harvest()`.
     * @return `true` if `harvest()` should be called, `false` otherwise.
     */
    function harvestTrigger(uint256 callCost) public virtual view returns (bool) {
        StrategyParams memory params = vault.strategies(address(this));

        // Should not trigger if Strategy is not activated
        if (params.activation == 0) return false;

        // Should not trigger if we haven't waited long enough since previous harvest
        if (block.timestamp.sub(params.lastReport) < minReportDelay) return false;

        // Should trigger if hasn't been called in a while
        if (block.timestamp.sub(params.lastReport) >= maxReportDelay) return true;

        // If some amount is owed, pay it back
        // NOTE: Since debt is based on deposits, it makes sense to guard against large
        //       changes to the value from triggering a harvest directly through user
        //       behavior. This should ensure reasonable resistance to manipulation
        //       from user-initiated withdrawals as the outstanding debt fluctuates.
        uint256 outstanding = vault.debtOutstanding();
        if (outstanding > debtThreshold) return true;

        // Check for profits and losses
        uint256 total = estimatedTotalAssets();
        // Trigger if we have a loss to report
        if (total.add(debtThreshold) < params.totalDebt) return true;

        uint256 profit = 0;
        if (total > params.totalDebt) profit = total.sub(params.totalDebt); // We've earned a profit!

        // Otherwise, only trigger if it "makes sense" economically (gas cost
        // is <N% of value moved)
        uint256 credit = vault.creditAvailable();
        return (profitFactor.mul(callCost) < credit.add(profit));
    }

    /**
     * @notice
     *  Harvests the Strategy, recognizing any profits or losses and adjusting
     *  the Strategy's position.
     *
     *  In the rare case the Strategy is in emergency shutdown, this will exit
     *  the Strategy's position.
     *
     *  This may only be called by governance, the strategist, or the keeper.
     * @dev
     *  When `harvest()` is called, the Strategy reports to the Vault (via
     *  `vault.report()`), so in some cases `harvest()` must be called in order
     *  to take in profits, to borrow newly available funds from the Vault, or
     *  otherwise adjust its position. In other cases `harvest()` must be
     *  called to report to the Vault on the Strategy's position, especially if
     *  any losses have occurred.
     */
    function harvest() external onlyKeepers {
        uint256 profit = 0;
        uint256 loss = 0;
        uint256 debtOutstanding = vault.debtOutstanding();
        uint256 debtPayment = 0;
        if (emergencyExit) {
            // Free up as much capital as possible
            uint256 totalAssets = estimatedTotalAssets();
            // NOTE: use the larger of total assets or debt outstanding to book losses properly
            (debtPayment, loss) = liquidatePosition(totalAssets > debtOutstanding ? totalAssets : debtOutstanding);
            // NOTE: take up any remainder here as profit
            if (debtPayment > debtOutstanding) {
                profit = debtPayment.sub(debtOutstanding);
                debtPayment = debtOutstanding;
            }
        } else {
            // Free up returns for Vault to pull
            (profit, loss, debtPayment) = prepareReturn(debtOutstanding);
        }

        // Allow Vault to take up to the "harvested" balance of this contract,
        // which is the amount it has earned since the last time it reported to
        // the Vault.
        debtOutstanding = vault.report(profit, loss, debtPayment);

        // Check if free returns are left, and re-invest them
        adjustPosition(debtOutstanding);

        emit Harvested(profit, loss, debtPayment, debtOutstanding);
    }

    /**
     * @notice
     *  Withdraws `_amountNeeded` to `vault`.
     *
     *  This may only be called by the Vault.
     * @param _amountNeeded How much `want` to withdraw.
     * @return _loss Any realized losses
     */
    function withdraw(uint256 _amountNeeded) external returns (uint256 _loss) {
        require(msg.sender == address(vault), "!vault");
        // Liquidate as much as possible to `want`, up to `_amountNeeded`
        uint256 amountFreed;
        (amountFreed, _loss) = liquidatePosition(_amountNeeded);
        // Send it directly back (NOTE: Using `msg.sender` saves some gas here)
        want.safeTransfer(msg.sender, amountFreed);
        // NOTE: Reinvest anything leftover on next `tend`/`harvest`
    }

    /**
     * Do anything necessary to prepare this Strategy for migration, such as
     * transferring any reserve or LP tokens, CDPs, or other tokens or stores of
     * value.
     */
    function prepareMigration(address _newStrategy) internal virtual;

    /**
     * @notice
     *  Transfers all `want` from this Strategy to `_newStrategy`.
     *
     *  This may only be called by governance or the Vault.
     * @dev
     *  The new Strategy's Vault must be the same as this Strategy's Vault.
     * @param _newStrategy The Strategy to migrate to.
     */
    function migrate(address _newStrategy) external {
        require(msg.sender == address(vault) || msg.sender == governance());
        require(BaseStrategy(_newStrategy).vault() == vault);
        prepareMigration(_newStrategy);
        want.safeTransfer(_newStrategy, want.balanceOf(address(this)));
    }

    /**
     * @notice
     *  Activates emergency exit. Once activated, the Strategy will exit its
     *  position upon the next harvest, depositing all funds into the Vault as
     *  quickly as is reasonable given on-chain conditions.
     *
     *  This may only be called by governance or the strategist.
     * @dev
     *  See `vault.setEmergencyShutdown()` and `harvest()` for further details.
     */
    function setEmergencyExit() external onlyAuthorized {
        emergencyExit = true;
        vault.revokeStrategy();

        emit EmergencyExitEnabled();
    }

    /**
     * Override this to add all tokens/tokenized positions this contract
     * manages on a *persistent* basis (e.g. not just for swapping back to
     * want ephemerally).
     *
     * NOTE: Do *not* include `want`, already included in `sweep` below.
     *
     * Example:
     *
     *    function protectedTokens() internal override view returns (address[] memory) {
     *      address[] memory protected = new address[](3);
     *      protected[0] = tokenA;
     *      protected[1] = tokenB;
     *      protected[2] = tokenC;
     *      return protected;
     *    }
     */
    function protectedTokens() internal virtual view returns (address[] memory);

    /**
     * @notice
     *  Removes tokens from this Strategy that are not the type of tokens
     *  managed by this Strategy. This may be used in case of accidentally
     *  sending the wrong kind of token to this Strategy.
     *
     *  Tokens will be sent to `governance()`.
     *
     *  This will fail if an attempt is made to sweep `want`, or any tokens
     *  that are protected by this Strategy.
     *
     *  This may only be called by governance.
     * @dev
     *  Implement `protectedTokens()` to specify any additional tokens that
     *  should be protected from sweeping in addition to `want`.
     * @param _token The token to transfer out of this vault.
     */
    function sweep(address _token) external onlyGovernance {
        require(_token != address(want), "!want");
        require(_token != address(vault), "!shares");

        address[] memory _protectedTokens = protectedTokens();
        for (uint256 i; i < _protectedTokens.length; i++) require(_token != _protectedTokens[i], "!protected");

        IERC20(_token).safeTransfer(governance(), IERC20(_token).balanceOf(address(this)));
    }
}

// Part: IAToken

interface IAToken is IERC20, IScaledBalanceToken, IInitializableAToken {
    /**
     * @dev Emitted after the mint action
     * @param from The address performing the mint
     * @param value The amount being
     * @param index The new liquidity index of the reserve
     **/
    event Mint(address indexed from, uint256 value, uint256 index);

    /**
     * @dev Mints `amount` aTokens to `user`
     * @param user The address receiving the minted tokens
     * @param amount The amount of tokens getting minted
     * @param index The new liquidity index of the reserve
     * @return `true` if the the previous balance of the user was 0
     */
    function mint(
        address user,
        uint256 amount,
        uint256 index
    ) external returns (bool);

    /**
     * @dev Emitted after aTokens are burned
     * @param from The owner of the aTokens, getting them burned
     * @param target The address that will receive the underlying
     * @param value The amount being burned
     * @param index The new liquidity index of the reserve
     **/
    event Burn(
        address indexed from,
        address indexed target,
        uint256 value,
        uint256 index
    );

    /**
     * @dev Emitted during the transfer action
     * @param from The user whose tokens are being transferred
     * @param to The recipient
     * @param value The amount being transferred
     * @param index The new liquidity index of the reserve
     **/
    event BalanceTransfer(
        address indexed from,
        address indexed to,
        uint256 value,
        uint256 index
    );

    /**
     * @dev Burns aTokens from `user` and sends the equivalent amount of underlying to `receiverOfUnderlying`
     * @param user The owner of the aTokens, getting them burned
     * @param receiverOfUnderlying The address that will receive the underlying
     * @param amount The amount being burned
     * @param index The new liquidity index of the reserve
     **/
    function burn(
        address user,
        address receiverOfUnderlying,
        uint256 amount,
        uint256 index
    ) external;

    /**
     * @dev Mints aTokens to the reserve treasury
     * @param amount The amount of tokens getting minted
     * @param index The new liquidity index of the reserve
     */
    function mintToTreasury(uint256 amount, uint256 index) external;

    /**
     * @dev Transfers aTokens in the event of a borrow being liquidated, in case the liquidators reclaims the aToken
     * @param from The address getting liquidated, current owner of the aTokens
     * @param to The recipient
     * @param value The amount of tokens getting transferred
     **/
    function transferOnLiquidation(
        address from,
        address to,
        uint256 value
    ) external;

    /**
     * @dev Transfers the underlying asset to `target`. Used by the LendingPool to transfer
     * assets in borrow(), withdraw() and flashLoan()
     * @param user The recipient of the underlying
     * @param amount The amount getting transferred
     * @return The amount transferred
     **/
    function transferUnderlyingTo(address user, uint256 amount)
        external
        returns (uint256);

    /**
     * @dev Invoked to execute actions on the aToken side after a repayment.
     * @param user The user executing the repayment
     * @param amount The amount getting repaid
     **/
    function handleRepayment(address user, uint256 amount) external;

    /**
     * @dev Returns the address of the incentives controller contract
     **/
    function getIncentivesController()
        external
        view
        returns (IAaveIncentivesController);

    /**
     * @dev Returns the address of the underlying asset of this aToken (E.g. WETH for aWETH)
     **/
    function UNDERLYING_ASSET_ADDRESS() external view returns (address);
}

// File: Strategy.sol

contract Strategy is BaseStrategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    using WadRayMath for uint256;

    bool internal isOriginal = true;
    // max interest rate we can afford to pay for borrowing investment token
    // amount in Ray (1e27 = 100%)
    uint256 public acceptableCostsRay = 1e27;

    // max amount to borrow. used to manually limit amount (for yVault to keep APY)
    uint256 public maxTotalBorrowIT;

    bool public isWantIncentivised;
    bool public isInvestmentTokenIncentivised;

    // if set to true, the strategy will not try to repay debt by selling want
    bool public leaveDebtBehind;

    // Aave's referral code
    uint16 internal referral;

    // NOTE: LTV = Loan-To-Value = debt/collateral

    // Target LTV: ratio up to which which we will borrow
    uint16 public targetLTVMultiplier = 6_000;

    // Warning LTV: ratio at which we will repay
    uint16 public warningLTVMultiplier = 8_000; // 80% of liquidation LTV

    // support
    uint16 internal constant MAX_BPS = 10_000; // 100%
    uint16 internal constant MAX_MULTIPLIER = 9_000; // 90%

    IAToken internal aToken;
    IVariableDebtToken internal variableDebtToken;
    IVault public yVault;
    IERC20 internal investmentToken;

    ISwap internal constant router =
        ISwap(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    IStakedAave internal constant stkAave =
        IStakedAave(0x4da27a545c0c5B758a6BA100e3a049001de870f5);

    IProtocolDataProvider internal constant protocolDataProvider =
        IProtocolDataProvider(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d);

    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant AAVE = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;

    uint256 internal minThreshold;
    uint256 public maxLoss;
    string internal strategyName;

    constructor(
        address _vault,
        address _yVault,
        bool _isWantIncentivised,
        bool _isInvestmentTokenIncentivised,
        string memory _strategyName
    ) public BaseStrategy(_vault) {
        _initializeThis(
            _yVault,
            _isWantIncentivised,
            _isInvestmentTokenIncentivised,
            _strategyName
        );
    }

    // ----------------- PUBLIC VIEW FUNCTIONS -----------------

    function name() external view override returns (string memory) {
        return strategyName;
    }

    function estimatedTotalAssets() public view override returns (uint256) {
        // not taking into account aave rewards (they are staked and not accesible)
        return
            balanceOfWant() // balance of want
                .add(balanceOfAToken()) // asset suplied as collateral
                .add(
                _fromETH(
                    _toETH(_valueOfInvestment(), address(investmentToken)),
                    address(want)
                )
            ) // current value of assets deposited in vault
                .sub(
                _fromETH(
                    _toETH(balanceOfDebt(), address(investmentToken)),
                    address(want)
                )
            ); // liabilities
    }

    // ----------------- SETTERS -----------------
    // we put all together to save contract bytecode (!)
    function setStrategyParams(
        uint16 _targetLTVMultiplier,
        uint16 _warningLTVMultiplier,
        uint256 _acceptableCostsRay,
        uint16 _aaveReferral,
        uint256 _maxTotalBorrowIT,
        bool _isWantIncentivised,
        bool _isInvestmentTokenIncentivised,
        bool _leaveDebtBehind,
        uint256 _maxLoss
    ) external onlyAuthorized {
        require(
            _warningLTVMultiplier <= MAX_MULTIPLIER &&
                _targetLTVMultiplier <= _warningLTVMultiplier
        );
        targetLTVMultiplier = _targetLTVMultiplier;
        warningLTVMultiplier = _warningLTVMultiplier;
        acceptableCostsRay = _acceptableCostsRay;
        maxTotalBorrowIT = _maxTotalBorrowIT;
        referral = _aaveReferral;
        isWantIncentivised = _isWantIncentivised;
        isInvestmentTokenIncentivised = _isInvestmentTokenIncentivised;
        leaveDebtBehind = _leaveDebtBehind;
        require(maxLoss <= 10_000);
        maxLoss = _maxLoss;
    }

    event Cloned(address indexed clone);

    function cloneAaveLenderBorrower(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _yVault,
        bool _isWantIncentivised,
        bool _isInvestmentTokenIncentivised,
        string memory _strategyName
    ) external returns (address newStrategy) {
        require(isOriginal);
        // Copied from https://github.com/optionality/clone-factory/blob/master/contracts/CloneFactory.sol
        bytes20 addressBytes = bytes20(address(this));
        assembly {
            // EIP-1167 bytecode
            let clone_code := mload(0x40)
            mstore(
                clone_code,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone_code, 0x14), addressBytes)
            mstore(
                add(clone_code, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            newStrategy := create(0, clone_code, 0x37)
        }

        Strategy(newStrategy).initialize(
            _vault,
            _strategist,
            _rewards,
            _keeper,
            _yVault,
            _isWantIncentivised,
            _isInvestmentTokenIncentivised,
            _strategyName
        );

        emit Cloned(newStrategy);
    }

    function _initializeThis(
        address _yVault,
        bool _isWantIncentivised,
        bool _isInvestmentTokenIncentivised,
        string memory _strategyName
    ) internal {
        minReportDelay = 24 * 3600;
        maxReportDelay = 10 * 24 * 3600;
        profitFactor = 100;
        // debtThreshold = 0; It's 0 by default.

        yVault = IVault(_yVault);
        investmentToken = IERC20(IVault(_yVault).token());

        (address _aToken, , ) =
            protocolDataProvider.getReserveTokensAddresses(address(want));
        aToken = IAToken(_aToken);

        (, , address _variableDebtToken) =
            protocolDataProvider.getReserveTokensAddresses(
                address(investmentToken)
            );

        variableDebtToken = IVariableDebtToken(_variableDebtToken);
        minThreshold = (10**(yVault.decimals())).div(100); // 0.01 minThreshold
        isWantIncentivised = _isWantIncentivised;
        isInvestmentTokenIncentivised = _isInvestmentTokenIncentivised;

        maxTotalBorrowIT = type(uint256).max; // set to max to avoid limits. this may trigger revert in some parts if not correctly handled

        maxLoss = 1;
        strategyName = _strategyName;
    }

    function initialize(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _yVault,
        bool _isWantIncentivised,
        bool _isInvestmentTokenIncentivised,
        string memory _strategyName
    ) public {
        _initialize(_vault, _strategist, _rewards, _keeper);
        require(address(yVault) == address(0));
        _initializeThis(
            _yVault,
            _isWantIncentivised,
            _isInvestmentTokenIncentivised,
            _strategyName
        );
    }

    // ----------------- MAIN STRATEGY FUNCTIONS -----------------
    function prepareReturn(uint256 _debtOutstanding)
        internal
        override
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        )
    {
        uint256 balanceInit = balanceOfWant();
        // claim rewards from Aave's Liquidity Mining Program
        _claimRewards();

        // claim rewards from yVault
        _takeVaultProfit();

        // claim interest from lending
        _takeLendingProfit();

        uint256 balanceOfWant = balanceOfWant();

        if (balanceOfWant > balanceInit) {
            _profit = balanceOfWant.sub(balanceInit);
        }

        // if the vault is claiming repayment of debt
        if (_debtOutstanding > 0) {
            uint256 _amountFreed = 0;
            (_amountFreed, _loss) = liquidatePosition(_debtOutstanding);
            _debtPayment = Math.min(_debtOutstanding, _amountFreed);
            if (_loss > 0) {
                _profit = 0;
            }
        }
    }

    function adjustPosition(uint256 _debtOutstanding) internal override {
        uint256 wantBalance = balanceOfWant();

        // if we have enough want to deposit more into Aave, we do
        // NOTE: we do not skip the rest of the function if we don't as it may need to repay or take on more debt
        if (wantBalance > _debtOutstanding) {
            uint256 amountToDeposit = wantBalance.sub(_debtOutstanding);
            _depositToAave(amountToDeposit);
        }

        // NOTE: debt + collateral calcs are done in ETH
        (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            ,

        ) = _getAaveUserAccountData();

        // if there is no want deposited into aave, don't do nothing
        // this means no debt is borrowed from aave too
        if (totalCollateralETH == 0) {
            return;
        }

        uint256 currentLTV = totalDebtETH.mul(MAX_BPS).div(totalCollateralETH);
        uint256 targetLTV = _getTargetLTV(currentLiquidationThreshold); // 60% under liquidation Threshold
        uint256 warningLTV = _getWarningLTV(currentLiquidationThreshold); // 80% under liquidation Threshold

        // decide in which range we are and act accordingly:
        // SUBOPTIMAL(borrow) (e.g. from 0 to 60% liqLTV)
        // HEALTHY(do nothing) (e.g. from 60% to 80% liqLTV)
        // UNHEALTHY(repay) (e.g. from 80% to 100% liqLTV)

        // we use our target cost of capital to calculate how much debt we can take on / how much debt we need to repay
        // in order to bring costs back to an acceptable range
        // currentProtocolDebt => total amount of debt taken by all Aave's borrowers
        // maxProtocolDebt => amount of total debt at which the cost of capital is equal to our acceptable costs
        // if the current protocol debt is higher than the max protocol debt, we will repay debt
        (uint256 currentProtocolDebt, uint256 maxProtocolDebt) =
            _calculateMaxDebt();

        if (targetLTV > currentLTV && currentProtocolDebt < maxProtocolDebt) {
            // SUBOPTIMAL RATIO: our current Loan-to-Value is lower than what we want
            // AND costs are lower than our max acceptable costs

            // we need to take on more debt
            uint256 targetDebtETH =
                totalCollateralETH.mul(targetLTV).div(MAX_BPS);

            uint256 amountToBorrowETH = targetDebtETH.sub(totalDebtETH); // safe bc we checked ratios
            amountToBorrowETH = Math.min(
                availableBorrowsETH,
                amountToBorrowETH
            );

            // cap the amount of debt we are taking according to our acceptable costs
            // if with the new loan we are increasing our cost of capital over what is healthy
            if (currentProtocolDebt.add(amountToBorrowETH) > maxProtocolDebt) {
                // Can't underflow because it's checked in the previous if condition
                amountToBorrowETH = maxProtocolDebt.sub(currentProtocolDebt);
            }

            uint256 maxTotalBorrowETH =
                _toETH(maxTotalBorrowIT, address(investmentToken));
            if (totalDebtETH.add(amountToBorrowETH) > maxTotalBorrowETH) {
                amountToBorrowETH = maxTotalBorrowETH > totalDebtETH
                    ? maxTotalBorrowETH.sub(totalDebtETH)
                    : 0;
            }

            // convert to InvestmentToken
            uint256 amountToBorrowIT =
                _fromETH(amountToBorrowETH, address(investmentToken));

            if (amountToBorrowIT > 0) {
                _lendingPool().borrow(
                    address(investmentToken),
                    amountToBorrowIT,
                    2,
                    referral,
                    address(this)
                );
            }

            _depositInYVault();
        } else if (
            currentLTV > warningLTV || currentProtocolDebt > maxProtocolDebt
        ) {
            // UNHEALTHY RATIO
            // we may be in this case if the current cost of capital is higher than our max cost of capital
            // we repay debt to set it to targetLTV
            uint256 targetDebtETH =
                targetLTV.mul(totalCollateralETH).div(MAX_BPS);
            uint256 amountToRepayETH =
                targetDebtETH < totalDebtETH
                    ? totalDebtETH.sub(targetDebtETH)
                    : 0;

            if (maxProtocolDebt == 0) {
                amountToRepayETH = totalDebtETH;
            } else if (currentProtocolDebt > maxProtocolDebt) {
                amountToRepayETH = Math.max(
                    amountToRepayETH,
                    currentProtocolDebt.sub(maxProtocolDebt)
                );
            }

            uint256 amountToRepayIT =
                _fromETH(amountToRepayETH, address(investmentToken));
            uint256 withdrawnIT = _withdrawFromYVault(amountToRepayIT); // we withdraw from investmentToken vault
            _repayInvestmentTokenDebt(withdrawnIT); // we repay the investmentToken debt with Aave
        }
    }

    function liquidatePosition(uint256 _amountNeeded)
        internal
        override
        returns (uint256 _liquidatedAmount, uint256 _loss)
    {
        uint256 balance = balanceOfWant();
        // if we have enough want to take care of the liquidatePosition without actually liquidating positons
        if (balance >= _amountNeeded) {
            return (_amountNeeded, 0);
        }

        // NOTE: amountNeeded is in want
        // NOTE: repayment amount is in investmentToken
        // NOTE: collateral and debt calcs are done in ETH (always, see Aave docs)

        // We first repay whatever we need to repay to keep healthy ratios
        uint256 amountToRepayIT = _calculateAmountToRepay(_amountNeeded);
        uint256 withdrawnIT = _withdrawFromYVault(amountToRepayIT); // we withdraw from investmentToken vault
        _repayInvestmentTokenDebt(withdrawnIT); // we repay the investmentToken debt with Aave

        // it will return the free amount of want
        _withdrawWantFromAave(_amountNeeded);

        balance = balanceOfWant();
        // we check if we withdrew less than expected AND should buy investmentToken with want (realising losses)
        if (
            _amountNeeded > balance &&
            balanceOfDebt() > 0 && // still some debt remaining
            balanceOfInvestmentToken().add(_valueOfInvestment()) == 0 && // but no capital to repay
            !leaveDebtBehind // if set to true, the strategy will not try to repay debt by selling want
        ) {
            // using this part of code will result in losses but it is necessary to unlock full collateral in case of wind down
            // we calculate how much want we need to fulfill the want request
            uint256 remainingAmountWant = _amountNeeded.sub(balance);
            // then calculate how much InvestmentToken we need to unlock collateral
            amountToRepayIT = _calculateAmountToRepay(remainingAmountWant);

            // we buy investmentToken with Want
            _buyInvestmentTokenWithWant(amountToRepayIT);

            // we repay debt to actually unlock collateral
            // after this, balanceOfDebt should be 0
            _repayInvestmentTokenDebt(amountToRepayIT);

            // then we try withdraw once more
            _withdrawWantFromAave(remainingAmountWant);
        }

        uint256 totalAssets = balanceOfWant();
        if (_amountNeeded > totalAssets) {
            _liquidatedAmount = totalAssets;
            _loss = _amountNeeded.sub(totalAssets);
        } else {
            _liquidatedAmount = _amountNeeded;
        }
    }

    function delegatedAssets() external view override returns (uint256) {
        // returns total debt borrowed in want (which is the delegatedAssets)
        return
            _fromETH(
                _toETH(balanceOfDebt(), address(investmentToken)),
                address(want)
            );
    }

    function prepareMigration(address _newStrategy) internal override {
        // nothing to do since debt cannot be migrated
    }

    function harvestTrigger(uint256 callCost)
        public
        view
        override
        returns (bool)
    {
        // we harvest if:
        // 1. stakedAave is ready to be converted to Aave and sold

        return
            _checkCooldown() ||
            super.harvestTrigger(_fromETH(callCost, address(want)));
    }

    function tendTrigger(uint256 callCost) public view override returns (bool) {
        // we adjust position if:
        // 1. LTV ratios are not in the HEALTHY range (either we take on more debt or repay debt)
        // 2. costs are not acceptable and we need to repay debt

        (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            ,
            uint256 currentLiquidationThreshold,
            ,

        ) = _getAaveUserAccountData();

        uint256 currentLTV = totalDebtETH.mul(MAX_BPS).div(totalCollateralETH);
        uint256 targetLTV = _getTargetLTV(currentLiquidationThreshold);
        uint256 warningLTV = _getWarningLTV(currentLiquidationThreshold);
        (uint256 currentProtocolDebt, uint256 maxProtocolDebt) =
            _calculateMaxDebt();

        if (
            (currentLTV < targetLTV &&
                currentProtocolDebt < maxProtocolDebt &&
                targetLTV.sub(currentLTV) > 100) || // WE NEED TO TAKE ON MORE DEBT
            (currentLTV > warningLTV || currentProtocolDebt > maxProtocolDebt) // WE NEED TO REPAY DEBT BECAUSE OF UNHEALTHY RATIO OR BORROWING COSTS
        ) {
            return true;
        }

        // no call to super.tendTrigger as it would return false
        return false;
    }

    // ----------------- INTERNAL FUNCTIONS SUPPORT -----------------

    function _withdrawFromYVault(uint256 _amountIT) internal returns (uint256) {
        if (_amountIT == 0) {
            return 0;
        }
        // no need to check allowance bc the contract == token
        uint256 balancePrior = balanceOfInvestmentToken();
        uint256 sharesToWithdraw =
            Math.min(
                _investmentTokenToYShares(_amountIT),
                yVault.balanceOf(address(this))
            );
        yVault.withdraw(sharesToWithdraw, address(this), maxLoss);
        return balanceOfInvestmentToken().sub(balancePrior);
    }

    function _repayInvestmentTokenDebt(uint256 amount) internal {
        if (amount == 0) {
            return;
        }

        // we cannot pay more than loose balance
        uint256 balance = balanceOfInvestmentToken();
        amount = Math.min(amount, balance);
        // we cannot pay more than we owe
        amount = Math.min(balanceOfDebt(), amount);

        _checkAllowance(
            address(_lendingPool()),
            address(investmentToken),
            amount
        );

        if (amount > 0) {
            _lendingPool().repay(
                address(investmentToken),
                amount,
                uint256(2),
                address(this)
            );
        }
    }

    function _depositInYVault() internal {
        uint256 balanceIT = balanceOfInvestmentToken();
        if (balanceIT > 0) {
            _checkAllowance(
                address(yVault),
                address(investmentToken),
                balanceIT
            );
            yVault.deposit();
        }
    }

    function _claimRewards() internal {
        if (isInvestmentTokenIncentivised || isWantIncentivised) {
            // redeem AAVE from stkAave
            uint256 stkAaveBalance =
                IERC20(address(stkAave)).balanceOf(address(this));
            if (stkAaveBalance > 0 && _checkCooldown()) {
                stkAave.redeem(address(this), stkAaveBalance);
            }

            // claim AAVE rewards
            stkAave.claimRewards(address(this), type(uint256).max);

            // sell AAVE for want
            // a minimum balance of 0.01 AAVE is required
            uint256 aaveBalance = IERC20(AAVE).balanceOf(address(this));
            if (aaveBalance > 1e15) {
                _sellAAVEForWant(aaveBalance);
            }

            // claim rewards
            // only add to assets those assets that are incentivised
            address[] memory assets;
            if (isInvestmentTokenIncentivised && isWantIncentivised) {
                assets = new address[](2);
                assets[0] = address(aToken);
                assets[1] = address(variableDebtToken);
            } else if (isInvestmentTokenIncentivised) {
                assets = new address[](1);
                assets[0] = address(variableDebtToken);
            } else if (isWantIncentivised) {
                assets = new address[](1);
                assets[0] = address(aToken);
            }

            _incentivesController().claimRewards(
                assets,
                type(uint256).max,
                address(this)
            );

            // request start of cooldown period
            if (IERC20(address(stkAave)).balanceOf(address(this)) > 0) {
                stkAave.cooldown();
            }
        }
    }

    function _takeLendingProfit() internal {
        uint256 depositedWant = vault.strategies(address(this)).totalDebt;
        uint256 currentWantInAave = balanceOfAToken();

        if (currentWantInAave > depositedWant) {
            uint256 toWithdraw = currentWantInAave.sub(depositedWant);
            _withdrawWantFromAave(toWithdraw);
        }
    }

    //withdraw an amount including any want balance
    function _withdrawWantFromAave(uint256 amount) internal {
        uint256 balanceUnderlying = balanceOfAToken();
        if (amount > balanceUnderlying) {
            amount = balanceUnderlying;
        }

        uint256 maxWithdrawal =
            Math.min(_maxWithdrawal(), want.balanceOf(address(aToken)));

        uint256 toWithdraw = Math.min(amount, maxWithdrawal);
        if (toWithdraw > 0) {
            _checkAllowance(
                address(_lendingPool()),
                address(aToken),
                toWithdraw
            );
            _lendingPool().withdraw(address(want), toWithdraw, address(this));
        }
    }

    function _maxWithdrawal() internal view returns (uint256) {
        (uint256 totalCollateralETH, uint256 totalDebtETH, , , uint256 ltv, ) =
            _getAaveUserAccountData();
        uint256 minCollateralETH =
            ltv > 0 ? totalDebtETH.mul(MAX_BPS).div(ltv) : totalCollateralETH;
        if (minCollateralETH > totalCollateralETH) {
            return 0;
        }
        return
            _fromETH(totalCollateralETH.sub(minCollateralETH), address(want));
    }

    function _calculateAmountToRepay(uint256 amount)
        internal
        view
        returns (uint256)
    {
        if (amount == 0) {
            return 0;
        }

        // we check if the collateral that we are withdrawing leaves us in a risky range, we then take action
        (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            ,
            uint256 currentLiquidationThreshold,
            ,

        ) = _getAaveUserAccountData();

        uint256 amountToWithdrawETH = _toETH(amount, address(want));
        // calculate the collateral that we are leaving after withdrawing
        uint256 newCollateral =
            totalCollateralETH > amountToWithdrawETH
                ? totalCollateralETH.sub(amountToWithdrawETH)
                : 0;

        uint256 ltvAfterWithdrawal =
            newCollateral > 0
                ? totalDebtETH.mul(MAX_BPS).div(newCollateral)
                : type(uint256).max;

        // check if the new LTV is in UNHEALTHY range
        // remember that if balance > _amountNeeded, ltvAfterWithdrawal == 0 (0 risk)
        // this is not true but the effect will be the same
        uint256 warningLTV = _getWarningLTV(currentLiquidationThreshold);

        if (ltvAfterWithdrawal <= warningLTV) {
            // no need of repaying debt because the LTV is ok
            return 0;
        } else if (ltvAfterWithdrawal == type(uint256).max) {
            // we are withdrawing 100% of collateral so we need to repay full debt
            return _fromETH(totalDebtETH, address(investmentToken));
        }

        uint256 targetLTV = _getTargetLTV(currentLiquidationThreshold);
        // WARNING: this only works for a single collateral asset, otherwise liquidationThreshold might change depending on the collateral being withdrawn
        // e.g. we have USDC + WBTC as collateral, end liquidationThreshold will be different depending on which asset we withdraw
        uint256 newTargetDebt = targetLTV.mul(newCollateral).div(MAX_BPS);

        // if newTargetDebt is higher, we don't need to repay anything
        if (newTargetDebt > totalDebtETH) {
            return 0;
        }

        return
            _fromETH(
                totalDebtETH.sub(newTargetDebt) < minThreshold
                    ? totalDebtETH
                    : totalDebtETH.sub(newTargetDebt),
                address(investmentToken)
            );
    }

    function _depositToAave(uint256 amount) internal {
        if (amount == 0) {
            return;
        }

        ILendingPool lp = _lendingPool();
        _checkAllowance(address(lp), address(want), amount);
        lp.deposit(address(want), amount, address(this), referral);
    }

    function _checkCooldown() internal view returns (bool) {
        if (!isWantIncentivised && !isInvestmentTokenIncentivised) {
            return false;
        }

        uint256 cooldownStartTimestamp =
            IStakedAave(stkAave).stakersCooldowns(address(this));
        uint256 COOLDOWN_SECONDS = IStakedAave(stkAave).COOLDOWN_SECONDS();
        uint256 UNSTAKE_WINDOW = IStakedAave(stkAave).UNSTAKE_WINDOW();
        if (block.timestamp >= cooldownStartTimestamp.add(COOLDOWN_SECONDS)) {
            return
                block.timestamp.sub(
                    cooldownStartTimestamp.add(COOLDOWN_SECONDS)
                ) <=
                UNSTAKE_WINDOW ||
                cooldownStartTimestamp == 0;
        }

        return false;
    }

    function _checkAllowance(
        address _contract,
        address _token,
        uint256 _amount
    ) internal {
        if (IERC20(_token).allowance(address(this), _contract) < _amount) {
            IERC20(_token).safeApprove(_contract, 0);
            IERC20(_token).safeApprove(_contract, type(uint256).max);
        }
    }

    function _takeVaultProfit() internal {
        uint256 _debt = balanceOfDebt();
        uint256 _valueInVault = _valueOfInvestment();
        if (_debt >= _valueInVault) {
            return;
        }

        uint256 profit = _valueInVault.sub(_debt);
        uint256 ySharesToWithdraw = _investmentTokenToYShares(profit);
        if (ySharesToWithdraw > 0) {
            yVault.withdraw(ySharesToWithdraw, address(this), maxLoss);
            _sellInvestmentForWant(balanceOfInvestmentToken());
        }
    }

    // ----------------- INTERNAL CALCS -----------------
    function _calculateMaxDebt()
        internal
        view
        returns (uint256 currentProtocolDebt, uint256 maxProtocolDebt)
    {
        // This function is used to calculate the maximum amount of debt that the protocol can take
        // to keep the cost of capital lower than the set acceptableCosts
        // This maxProtocolDebt will be used to decide if capital costs are acceptable or not
        // and to repay required debt to keep the rates below acceptable costs

        // Hack to avoid the stack too deep compiler error.
        SupportStructs.CalcMaxDebtLocalVars memory vars;
        DataTypes.ReserveData memory reserveData =
            _lendingPool().getReserveData(address(investmentToken));
        IReserveInterestRateStrategy irs =
            IReserveInterestRateStrategy(
                reserveData.interestRateStrategyAddress
            );

        (
            vars.availableLiquidity, // = total supply - total stable debt - total variable debt
            vars.totalStableDebt, // total debt paying stable interest rates
            vars.totalVariableDebt, // total debt paying stable variable rates
            ,
            ,
            ,
            ,
            ,
            ,

        ) = protocolDataProvider.getReserveData(address(investmentToken));

        vars.totalDebt = vars.totalStableDebt.add(vars.totalVariableDebt);
        vars.totalLiquidity = vars.availableLiquidity.add(vars.totalDebt);
        vars.utilizationRate = vars.totalDebt == 0
            ? 0
            : vars.totalDebt.rayDiv(vars.totalLiquidity);

        // Aave's Interest Rate Strategy Parameters (see docs)
        SupportStructs.IrsVars memory irsVars;
        irsVars.optimalRate = irs.OPTIMAL_UTILIZATION_RATE();
        irsVars.baseRate = irs.baseVariableBorrowRate(); // minimum cost of capital with 0 % of utilisation rate
        irsVars.slope1 = irs.variableRateSlope1(); // rate of increase of cost of debt up to Optimal Utilisation Rate
        irsVars.slope2 = irs.variableRateSlope2(); // rate of increase of cost of debt above Optimal Utilisation Rate

        // acceptableCosts should always be > baseVariableBorrowRate
        // If it's not this will revert since the strategist set the wrong
        // acceptableCosts value
        if (
            vars.utilizationRate < irsVars.optimalRate &&
            acceptableCostsRay < irsVars.baseRate.add(irsVars.slope1)
        ) {
            // we solve Aave's Interest Rates equation for sub optimal utilisation rates
            // IR = BASERATE + SLOPE1 * CURRENT_UTIL_RATE / OPTIMAL_UTIL_RATE
            vars.targetUtilizationRate = (
                acceptableCostsRay.sub(irsVars.baseRate)
            )
                .rayMul(irsVars.optimalRate)
                .rayDiv(irsVars.slope1);
        } else {
            // Special case where protocol is above utilization rate but we want
            // a lower interest rate than (base + slope1)
            if (acceptableCostsRay < irsVars.baseRate.add(irsVars.slope1)) {
                return (_toETH(vars.totalDebt, address(investmentToken)), 0);
            }

            // we solve Aave's Interest Rates equation for utilisation rates above optimal U
            // IR = BASERATE + SLOPE1 + SLOPE2 * (CURRENT_UTIL_RATE - OPTIMAL_UTIL_RATE) / (1-OPTIMAL_UTIL_RATE)
            vars.targetUtilizationRate = (
                acceptableCostsRay.sub(irsVars.baseRate.add(irsVars.slope1))
            )
                .rayMul(uint256(1e27).sub(irsVars.optimalRate))
                .rayDiv(irsVars.slope2)
                .add(irsVars.optimalRate);
        }

        vars.maxProtocolDebt = vars
            .totalLiquidity
            .rayMul(vars.targetUtilizationRate)
            .rayDiv(1e27);

        return (
            _toETH(vars.totalDebt, address(investmentToken)),
            _toETH(vars.maxProtocolDebt, address(investmentToken))
        );
    }

    function balanceOfWant() internal view returns (uint256) {
        return want.balanceOf(address(this));
    }

    function balanceOfInvestmentToken() internal view returns (uint256) {
        return investmentToken.balanceOf(address(this));
    }

    function balanceOfAToken() internal view returns (uint256) {
        return aToken.balanceOf(address(this));
    }

    function balanceOfDebt() internal view returns (uint256) {
        return variableDebtToken.balanceOf(address(this));
    }

    function _valueOfInvestment() internal view returns (uint256) {
        return
            yVault.balanceOf(address(this)).mul(yVault.pricePerShare()).div(
                10**yVault.decimals()
            );
    }

    function _investmentTokenToYShares(uint256 amount)
        internal
        view
        returns (uint256)
    {
        return amount.mul(10**yVault.decimals()).div(yVault.pricePerShare());
    }

    function _getAaveUserAccountData()
        internal
        view
        returns (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        )
    {
        return _lendingPool().getUserAccountData(address(this));
    }

    function _getTargetLTV(uint256 liquidationThreshold)
        internal
        view
        returns (uint256)
    {
        return
            liquidationThreshold.mul(uint256(targetLTVMultiplier)).div(MAX_BPS);
    }

    function _getWarningLTV(uint256 liquidationThreshold)
        internal
        view
        returns (uint256)
    {
        return
            liquidationThreshold.mul(uint256(warningLTVMultiplier)).div(
                MAX_BPS
            );
    }

    // ----------------- TOKEN CONVERSIONS -----------------
    function getTokenOutPath(address _token_in, address _token_out)
        internal
        pure
        returns (address[] memory _path)
    {
        bool is_weth =
            _token_in == address(WETH) || _token_out == address(WETH);
        _path = new address[](is_weth ? 2 : 3);
        _path[0] = _token_in;

        if (is_weth) {
            _path[1] = _token_out;
        } else {
            _path[1] = address(WETH);
            _path[2] = _token_out;
        }
    }

    function _sellAAVEForWant(uint256 _amount) internal {
        if (_amount == 0) {
            return;
        }

        _checkAllowance(address(router), address(AAVE), _amount);
        router.swapExactTokensForTokens(
            _amount,
            0,
            getTokenOutPath(address(AAVE), address(want)),
            address(this),
            now
        );
    }

    function _sellInvestmentForWant(uint256 _amount) internal {
        if (_amount == 0) {
            return;
        }

        // NOTE: 1:1
        if (address(want) == address(investmentToken)) {
            return;
        }

        _checkAllowance(address(router), address(investmentToken), _amount);
        router.swapExactTokensForTokens(
            _amount,
            0,
            getTokenOutPath(address(investmentToken), address(want)),
            address(this),
            now
        );
    }

    function _buyInvestmentTokenWithWant(uint256 _amount) internal {
        if (_amount == 0) {
            return;
        }

        if (address(investmentToken) == address(want)) {
            return;
        }

        _checkAllowance(address(router), address(want), _amount);
        router.swapTokensForExactTokens(
            _amount,
            type(uint256).max,
            getTokenOutPath(address(want), address(investmentToken)),
            address(this),
            now
        );
    }

    function _toETH(uint256 _amount, address asset)
        internal
        view
        returns (uint256)
    {
        if (
            _amount == 0 ||
            _amount == type(uint256).max ||
            address(asset) == address(WETH) // 1:1 change
        ) {
            return _amount;
        }

        return
            _amount.mul(_priceOracle().getAssetPrice(asset)).div(
                uint256(10)**uint256(IOptionalERC20(asset).decimals())
            );
    }

    function _fromETH(uint256 _amount, address asset)
        internal
        view
        returns (uint256)
    {
        if (
            _amount == 0 ||
            _amount == type(uint256).max ||
            address(asset) == address(WETH) // 1:1 change
        ) {
            return _amount;
        }

        return
            _amount
                .mul(uint256(10)**uint256(IOptionalERC20(asset).decimals()))
                .div(_priceOracle().getAssetPrice(asset));
    }

    // ----------------- INTERNAL SUPPORT GETTERS -----------------

    function _lendingPool() internal view returns (ILendingPool lendingPool) {
        lendingPool = ILendingPool(
            protocolDataProvider.ADDRESSES_PROVIDER().getLendingPool()
        );
    }

    function _priceOracle() internal view returns (IPriceOracle) {
        return
            IPriceOracle(
                protocolDataProvider.ADDRESSES_PROVIDER().getPriceOracle()
            );
    }

    function _incentivesController()
        internal
        view
        returns (IAaveIncentivesController)
    {
        if (isWantIncentivised) {
            return aToken.getIncentivesController();
        } else if (isInvestmentTokenIncentivised) {
            return variableDebtToken.getIncentivesController();
        } else {
            return IAaveIncentivesController(0);
        }
    }

    function protectedTokens()
        internal
        view
        override
        returns (address[] memory)
    {}
}