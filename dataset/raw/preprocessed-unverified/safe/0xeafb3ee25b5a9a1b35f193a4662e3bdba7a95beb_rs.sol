/**
 *Submitted for verification at Etherscan.io on 2021-06-29
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
struct Rebase {
    uint128 elastic;
    uint128 base;
}

// Part: BIERC20



// Part: BoringMath

/// @notice A library for performing overflow-/underflow-safe math,
/// updated with awesomeness from of DappHub (https://github.com/dapphub/ds-math).


// Part: BoringMath128

/// @notice A library for performing overflow-/underflow-safe addition and subtraction on uint128.


// Part: IMasterChef



// Part: IOracle



// Part: IStrategy



// Part: IUniswapV2Router01



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



// Part: IBatchFlashBorrower



// Part: IFlashBorrower



// Part: ISwapper



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


// Part: RebaseLibrary

/// @notice A rebasing library using overflow-/underflow-safe math.


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

// Part: IBentoBoxV1 (Alias import as IBentoBox)



// Part: IBentoBoxV1



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
        return "0.4.2";
    }

    /**
     * @notice This Strategy's name.
     * @dev
     *  You can use this field to manage the "version" of this Strategy, e.g.
     *  `StrategySomethingOrOtherV1`. However, "API Version" is managed by
     *  `apiVersion()` function above.
     * @return This Strategy's name.
     */
    function name() external view virtual returns (string memory);

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
    function delegatedAssets() external view virtual returns (uint256) {
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

    modifier onlyEmergencyAuthorized() {
        require(
            msg.sender == strategist || msg.sender == governance() || msg.sender == vault.guardian() || msg.sender == vault.management(),
            "!authorized"
        );
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
        require(msg.sender == vault.management() || msg.sender == governance(), "!authorized");
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
     * @param _strategist The address to assign as `strategist`.
     * The strategist is able to change the reward address
     * @param _rewards  The address to use for pulling rewards.
     * @param _keeper The adddress of the _keeper. _keeper
     * can harvest and tend a strategy.
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
     *  Provide an accurate conversion from `_amtInWei` (denominated in wei)
     *  to `want` (using the native decimal characteristics of `want`).
     * @dev
     *  Care must be taken when working with decimals to assure that the conversion
     *  is compatible. As an example:
     *
     *      given 1e17 wei (0.1 ETH) as input, and want is USDC (6 decimals),
     *      with USDC/ETH = 1800, this should give back 1800000000 (180 USDC)
     *
     * @param _amtInWei The amount (in wei/1e-18 ETH) to convert to `want`
     * @return The amount in `want` of `_amtInEth` converted to `want`
     **/
    function ethToWant(uint256 _amtInWei) public view virtual returns (uint256);

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
    function estimatedTotalAssets() public view virtual returns (uint256);

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
     * `want.balanceOf(this) >= _debtPayment + _profit`).
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
     *
     * NOTE: The invariant `_liquidatedAmount + _loss <= _amountNeeded` should always be maintained
     */
    function liquidatePosition(uint256 _amountNeeded) internal virtual returns (uint256 _liquidatedAmount, uint256 _loss);

    /**
     * Liquidate everything and returns the amount that got freed.
     * This function is used during emergency exit instead of `prepareReturn()` to
     * liquidate all of the Strategy's positions back to the Vault.
     */

    function liquidateAllPositions() internal virtual returns (uint256 _amountFreed);

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
     *  `callCostInWei` must be priced in terms of `wei` (1e-18 ETH).
     *
     *  This call and `harvestTrigger()` should never return `true` at the same
     *  time.
     * @param callCostInWei The keeper's estimated gas cost to call `tend()` (in wei).
     * @return `true` if `tend()` should be called, `false` otherwise.
     */
    function tendTrigger(uint256 callCostInWei) public view virtual returns (bool) {
        // We usually don't need tend, but if there are positions that need
        // active maintainence, overriding this function is how you would
        // signal for that.
        uint256 callCost = ethToWant(callCostInWei);
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
     *  `callCostInWei` must be priced in terms of `wei` (1e-18 ETH).
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
     * @param callCostInWei The keeper's estimated gas cost to call `harvest()` (in wei).
     * @return `true` if `harvest()` should be called, `false` otherwise.
     */
    function harvestTrigger(uint256 callCostInWei) public view virtual returns (bool) {
        uint256 callCost = ethToWant(callCostInWei);
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
            uint256 amountFreed = liquidateAllPositions();
            if (amountFreed < debtOutstanding) {
                loss = debtOutstanding.sub(amountFreed);
            } else if (amountFreed > debtOutstanding) {
                profit = amountFreed.sub(debtOutstanding);
            }
            debtPayment = debtOutstanding.sub(loss);
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
            require(HealthCheck(healthCheck).check(profit, loss, debtPayment, debtOutstanding, totalDebt), "!healthcheck");
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
     *  This may only be called by the Vault.
     * @dev
     * The new Strategy's Vault must be the same as this Strategy's Vault.
     *  The migration process should be carefully performed to make sure all
     * the assets are migrated to the new address, which should have never
     * interacted with the vault before.
     * @param _newStrategy The Strategy to migrate to.
     */
    function migrate(address _newStrategy) external {
        require(msg.sender == address(vault));
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
    function setEmergencyExit() external onlyEmergencyAuthorized {
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
     * ```
     *    function protectedTokens() internal override view returns (address[] memory) {
     *      address[] memory protected = new address[](3);
     *      protected[0] = tokenA;
     *      protected[1] = tokenB;
     *      protected[2] = tokenC;
     *      return protected;
     *    }
     * ```
     */
    function protectedTokens() internal view virtual returns (address[] memory);

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

// Part: IKashiPair



// File: Strategy.sol

contract Strategy is BaseStrategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    using RebaseLibrary for Rebase;

    struct KashiPairInfo {
        IKashiPair kashiPair;
        uint256 pid;
    }

    bool internal isOriginal = true;
    uint256 internal constant MAX_PAIRS = 5;
    uint256 internal constant MAX_BPS = 1e4;

    // Kashi constants (apply to MediumRiskPairs)
    uint256 internal constant KASHI_MINIMUM_TARGET_UTILIZATION = 7e17; // 70%
    uint256 internal constant KASHI_MAXIMUM_TARGET_UTILIZATION = 8e17; // 80%
    uint256 internal constant KASHI_UTILIZATION_PRECISION = 1e18;

    IERC20 internal constant weth =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 internal constant sushi =
        IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);

    IMasterChef public constant masterChef =
        IMasterChef(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);
    IUniswapV2Router02 public constant sushiRouter =
        IUniswapV2Router02(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    IBentoBox public bentoBox;
    KashiPairInfo[] public kashiPairs;

    uint256 public dustThreshold = 2;

    // Path for swaps
    address[] private path;

    string private strategyName;

    constructor(
        address _vault,
        address _bentoBox,
        address[] memory _kashiPairs,
        uint256[] memory _pids,
        string memory _strategyName
    ) public BaseStrategy(_vault) {
        _initializeStrat(_bentoBox, _kashiPairs, _pids, _strategyName);
    }

    function initialize(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _bentoBox,
        address[] memory _kashiPairs,
        uint256[] memory _pids,
        string memory _strategyName
    ) public {
        _initialize(_vault, _strategist, _rewards, _keeper);
        _initializeStrat(_bentoBox, _kashiPairs, _pids, _strategyName);
    }

    event Cloned(address indexed clone);

    function cloneKashiLender(
        address _vault,
        address _strategist,
        address _rewards,
        address _keeper,
        address _bentoBox,
        address[] memory _kashiPairs,
        uint256[] memory _pids,
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
            _bentoBox,
            _kashiPairs,
            _pids,
            _strategyName
        );

        emit Cloned(newStrategy);
    }

    function _initializeStrat(
        address _bentoBox,
        address[] memory _kashiPairs,
        uint256[] memory _pids,
        string memory _strategyName
    ) internal {
        require(address(bentoBox) == address(0)); // Check if previously initialized
        require(_kashiPairs.length <= MAX_PAIRS); // Must not exceed the max length
        require(_kashiPairs.length == _pids.length); // Pairs length must match pids length

        strategyName = bytes(_strategyName).length == 0
            ? "StrategyKashiMultiPairLender"
            : _strategyName;

        bentoBox = IBentoBox(_bentoBox);

        healthCheck = address(0xDDCea799fF1699e98EDF118e0629A974Df7DF012); // health.ychad.eth

        for (uint256 i = 0; i < _kashiPairs.length; i++) {
            kashiPairs.push(
                KashiPairInfo(IKashiPair(_kashiPairs[i]), _pids[i])
            );
            // kashiPair must use the right bentoBox
            require(address(kashiPairs[i].kashiPair.bentoBox()) == _bentoBox);
            // kashiPair asset must match want
            require(address(kashiPairs[i].kashiPair.asset()) == address(want));

            if (_pids[i] != 0) {
                // the masterChef pid token must match the kashiPair
                require(
                    address(masterChef.poolInfo(_pids[i]).lpToken) ==
                        _kashiPairs[i]
                );

                IERC20(_kashiPairs[i]).safeApprove(
                    address(masterChef),
                    type(uint256).max
                );
            }
        }

        want.safeApprove(_bentoBox, type(uint256).max);
        sushi.safeApprove(address(sushiRouter), type(uint256).max);

        // Initialize the swap path
        path = new address[](3);
        path[0] = address(sushi);
        path[1] = address(weth);
        path[2] = address(want);
    }

    function name() external view override returns (string memory) {
        return strategyName;
    }

    function estimatedTotalAssets() public view override returns (uint256) {
        uint256 totalShares = sharesInBento();

        for (uint256 i = 0; i < kashiPairs.length; i++) {
            KashiPairInfo memory kashiPairInfo = kashiPairs[i];

            totalShares = totalShares.add(
                kashiFractionToBentoShares(
                    kashiPairInfo.kashiPair,
                    kashiFractionTotal(
                        kashiPairInfo.kashiPair,
                        kashiPairInfo.pid
                    )
                )
            );
        }

        return balanceOfWant().add(bentoSharesToWant(totalShares));
    }

    function kashiPairEstimatedAssets(uint256 i) public view returns (uint256) {
        KashiPairInfo memory kashiPairInfo = kashiPairs[i];

        return
            bentoSharesToWant(
                kashiFractionToBentoShares(
                    kashiPairInfo.kashiPair,
                    kashiFractionTotal(
                        kashiPairInfo.kashiPair,
                        kashiPairInfo.pid
                    )
                )
            );
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
        for (uint256 i = 0; i < kashiPairs.length; i++) {
            KashiPairInfo memory kashiPairInfo = kashiPairs[i];
            accrueInterest(kashiPairInfo.kashiPair);
            depositKashiInMasterChef(
                kashiPairInfo.kashiPair,
                kashiPairInfo.pid
            ); // claim and deposit loose
        }

        sell();

        uint256 assets = estimatedTotalAssets();
        uint256 wantBal = balanceOfWant();

        uint256 debt = vault.strategies(address(this)).totalDebt;

        if (assets >= debt) {
            _profit = assets.sub(debt);
        } else {
            _loss = debt.sub(assets);
        }

        _debtPayment = _debtOutstanding;
        uint256 amountToFree = _debtPayment.add(_profit);

        if (amountToFree > 0 && wantBal < amountToFree) {
            (uint256 newLoose, ) = liquidatePosition(amountToFree.sub(wantBal));

            // if we didnt free enough money, prioritize paying down debt before taking profit
            if (newLoose < amountToFree) {
                if (newLoose <= _debtPayment) {
                    _profit = 0;
                    _loss += _debtPayment.sub(newLoose);
                    _debtPayment = newLoose;
                } else {
                    _profit = newLoose.sub(_debtPayment);
                }
            }
        }
    }

    function adjustPosition(uint256 _debtOutstanding) internal override {
        if (emergencyExit) {
            return;
        }

        uint256 wantBalance = balanceOfWant();

        uint256 shares = 0;

        if (wantBalance > dustThreshold) {
            (, shares) = depositInBento(wantBalance);
        }

        uint256 sharesInBento = sharesInBento();

        if (sharesInBento > wantToBentoShares(dustThreshold)) {
            // Get highest interest rate pair
            (IKashiPair highestPair, uint256 highestPid) =
                highestInterestPair(sharesInBento);

            depositInKashiPair(highestPair, highestPid, sharesInBento);
        }
    }

    function liquidatePosition(uint256 _amountNeeded)
        internal
        override
        returns (uint256 _liquidatedAmount, uint256 _loss)
    {
        uint256 wantBalance = balanceOfWant();

        if (_amountNeeded <= wantBalance) {
            return (_amountNeeded, 0);
        }

        uint256 amountToFree = _amountNeeded.sub(wantBalance);
        uint256 deposited = estimatedTotalAssets().sub(wantBalance);

        if (amountToFree > deposited) {
            amountToFree = deposited;
        }

        if (amountToFree > 0) {
            uint256 sharesNeeded = wantToBentoShares(amountToFree);
            uint256 bentoShares = sharesInBento();

            if (sharesNeeded > bentoShares) {
                uint256 sharesToFreeFromKashi = sharesNeeded.sub(bentoShares);
                uint256 sharesFreedFromKashi = 0;

                // Find the lowest apr pair with at least the lesser of
                //   - the amount to free
                //   - the mean assets per pair
                (IKashiPair lowestPair, uint256 lowestPid) =
                    lowestInterestPair(
                        Math.min(
                            sharesToFreeFromKashi,
                            wantToBentoShares(
                                estimatedTotalAssets().div(kashiPairs.length)
                            )
                        )
                    );
                if (address(lowestPair) != address(0)) {
                    sharesFreedFromKashi = liquidateKashiPair(
                        lowestPair,
                        lowestPid,
                        sharesToFreeFromKashi
                    );
                }

                for (
                    uint256 i = 0;
                    i < kashiPairs.length &&
                        sharesToFreeFromKashi > sharesFreedFromKashi;
                    i++
                ) {
                    KashiPairInfo memory kashiPairInfo = kashiPairs[i];

                    if (address(kashiPairInfo.kashiPair) == address(lowestPair))
                        continue; // we already visited this

                    sharesFreedFromKashi = sharesFreedFromKashi.add(
                        liquidateKashiPair(
                            kashiPairInfo.kashiPair,
                            kashiPairInfo.pid,
                            sharesToFreeFromKashi.sub(sharesFreedFromKashi)
                        )
                    );
                }
            }

            bentoBox.withdraw(
                BIERC20(address(want)),
                address(this),
                address(this),
                0,
                sharesInBento()
            );
        }

        _liquidatedAmount = Math.min(balanceOfWant(), _amountNeeded);

        if (_amountNeeded > _liquidatedAmount) {
            _loss = _amountNeeded.sub(_liquidatedAmount);
        }
    }

    function liquidateAllPositions()
        internal
        override
        returns (uint256 _liquidatedAmount)
    {
        (_liquidatedAmount, ) = liquidatePosition(estimatedTotalAssets());
    }

    // new strategy **must** have the same kashiPairs attached
    function prepareMigration(address _newStrategy) internal override {
        for (uint256 i = 0; i < kashiPairs.length; i++) {
            KashiPairInfo memory kashiPairInfo = kashiPairs[i];

            if (kashiPairInfo.pid != 0) {
                masterChef.withdraw(
                    kashiPairInfo.pid,
                    kashiFactionInMasterChef(kashiPairInfo.pid)
                );
            }

            kashiPairs[i].kashiPair.transfer(
                _newStrategy,
                kashiFractionInPair(kashiPairInfo.kashiPair)
            );
        }
    }

    function addKashiPair(address _newKashiPair, uint256 _newPid)
        external
        onlyGovernance
    {
        // cannot exceed max pair length
        require(kashiPairs.length < MAX_PAIRS);
        // must use the correct bentobox
        require(
            address(IKashiPair(_newKashiPair).bentoBox()) == address(bentoBox)
        );
        // kashPair asset must match want
        require(IKashiPair(_newKashiPair).asset() == BIERC20(address(want)));
        if (_newPid != 0) {
            // masterChef pid token must match the kashiPair
            require(
                address(masterChef.poolInfo(_newPid).lpToken) == _newKashiPair
            );
        }

        for (uint256 i = 0; i < kashiPairs.length; i++) {
            // kashiPair must not already be attached
            require(_newKashiPair != address(kashiPairs[i].kashiPair));
        }

        kashiPairs.push(KashiPairInfo(IKashiPair(_newKashiPair), _newPid));

        if (_newPid != 0) {
            IERC20(_newKashiPair).safeApprove(
                address(masterChef),
                type(uint256).max
            );
        }
    }

    function removeKashiPair(address _remKashiPair, uint256 _remIndex)
        external
        onlyEmergencyAuthorized
    {
        KashiPairInfo memory kashiPairInfo = kashiPairs[_remIndex];

        require(_remKashiPair == address(kashiPairInfo.kashiPair));
        liquidateKashiPair(
            kashiPairInfo.kashiPair,
            kashiPairInfo.pid,
            wantToBentoShares(estimatedTotalAssets())
        );
        if (kashiPairInfo.pid != 0) {
            IERC20(_remKashiPair).safeApprove(address(masterChef), 0);
        }
        kashiPairs[_remIndex] = kashiPairs[kashiPairs.length - 1];
        kashiPairs.pop();
        return;
    }

    function adjustKashiPairRatios(uint256[] calldata _ratios)
        external
        onlyAuthorized
    {
        // length of ratios must match number of pairs
        require(_ratios.length == kashiPairs.length);

        uint256 totalRatio;

        for (uint256 i = 0; i < kashiPairs.length; i++) {
            // We must accrue all pairs to ensure we get an accurate estimate of assets
            accrueInterest(kashiPairs[i].kashiPair);
            totalRatio += _ratios[i];
        }

        require(totalRatio == MAX_BPS); //ratios must add to 10000 bps

        uint256 wantBalance = balanceOfWant();
        if (wantBalance > dustThreshold) {
            depositInBento(wantBalance);
        }

        uint256 totalAssets = estimatedTotalAssets();
        uint256[] memory kashiPairsIncreasedAllocation =
            new uint256[](kashiPairs.length);

        for (uint256 i = 0; i < kashiPairs.length; i++) {
            KashiPairInfo memory kashiPairInfo = kashiPairs[i];

            uint256 pairTotalAssets =
                bentoSharesToWant(
                    kashiFractionToBentoShares(
                        kashiPairInfo.kashiPair,
                        kashiFractionTotal(
                            kashiPairInfo.kashiPair,
                            kashiPairInfo.pid
                        )
                    )
                );
            uint256 targetAssets = (_ratios[i] * totalAssets) / MAX_BPS;
            if (targetAssets < pairTotalAssets) {
                uint256 toLiquidate = pairTotalAssets.sub(targetAssets);
                liquidateKashiPair(
                    kashiPairInfo.kashiPair,
                    kashiPairInfo.pid,
                    wantToBentoShares(toLiquidate)
                );
            } else if (targetAssets > pairTotalAssets) {
                kashiPairsIncreasedAllocation[i] = targetAssets.sub(
                    pairTotalAssets
                );
            }
        }

        for (uint256 i = 0; i < kashiPairs.length; i++) {
            if (kashiPairsIncreasedAllocation[i] == 0) continue;

            KashiPairInfo memory kashiPairInfo = kashiPairs[i];

            uint256 sharesInBento = sharesInBento();
            uint256 sharesToAdd =
                wantToBentoShares(kashiPairsIncreasedAllocation[i]);

            if (sharesToAdd > sharesInBento) {
                sharesToAdd = sharesInBento;
            }

            depositInKashiPair(
                kashiPairInfo.kashiPair,
                kashiPairInfo.pid,
                sharesToAdd
            );
        }
    }

    function depositInKashiPair(
        IKashiPair kashiPair,
        uint256 pid,
        uint256 sharesToDeposit
    ) internal {
        transferBento(address(kashiPair), sharesToDeposit);

        uint256 depositedFraction =
            kashiPair.addAsset(address(this), true, sharesToDeposit);

        depositKashiInMasterChef(kashiPair, pid);
    }

    function depositKashiInMasterChef(IKashiPair kashiPair, uint256 pid)
        internal
    {
        if (pid == 0) return;

        uint256 fractionsToStake = kashiFractionInPair(kashiPair);

        if (fractionsToStake > dustThreshold) {
            masterChef.deposit(pid, fractionsToStake);
        }
    }

    function depositInBento(uint256 wantToDeposit)
        internal
        returns (uint256 amountOut, uint256 shareOut)
    {
        return
            bentoBox.deposit(
                BIERC20(address(want)),
                address(this),
                address(this),
                wantToDeposit,
                0
            );
    }

    function transferBento(address to, uint256 shares) internal {
        bentoBox.transfer(
            BIERC20(address(want)),
            address(this),
            address(to),
            shares
        );
    }

    function liquidateKashiPair(
        IKashiPair kashiPair,
        uint256 pid,
        uint256 sharesToFree
    ) internal returns (uint256 _shareLiquidated) {
        // We need to call accrue to accurately calculate totalAssets
        accrueInterest(kashiPair);

        uint256 liquidShares = kashiPairLiquidShares(kashiPair);
        if (sharesToFree > liquidShares) {
            sharesToFree = liquidShares;
        }

        if (sharesToFree == 0) return 0;

        uint256 fractionsToFree =
            bentoSharesToKashiFraction(kashiPair, sharesToFree);

        // Remove from masterChef if there is a non-zero pid
        if (pid != 0) {
            uint256 fractionInMc = kashiFactionInMasterChef(pid);
            uint256 fractionsToFreeFromMc = fractionsToFree;
            if (fractionsToFreeFromMc > fractionInMc) {
                fractionsToFreeFromMc = fractionInMc;
            }
            masterChef.withdraw(pid, fractionsToFreeFromMc);
        }

        uint256 fractionBalance = kashiFractionInPair(kashiPair);

        if (fractionsToFree > fractionBalance) {
            fractionsToFree = fractionBalance;
        }

        _shareLiquidated = kashiPair.removeAsset(
            address(this),
            fractionsToFree
        );

        // Redeposit into the masterChef if there's some spare change
        depositKashiInMasterChef(kashiPair, pid);
    }

    // sell all function
    function sell() internal {
        uint256 sushiBal = balanceOfSushi();
        if (sushiBal == 0) {
            return;
        }

        sushiRouter.swapExactTokensForTokens(
            sushiBal,
            uint256(0),
            path,
            address(this),
            now
        );
    }

    function accrueInterest(IKashiPair kashiPair) internal {
        (, uint256 lastAccrued, ) = kashiPair.accrueInfo();
        // Accure interest
        if (block.timestamp > lastAccrued) {
            kashiPair.accrue();
        }
    }

    function setDustThreshold(uint256 _newDustThreshold)
        external
        onlyAuthorized
    {
        dustThreshold = _newDustThreshold;
    }

    function setPath(address[] calldata _path) external onlyGovernance {
        path = _path;
    }

    function balanceOfWant() internal view returns (uint256) {
        return want.balanceOf(address(this));
    }

    function balanceOfSushi() internal view returns (uint256) {
        return sushi.balanceOf(address(this));
    }

    function sharesInBento() internal view returns (uint256) {
        return bentoBox.balanceOf(BIERC20(address(want)), address(this));
    }

    function kashiFractionTotal(IKashiPair kashiPair, uint256 pid)
        internal
        view
        returns (uint256)
    {
        return
            kashiFactionInMasterChef(pid).add(kashiFractionInPair(kashiPair));
    }

    function kashiFactionInMasterChef(uint256 pid)
        internal
        view
        returns (uint256 _kashiFraction)
    {
        if (pid != 0) {
            _kashiFraction = masterChef.userInfo(pid, address(this)).amount;
        }
    }

    function kashiFractionInPair(IKashiPair kashiPair)
        internal
        view
        returns (uint256)
    {
        return kashiPair.balanceOf(address(this));
    }

    function kashiPairLiquidShares(IKashiPair kashiPair)
        internal
        view
        returns (uint256)
    {
        return kashiPair.totalAsset().elastic;
    }

    // highestInterestIndex finds the best pair to invest the given deposit
    function highestInterestPair(uint256 sharesToDeposit)
        internal
        view
        returns (IKashiPair _highestPair, uint256 _highestPid)
    {
        uint256 highestInterest = 0;
        uint256 highestUtilization = 0;

        for (uint256 i = 0; i < kashiPairs.length; i++) {
            KashiPairInfo memory kashiPairInfo = kashiPairs[i];

            (uint256 interestPerBlock, , ) =
                kashiPairInfo.kashiPair.accrueInfo();

            uint256 utilization =
                kashiPairUtilization(kashiPairInfo.kashiPair, sharesToDeposit);

            // A pair is highest (really best) if either
            //   - It's utilization is higher, and either
            //     - It is above the max target util
            //     - The existing choice is below the min util target
            //   - Compare APR directly only if both are between the min and max
            if (
                (utilization > highestUtilization &&
                    (utilization > KASHI_MAXIMUM_TARGET_UTILIZATION ||
                        highestUtilization <
                        KASHI_MINIMUM_TARGET_UTILIZATION)) ||
                (interestPerBlock > highestInterest &&
                    utilization < KASHI_MAXIMUM_TARGET_UTILIZATION &&
                    utilization > KASHI_MINIMUM_TARGET_UTILIZATION &&
                    highestUtilization < KASHI_MAXIMUM_TARGET_UTILIZATION &&
                    highestUtilization > KASHI_MINIMUM_TARGET_UTILIZATION)
            ) {
                highestInterest = interestPerBlock;
                highestUtilization = utilization;
                _highestPair = kashiPairInfo.kashiPair;
                _highestPid = kashiPairInfo.pid;
            }
        }
    }

    function lowestInterestPair(uint256 minLiquidShares)
        internal
        view
        returns (IKashiPair _lowestPair, uint256 _lowestPid)
    {
        uint256 lowestInterest = type(uint256).max;
        uint256 lowestUtilization = KASHI_UTILIZATION_PRECISION;

        for (uint256 i = 0; i < kashiPairs.length; i++) {
            KashiPairInfo memory kashiPairInfo = kashiPairs[i];

            (uint256 interestPerBlock, , ) =
                kashiPairInfo.kashiPair.accrueInfo();

            uint256 utilization =
                kashiPairUtilization(kashiPairInfo.kashiPair, 0);

            // A pair is lowest if either
            //   - It's utilization is lower, and either
            //     - It is below the min taget util
            //     - The existing choice is above the max target util
            //   - Compare APR directly only if both are between the min and max
            if (
                ((utilization < lowestUtilization &&
                    (lowestUtilization > KASHI_MAXIMUM_TARGET_UTILIZATION ||
                        utilization < KASHI_MINIMUM_TARGET_UTILIZATION)) ||
                    (interestPerBlock < lowestInterest &&
                        utilization < KASHI_MAXIMUM_TARGET_UTILIZATION &&
                        utilization > KASHI_MINIMUM_TARGET_UTILIZATION &&
                        lowestUtilization < KASHI_MAXIMUM_TARGET_UTILIZATION &&
                        lowestUtilization >
                        KASHI_MINIMUM_TARGET_UTILIZATION)) &&
                kashiFractionTotal(kashiPairInfo.kashiPair, kashiPairInfo.pid) >
                dustThreshold &&
                kashiPairLiquidShares(kashiPairInfo.kashiPair) >=
                minLiquidShares
            ) {
                lowestInterest = interestPerBlock;
                _lowestPair = kashiPairInfo.kashiPair;
                _lowestPid = kashiPairInfo.pid;
            }
        }
    }

    function kashiPairUtilization(IKashiPair kashiPair, uint256 sharesToDeposit)
        internal
        view
        returns (uint256)
    {
        uint256 totalAssetShares = kashiPair.totalAsset().elastic;
        uint256 totalBorrowAmount = kashiPair.totalBorrow().elastic;
        uint256 fullAssetAmount =
            bentoBox
                .toAmount(
                BIERC20(address(this)),
                totalAssetShares.add(sharesToDeposit),
                false
            )
                .add(totalBorrowAmount);

        return
            uint256(totalBorrowAmount).mul(KASHI_UTILIZATION_PRECISION).div(
                fullAssetAmount
            );
    }

    function wantToBentoShares(uint256 wantAmount)
        internal
        view
        returns (uint256)
    {
        if (wantAmount == 0) return 0;
        return bentoBox.toShare(BIERC20(address(this)), wantAmount, true);
    }

    function bentoSharesToWant(uint256 bentoShares)
        internal
        view
        returns (uint256)
    {
        if (bentoShares == 0) return 0;
        return bentoBox.toAmount(BIERC20(address(this)), bentoShares, true);
    }

    function bentoSharesToKashiFraction(
        IKashiPair kashiPair,
        uint256 bentoShares
    ) internal view returns (uint256 _kashiFraction) {
        // Adapted from https://github.com/sushiswap/kashi-lending/blob/b6e3521d8628a835935c94a9039cfd192044d66b/contracts/KashiPair.sol#L320-L323
        Rebase memory totalAsset = kashiPair.totalAsset();
        Rebase memory totalBorrow = kashiPair.totalBorrow();
        uint256 allShare =
            uint256(totalAsset.elastic).add(
                wantToBentoShares(totalBorrow.elastic)
            );
        _kashiFraction = allShare == 0
            ? bentoShares
            : bentoShares.mul(totalAsset.base).div(allShare);
    }

    function kashiFractionToBentoShares(
        IKashiPair kashiPair,
        uint256 _kashiFraction
    ) internal view returns (uint256 bentoShares) {
        // Adapted from https://github.com/sushiswap/kashi-lending/blob/b6e3521d8628a835935c94a9039cfd192044d66b/contracts/KashiPair.sol#L351-L353
        Rebase memory totalAsset = kashiPair.totalAsset();
        Rebase memory totalBorrow = kashiPair.totalBorrow();
        uint256 allShare =
            uint256(totalAsset.elastic).add(
                wantToBentoShares(totalBorrow.elastic)
            );
        bentoShares = _kashiFraction.mul(allShare).div(totalAsset.base);
    }

    function protectedTokens()
        internal
        view
        override
        returns (address[] memory)
    {}

    function ethToWant(uint256 _amtInWei)
        public
        view
        virtual
        override
        returns (uint256)
    {
        // TODO create an accurate price oracle
        return _amtInWei;
    }
}