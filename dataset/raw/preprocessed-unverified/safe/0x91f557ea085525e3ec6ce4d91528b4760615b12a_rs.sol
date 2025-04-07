/**
 *Submitted for verification at Etherscan.io on 2020-12-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

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




// solhint-disable-next-line compiler-version

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }
}

/**
 * @title LnAdminUpgradeable
 *
 * @dev This is an upgradeable version of `LnAdmin` by replacing the constructor with
 * an initializer and reserving storage slots.
 */
contract LnAdminUpgradeable is Initializable {
    event CandidateChanged(address oldCandidate, address newCandidate);
    event AdminChanged(address oldAdmin, address newAdmin);

    address public admin;
    address public candidate;

    function __LnAdminUpgradeable_init(address _admin) public initializer {
        require(_admin != address(0), "LnAdminUpgradeable: zero address");
        admin = _admin;
        emit AdminChanged(address(0), _admin);
    }

    function setCandidate(address _candidate) external onlyAdmin {
        address old = candidate;
        candidate = _candidate;
        emit CandidateChanged(old, candidate);
    }

    function becomeAdmin() external {
        require(msg.sender == candidate, "LnAdminUpgradeable: only candidate can become admin");
        address old = admin;
        admin = candidate;
        emit AdminChanged(old, admin);
    }

    modifier onlyAdmin {
        require((msg.sender == admin), "LnAdminUpgradeable: only the contract admin can perform this action");
        _;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[48] private __gap;
}

// a facade for prices fetch from oracles


abstract contract LnBasePrices is LnPrices {
    // const name
    bytes32 public constant override LINA = "LINA";
    bytes32 public constant override LUSD = "lUSD";
}

contract LnDefaultPrices is LnAdminUpgradeable, LnBasePrices {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    address public oracle;

    uint public override stalePeriod;

    mapping(bytes32 => uint) public mPricesLastRound;

    struct PriceData {
        uint216 mPrice;
        uint40 mTime;
    }

    mapping(bytes32 => mapping(uint => PriceData)) private mPricesStorage;

    uint private constant ORACLE_TIME_LIMIT = 10 minutes;

    function __LnDefaultPrices_init(
        address _admin,
        address _oracle,
        bytes32[] memory _currencyNames,
        uint[] memory _newPrices
    ) public initializer {
        __LnAdminUpgradeable_init(_admin);

        stalePeriod = 12 hours;

        require(_currencyNames.length == _newPrices.length, "array length error.");

        oracle = _oracle;

        // The LUSD price is always 1 and is never stale.
        _setPrice(LUSD, SafeDecimalMath.unit(), now);

        _updateAll(_currencyNames, _newPrices, now);
    }

    /* interface */
    function getPrice(bytes32 currencyName) external view override returns (uint) {
        return _getPrice(currencyName);
    }

    function getPriceAndUpdatedTime(bytes32 currencyName) external view override returns (uint price, uint time) {
        PriceData memory priceAndTime = _getPriceData(currencyName);
        return (priceAndTime.mPrice, priceAndTime.mTime);
    }

    function exchange(
        bytes32 sourceName,
        uint sourceAmount,
        bytes32 destName
    ) external view override returns (uint value) {
        (value, , ) = _exchangeAndPrices(sourceName, sourceAmount, destName);
    }

    function exchangeAndPrices(
        bytes32 sourceName,
        uint sourceAmount,
        bytes32 destName
    )
        external
        view
        override
        returns (
            uint value,
            uint sourcePrice,
            uint destPrice
        )
    {
        return _exchangeAndPrices(sourceName, sourceAmount, destName);
    }

    function isStale(bytes32 currencyName) external view override returns (bool) {
        if (currencyName == LUSD) return false;
        return _getUpdatedTime(currencyName).add(stalePeriod) < now;
    }

    /* functions */
    function getCurrentRoundId(bytes32 currencyName) external view returns (uint) {
        return mPricesLastRound[currencyName];
    }

    function setOracle(address _oracle) external onlyAdmin {
        oracle = _oracle;
        emit OracleUpdated(oracle);
    }

    function setStalePeriod(uint _time) external onlyAdmin {
        stalePeriod = _time;
        emit StalePeriodUpdated(stalePeriod);
    }

    // 外部调用，更新汇率 oracle是一个地址，从外部用脚本定期调用这个接口
    function updateAll(
        bytes32[] calldata currencyNames,
        uint[] calldata newPrices,
        uint timeSent
    ) external onlyOracle returns (bool) {
        _updateAll(currencyNames, newPrices, timeSent);
    }

    function deletePrice(bytes32 currencyName) external onlyOracle {
        require(_getPrice(currencyName) > 0, "price is zero");

        delete mPricesStorage[currencyName][mPricesLastRound[currencyName]];

        mPricesLastRound[currencyName]--;

        emit PriceDeleted(currencyName);
    }

    function _setPrice(
        bytes32 currencyName,
        uint256 price,
        uint256 time
    ) internal {
        // start from 1
        mPricesLastRound[currencyName]++;
        mPricesStorage[currencyName][mPricesLastRound[currencyName]] = PriceData({
            mPrice: uint216(price),
            mTime: uint40(time)
        });
    }

    function _updateAll(
        bytes32[] memory currencyNames,
        uint[] memory newPrices,
        uint timeSent
    ) internal returns (bool) {
        require(currencyNames.length == newPrices.length, "array length error, not match.");
        require(timeSent < (now + ORACLE_TIME_LIMIT), "Time error");

        for (uint i = 0; i < currencyNames.length; i++) {
            bytes32 currencyName = currencyNames[i];

            require(newPrices[i] != 0, "Zero is not a valid price, please call deletePrice instead.");
            require(currencyName != LUSD, "LUSD cannot be updated.");

            if (timeSent < _getUpdatedTime(currencyName)) {
                continue;
            }

            _setPrice(currencyName, newPrices[i], timeSent);
        }

        emit PricesUpdated(currencyNames, newPrices);

        return true;
    }

    function _getPriceData(bytes32 currencyName) internal view virtual returns (PriceData memory) {
        return mPricesStorage[currencyName][mPricesLastRound[currencyName]];
    }

    function _getPrice(bytes32 currencyName) internal view returns (uint256) {
        PriceData memory priceAndTime = _getPriceData(currencyName);
        return priceAndTime.mPrice;
    }

    function _getUpdatedTime(bytes32 currencyName) internal view returns (uint256) {
        PriceData memory priceAndTime = _getPriceData(currencyName);
        return priceAndTime.mTime;
    }

    function _exchangeAndPrices(
        bytes32 sourceName,
        uint sourceAmount,
        bytes32 destName
    )
        internal
        view
        returns (
            uint value,
            uint sourcePrice,
            uint destPrice
        )
    {
        sourcePrice = _getPrice(sourceName);
        // If there's no change in the currency, then just return the amount they gave us
        if (sourceName == destName) {
            destPrice = sourcePrice;
            value = sourceAmount;
        } else {
            // Calculate the effective value by going from source -> USD -> destination
            destPrice = _getPrice(destName);
            value = sourceAmount.multiplyDecimalRound(sourcePrice).divideDecimalRound(destPrice);
        }
    }

    /* ========== MODIFIERS ========== */
    modifier onlyOracle {
        require(msg.sender == oracle, "Only the oracle can perform this action");
        _;
    }

    /* ========== EVENTS ========== */
    event OracleUpdated(address newOracle);
    event StalePeriodUpdated(uint priceStalePeriod);
    event PricesUpdated(bytes32[] currencyNames, uint[] newPrices);
    event PriceDeleted(bytes32 currencyName);

    // Reserved storage space to allow for layout changes in the future.
    uint256[46] private __gap;
}