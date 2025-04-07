/**
 *Submitted for verification at Etherscan.io on 2021-09-01
*/

pragma solidity 0.6.6;






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

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

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
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


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

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// SPDX-License-Identifier: MIT
/**
 * @dev Standard math utilities missing in the Solidity language.
 */


// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)


// SPDX-License-Identifier: MIT
/**
 * @dev Collection of functions related to the address type
 */


// SPDX-License-Identifier: MIT
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// SPDX-License-Identifier: UNLICENSED
abstract contract IMlp {
    function makeOffer(address _token, uint _amount, uint _unlockDate, uint _endDate, uint _slippageTolerancePpm, uint _maxPriceVariationPpm) external virtual returns (uint offerId);

    function takeOffer(uint _pendingOfferId, uint _amount, uint _deadline) external virtual returns (uint activeOfferId);

    function cancelOffer(uint _offerId) external virtual;

    function release(uint256 _offerId, uint256 amount0Min, uint256 amount1Min, uint256 slippage, uint256 _deadline) external virtual;
}

// SPDX-License-Identifier: UNLICENSED
abstract contract IFeesController {
    function feesTo() public view virtual returns (address);
    function setFeesTo(address) public virtual;

    function feesPpm() public view virtual returns (uint);
    function setFeesPpm(uint) public virtual;

    function candyFarmBurnPpm() public view virtual returns (uint);
    function setCandyFarmBurnPpm(uint) public virtual;
}

// SPDX-License-Identifier: UNLICENSED
abstract contract IRewardManager {
    function add(uint256 _allocPoint, address _newMlp) public virtual;
    function notifyDeposit(address _account, uint256 _amount) public virtual;
    function notifyWithdraw(address _account, uint256 _amount) public virtual;
    function getPoolSupply(address pool) public view virtual returns(uint);
    function getUserAmount(address pool, address user) public view virtual returns(uint);
}

