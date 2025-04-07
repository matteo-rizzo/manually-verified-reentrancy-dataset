/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

/*
    ___            _       ___  _                          
    | .\ ___  _ _ <_> ___ | __><_>._ _  ___ ._ _  ___  ___ 
    |  _// ._>| '_>| ||___|| _> | || ' |<_> || ' |/ | '/ ._>
    |_|  \___.|_|  |_|     |_|  |_||_|_|<___||_|_|\_|_.\___.
    
* PeriFinance: CollateralManager.sol
*
* Latest source (may be newer): https://github.com/perifinance/peri-finance/blob/master/contracts/CollateralManager.sol
* Docs: Will be added in the future. 
* https://docs.peri.finance/contracts/source/contracts/CollateralManager
*
* Contract Dependencies: 
*	- IAddressResolver
*	- ICollateralManager
*	- MixinResolver
*	- Owned
*	- Pausable
*	- State
* Libraries: 
*	- AddressSetLib
*	- Bytes32SetLib
*	- SafeDecimalMath
*	- SafeMath
*
* MIT License
* ===========
*
* Copyright (c) 2021 PeriFinance
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/



pragma solidity 0.5.16;

// https://docs.peri.finance/contracts/source/contracts/owned



// Inheritance


// https://docs.peri.finance/contracts/source/contracts/pausable
contract Pausable is Owned {
    uint public lastPauseTime;
    bool public paused;

    constructor() internal {
        // This contract is abstract, and thus cannot be instantiated directly
        require(owner != address(0), "Owner must be set");
        // Paused will be false, and lastPauseTime will be 0 upon initialisation
    }

    /**
     * @notice Change the paused state of the contract
     * @dev Only the contract owner may call this.
     */
    function setPaused(bool _paused) external onlyOwner {
        // Ensure we're actually changing the state before we do anything
        if (_paused == paused) {
            return;
        }

        // Set our paused state.
        paused = _paused;

        // If applicable, set the last pause time.
        if (paused) {
            lastPauseTime = now;
        }

        // Let everyone know that our pause state has changed.
        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
}


// https://docs.peri.finance/contracts/source/interfaces/iaddressresolver



// https://docs.peri.finance/contracts/source/interfaces/ipynth



// https://docs.peri.finance/contracts/source/interfaces/iissuer



// Inheritance


// Internal references


// https://docs.peri.finance/contracts/source/contracts/addressresolver
contract AddressResolver is Owned, IAddressResolver {
    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}

    /* ========== RESTRICTED FUNCTIONS ========== */

    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {
        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            bytes32 name = names[i];
            address destination = destinations[i];
            repository[name] = destination;
            emit AddressImported(name, destination);
        }
    }

    /* ========= PUBLIC FUNCTIONS ========== */

    function rebuildCaches(MixinResolver[] calldata destinations) external {
        for (uint i = 0; i < destinations.length; i++) {
            destinations[i].rebuildCache();
        }
    }

    /* ========== VIEWS ========== */

    function areAddressesImported(bytes32[] calldata names, address[] calldata destinations) external view returns (bool) {
        for (uint i = 0; i < names.length; i++) {
            if (repository[names[i]] != destinations[i]) {
                return false;
            }
        }
        return true;
    }

    function getAddress(bytes32 name) external view returns (address) {
        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address) {
        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    function getPynth(bytes32 key) external view returns (address) {
        IIssuer issuer = IIssuer(repository["Issuer"]);
        require(address(issuer) != address(0), "Cannot find Issuer address");
        return address(issuer.pynths(key));
    }

    /* ========== EVENTS ========== */

    event AddressImported(bytes32 name, address destination);
}


// solhint-disable payable-fallback

