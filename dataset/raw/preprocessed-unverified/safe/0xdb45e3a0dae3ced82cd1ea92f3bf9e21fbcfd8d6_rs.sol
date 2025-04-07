/**
 *Submitted for verification at Etherscan.io on 2021-06-07
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

// Part: IAddressResolver

// https://docs.synthetix.io/contracts/source/interfaces/iaddressresolver


// Part: ICurveFi



// Part: IERC20Extended



// Part: IExchangeRates

// https://docs.synthetix.io/contracts/source/interfaces/iexchangerates


// Part: IReadProxy



// Part: ISynth

// https://docs.synthetix.io/contracts/source/interfaces/isynth


// Part: ISynthetix

// https://docs.synthetix.io/contracts/source/interfaces/isynthetix


// Part: IUni



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


// Part: iearn-finance/[email protected]/HealthCheck



// Part: ICrvV3

interface ICrvV3 is IERC20 {
    function minter() external view returns (address);

}

// Part: IVaultV2

interface IVaultV2 is IERC20 {
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

    function addStrategy(
        address,
        uint256,
        uint256,
        uint256,
        uint256
    ) external;

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

    function deposit(uint256 amount, address recipient)
        external
        returns (uint256);

    // NOTE: Vyper produces multiple signatures for a given function with "default" args
    function withdraw() external returns (uint256);

    function withdraw(uint256 maxShares) external returns (uint256);

    function withdraw(
        uint256 maxShares,
        address receiver,
        uint256 maxloss
    ) external returns (uint256);

    function setManagementFee(uint256) external;

    function updateStrategyDebtRatio(address, uint256) external;

    function withdraw(uint256 maxShares, address recipient)
        external
        returns (uint256);

    function withdrawalQueue(uint256) external view returns (address);

    function token() external view returns (address);

    function pricePerShare() external view returns (uint256);

    function totalAssets() external view returns (uint256);

    function depositLimit() external view returns (uint256);

    function maxAvailableShares() external view returns (uint256);

    function strategies(address _strategy)
        external
        view
        returns (StrategyParams memory);

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

    function setDepositLimit(uint256) external;
}

// Part: IVirtualSynth



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

// Part: IExchanger

// https://docs.synthetix.io/contracts/source/interfaces/iexchanger


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

    // health checks
    bool public doHealthCheck;
    address public healthCheck;

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

    modifier onlyVaultManagers() {
        require(
            msg.sender == vault.management() || msg.sender == governance(),
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

    function setHealthCheck(address _healthCheck) external onlyVaultManagers {
        healthCheck = _healthCheck;
    }

    function setDoHealthCheck(bool _doHealthCheck) external onlyVaultManagers {
        doHealthCheck = _doHealthCheck;
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
        uint256 totalDebt = vault.strategies(address(this)).totalDebt;
        debtOutstanding = vault.report(profit, loss, debtPayment);

        // Check if free returns are left, and re-invest them
        adjustPosition(debtOutstanding);

        // call healthCheck contract
        if (doHealthCheck && healthCheck != address(0)) {
            require(
                HealthCheck(healthCheck).check(
                    profit,
                    loss,
                    debtPayment,
                    debtOutstanding,
                    totalDebt
                ),
                "!healthcheck"
            );
        } else {
            doHealthCheck = true;
        }

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

// Part: Synthetix

contract Synthetix {
    using SafeMath for uint256;

    // ========== SYNTHETIX CONFIGURATION ==========
    bytes32 public constant sUSD = "sUSD";
    bytes32 public synthCurrencyKey;

    bytes32 internal constant TRACKING_CODE = "YEARN";

    // ========== ADDRESS RESOLVER CONFIGURATION ==========
    bytes32 private constant CONTRACT_SYNTHETIX = "Synthetix";
    bytes32 private constant CONTRACT_EXCHANGER = "Exchanger";
    bytes32 private constant CONTRACT_EXCHANGERATES = "ExchangeRates";
    bytes32 private constant CONTRACT_SYNTHSUSD = "ProxyERC20sUSD";
    bytes32 private contractSynth;

    IReadProxy public constant readProxy =
        IReadProxy(0x4E3b31eB0E5CB73641EE1E65E7dCEFe520bA3ef2);

    function _initializeSynthetix(bytes32 _synth) internal {
        // sETH / sBTC / sEUR / sLINK
        contractSynth = _synth;
        synthCurrencyKey = ISynth(
            IReadProxy(address(resolver().getAddress(_synth))).target()
        ).currencyKey();
    }

    function _balanceOfSynth() internal view returns (uint256) {
        return IERC20(address(_synthCoin())).balanceOf(address(this));
    }

    function _balanceOfSUSD() internal view returns (uint256) {
        return IERC20(address(_synthsUSD())).balanceOf(address(this));
    }

    function _synthToSUSD(uint256 _amountToSend)
        internal
        view
        returns (uint256 amountReceived)
    {
        if (_amountToSend == 0 || _amountToSend == type(uint256).max) {
            return _amountToSend;
        }
        (amountReceived, , ) = _exchanger().getAmountsForExchange(
            _amountToSend,
            synthCurrencyKey,
            sUSD
        );
    }

    function _sUSDToSynth(uint256 _amountToSend)
        internal
        view
        returns (uint256 amountReceived)
    {
        if (_amountToSend == 0 || _amountToSend == type(uint256).max) {
            return _amountToSend;
        }
        (amountReceived, , ) = _exchanger().getAmountsForExchange(
            _amountToSend,
            sUSD,
            synthCurrencyKey
        );
    }

    function _sUSDFromSynth(uint256 _amountToReceive)
        internal
        view
        returns (uint256 amountToSend)
    {
        if (_amountToReceive == 0 || _amountToReceive == type(uint256).max) {
            return _amountToReceive;
        }
        // NOTE: the fee of the trade that would be done (sUSD => synth) in this case
        uint256 feeRate = _exchanger().feeRateForExchange(
            sUSD,
            synthCurrencyKey
        ); // in base 1e18
        // formula => amountToReceive (Synth) * price (sUSD/Synth) / (1 - feeRate)
        return
            _exchangeRates()
                .effectiveValue(synthCurrencyKey, _amountToReceive, sUSD)
                .mul(1e18)
                .div(uint256(1e18).sub(feeRate));
    }

    function _synthFromSUSD(uint256 _amountToReceive)
        internal
        view
        returns (uint256 amountToSend)
    {
        if (_amountToReceive == 0 || _amountToReceive == type(uint256).max) {
            return _amountToReceive;
        }
        // NOTE: the fee of the trade that would be done (synth => sUSD) in this case
        uint256 feeRate = _exchanger().feeRateForExchange(
            synthCurrencyKey,
            sUSD
        ); // in base 1e18
        // formula => amountToReceive (sUSD) * price (Synth/sUSD) / (1 - feeRate)
        return
            _exchangeRates()
                .effectiveValue(sUSD, _amountToReceive, synthCurrencyKey)
                .mul(1e18)
                .div(uint256(1e18).sub(feeRate));
    }

    function exchangeSynthToSUSD() internal returns (uint256) {
        // swap full balance synth to sUSD
        uint256 synthBalance = _balanceOfSynth();

        if (synthBalance == 0) {
            return 0;
        }

        return
            _synthetix().exchangeWithTracking(
                synthCurrencyKey,
                synthBalance,
                sUSD,
                address(this),
                TRACKING_CODE
            );
    }

    function exchangeSUSDToSynth(uint256 amount) internal returns (uint256) {
        // swap amount of sUSD for Synth
        if (amount == 0) {
            return 0;
        }

        return
            _synthetix().exchangeWithTracking(
                sUSD,
                amount,
                synthCurrencyKey,
                address(this),
                TRACKING_CODE
            );
    }

    function resolver() internal view returns (IAddressResolver) {
        return IAddressResolver(readProxy.target());
    }

    function _synthCoin() internal view returns (ISynth) {
        return ISynth(resolver().getAddress(contractSynth));
    }

    function _synthsUSD() internal view returns (ISynth) {
        return ISynth(resolver().getAddress(CONTRACT_SYNTHSUSD));
    }

    function _synthetix() internal view returns (ISynthetix) {
        return ISynthetix(resolver().getAddress(CONTRACT_SYNTHETIX));
    }

    function _exchangeRates() internal view returns (IExchangeRates) {
        return IExchangeRates(resolver().getAddress(CONTRACT_EXCHANGERATES));
    }

    function _exchanger() internal view returns (IExchanger) {
        return IExchanger(resolver().getAddress(CONTRACT_EXCHANGER));
    }
}

// File: Strategy.sol

contract Strategy is BaseStrategy, Synthetix {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    ICurveFi public curvePool;
    ICrvV3 public curveToken;

    uint256 public susdBuffer; // 10% (over 10_000 BPS) amount of sUSD that should not be exchanged for sETH

    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant uniswapRouter =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    IVaultV2 public yvToken;

    uint256 public lastInvest;
    uint256 public minTimePerInvest; // = 3600;
    uint256 public maxSingleInvest; // // 2 hbtc per hour default
    uint256 public slippageProtectionIn; // = 50; //out of 10000. 50 = 0.5%
    uint256 public slippageProtectionOut; // = 50; //out of 10000. 50 = 0.5%
    uint256 public constant DENOMINATOR = 10_000;
    uint256 public maxLoss; // maximum loss allowed from yVault withdrawal default value: 1 (in BPS)
    uint8 private synth_decimals;

    uint256 internal constant DUST_THRESHOLD = 10_000;

    int128 public curveId;
    uint256 public poolSize;
    bool public hasUnderlying;

    bool public withdrawProtection;

    constructor(
        address _vault,
        address _curvePool,
        address _curveToken,
        address _yvToken,
        uint256 _poolSize,
        bool _hasUnderlying,
        bytes32 _synth
    ) public BaseStrategy(_vault) {
        _initializeSynthetix(_synth);
        _initializeStrat(
            _curvePool,
            _curveToken,
            _yvToken,
            _poolSize,
            _hasUnderlying
        );
    }

    function initialize(
        address _vault,
        address _curvePool,
        address _curveToken,
        address _yvToken,
        uint256 _poolSize,
        bool _hasUnderlying,
        bytes32 _synth
    ) external {
        //note: initialise can only be called once. in _initialize in BaseStrategy we have: require(address(want) == address(0), "Strategy already initialized");
        _initialize(_vault, msg.sender, msg.sender, msg.sender);
        _initializeSynthetix(_synth);
        _initializeStrat(
            _curvePool,
            _curveToken,
            _yvToken,
            _poolSize,
            _hasUnderlying
        );
    }

    function _initializeStrat(
        address _curvePool,
        address _curveToken,
        address _yvToken,
        uint256 _poolSize,
        bool _hasUnderlying
    ) internal {
        require(
            address(curvePool) == address(curvePool),
            "Already Initialized"
        );
        require(_poolSize > 1 && _poolSize < 5, "incorrect pool size");
        require(address(want) == address(_synthsUSD()), "want must be sUSD");

        curvePool = ICurveFi(_curvePool);

        if (
            curvePool.coins(0) == address(_synthCoin()) ||
            (_hasUnderlying &&
                curvePool.underlying_coins(0) == address(_synthCoin()))
        ) {
            curveId = 0;
        } else if (
            curvePool.coins(1) == address(_synthCoin()) ||
            (_hasUnderlying &&
                curvePool.underlying_coins(1) == address(_synthCoin()))
        ) {
            curveId = 1;
        } else if (
            curvePool.coins(2) == address(_synthCoin()) ||
            (_hasUnderlying &&
                curvePool.underlying_coins(2) == address(_synthCoin()))
        ) {
            curveId = 2;
        } else if (
            curvePool.coins(3) == address(_synthCoin()) ||
            (_hasUnderlying &&
                curvePool.underlying_coins(3) == address(_synthCoin()))
        ) {
            //will revert if there are not enough coins
            curveId = 3;
        } else {
            require(false, "incorrect want for curve pool");
        }

        maxSingleInvest = type(uint256).max; // save on stack
        // minTimePerInvest = _minTimePerInvest; // save on stack
        slippageProtectionIn = 50; // default to save on stack
        slippageProtectionOut = 50; // default to save on stack

        poolSize = _poolSize;
        hasUnderlying = _hasUnderlying;

        yvToken = IVaultV2(_yvToken);
        curveToken = ICrvV3(_curveToken);

        _setupStatics();
    }

    function _setupStatics() internal {
        maxReportDelay = 86400;
        profitFactor = 1500;
        minReportDelay = 3600;
        debtThreshold = 100 * 1e18;
        withdrawProtection = true;
        maxLoss = 1;
        susdBuffer = 1_000; // 10% over 10_000 BIPS
        synth_decimals = IERC20Extended(address(_synthCoin())).decimals();
        want.safeApprove(address(curvePool), type(uint256).max);
        curveToken.approve(address(yvToken), type(uint256).max);
    }

    event Cloned(address indexed clone);

    function cloneSingleSidedCurve(
        address _vault,
        address _curvePool,
        address _curveToken,
        address _yvToken,
        uint256 _poolSize,
        bool _hasUnderlying,
        bytes32 _synth
    ) external returns (address newStrategy) {
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
            _curvePool,
            _curveToken,
            _yvToken,
            _poolSize,
            _hasUnderlying,
            _synth
        );

        emit Cloned(newStrategy);
    }

    function name() external view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "SingleSidedCrvSynth",
                    IERC20Extended(address(_synthCoin())).symbol()
                )
            );
    }

    function updateMinTimePerInvest(uint256 _minTimePerInvest)
        public
        onlyAuthorized
    {
        minTimePerInvest = _minTimePerInvest;
    }

    function updateSUSDBuffer(uint256 _susdBuffer) public onlyAuthorized {
        // IN BIPS
        require(_susdBuffer <= 10_000, "!too high");
        susdBuffer = _susdBuffer;
    }

    function updatemaxSingleInvest(uint256 _maxSingleInvest)
        public
        onlyAuthorized
    {
        maxSingleInvest = _maxSingleInvest;
    }

    function updateSlippageProtectionIn(uint256 _slippageProtectionIn)
        public
        onlyAuthorized
    {
        slippageProtectionIn = _slippageProtectionIn;
    }

    function updateSlippageProtectionOut(uint256 _slippageProtectionOut)
        public
        onlyAuthorized
    {
        slippageProtectionOut = _slippageProtectionOut;
    }

    function updateWithdrawProtection(bool _withdrawProtection)
        external
        onlyAuthorized
    {
        withdrawProtection = _withdrawProtection;
    }

    function updateMaxLoss(uint256 _maxLoss) public onlyAuthorized {
        require(_maxLoss <= 10_000);
        maxLoss = _maxLoss;
    }

    function delegatedAssets() public view override returns (uint256) {
        return
            Math.min(
                curveTokenToWant(curveTokensInYVault()),
                vault.strategies(address(this)).totalDebt
            );
    }

    function estimatedTotalAssets() public view override returns (uint256) {
        uint256 totalCurveTokens = curveTokensInYVault().add(
            curveToken.balanceOf(address(this))
        );
        // NOTE: want is always sUSD so we directly use _balanceOfSUSD
        // NOTE: _synthToSUSD takes into account future fees in which the strategy will incur for exchanging synth for sUSD
        return
            _balanceOfSUSD().add(_synthToSUSD(_balanceOfSynth())).add(
                curveTokenToWant(totalCurveTokens)
            );
    }

    // returns value of total
    function curveTokenToWant(uint256 tokens) public view returns (uint256) {
        if (tokens == 0) {
            return 0;
        }

        //we want to choose lower value of virtual price and amount we really get out
        //this means we will always underestimate current assets.
        uint256 virtualOut = virtualPriceToSynth().mul(tokens).div(1e18);

        return _synthToSUSD(virtualOut);
    }

    //we lose some precision here. but it shouldnt matter as we are underestimating
    function virtualPriceToSynth() public view returns (uint256) {
        return curvePool.get_virtual_price();
    }

    function curveTokensInYVault() public view returns (uint256) {
        uint256 balance = yvToken.balanceOf(address(this));

        if (yvToken.totalSupply() == 0) {
            //needed because of revert on priceperfullshare if 0
            return 0;
        }
        uint256 pricePerShare = yvToken.pricePerShare();
        //curve tokens are 1e18 decimals
        return balance.mul(pricePerShare).div(1e18);
    }

    function prepareReturn(uint256 _debtOutstanding)
        internal
        override
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        )
    {
        _debtPayment = _debtOutstanding;

        uint256 debt = vault.strategies(address(this)).totalDebt;
        uint256 currentValue = estimatedTotalAssets();
        uint256 wantBalance = _balanceOfSUSD(); // want is always sUSD

        // we check against estimatedTotalAssets
        if (debt < currentValue) {
            //profit
            _profit = currentValue.sub(debt);
            // NOTE: the strategy will only be able to serve profit payment up to buffer amount
            // we limit profit and try to delay its reporting until there is enough unlocked want to repay it to the vault
            _profit = Math.min(wantBalance, _profit);
        } else {
            _loss = debt.sub(currentValue);
        }

        uint256 toFree = _debtPayment.add(_profit);
        // if the strategy needs to exchange sETH into sUSD, the waiting period will kick in and the vault.report will revert !!!
        // this only works if the strategy has been previously unwinded using BUFFER = 100% OR manual function
        // otherwise, max amount "toFree" is wantBalance (which should be the buffer, which should be setted to be able to serve profit taking)
        if (toFree > wantBalance) {
            toFree = toFree.sub(wantBalance);

            (, uint256 withdrawalLoss) = withdrawSomeWant(toFree);

            //when we withdraw we can lose money in the withdrawal
            if (withdrawalLoss < _profit) {
                _profit = _profit.sub(withdrawalLoss);
            } else {
                _loss = _loss.add(withdrawalLoss.sub(_profit));
                _profit = 0;
            }

            wantBalance = _balanceOfSUSD();

            if (wantBalance < _profit) {
                _profit = wantBalance;
                _debtPayment = 0;
            } else if (wantBalance < _debtPayment.add(_profit)) {
                _debtPayment = wantBalance.sub(_profit);
            }
        }
    }

    function harvestTrigger(uint256 callCost)
        public
        view
        override
        returns (bool)
    {
        uint256 wantCallCost;

        if (address(want) == weth) {
            wantCallCost = callCost;
        } else {
            wantCallCost = _ethToWant(callCost);
        }

        return super.harvestTrigger(wantCallCost);
    }

    function _ethToWant(uint256 _amount) internal view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = address(want);

        uint256[] memory amounts = IUni(uniswapRouter).getAmountsOut(
            _amount,
            path
        );

        return amounts[amounts.length - 1];
    }

    function adjustPosition(uint256 _debtOutstanding) internal override {
        if (lastInvest.add(minTimePerInvest) > block.timestamp) {
            return;
        }

        // 1. Check if we can invest Synth
        uint256 looseSynth = _balanceOfSynth();
        uint256 _sUSDBalance = _balanceOfSUSD();

        // we calculate how much we need to keep in buffer
        // all the amount over it will be converted into Synth
        uint256 totalDebt = vault.strategies(address(this)).totalDebt; // in sUSD (want)
        uint256 buffer = totalDebt.mul(susdBuffer).div(DENOMINATOR);

        uint256 _sUSDToInvest = _sUSDBalance > buffer
            ? _sUSDBalance.sub(buffer)
            : 0;
        uint256 _sUSDNeeded = _sUSDToInvest == 0 ? buffer.sub(_sUSDBalance) : 0;
        uint256 _synthToSell = _sUSDNeeded > 0
            ? _synthFromSUSD(_sUSDNeeded)
            : 0; // amount of Synth that we need to sell to refill buffer
        uint256 _synthToInvest = looseSynth > _synthToSell
            ? looseSynth.sub(_synthToSell)
            : 0;
        // how much loose Synth, available to invest, we will have after buying sUSD?
        // if we cannot invest synth (either due to Synthetix waiting period OR because we don't have enough available)
        // we buy synth with sUSD and return (due to Synthetix waiting period we cannot do anything else)
        if (
            _exchanger().maxSecsLeftInWaitingPeriod(
                address(this),
                synthCurrencyKey
            ) ==
            0 &&
            _synthToInvest > DUST_THRESHOLD
        ) {
            // 2. Supply liquidity (single sided) to Curve Pool
            // calculate LP tokens that we will receive
            uint256 expectedOut = _synthToInvest.mul(1e18).div(
                virtualPriceToSynth()
            );

            // Minimum amount of LP tokens to mint
            uint256 minMint = expectedOut
            .mul(DENOMINATOR.sub(slippageProtectionIn))
            .div(DENOMINATOR);

            ensureAllowance(
                address(curvePool),
                address(_synthCoin()),
                _synthToInvest
            );

            // NOTE: pool size cannot be more than 4 or less than 2
            if (poolSize == 2) {
                uint256[2] memory amounts;
                amounts[uint256(curveId)] = _synthToInvest;
                if (hasUnderlying) {
                    curvePool.add_liquidity(amounts, minMint, true);
                } else {
                    curvePool.add_liquidity(amounts, minMint);
                }
            } else if (poolSize == 3) {
                uint256[3] memory amounts;
                amounts[uint256(curveId)] = _synthToInvest;
                if (hasUnderlying) {
                    curvePool.add_liquidity(amounts, minMint, true);
                } else {
                    curvePool.add_liquidity(amounts, minMint);
                }
            } else {
                uint256[4] memory amounts;
                amounts[uint256(curveId)] = _synthToInvest;
                if (hasUnderlying) {
                    curvePool.add_liquidity(amounts, minMint, true);
                } else {
                    curvePool.add_liquidity(amounts, minMint);
                }
            }

            // 3. Deposit LP tokens in yVault
            uint256 lpBalance = curveToken.balanceOf(address(this));

            if (lpBalance > 0) {
                ensureAllowance(
                    address(yvToken),
                    address(curveToken),
                    lpBalance
                );
                yvToken.deposit();
            }
            lastInvest = block.timestamp;
        }

        if (_synthToSell == 0) {
            // This will invest all available sUSD (exchanging to Synth first)
            // Exchange amount of sUSD to Synth
            _sUSDToInvest = Math.min(
                _sUSDToInvest,
                _sUSDFromSynth(maxSingleInvest)
            );
            if (_sUSDToInvest == 0) {
                return;
            }
            exchangeSUSDToSynth(_sUSDToInvest);
            // now the waiting period starts
        } else if (_synthToSell >= DUST_THRESHOLD) {
            // this means that we need to refill the buffer
            // we may have already some uninvested Synth so we use it (and avoid withdrawing from Curve's Pool)
            uint256 available = _synthToSUSD(_balanceOfSynth());
            uint256 sUSDToWithdraw = _sUSDNeeded > available
                ? _sUSDNeeded.sub(available)
                : 0;
            // this will withdraw and sell full balance of Synth (inside withdrawSomeWant)
            if (sUSDToWithdraw > 0) {
                withdrawSomeWant(sUSDToWithdraw);
            }
            // now the waiting period starts
        }
    }

    function ensureAllowance(
        address _spender,
        address _token,
        uint256 _amount
    ) internal {
        if (IERC20(_token).allowance(address(this), _spender) < _amount) {
            IERC20(_token).safeApprove(_spender, 0);
            IERC20(_token).safeApprove(_spender, type(uint256).max);
        }
    }

    function liquidatePosition(uint256 _amountNeeded)
        internal
        override
        returns (uint256 _liquidatedAmount, uint256 _loss)
    {
        uint256 wantBal = _balanceOfSUSD(); // want is always sUSD
        if (wantBal < _amountNeeded) {
            (_liquidatedAmount, _loss) = withdrawSomeWant(
                _amountNeeded.sub(wantBal)
            );
        }

        _liquidatedAmount = Math.min(
            _amountNeeded,
            _liquidatedAmount.add(wantBal)
        );
    }

    //safe to enter more than we have
    function withdrawSomeWant(uint256 _amount)
        internal
        returns (uint256 _liquidatedAmount, uint256 _loss)
    {
        uint256 sUSDBalanceBefore = _balanceOfSUSD();

        // LPtoken virtual price in Synth
        uint256 virtualPrice = virtualPriceToSynth();

        // 1. We calculate how many LP tokens we need to burn to get requested want
        uint256 amountWeNeedFromVirtualPrice = _synthFromSUSD(_amount)
        .mul(1e18)
        .div(virtualPrice);

        // 2. Withdraw LP tokens from yVault
        uint256 crvBeforeBalance = curveToken.balanceOf(address(this));

        // Calculate how many shares we need to burn to get the amount of LP tokens that we want
        uint256 pricePerFullShare = yvToken.pricePerShare();
        uint256 amountFromVault = amountWeNeedFromVirtualPrice.mul(1e18).div(
            pricePerFullShare
        );

        // cap to our yShares balance
        uint256 yBalance = yvToken.balanceOf(address(this));
        if (amountFromVault > yBalance) {
            amountFromVault = yBalance;
            // this is not loss. so we amend amount

            uint256 _amountOfCrv = amountFromVault.mul(pricePerFullShare).div(
                1e18
            );
            _amount = _amountOfCrv.mul(virtualPrice).div(1e18);
        }

        if (amountFromVault > 0) {
            // Added explicit maxLoss protection in case something goes wrong
            yvToken.withdraw(amountFromVault, address(this), maxLoss);

            if (withdrawProtection) {
                //this tests that we liquidated all of the expected ytokens. Without it if we get back less then will mark it is loss
                require(
                    yBalance.sub(yvToken.balanceOf(address(this))) >=
                        amountFromVault.sub(1),
                    "YVAULTWITHDRAWFAILED"
                );
            }

            // 3. Get coins back by burning LP tokens
            // We are going to burn the amount of LP tokens we just withdrew
            uint256 toBurn = curveToken.balanceOf(address(this)).sub(
                crvBeforeBalance
            );

            // amount of synth we expect to receive
            uint256 toWithdraw = toBurn.mul(virtualPriceToSynth()).div(1e18);

            // minimum amount of coins we are going to receive
            uint256 minAmount = toWithdraw
            .mul(DENOMINATOR.sub(slippageProtectionOut))
            .div(DENOMINATOR);

            if (hasUnderlying) {
                curvePool.remove_liquidity_one_coin(
                    toBurn,
                    curveId,
                    minAmount,
                    true
                );
            } else {
                curvePool.remove_liquidity_one_coin(toBurn, curveId, minAmount);
            }
        }

        // 4. Exchange the full balance of Synth for sUSD (want)
        if (_balanceOfSynth() > DUST_THRESHOLD) {
            exchangeSynthToSUSD();
        }

        uint256 diff = _balanceOfSUSD().sub(sUSDBalanceBefore);
        if (diff > _amount) {
            _liquidatedAmount = _amount;
        } else {
            _liquidatedAmount = diff;
            _loss = _amount.sub(diff);
        }
    }

    function manualRemoveFullLiquidity()
        external
        onlyGovernance
        returns (uint256 _liquidatedAmount, uint256 _loss)
    {
        // It will remove max amount of assets and trade sETH for sUSD
        // the Synthetix waiting period will start (and harvest can be called 6 mins later)
        (_liquidatedAmount, _loss) = withdrawSomeWant(estimatedTotalAssets());
    }

    function prepareMigration(address _newStrategy) internal override {
        // only yvToken and want balances should be required but we do all of them to avoid having them stuck in strategy's middle steps
        // want balance is sent from BaseStrategy's migrate method
        yvToken.transfer(_newStrategy, yvToken.balanceOf(address(this)));
        curveToken.transfer(_newStrategy, curveToken.balanceOf(address(this)));
        IERC20(address(_synthCoin())).transfer(_newStrategy, _balanceOfSynth());
    }

    // Override this to add all tokens/tokenized positions this contract manages
    // on a *persistent* basis (e.g. not just for swapping back to want ephemerally)
    // NOTE: Do *not* include `want`, already included in `sweep` below
    //
    // Example:
    //
    //    function protectedTokens() internal override view returns (address[] memory) {
    //      address[] memory protected = new address[](3);
    //      protected[0] = tokenA;
    //      protected[1] = tokenB;
    //      protected[2] = tokenC;
    //      return protected;
    //    }
    function protectedTokens()
        internal
        view
        override
        returns (address[] memory)
    {
        address[] memory protected = new address[](1);
        protected[0] = address(yvToken);

        return protected;
    }
}