// SPDX-License-Identifier: UNLICENSED
contract Mlp is IMlp, Initializable, OwnableUpgradeSafe {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 constant private RATIO_MULTIPLIER = 10**18;
    uint256 constant public FULL_SLIPPAGE = 1000;
    uint256 constant public MAX_SLIPPAGE_TOLERANCE = 75;

    uint256 public endDate;
    address public submitter;
    uint256 public exceedingLiquidity;
    uint256 public bonusToken0;
    uint256 public reward0Rate;
    uint256 public reward0PerTokenStored;
    uint256 public bonusToken1;
    uint256 public reward1Rate;
    uint256 public reward1PerTokenStored;
    uint256 public lastUpdateTime;
    uint256 public pendingOfferCount;
    uint256 public activeOfferCount;

    IRewardManager public rewardManager;
    IUniswapV2Pair public uniswapPair;
    IFeesController public feesController;
    IUniswapV2Router02 public uniswapRouter;

    IUniswapV2Pair public safetyPair0;
    bool public isFirstTokenInSafetyPair0;
    IUniswapV2Pair public safetyPair1;
    bool public isFirstTokenInSafetyPair1;

    bool public doCheckSafetyPools;

    // ######## LEGACY STORAGE ########
    mapping(address => uint256) private userReward0PerTokenPaid; // Legacy variable
    mapping(address => uint256) private userRewards0; // Legacy variable
    mapping(address => uint256) private userReward1PerTokenPaid; // Legacy variable
    mapping(address => uint256) private userRewards1; // Legacy variable
    // ################################

    mapping(address => uint256) public directStakeBalances;
    mapping(uint256 => PendingOffer) public getPendingOffer;
    mapping(uint256 => ActiveOffer) public getActiveOffer;

    enum OfferStatus {PENDING, TAKEN, CANCELED}

    event OfferMade(uint256 id);
    event OfferTaken(uint256 pendingOfferId, uint256 activeOfferId);
    event OfferCanceled(uint256 id);
    event OfferReleased(uint256 offerId);
    event PayReward(uint256 amount0, uint256 amount1);

    struct PendingOffer {
        address owner;
        address token;
        uint256 amount;
        uint256 unlockDate;
        uint256 endDate;
        OfferStatus status;
        uint256 slippageTolerancePpm;
        uint256 maxPriceVariationPpm;
    }

    struct ActiveOffer {
        address user0;
        uint256 originalAmount0;
        address user1;
        uint256 originalAmount1;
        uint256 unlockDate;
        uint256 liquidity;
        bool released;
        uint256 maxPriceVariationPpm;
    }

    function initialize (
        address _feesController,
        address _uniswapPair,
        address _submitter,
        uint256 _endDate,
        address _uniswapRouter,
        address _rewardManager,
        address _safetyPair0,
        address _safetyPair1,
        bool _isFirstTokenInPair0,
        bool _isFirstTokenInPair1,
        bool _doCheckSafetyPairs
    ) public initializer {
        OwnableUpgradeSafe.__Ownable_init();
        feesController = IFeesController(_feesController);
        uniswapPair = IUniswapV2Pair(_uniswapPair);
        endDate = _endDate;
        submitter = _submitter;
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        rewardManager = IRewardManager(_rewardManager);
        lastUpdateTime = block.timestamp;

        safetyPair0 = IUniswapV2Pair(_safetyPair0);
        isFirstTokenInSafetyPair0 = _isFirstTokenInPair0;
        safetyPair1 = IUniswapV2Pair(_safetyPair1);
        isFirstTokenInSafetyPair1 = _isFirstTokenInPair1;

        doCheckSafetyPools = _doCheckSafetyPairs;
    }

    function _notifyDeposit(address account, uint256 amount) internal {
        rewardManager.notifyDeposit(account, amount);
    }

    function _notifyWithdraw(address account, uint256 amount) internal {
        rewardManager.notifyWithdraw(account, amount);
    }

    function makeOffer(
        address _token,
        uint256 _amount,
        uint256 _unlockDate,
        uint256 _endDate,
        uint256 _slippageTolerancePpm,
        uint256 _maxPriceVariationPpm
    ) external override returns (uint256 offerId) {
        require(_amount > 0, "makeOffer: ZERO_AMOUNT");
        require(_endDate > now, "makeOffer: END_DATE_MORE_THAN_NOW");
        require(_endDate <= _unlockDate, "makeOffer: END_DATE_LESS_THAN_UNLOCK_DATE");
        require(
            _token == address(uniswapPair.token0()) || 
            _token == address(uniswapPair.token1()),
            "unknown token");
        offerId = pendingOfferCount;
        pendingOfferCount++;
        getPendingOffer[offerId] = PendingOffer(
            msg.sender,
            _token,
            _amount,
            _unlockDate,
            _endDate,
            OfferStatus.PENDING,
            _slippageTolerancePpm,
            _maxPriceVariationPpm
        );

        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        emit OfferMade(offerId);
    }

    struct ProviderInfo {
        address user;
        uint256 amount;
        IERC20 token;
    }

    struct OfferInfo {
        uint256 deadline;
        uint256 slippageTolerancePpm;
    }

    function takeOffer(
        uint256 _pendingOfferId,
        uint256 _amount,
        uint256 _deadline
    ) external override returns (uint256 activeOfferId) {
        PendingOffer storage pendingOffer = getPendingOffer[_pendingOfferId];
        require(pendingOffer.status == OfferStatus.PENDING);
        require(pendingOffer.endDate > now);
        pendingOffer.status = OfferStatus.TAKEN;

        // Sort the users, tokens, and amount
        ProviderInfo memory provider0;
        ProviderInfo memory provider1;
        {
            if (pendingOffer.token == uniswapPair.token0()) {
                provider0 = ProviderInfo(
                    pendingOffer.owner,
                    pendingOffer.amount,
                    IERC20(uniswapPair.token0())
                );
                provider1 = ProviderInfo(
                    msg.sender,
                    _amount,
                    IERC20(uniswapPair.token1())
                );

                provider1.token.safeTransferFrom(
                    provider1.user,
                    address(this),
                    provider1.amount
                );
            } else {
                provider0 = ProviderInfo(
                    msg.sender,
                    _amount,
                    IERC20(uniswapPair.token0())
                );
                provider1 = ProviderInfo(
                    pendingOffer.owner,
                    pendingOffer.amount,
                    IERC20(uniswapPair.token1())
                );

                provider0.token.safeTransferFrom(
                    provider0.user,
                    address(this),
                    provider0.amount
                );
            }
        }

        // calculate fees
        uint256 feesAmount0 =
            provider0.amount.mul(feesController.feesPpm()) / 1000;
        uint256 feesAmount1 =
            provider1.amount.mul(feesController.feesPpm()) / 1000;

        // take fees
        provider0.amount = provider0.amount.sub(feesAmount0);
        provider1.amount = provider1.amount.sub(feesAmount1);

        // send fees
        provider0.token.safeTransfer(feesController.feesTo(), feesAmount0);
        provider1.token.safeTransfer(feesController.feesTo(), feesAmount1);

        uint256 spentAmount0;
        uint256 spentAmount1;
        uint256 liquidity;
        uint256[] memory returnedValues = new uint256[](3);

        // send tokens to uniswap
        {
            returnedValues = _provideLiquidity(
                provider0,
                provider1,
                OfferInfo(_deadline, pendingOffer.slippageTolerancePpm)
            );
            liquidity = returnedValues[0];
            spentAmount0 = returnedValues[1];
            spentAmount1 = returnedValues[2];
        }

        // stake liquidity
        _notifyDeposit(provider0.user, liquidity / 2);
        _notifyDeposit(provider1.user, liquidity / 2);

        if (liquidity % 2 != 0) {
            exceedingLiquidity = exceedingLiquidity.add(1);
        }

        // Record the active offer
        activeOfferId = activeOfferCount;
        activeOfferCount++;

        getActiveOffer[activeOfferId] = ActiveOffer(
            provider0.user,
            spentAmount0,
            provider1.user,
            spentAmount1,
            pendingOffer.unlockDate,
            liquidity,
            false,
            pendingOffer.maxPriceVariationPpm
        );

        emit OfferTaken(_pendingOfferId, activeOfferId);

        return activeOfferId;
    }

    function _provideLiquidity(
        ProviderInfo memory _provider0,
        ProviderInfo memory _provider1,
        OfferInfo memory _info
    ) internal returns (uint256[] memory) {
        _provider0.token.safeApprove(address(uniswapRouter), 0);
        _provider1.token.safeApprove(address(uniswapRouter), 0);

        _provider0.token.safeApprove(address(uniswapRouter), _provider0.amount);
        _provider1.token.safeApprove(address(uniswapRouter), _provider1.amount);

        uint256 amountMin0 =
            _provider0.amount.sub(
                _provider0.amount.mul(_info.slippageTolerancePpm) / 1000
            );
        uint256 amountMin1 =
            _provider1.amount.sub(
                _provider1.amount.mul(_info.slippageTolerancePpm) / 1000
            );

        // Add the liquidity to Uniswap
        uint256 spentAmount0;
        uint256 spentAmount1;
        uint256 liquidity;
        {
            (spentAmount0, spentAmount1, liquidity) = uniswapRouter
                .addLiquidity(
                address(_provider0.token),
                address(_provider1.token),
                _provider0.amount,
                _provider1.amount,
                amountMin0,
                amountMin1,
                address(this),
                _info.deadline
            );
        }
        // Give back the exceeding tokens
        if (spentAmount0 < _provider0.amount) {
            _provider0.token.safeTransfer(
                _provider0.user,
                _provider0.amount - spentAmount0
            );
        }
        if (spentAmount1 < _provider1.amount) {
            _provider1.token.safeTransfer(
                _provider1.user,
                _provider1.amount - spentAmount1
            );
        }
        uint256[] memory liq = new uint256[](3);
        liq[0] = liquidity;
        liq[1] = spentAmount0;
        liq[2] = spentAmount1;
        return (liq);
    }

    function cancelOffer(uint256 _offerId) external override {
        PendingOffer storage pendingOffer = getPendingOffer[_offerId];
        require(pendingOffer.status == OfferStatus.PENDING);
        pendingOffer.status = OfferStatus.CANCELED;
        IERC20(pendingOffer.token).safeTransfer(
            pendingOffer.owner,
            pendingOffer.amount
        );
        emit OfferCanceled(_offerId);
    }

    function release(uint256 _offerId, uint256 amount0Min, uint256 amount1Min, uint256 slippageTolerance, uint256 _deadline) external override {
        ActiveOffer storage offer = getActiveOffer[_offerId];

        require(
            msg.sender == offer.user0 || msg.sender == offer.user1,
            "unauthorized"
        );
        require(now > offer.unlockDate, "locked");
        require(!offer.released, "already released");
        require(slippageTolerance <= MAX_SLIPPAGE_TOLERANCE, "release: SLIPPAGE_TOO_BIG");

        // check if ETH or USDT pools are in correct ratio
        if (doCheckSafetyPools) {
            uint256 totalSlippage = _getPriceSlippage();
            require(totalSlippage <= slippageTolerance, "release: BAD_SLIPPAGE_RATIO");
        }

        offer.released = true;

        IERC20 token0 = IERC20(uniswapPair.token0());
        IERC20 token1 = IERC20(uniswapPair.token1());

        IERC20(address(uniswapPair)).safeApprove(address(uniswapRouter), 0);

        IERC20(address(uniswapPair)).safeApprove(
            address(uniswapRouter),
            offer.liquidity
        );
        (uint256 amount0, uint256 amount1) =
            uniswapRouter.removeLiquidity(
                address(token0),
                address(token1),
                offer.liquidity,
                amount0Min,
                amount1Min,
                address(this),
                _deadline
            );

        _notifyWithdraw(offer.user0, offer.liquidity / 2);
        _notifyWithdraw(offer.user1, offer.liquidity / 2);

        if (
            _getPriceVariation(offer.originalAmount0, amount0) >
            offer.maxPriceVariationPpm
        ) {
            if (amount0 > offer.originalAmount0) {
                uint256 toSwap = amount0.sub(offer.originalAmount0);
                address[] memory path = new address[](2);
                path[0] = address(token0);
                path[1] = address(token1);
                token0.safeApprove(address(uniswapRouter), 0);
                token0.safeApprove(address(uniswapRouter), toSwap);

                uint256[] memory newAmounts =
                    uniswapRouter.swapExactTokensForTokens(
                        toSwap,
                        0,
                        path,
                        address(this),
                        _deadline
                    );
                amount0 = amount0.sub(toSwap);
                amount1 = amount1.add(newAmounts[1]);
            }
        }
        if (
            _getPriceVariation(offer.originalAmount1, amount1) >
            offer.maxPriceVariationPpm
        ) {
            if (amount1 > offer.originalAmount1) {
                uint256 toSwap = amount1.sub(offer.originalAmount1);
                address[] memory path = new address[](2);
                path[0] = address(token1);
                path[1] = address(token0);
                token1.safeApprove(address(uniswapRouter), 0);
                token1.safeApprove(address(uniswapRouter), toSwap);
                uint256[] memory newAmounts =
                    uniswapRouter.swapExactTokensForTokens(
                        toSwap,
                        0,
                        path,
                        address(this),
                        _deadline
                    );
                amount1 = amount1.sub(toSwap);
                amount0 = amount0.add(newAmounts[1]);
            }
        }

        token0.safeTransfer(offer.user0, amount0);
        token1.safeTransfer(offer.user1, amount1);

        emit OfferReleased(_offerId);
    }

    function setDoCheckSafetyPools(bool _doCheckSafetyPools) external onlyOwner {
        doCheckSafetyPools = _doCheckSafetyPools;
    }

    function _getPriceSlippage() private view returns (uint256) {

        uint256 safetyRatio0 = _calculateSafetyPairRatio(safetyPair0, isFirstTokenInSafetyPair0);
        uint256 safetyRatio1 = _calculateSafetyPairRatio(safetyPair1, isFirstTokenInSafetyPair1);

        uint256 safetyRatio = safetyRatio0.mul(RATIO_MULTIPLIER) / safetyRatio1;
        uint256 mlpTokensRatio = _calculateMlpPairRatio();

        uint256 totalSlippage = _getAbsoluteSubstraction(safetyRatio, mlpTokensRatio).mul(FULL_SLIPPAGE) / safetyRatio;

        return totalSlippage;
    }

    function _getAbsoluteSubstraction(uint256 x, uint256 y) private pure returns (uint256) {
        if (x > y) {
            return x - y;
        } else {
            return y - x;
        }
    }

    function _calculateSafetyPairRatio(IUniswapV2Pair safetyPair, bool isFirstTokenInPair) private view returns(uint256) {
        uint112 mlpTokenReserve;
        uint112 safetyTokenReserve;

        if (isFirstTokenInPair) {
            (mlpTokenReserve, safetyTokenReserve,) = safetyPair.getReserves();
        } else {
            (safetyTokenReserve, mlpTokenReserve,) = safetyPair.getReserves();
        }

        return (uint256(mlpTokenReserve)).mul(RATIO_MULTIPLIER) / (uint256(safetyTokenReserve));
    }

    function _calculateMlpPairRatio() private view returns(uint256) {
        (uint112 reserve0, uint112 reserve1,) = uniswapPair.getReserves();

        return (uint256(reserve0)).mul(RATIO_MULTIPLIER) / (uint256(reserve1));
    }

    function _getPriceVariation(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 sub;
        if (a > b) {
            sub = a.sub(b);
            return sub.mul(1000) / a;
        } else {
            sub = b.sub(a);
            return sub.mul(1000) / b;
        }
    }

    function directStake(uint256 _amount) external {
        require(_amount > 0, "cannot stake 0");
        IERC20(address(uniswapPair)).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        // calculate fees
        uint256 feesAmount = _amount.mul(feesController.feesPpm()) / 1000;

        // take fees
        uint256 stakeAmount = _amount.sub(feesAmount);

        // send fees
        IERC20(address(uniswapPair)).safeTransfer(feesController.feesTo(), feesAmount);

        _notifyDeposit(msg.sender, stakeAmount);
        directStakeBalances[msg.sender] = directStakeBalances[msg.sender].add(
            stakeAmount
        );
    }

    function directWithdraw(uint256 _amount) external {
        require(_amount > 0, "cannot withdraw 0");
        _notifyWithdraw(msg.sender, _amount);
        directStakeBalances[msg.sender] = directStakeBalances[msg.sender].sub(
            _amount
        );
        IERC20(address(uniswapPair)).safeTransfer(msg.sender, _amount);
    }

    function transferExceedingLiquidity() external {
        require(exceedingLiquidity != 0);
        IERC20(address(uniswapPair)).safeTransfer(
            feesController.feesTo(),
            exceedingLiquidity
        );
        exceedingLiquidity = 0;
    }
}