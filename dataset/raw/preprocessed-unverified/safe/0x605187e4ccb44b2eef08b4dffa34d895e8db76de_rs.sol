/**
 *Submitted for verification at Etherscan.io on 2021-02-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


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


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract ContractGuard {
    mapping(uint256 => mapping(address => bool)) private _status;

    function checkSameOriginReentranted() internal view returns (bool) {
        return _status[block.number][tx.origin];
    }

    function checkSameSenderReentranted() internal view returns (bool) {
        return _status[block.number][msg.sender];
    }

    modifier onlyOneBlock() {
        require(!checkSameOriginReentranted(), "ContractGuard: one block, one function");
        require(!checkSameSenderReentranted(), "ContractGuard: one block, one function");

        _;

        _status[block.number][tx.origin] = true;
        _status[block.number][msg.sender] = true;
    }
}



interface ITreasury is IEpochController {
    function dollarPriceOne() external view returns (uint256);

    function dollarPriceCeiling() external view returns (uint256);
}









contract Treasury is ContractGuard, ITreasury {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    /* ========== STATE VARIABLES ========== */

    // governance
    address public operator;
    address public strategist;

    // flags
    bool public initialized = false;

    // epoch
    uint256 public baseEpochPeriod;
    uint256 public lastEpochTime;
    uint256 private _epoch = 0;

    // core components
    address public dollar;
    address public dollarOracle;
    address public bondMarket;
    address public reserveFund;
    address public lpPool; // vUSD-WETH 80/20
    address public stakePool; // vUSD-WETH 98/2
    address public liquidityIncentiveFund;

    // expansion distribution percents
    uint256 public expansionPercentReserveFund;
    uint256 public expansionPercentLpPool;
    uint256 public expansionPercentStakePool;
    uint256 public expansionPercentLiquidityIncentiveFund;
    uint256 public expansionPercentDebtPhaseReserveFund;
    uint256 public expansionPercentDebtPhaseLpPool;
    uint256 public expansionPercentDebtPhaseStakePool;
    uint256 public expansionPercentDebtPhaseLiquidityIncentiveFund;

    // price
    uint256 public override dollarPriceOne;
    uint256 public override dollarPriceCeiling;
    address public sideToken; // WETH

    uint256 public maxSupplyExpansionRate;

    uint256 public bootstrapEpochs;
    uint256 public bootstrapDollarPrice;

    uint256 public allocateSeigniorageSalary;

    /* =================== Events =================== */

    event Initialized(address indexed executor, uint256 at);
    event SeigniorageFunded(
        uint256 timestamp,
        uint256 reserveFundAmt,
        uint256 lpPoolAmt,
        uint256 stakePoolAmt,
        uint256 liquidityIncentiveFundAmt,
        uint256 bondMarketFundAmt
    );

    /* =================== Modifier =================== */

    modifier onlyOperator() {
        require(operator == msg.sender, "Treasury: caller is not the operator");
        _;
    }

    modifier onlyStrategist() {
        require(strategist == msg.sender || operator == msg.sender, "Treasury: caller is not a strategist");
        _;
    }

    modifier checkEpoch {
        uint256 _nextEpochPoint = nextEpochPoint();
        require(now >= _nextEpochPoint, "Treasury: not opened yet");
        _;
        lastEpochTime = _nextEpochPoint;
        _epoch = _epoch.add(1);
    }

    modifier notInitialized {
        require(!initialized, "Treasury: already initialized");
        _;
    }

    /* ========== VIEW FUNCTIONS ========== */

    // flags
    function isInitialized() public view returns (bool) {
        return initialized;
    }

    // epoch
    function epoch() public view override returns (uint256) {
        return _epoch;
    }

    function nextEpochPoint() public view override returns (uint256) {
        return lastEpochTime.add(nextEpochLength());
    }

    function nextEpochLength() public view override returns (uint256 _length) {
        if (_epoch <= bootstrapEpochs) {
            // 14 first epochs with 12h long
            _length = 12 hours;
        } else {
            uint256 dollarPrice = getDollarPrice();
            if (dollarPrice > dollarPriceOne.mul(2))
                dollarPrice = dollarPriceOne.mul(2); // in expansion: round(10h * min(TWAP, 2))
            else if (dollarPrice < dollarPriceOne.div(2)) dollarPrice = dollarPriceOne.div(2); // in contraction: round(10h * max(TWAP, 0.5))
            _length = dollarPrice.mul(baseEpochPeriod).div(dollarPriceOne);
            _length = _length.div(3600).mul(3600);
        }
    }

    // oracle
    function getDollarPrice() public view returns (uint256 _dollarPrice) {
        if (dollarOracle == address(0)) {
            return dollarPriceOne;
        }
        try IOracle(dollarOracle).consultDollarPrice(sideToken, 1e18) returns (uint256 price) {
            return price;
        } catch {
            revert("Treasury: failed to consult dollar price from the oracle");
        }
    }

    // oracle
    function getDollarUpdatedPrice() public view returns (uint256 _dollarPrice) {
        if (dollarOracle == address(0)) {
            return dollarPriceOne;
        }
        try IOracle(dollarOracle).twapDollarPrice(sideToken, 1e18) returns (uint256 price) {
            return price;
        } catch {
            revert("Treasury: failed to get TWAP dollar price from the oracle");
        }
    }

    function isDebtPhase() public view returns (bool) {
        return (bondMarket == address(0)) ? false : IBondMarket(bondMarket).isDebtPhase();
    }

    /* ========== GOVERNANCE ========== */

    function initialize(
        address _dollar,
        address _sideToken,
        address _reserveFund,
        address _lpPool,
        address _stakePool,
        address _liquidityIncentiveFund,
        uint256 _baseEpochPeriod,
        uint256 _startTime
    ) public notInitialized {
        dollar = _dollar;
        sideToken = _sideToken;
        reserveFund = _reserveFund;
        lpPool = _lpPool;
        stakePool = _stakePool;
        liquidityIncentiveFund = _liquidityIncentiveFund;
        baseEpochPeriod = _baseEpochPeriod; // 10 hours
        lastEpochTime = _startTime.sub(12 hours);

        expansionPercentReserveFund = 500; // 5% goes to reserveFund
        expansionPercentLpPool = 3500; // 35% goes to lpPool (vUSD-WETH 80/20)
        expansionPercentStakePool = 5000; // 50% goes to lpPool (vUSD-WETH 98/2)
        expansionPercentLiquidityIncentiveFund = 1000; // 10% goes to liquidityIncentiveFund

        // In Debt Phase
        expansionPercentDebtPhaseReserveFund = 500; // 5% goes to reserveFund
        expansionPercentDebtPhaseLpPool = 1500; // 15% goes to lpPool (vUSD-WETH 80/20)
        expansionPercentDebtPhaseStakePool = 1000; // 10% goes to lpPool (vUSD-WETH 98/2)
        expansionPercentDebtPhaseLiquidityIncentiveFund = 500; // 5% goes to liquidityIncentiveFund

        dollarPriceOne = 10**18;
        dollarPriceCeiling = dollarPriceOne.mul(101).div(100);

        maxSupplyExpansionRate = 2e16; // Upto 2% supply for expansion

        bootstrapEpochs = 14;
        bootstrapDollarPrice = dollarPriceOne.mul(120).div(100);

        allocateSeigniorageSalary = 10 ether;

        initialized = true;
        operator = msg.sender;
        emit Initialized(msg.sender, block.number);
    }

    function setOperator(address _operator) external onlyOperator {
        operator = _operator;
    }

    function setStrategist(address _strategist) external onlyOperator {
        strategist = _strategist;
    }

    function setBaseEpochPeriod(uint256 _baseEpochPeriod) external onlyOperator {
        require(_baseEpochPeriod >= 30 minutes && _baseEpochPeriod <= 48 hours, "out of range");
        baseEpochPeriod = _baseEpochPeriod;
    }

    function setDollarOracle(address _dollarOracle) external onlyOperator {
        dollarOracle = _dollarOracle;
    }

    function setBondMarket(address _bondMarket) external onlyOperator {
        bondMarket = _bondMarket;
    }

    function setReserveFund(address _reserveFund) external onlyOperator {
        reserveFund = _reserveFund;
    }

    function setLpPool(address _lpPool) external onlyOperator {
        lpPool = _lpPool;
    }

    function setStakePool(address _stakePool) external onlyOperator {
        stakePool = _stakePool;
    }

    function setLiquidityIncentiveFund(address _liquidityIncentiveFund) external onlyOperator {
        liquidityIncentiveFund = _liquidityIncentiveFund;
    }

    function setExpansionPercents(
        uint256 _expansionPercentReserveFund,
        uint256 _expansionPercentLpPool,
        uint256 _expansionPercentStakePool,
        uint256 _expansionPercentLiquidityIncentiveFund
    ) external onlyOperator {
        require(
            _expansionPercentReserveFund.add(_expansionPercentLpPool).add(_expansionPercentStakePool).add(_expansionPercentLiquidityIncentiveFund) == 10000,
            "!100%"
        );
        expansionPercentReserveFund = _expansionPercentReserveFund;
        expansionPercentLpPool = _expansionPercentLpPool;
        expansionPercentStakePool = _expansionPercentStakePool;
        expansionPercentLiquidityIncentiveFund = _expansionPercentLiquidityIncentiveFund;
    }

    function setExpansionPercentsDebtPhase(
        uint256 _expansionPercentDebtPhaseReserveFund,
        uint256 _expansionPercentDebtPhaseLpPool,
        uint256 _expansionPercentDebtPhaseStakePool,
        uint256 _expansionPercentDebtPhaseLiquidityIncentiveFund
    ) external onlyOperator {
        require(
            _expansionPercentDebtPhaseReserveFund.add(_expansionPercentDebtPhaseLpPool).add(_expansionPercentDebtPhaseStakePool).add(
                _expansionPercentDebtPhaseLiquidityIncentiveFund
            ) <= 5000,
            "over 50%"
        );
        expansionPercentDebtPhaseReserveFund = _expansionPercentDebtPhaseReserveFund;
        expansionPercentDebtPhaseLpPool = _expansionPercentDebtPhaseLpPool;
        expansionPercentDebtPhaseStakePool = _expansionPercentDebtPhaseStakePool;
        expansionPercentDebtPhaseLiquidityIncentiveFund = _expansionPercentDebtPhaseLiquidityIncentiveFund;
    }

    function setDollarPriceCeiling(uint256 _dollarPriceCeiling) external onlyOperator {
        require(_dollarPriceCeiling >= dollarPriceOne && _dollarPriceCeiling <= dollarPriceOne.mul(120).div(100), "out of range"); // [$1.0, $1.2]
        dollarPriceCeiling = _dollarPriceCeiling;
    }

    function setMaxSupplyExpansionRate(uint256 _maxSupplyExpansionRate) external onlyOperator {
        require(_maxSupplyExpansionRate >= 10 && _maxSupplyExpansionRate <= 1500, "out of range"); // [0.1%, 15%]
        maxSupplyExpansionRate = _maxSupplyExpansionRate;
    }

    function setBootstrapEpochs(uint256 _bootstrapEpochs) external onlyOperator {
        require(_bootstrapEpochs <= 60, "_bootstrapEpochs: out of range"); // <= 1 month
        bootstrapEpochs = _bootstrapEpochs;
    }

    function setAllocateSeigniorageSalary(uint256 _allocateSeigniorageSalary) external onlyOperator {
        require(_allocateSeigniorageSalary <= 100 ether, "Treasury: dont pay too much");
        allocateSeigniorageSalary = _allocateSeigniorageSalary;
    }

    function governanceRecoverUnsupported(
        IERC20 _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        // do not allow to drain core tokens
        require(address(_token) != address(dollar), "dollar");
        _token.safeTransfer(_to, _amount);
    }

    /* ========== MUTABLE FUNCTIONS ========== */

    function _updateDollarPrice() internal {
        try IOracle(dollarOracle).update() {} catch {}
    }

    function _updateDollarPriceCumulative() internal {
        try IOracle(dollarOracle).updateCumulative() {} catch {}
    }

    function nextEpochAllocatedReward(address _pool) external view override returns (uint256 _allocatedReward) {
        uint256 dollarPrice = (_epoch <= bootstrapEpochs) ? bootstrapDollarPrice : getDollarPrice();
        uint256 _dollarSupply = IERC20(dollar).totalSupply();
        uint256 _supplyExpansion = 0;
        if (dollarPrice >= dollarPriceCeiling) {
            uint256 _percentage = dollarPrice.sub(dollarPriceOne);
            if (_percentage > maxSupplyExpansionRate) {
                _percentage = maxSupplyExpansionRate;
            }
            _supplyExpansion = _dollarSupply.mul(_percentage).div(1e18);
        }
        bool _debtPhase = isDebtPhase();
        if (_pool == reserveFund) {
            _allocatedReward = _supplyExpansion.mul((_debtPhase) ? expansionPercentDebtPhaseReserveFund : expansionPercentReserveFund).div(10000);
        } else if (_pool == lpPool) {
            uint256 _lpPoolExtraAmt = IERC20(dollar).balanceOf(address(this)); // 5% of the burned vUSD via BondMarket
            _allocatedReward = _lpPoolExtraAmt.add(_supplyExpansion.mul((_debtPhase) ? expansionPercentDebtPhaseLpPool : expansionPercentLpPool).div(10000));
        } else if (_pool == stakePool) {
            _allocatedReward = _supplyExpansion.mul((_debtPhase) ? expansionPercentDebtPhaseStakePool : expansionPercentStakePool).div(10000);
        } else if (_pool == liquidityIncentiveFund) {
            _allocatedReward = _supplyExpansion
                .mul((_debtPhase) ? expansionPercentDebtPhaseLiquidityIncentiveFund : expansionPercentLiquidityIncentiveFund)
                .div(10000);
        }
    }

    function _allocateReward(address _pool, uint256 _amount) internal {
        if (_amount > 0) {
            IERC20(dollar).safeApprove(_pool, 0);
            IERC20(dollar).safeApprove(_pool, _amount);
            IStakePoolEpochReward(_pool).allocateReward(_amount);
        }
    }

    function _mintedNewDollars(uint256 _supplyExpansion, bool _debtPhase) internal {
        uint256 _reserveFundAmt = _supplyExpansion.mul((_debtPhase) ? expansionPercentDebtPhaseReserveFund : expansionPercentReserveFund).div(10000);
        uint256 _lpPoolExtraAmt = IERC20(dollar).balanceOf(address(this)); // 5% of the burned vUSD via BondMarket
        uint256 _lpPoolAmt = _lpPoolExtraAmt.add(_supplyExpansion.mul((_debtPhase) ? expansionPercentDebtPhaseLpPool : expansionPercentLpPool).div(10000));
        uint256 _stakePoolAmt = _supplyExpansion.mul((_debtPhase) ? expansionPercentDebtPhaseStakePool : expansionPercentStakePool).div(10000);
        uint256 _liquidityIncentiveFundAmt =
            _supplyExpansion.mul((_debtPhase) ? expansionPercentDebtPhaseLiquidityIncentiveFund : expansionPercentLiquidityIncentiveFund).div(10000);
        IDollar(dollar).mint(address(this), _supplyExpansion);
        IERC20(dollar).safeTransfer(reserveFund, _reserveFundAmt);
        _allocateReward(lpPool, _lpPoolAmt);
        _allocateReward(stakePool, _stakePoolAmt);
        IERC20(dollar).safeTransfer(liquidityIncentiveFund, _liquidityIncentiveFundAmt);
        uint256 _bondMarketFundAmt = 0;
        if (_debtPhase) {
            _bondMarketFundAmt = IERC20(dollar).balanceOf(address(this));
            IERC20(dollar).safeTransfer(bondMarket, _bondMarketFundAmt);
        }
        emit SeigniorageFunded(block.timestamp, _reserveFundAmt, _lpPoolAmt, _stakePoolAmt, _liquidityIncentiveFundAmt, _bondMarketFundAmt);
    }

    function allocateSeigniorage(uint256 _rate) external onlyOneBlock checkEpoch onlyStrategist {
        _updateDollarPrice();
        uint256 dollarPrice = (_epoch <= bootstrapEpochs) ? bootstrapDollarPrice : getDollarPrice();
        uint256 _dollarSupply = IERC20(dollar).totalSupply();
        if (dollarPrice >= dollarPriceCeiling) {
            uint256 _percentage = dollarPrice.sub(dollarPriceOne);
            require(_rate <= _percentage, "Treasury: over expansion rate");
            require(_rate <= maxSupplyExpansionRate, "Treasury: over maxSupplyExpansionRate");
            uint256 _supplyExpansion = _dollarSupply.mul(_rate).div(1e18);
            _mintedNewDollars(_supplyExpansion, isDebtPhase());
        } else if (dollarPrice < dollarPriceOne) {
            require(_rate <= 2e17, "Treasury: issued new bonds is over 20%");
            uint256 _issuedBond = _dollarSupply.mul(_rate).div(1e18);
            IBondMarket(bondMarket).issueNewBond(_issuedBond);
            _allocateReward(lpPool, IERC20(dollar).balanceOf(address(this))); // 5% of the burned vUSD via BondMarket
        }
        if (allocateSeigniorageSalary > 0) {
            IDollar(dollar).mint(address(msg.sender), allocateSeigniorageSalary);
        }
    }
}