// https://docs.peri.finance/contracts/source/contracts/readproxy
contract ReadProxy is Owned {
    address public target;

    constructor(address _owner) public Owned(_owner) {}

    function setTarget(address _target) external onlyOwner {
        target = _target;
        emit TargetUpdated(target);
    }

    function() external {
        // The basics of a proxy read call
        // Note that msg.sender in the underlying will always be the address of this contract.
        assembly {
            calldatacopy(0, 0, calldatasize)

            // Use of staticcall - this will revert if the underlying function mutates state
            let result := staticcall(gas, sload(target_slot), 0, calldatasize, 0, 0)
            returndatacopy(0, 0, returndatasize)

            if iszero(result) {
                revert(0, returndatasize)
            }
            return(0, returndatasize)
        }
    }

    event TargetUpdated(address newTarget);
}


// Inheritance


// Internal references


// https://docs.peri.finance/contracts/source/contracts/mixinresolver
contract MixinResolver {
    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    constructor(address _resolver) internal {
        resolver = AddressResolver(_resolver);
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function combineArrays(bytes32[] memory first, bytes32[] memory second)
        internal
        pure
        returns (bytes32[] memory combination)
    {
        combination = new bytes32[](first.length + second.length);

        for (uint i = 0; i < first.length; i++) {
            combination[i] = first[i];
        }

        for (uint j = 0; j < second.length; j++) {
            combination[first.length + j] = second[j];
        }
    }

    /* ========== PUBLIC FUNCTIONS ========== */

    // Note: this function is public not external in order for it to be overridden and invoked via super in subclasses
    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {}

    function rebuildCache() public {
        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        // The resolver must call this function whenver it updates its state
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            // Note: can only be invoked once the resolver has all the targets needed added
            address destination =
                resolver.requireAndGetAddress(name, string(abi.encodePacked("Resolver missing target: ", name)));
            addressCache[name] = destination;
            emit CacheUpdated(name, destination);
        }
    }

    /* ========== VIEWS ========== */

    function isResolverCached() external view returns (bool) {
        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            // false if our cache is invalid or if the resolver doesn't have the required address
            if (resolver.getAddress(name) != addressCache[name] || addressCache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function requireAndGetAddress(bytes32 name) internal view returns (address) {
        address _foundAddress = addressCache[name];
        require(_foundAddress != address(0), string(abi.encodePacked("Missing address: ", name)));
        return _foundAddress;
    }

    /* ========== EVENTS ========== */

    event CacheUpdated(bytes32 name, address destination);
}





// https://docs.peri.finance/contracts/source/libraries/addresssetlib/



// https://docs.peri.finance/contracts/source/libraries/bytes32setlib/



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



// Libraries


// https://docs.peri.finance/contracts/source/libraries/safedecimalmath



// Inheritance


// https://docs.peri.finance/contracts/source/contracts/state
contract State is Owned {
    // the address of the contract that can modify variables
    // this can only be changed by the owner of this contract
    address public associatedContract;

    constructor(address _associatedContract) internal {
        // This contract is abstract, and thus cannot be instantiated directly
        require(owner != address(0), "Owner must be set");

        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }

    /* ========== SETTERS ========== */

    // Change the associated contract to a new address
    function setAssociatedContract(address _associatedContract) external onlyOwner {
        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }

    /* ========== MODIFIERS ========== */

    modifier onlyAssociatedContract {
        require(msg.sender == associatedContract, "Only the associated contract can perform this action");
        _;
    }

    /* ========== EVENTS ========== */

    event AssociatedContractUpdated(address associatedContract);
}


pragma experimental ABIEncoderV2;

// Inheritance


// Libraries


contract CollateralManagerState is Owned, State {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    struct Balance {
        uint long;
        uint short;
    }

    uint public totalLoans;

    uint[] public borrowRates;
    uint public borrowRatesLastUpdated;

    mapping(bytes32 => uint[]) public shortRates;
    mapping(bytes32 => uint) public shortRatesLastUpdated;

    // The total amount of long and short for a pynth,
    mapping(bytes32 => Balance) public totalIssuedPynths;

    constructor(address _owner, address _associatedContract) public Owned(_owner) State(_associatedContract) {
        borrowRates.push(0);
        borrowRatesLastUpdated = block.timestamp;
    }

    function incrementTotalLoans() external onlyAssociatedContract returns (uint) {
        totalLoans = totalLoans.add(1);
        return totalLoans;
    }

    function long(bytes32 pynth) external view onlyAssociatedContract returns (uint) {
        return totalIssuedPynths[pynth].long;
    }

    function short(bytes32 pynth) external view onlyAssociatedContract returns (uint) {
        return totalIssuedPynths[pynth].short;
    }

    function incrementLongs(bytes32 pynth, uint256 amount) external onlyAssociatedContract {
        totalIssuedPynths[pynth].long = totalIssuedPynths[pynth].long.add(amount);
    }

    function decrementLongs(bytes32 pynth, uint256 amount) external onlyAssociatedContract {
        totalIssuedPynths[pynth].long = totalIssuedPynths[pynth].long.sub(amount);
    }

    function incrementShorts(bytes32 pynth, uint256 amount) external onlyAssociatedContract {
        totalIssuedPynths[pynth].short = totalIssuedPynths[pynth].short.add(amount);
    }

    function decrementShorts(bytes32 pynth, uint256 amount) external onlyAssociatedContract {
        totalIssuedPynths[pynth].short = totalIssuedPynths[pynth].short.sub(amount);
    }

    // Borrow rates, one array here for all currencies.

    function getRateAt(uint index) public view returns (uint) {
        return borrowRates[index];
    }

    function getRatesLength() public view returns (uint) {
        return borrowRates.length;
    }

    function updateBorrowRates(uint rate) external onlyAssociatedContract {
        borrowRates.push(rate);
        borrowRatesLastUpdated = block.timestamp;
    }

    function ratesLastUpdated() public view returns (uint) {
        return borrowRatesLastUpdated;
    }

    function getRatesAndTime(uint index)
        external
        view
        returns (
            uint entryRate,
            uint lastRate,
            uint lastUpdated,
            uint newIndex
        )
    {
        newIndex = getRatesLength();
        entryRate = getRateAt(index);
        lastRate = getRateAt(newIndex - 1);
        lastUpdated = ratesLastUpdated();
    }

    // Short rates, one array per currency.

    function addShortCurrency(bytes32 currency) external onlyAssociatedContract {
        if (shortRates[currency].length > 0) {} else {
            shortRates[currency].push(0);
            shortRatesLastUpdated[currency] = block.timestamp;
        }
    }

    function removeShortCurrency(bytes32 currency) external onlyAssociatedContract {
        delete shortRates[currency];
    }

    function getShortRateAt(bytes32 currency, uint index) internal view returns (uint) {
        return shortRates[currency][index];
    }

    function getShortRatesLength(bytes32 currency) public view returns (uint) {
        return shortRates[currency].length;
    }

    function updateShortRates(bytes32 currency, uint rate) external onlyAssociatedContract {
        shortRates[currency].push(rate);
        shortRatesLastUpdated[currency] = block.timestamp;
    }

    function shortRateLastUpdated(bytes32 currency) internal view returns (uint) {
        return shortRatesLastUpdated[currency];
    }

    function getShortRatesAndTime(bytes32 currency, uint index)
        external
        view
        returns (
            uint entryRate,
            uint lastRate,
            uint lastUpdated,
            uint newIndex
        )
    {
        newIndex = getShortRatesLength(currency);
        entryRate = getShortRateAt(currency, index);
        lastRate = getShortRateAt(currency, newIndex - 1);
        lastUpdated = shortRateLastUpdated(currency);
    }
}


// https://docs.peri.finance/contracts/source/interfaces/iexchangerates



// https://docs.peri.finance/contracts/source/interfaces/ierc20



// Inheritance


// Libraries


// Internal references


contract CollateralManager is ICollateralManager, Owned, Pausable, MixinResolver {
    /* ========== LIBRARIES ========== */
    using SafeMath for uint;
    using SafeDecimalMath for uint;
    using AddressSetLib for AddressSetLib.AddressSet;
    using Bytes32SetLib for Bytes32SetLib.Bytes32Set;

    /* ========== CONSTANTS ========== */

    bytes32 private constant pUSD = "pUSD";

    uint private constant SECONDS_IN_A_YEAR = 31556926 * 1e18;

    // Flexible storage names
    bytes32 public constant CONTRACT_NAME = "CollateralManager";
    bytes32 internal constant COLLATERAL_PYNTHS = "collateralPynth";

    /* ========== STATE VARIABLES ========== */

    // Stores debt balances and borrow rates.
    CollateralManagerState public state;

    // The set of all collateral contracts.
    AddressSetLib.AddressSet internal _collaterals;

    // The set of all pynths issuable by the various collateral contracts
    Bytes32SetLib.Bytes32Set internal _pynths;

    // Map from currency key to pynth contract name.
    mapping(bytes32 => bytes32) public pynthsByKey;

    // The set of all pynths that are shortable.
    Bytes32SetLib.Bytes32Set internal _shortablePynths;

    mapping(bytes32 => bytes32) public pynthToInversePynth;

    // The factor that will scale the utilisation ratio.
    uint public utilisationMultiplier = 1e18;

    // The maximum amount of debt in pUSD that can be issued by non peri collateral.
    uint public maxDebt;

    // The base interest rate applied to all borrows.
    uint public baseBorrowRate;

    // The base interest rate applied to all shorts.
    uint public baseShortRate;

    /* ---------- Address Resolver Configuration ---------- */

    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_EXRATES = "ExchangeRates";

    bytes32[24] private addressesToCache = [CONTRACT_ISSUER, CONTRACT_EXRATES];

    /* ========== CONSTRUCTOR ========== */
    constructor(
        CollateralManagerState _state,
        address _owner,
        address _resolver,
        uint _maxDebt,
        uint _baseBorrowRate,
        uint _baseShortRate
    ) public Owned(_owner) Pausable() MixinResolver(_resolver) {
        owner = msg.sender;
        state = _state;

        setMaxDebt(_maxDebt);
        setBaseBorrowRate(_baseBorrowRate);
        setBaseShortRate(_baseShortRate);

        owner = _owner;
    }

    /* ========== VIEWS ========== */

    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {
        bytes32[] memory staticAddresses = new bytes32[](2);
        staticAddresses[0] = CONTRACT_ISSUER;
        staticAddresses[1] = CONTRACT_EXRATES;

        // we want to cache the name of the pynth and the name of its corresponding iPynth
        bytes32[] memory shortAddresses;
        uint length = _shortablePynths.elements.length;

        if (length > 0) {
            shortAddresses = new bytes32[](length * 2);

            for (uint i = 0; i < length; i++) {
                shortAddresses[i] = _shortablePynths.elements[i];
                shortAddresses[i + length] = pynthToInversePynth[_shortablePynths.elements[i]];
            }
        }

        bytes32[] memory pynthAddresses = combineArrays(shortAddresses, _pynths.elements);

        if (pynthAddresses.length > 0) {
            addresses = combineArrays(pynthAddresses, staticAddresses);
        } else {
            addresses = staticAddresses;
        }
    }

    // helper function to check whether pynth "by key" is a collateral issued by multi-collateral
    function isPynthManaged(bytes32 currencyKey) external view returns (bool) {
        return pynthsByKey[currencyKey] != bytes32(0);
    }

    /* ---------- Related Contracts ---------- */

    function _issuer() internal view returns (IIssuer) {
        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER));
    }

    function _exchangeRates() internal view returns (IExchangeRates) {
        return IExchangeRates(requireAndGetAddress(CONTRACT_EXRATES));
    }

    function _pynth(bytes32 pynthName) internal view returns (IPynth) {
        return IPynth(requireAndGetAddress(pynthName));
    }

    /* ---------- Manager Information ---------- */

    function hasCollateral(address collateral) public view returns (bool) {
        return _collaterals.contains(collateral);
    }

    function hasAllCollaterals(address[] memory collaterals) public view returns (bool) {
        for (uint i = 0; i < collaterals.length; i++) {
            if (!hasCollateral(collaterals[i])) {
                return false;
            }
        }
        return true;
    }

    /* ---------- State Information ---------- */

    function long(bytes32 pynth) external view returns (uint amount) {
        return state.long(pynth);
    }

    function short(bytes32 pynth) external view returns (uint amount) {
        return state.short(pynth);
    }

    function totalLong() public view returns (uint pusdValue, bool anyRateIsInvalid) {
        bytes32[] memory pynths = _pynths.elements;

        if (pynths.length > 0) {
            for (uint i = 0; i < pynths.length; i++) {
                bytes32 pynth = _pynth(pynths[i]).currencyKey();
                if (pynth == pUSD) {
                    pusdValue = pusdValue.add(state.long(pynth));
                } else {
                    (uint rate, bool invalid) = _exchangeRates().rateAndInvalid(pynth);
                    uint amount = state.long(pynth).multiplyDecimal(rate);
                    pusdValue = pusdValue.add(amount);
                    if (invalid) {
                        anyRateIsInvalid = true;
                    }
                }
            }
        }
    }

    function totalShort() public view returns (uint pusdValue, bool anyRateIsInvalid) {
        bytes32[] memory pynths = _shortablePynths.elements;

        if (pynths.length > 0) {
            for (uint i = 0; i < pynths.length; i++) {
                bytes32 pynth = _pynth(pynths[i]).currencyKey();
                (uint rate, bool invalid) = _exchangeRates().rateAndInvalid(pynth);
                uint amount = state.short(pynth).multiplyDecimal(rate);
                pusdValue = pusdValue.add(amount);
                if (invalid) {
                    anyRateIsInvalid = true;
                }
            }
        }
    }

    function getBorrowRate() external view returns (uint borrowRate, bool anyRateIsInvalid) {
        // get the peri backed debt.
        uint periDebt = _issuer().totalIssuedPynths(pUSD, true);

        // now get the non peri backed debt.
        (uint nonPeriDebt, bool ratesInvalid) = totalLong();

        // the total.
        uint totalDebt = periDebt.add(nonPeriDebt);

        // now work out the utilisation ratio, and divide through to get a per second value.
        uint utilisation = nonPeriDebt.divideDecimal(totalDebt).divideDecimal(SECONDS_IN_A_YEAR);

        // scale it by the utilisation multiplier.
        uint scaledUtilisation = utilisation.multiplyDecimal(utilisationMultiplier);

        // finally, add the base borrow rate.
        borrowRate = scaledUtilisation.add(baseBorrowRate);

        anyRateIsInvalid = ratesInvalid;
    }

    function getShortRate(bytes32 pynth) external view returns (uint shortRate, bool rateIsInvalid) {
        bytes32 pynthKey = _pynth(pynth).currencyKey();

        rateIsInvalid = _exchangeRates().rateIsInvalid(pynthKey);

        // get the spot supply of the pynth, its iPynth
        uint longSupply = IERC20(address(_pynth(pynth))).totalSupply();
        uint inverseSupply = IERC20(address(_pynth(pynthToInversePynth[pynth]))).totalSupply();
        // add the iPynth to supply properly reflect the market skew.
        uint shortSupply = state.short(pynthKey).add(inverseSupply);

        // in this case, the market is skewed long so its free to short.
        if (longSupply > shortSupply) {
            return (0, rateIsInvalid);
        }

        // otherwise workout the skew towards the short side.
        uint skew = shortSupply.sub(longSupply);

        // divide through by the size of the market
        uint proportionalSkew = skew.divideDecimal(longSupply.add(shortSupply)).divideDecimal(SECONDS_IN_A_YEAR);

        // finally, add the base short rate.
        shortRate = proportionalSkew.add(baseShortRate);
    }

    function getRatesAndTime(uint index)
        external
        view
        returns (
            uint entryRate,
            uint lastRate,
            uint lastUpdated,
            uint newIndex
        )
    {
        (entryRate, lastRate, lastUpdated, newIndex) = state.getRatesAndTime(index);
    }

    function getShortRatesAndTime(bytes32 currency, uint index)
        external
        view
        returns (
            uint entryRate,
            uint lastRate,
            uint lastUpdated,
            uint newIndex
        )
    {
        (entryRate, lastRate, lastUpdated, newIndex) = state.getShortRatesAndTime(currency, index);
    }

    function exceedsDebtLimit(uint amount, bytes32 currency) external view returns (bool canIssue, bool anyRateIsInvalid) {
        uint usdAmount = _exchangeRates().effectiveValue(currency, amount, pUSD);

        (uint longValue, bool longInvalid) = totalLong();
        (uint shortValue, bool shortInvalid) = totalShort();

        anyRateIsInvalid = longInvalid || shortInvalid;

        return (longValue.add(shortValue).add(usdAmount) <= maxDebt, anyRateIsInvalid);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    /* ---------- SETTERS ---------- */

    function setUtilisationMultiplier(uint _utilisationMultiplier) public onlyOwner {
        require(_utilisationMultiplier > 0, "Must be greater than 0");
        utilisationMultiplier = _utilisationMultiplier;
    }

    function setMaxDebt(uint _maxDebt) public onlyOwner {
        require(_maxDebt > 0, "Must be greater than 0");
        maxDebt = _maxDebt;
        emit MaxDebtUpdated(maxDebt);
    }

    function setBaseBorrowRate(uint _baseBorrowRate) public onlyOwner {
        baseBorrowRate = _baseBorrowRate;
        emit BaseBorrowRateUpdated(baseBorrowRate);
    }

    function setBaseShortRate(uint _baseShortRate) public onlyOwner {
        baseShortRate = _baseShortRate;
        emit BaseShortRateUpdated(baseShortRate);
    }

    /* ---------- LOANS ---------- */

    function getNewLoanId() external onlyCollateral returns (uint id) {
        id = state.incrementTotalLoans();
    }

    /* ---------- MANAGER ---------- */

    function addCollaterals(address[] calldata collaterals) external onlyOwner {
        for (uint i = 0; i < collaterals.length; i++) {
            if (!_collaterals.contains(collaterals[i])) {
                _collaterals.add(collaterals[i]);
                emit CollateralAdded(collaterals[i]);
            }
        }
    }

    function removeCollaterals(address[] calldata collaterals) external onlyOwner {
        for (uint i = 0; i < collaterals.length; i++) {
            if (_collaterals.contains(collaterals[i])) {
                _collaterals.remove(collaterals[i]);
                emit CollateralRemoved(collaterals[i]);
            }
        }
    }

    function addPynths(bytes32[] calldata pynthNamesInResolver, bytes32[] calldata pynthKeys) external onlyOwner {
        for (uint i = 0; i < pynthNamesInResolver.length; i++) {
            if (!_pynths.contains(pynthNamesInResolver[i])) {
                bytes32 pynthName = pynthNamesInResolver[i];
                _pynths.add(pynthName);
                pynthsByKey[pynthKeys[i]] = pynthName;
                emit PynthAdded(pynthName);
            }
        }
    }

    function arePynthsAndCurrenciesSet(bytes32[] calldata requiredPynthNamesInResolver, bytes32[] calldata pynthKeys)
        external
        view
        returns (bool)
    {
        if (_pynths.elements.length != requiredPynthNamesInResolver.length) {
            return false;
        }

        for (uint i = 0; i < requiredPynthNamesInResolver.length; i++) {
            if (!_pynths.contains(requiredPynthNamesInResolver[i])) {
                return false;
            }
            if (pynthsByKey[pynthKeys[i]] != requiredPynthNamesInResolver[i]) {
                return false;
            }
        }

        return true;
    }

    function removePynths(bytes32[] calldata pynths, bytes32[] calldata pynthKeys) external onlyOwner {
        for (uint i = 0; i < pynths.length; i++) {
            if (_pynths.contains(pynths[i])) {
                // Remove it from the the address set lib.
                _pynths.remove(pynths[i]);
                delete pynthsByKey[pynthKeys[i]];

                emit PynthRemoved(pynths[i]);
            }
        }
    }

    // When we add a shortable pynth, we need to know the iPynth as well
    // This is so we can get the proper skew for the short rate.
    function addShortablePynths(bytes32[2][] calldata requiredPynthAndInverseNamesInResolver, bytes32[] calldata pynthKeys)
        external
        onlyOwner
    {
        require(requiredPynthAndInverseNamesInResolver.length == pynthKeys.length, "Input array length mismatch");

        for (uint i = 0; i < requiredPynthAndInverseNamesInResolver.length; i++) {
            // setting these explicitly for clarity
            // Each entry in the array is [Pynth, iPynth]
            bytes32 pynth = requiredPynthAndInverseNamesInResolver[i][0];
            bytes32 iPynth = requiredPynthAndInverseNamesInResolver[i][1];

            if (!_shortablePynths.contains(pynth)) {
                // Add it to the address set lib.
                _shortablePynths.add(pynth);

                // store the mapping to the iPynth so we can get its total supply for the borrow rate.
                pynthToInversePynth[pynth] = iPynth;

                emit ShortablePynthAdded(pynth);

                // now the associated pynth key to the CollateralManagerState
                state.addShortCurrency(pynthKeys[i]);
            }
        }

        rebuildCache();
    }

    function areShortablePynthsSet(bytes32[] calldata requiredPynthNamesInResolver, bytes32[] calldata pynthKeys)
        external
        view
        returns (bool)
    {
        require(requiredPynthNamesInResolver.length == pynthKeys.length, "Input array length mismatch");

        if (_shortablePynths.elements.length != requiredPynthNamesInResolver.length) {
            return false;
        }

        // first check contract state
        for (uint i = 0; i < requiredPynthNamesInResolver.length; i++) {
            bytes32 pynthName = requiredPynthNamesInResolver[i];
            if (!_shortablePynths.contains(pynthName) || pynthToInversePynth[pynthName] == bytes32(0)) {
                return false;
            }
        }

        // now check everything added to external state contract
        for (uint i = 0; i < pynthKeys.length; i++) {
            if (state.getShortRatesLength(pynthKeys[i]) == 0) {
                return false;
            }
        }

        return true;
    }

    function removeShortablePynths(bytes32[] calldata pynths) external onlyOwner {
        for (uint i = 0; i < pynths.length; i++) {
            if (_shortablePynths.contains(pynths[i])) {
                // Remove it from the the address set lib.
                _shortablePynths.remove(pynths[i]);

                bytes32 pynthKey = _pynth(pynths[i]).currencyKey();

                state.removeShortCurrency(pynthKey);

                // remove the inverse mapping.
                delete pynthToInversePynth[pynths[i]];

                emit ShortablePynthRemoved(pynths[i]);
            }
        }
    }

    /* ---------- STATE MUTATIONS ---------- */

    function updateBorrowRates(uint rate) external onlyCollateral {
        state.updateBorrowRates(rate);
    }

    function updateShortRates(bytes32 currency, uint rate) external onlyCollateral {
        state.updateShortRates(currency, rate);
    }

    function incrementLongs(bytes32 pynth, uint amount) external onlyCollateral {
        state.incrementLongs(pynth, amount);
    }

    function decrementLongs(bytes32 pynth, uint amount) external onlyCollateral {
        state.decrementLongs(pynth, amount);
    }

    function incrementShorts(bytes32 pynth, uint amount) external onlyCollateral {
        state.incrementShorts(pynth, amount);
    }

    function decrementShorts(bytes32 pynth, uint amount) external onlyCollateral {
        state.decrementShorts(pynth, amount);
    }

    /* ========== MODIFIERS ========== */

    modifier onlyCollateral {
        bool isMultiCollateral = hasCollateral(msg.sender);

        require(isMultiCollateral, "Only collateral contracts");
        _;
    }

    // ========== EVENTS ==========
    event MaxDebtUpdated(uint maxDebt);
    event LiquidationPenaltyUpdated(uint liquidationPenalty);
    event BaseBorrowRateUpdated(uint baseBorrowRate);
    event BaseShortRateUpdated(uint baseShortRate);

    event CollateralAdded(address collateral);
    event CollateralRemoved(address collateral);

    event PynthAdded(bytes32 pynth);
    event PynthRemoved(bytes32 pynth);

    event ShortablePynthAdded(bytes32 pynth);
    event ShortablePynthRemoved(bytes32 pynth);
}