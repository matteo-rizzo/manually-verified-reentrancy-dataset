/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

/*
    ___            _       ___  _                          
    | .\ ___  _ _ <_> ___ | __><_>._ _  ___ ._ _  ___  ___ 
    |  _// ._>| '_>| ||___|| _> | || ' |<_> || ' |/ | '/ ._>
    |_|  \___.|_|  |_|     |_|  |_||_|_|<___||_|_|\_|_.\___.
    
* PeriFinance: ExchangerWithVirtualPynth.sol
*
* Latest source (may be newer): https://github.com/perifinance/peri-finance/blob/master/contracts/ExchangerWithVirtualPynth.sol
* Docs: Will be added in the future. 
* https://docs.peri.finance/contracts/source/contracts/ExchangerWithVirtualPynth
*
* Contract Dependencies: 
*	- ERC20
*	- Exchanger
*	- IAddressResolver
*	- IERC20
*	- IExchanger
*	- IVirtualPynth
*	- MixinResolver
*	- MixinSystemSettings
*	- Owned
* Libraries: 
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


// https://docs.peri.finance/contracts/source/interfaces/iflexiblestorage



// Internal references


// https://docs.peri.finance/contracts/source/contracts/mixinsystemsettings
contract MixinSystemSettings is MixinResolver {
    bytes32 internal constant SETTING_CONTRACT_NAME = "SystemSettings";

    bytes32 internal constant SETTING_WAITING_PERIOD_SECS = "waitingPeriodSecs";
    bytes32 internal constant SETTING_PRICE_DEVIATION_THRESHOLD_FACTOR = "priceDeviationThresholdFactor";
    bytes32 internal constant SETTING_ISSUANCE_RATIO = "issuanceRatio";
    bytes32 internal constant SETTING_FEE_PERIOD_DURATION = "feePeriodDuration";
    bytes32 internal constant SETTING_TARGET_THRESHOLD = "targetThreshold";
    bytes32 internal constant SETTING_LIQUIDATION_DELAY = "liquidationDelay";
    bytes32 internal constant SETTING_LIQUIDATION_RATIO = "liquidationRatio";
    bytes32 internal constant SETTING_LIQUIDATION_PENALTY = "liquidationPenalty";
    bytes32 internal constant SETTING_RATE_STALE_PERIOD = "rateStalePeriod";
    bytes32 internal constant SETTING_EXCHANGE_FEE_RATE = "exchangeFeeRate";
    bytes32 internal constant SETTING_MINIMUM_STAKE_TIME = "minimumStakeTime";
    bytes32 internal constant SETTING_AGGREGATOR_WARNING_FLAGS = "aggregatorWarningFlags";
    bytes32 internal constant SETTING_TRADING_REWARDS_ENABLED = "tradingRewardsEnabled";
    bytes32 internal constant SETTING_DEBT_SNAPSHOT_STALE_TIME = "debtSnapshotStaleTime";
    bytes32 internal constant SETTING_CROSS_DOMAIN_DEPOSIT_GAS_LIMIT = "crossDomainDepositGasLimit";
    bytes32 internal constant SETTING_CROSS_DOMAIN_ESCROW_GAS_LIMIT = "crossDomainEscrowGasLimit";
    bytes32 internal constant SETTING_CROSS_DOMAIN_REWARD_GAS_LIMIT = "crossDomainRewardGasLimit";
    bytes32 internal constant SETTING_CROSS_DOMAIN_WITHDRAWAL_GAS_LIMIT = "crossDomainWithdrawalGasLimit";
    bytes32 internal constant SETTING_EXTERNAL_TOKEN_QUOTA = "externalTokenQuota";

    bytes32 internal constant CONTRACT_FLEXIBLESTORAGE = "FlexibleStorage";

    enum CrossDomainMessageGasLimits {Deposit, Escrow, Reward, Withdrawal}

    constructor(address _resolver) internal MixinResolver(_resolver) {}

    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {
        addresses = new bytes32[](1);
        addresses[0] = CONTRACT_FLEXIBLESTORAGE;
    }

    function flexibleStorage() internal view returns (IFlexibleStorage) {
        return IFlexibleStorage(requireAndGetAddress(CONTRACT_FLEXIBLESTORAGE));
    }

    function _getGasLimitSetting(CrossDomainMessageGasLimits gasLimitType) internal pure returns (bytes32) {
        if (gasLimitType == CrossDomainMessageGasLimits.Deposit) {
            return SETTING_CROSS_DOMAIN_DEPOSIT_GAS_LIMIT;
        } else if (gasLimitType == CrossDomainMessageGasLimits.Escrow) {
            return SETTING_CROSS_DOMAIN_ESCROW_GAS_LIMIT;
        } else if (gasLimitType == CrossDomainMessageGasLimits.Reward) {
            return SETTING_CROSS_DOMAIN_REWARD_GAS_LIMIT;
        } else if (gasLimitType == CrossDomainMessageGasLimits.Withdrawal) {
            return SETTING_CROSS_DOMAIN_WITHDRAWAL_GAS_LIMIT;
        } else {
            revert("Unknown gas limit type");
        }
    }

    function getCrossDomainMessageGasLimit(CrossDomainMessageGasLimits gasLimitType) internal view returns (uint) {
        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, _getGasLimitSetting(gasLimitType));
    }

    function getTradingRewardsEnabled() internal view returns (bool) {
        return flexibleStorage().getBoolValue(SETTING_CONTRACT_NAME, SETTING_TRADING_REWARDS_ENABLED);
    }

    function getWaitingPeriodSecs() internal view returns (uint) {
        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_WAITING_PERIOD_SECS);
    }

    function getPriceDeviationThresholdFactor() internal view returns (uint) {
        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_PRICE_DEVIATION_THRESHOLD_FACTOR);
    }

    function getIssuanceRatio() internal view returns (uint) {
        // lookup on flexible storage directly for gas savings (rather than via SystemSettings)
        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_ISSUANCE_RATIO);
    }

    function getFeePeriodDuration() internal view returns (uint) {
        // lookup on flexible storage directly for gas savings (rather than via SystemSettings)
        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_FEE_PERIOD_DURATION);
    }

    function getTargetThreshold() internal view returns (uint) {
        // lookup on flexible storage directly for gas savings (rather than via SystemSettings)
        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_TARGET_THRESHOLD);
    }

    function getLiquidationDelay() internal view returns (uint) {
        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_LIQUIDATION_DELAY);
    }

    function getLiquidationRatio() internal view returns (uint) {
        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_LIQUIDATION_RATIO);
    }

    function getLiquidationPenalty() internal view returns (uint) {
        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_LIQUIDATION_PENALTY);
    }

    function getRateStalePeriod() internal view returns (uint) {
        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_RATE_STALE_PERIOD);
    }

    function getExchangeFeeRate(bytes32 currencyKey) internal view returns (uint) {
        return
            flexibleStorage().getUIntValue(
                SETTING_CONTRACT_NAME,
                keccak256(abi.encodePacked(SETTING_EXCHANGE_FEE_RATE, currencyKey))
            );
    }

    function getMinimumStakeTime() internal view returns (uint) {
        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_MINIMUM_STAKE_TIME);
    }

    function getAggregatorWarningFlags() internal view returns (address) {
        return flexibleStorage().getAddressValue(SETTING_CONTRACT_NAME, SETTING_AGGREGATOR_WARNING_FLAGS);
    }

    function getDebtSnapshotStaleTime() internal view returns (uint) {
        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_DEBT_SNAPSHOT_STALE_TIME);
    }

    function getExternalTokenQuota() internal view returns (uint) {
        return flexibleStorage().getUIntValue(SETTING_CONTRACT_NAME, SETTING_EXTERNAL_TOKEN_QUOTA);
    }
}





// https://docs.peri.finance/contracts/source/interfaces/iexchanger



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



// https://docs.peri.finance/contracts/source/interfaces/isystemstatus



// https://docs.peri.finance/contracts/source/interfaces/iexchangestate



// https://docs.peri.finance/contracts/source/interfaces/iexchangerates



// https://docs.peri.finance/contracts/source/interfaces/iperiFinance



// https://docs.peri.finance/contracts/source/interfaces/ifeepool



// https://docs.peri.finance/contracts/source/interfaces/idelegateapprovals



// https://docs.peri.finance/contracts/source/interfaces/itradingrewards



// Inheritance


// Internal references


// https://docs.peri.finance/contracts/source/contracts/proxy
contract Proxy is Owned {
    Proxyable public target;

    constructor(address _owner) public Owned(_owner) {}

    function setTarget(Proxyable _target) external onlyOwner {
        target = _target;
        emit TargetUpdated(_target);
    }

    function _emit(
        bytes calldata callData,
        uint numTopics,
        bytes32 topic1,
        bytes32 topic2,
        bytes32 topic3,
        bytes32 topic4
    ) external onlyTarget {
        uint size = callData.length;
        bytes memory _callData = callData;

        assembly {
            /* The first 32 bytes of callData contain its length (as specified by the abi).
             * Length is assumed to be a uint256 and therefore maximum of 32 bytes
             * in length. It is also leftpadded to be a multiple of 32 bytes.
             * This means moving call_data across 32 bytes guarantees we correctly access
             * the data itself. */
            switch numTopics
                case 0 {
                    log0(add(_callData, 32), size)
                }
                case 1 {
                    log1(add(_callData, 32), size, topic1)
                }
                case 2 {
                    log2(add(_callData, 32), size, topic1, topic2)
                }
                case 3 {
                    log3(add(_callData, 32), size, topic1, topic2, topic3)
                }
                case 4 {
                    log4(add(_callData, 32), size, topic1, topic2, topic3, topic4)
                }
        }
    }

    // solhint-disable no-complex-fallback
    function() external payable {
        // Mutable call setting Proxyable.messageSender as this is using call not delegatecall
        target.setMessageSender(msg.sender);

        assembly {
            let free_ptr := mload(0x40)
            calldatacopy(free_ptr, 0, calldatasize)

            /* We must explicitly forward ether to the underlying contract as well. */
            let result := call(gas, sload(target_slot), callvalue, free_ptr, calldatasize, 0, 0)
            returndatacopy(free_ptr, 0, returndatasize)

            if iszero(result) {
                revert(free_ptr, returndatasize)
            }
            return(free_ptr, returndatasize)
        }
    }

    modifier onlyTarget {
        require(Proxyable(msg.sender) == target, "Must be proxy target");
        _;
    }

    event TargetUpdated(Proxyable newTarget);
}


// Inheritance


// Internal references


// https://docs.peri.finance/contracts/source/contracts/proxyable
contract Proxyable is Owned {
    // This contract should be treated like an abstract contract

    /* The proxy this contract exists behind. */
    Proxy public proxy;
    Proxy public integrationProxy;

    /* The caller of the proxy, passed through to this contract.
     * Note that every function using this member must apply the onlyProxy or
     * optionalProxy modifiers, otherwise their invocations can use stale values. */
    address public messageSender;

    constructor(address payable _proxy) internal {
        // This contract is abstract, and thus cannot be instantiated directly
        require(owner != address(0), "Owner must be set");

        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setProxy(address payable _proxy) external onlyOwner {
        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setIntegrationProxy(address payable _integrationProxy) external onlyOwner {
        integrationProxy = Proxy(_integrationProxy);
    }

    function setMessageSender(address sender) external onlyProxy {
        messageSender = sender;
    }

    modifier onlyProxy {
        _onlyProxy();
        _;
    }

    function _onlyProxy() private view {
        require(Proxy(msg.sender) == proxy || Proxy(msg.sender) == integrationProxy, "Only the proxy can call");
    }

    modifier optionalProxy {
        _optionalProxy();
        _;
    }

    function _optionalProxy() private {
        if (Proxy(msg.sender) != proxy && Proxy(msg.sender) != integrationProxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
    }

    modifier optionalProxy_onlyOwner {
        _optionalProxy_onlyOwner();
        _;
    }

    // solhint-disable-next-line func-name-mixedcase
    function _optionalProxy_onlyOwner() private {
        if (Proxy(msg.sender) != proxy && Proxy(msg.sender) != integrationProxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
        require(messageSender == owner, "Owner only function");
    }

    event ProxyUpdated(address proxyAddress);
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */



// Inheritance


// Libraries


// Internal references


// Note: use OZ's IERC20 here as using ours will complain about conflicting names
// during the build (VirtualPynth has IERC20 from the OZ ERC20 implementation)


// Used to have strongly-typed access to internal mutative functions in PeriFinance




// https://docs.peri.finance/contracts/source/contracts/exchanger
contract Exchanger is Owned, MixinSystemSettings, IExchanger {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    struct ExchangeEntrySettlement {
        bytes32 src;
        uint amount;
        bytes32 dest;
        uint reclaim;
        uint rebate;
        uint srcRoundIdAtPeriodEnd;
        uint destRoundIdAtPeriodEnd;
        uint timestamp;
    }

    bytes32 private constant pUSD = "pUSD";

    // SIP-65: Decentralized circuit breaker
    uint public constant CIRCUIT_BREAKER_SUSPENSION_REASON = 65;

    mapping(bytes32 => uint) public lastExchangeRate;

    /* ========== ADDRESS RESOLVER CONFIGURATION ========== */

    bytes32 private constant CONTRACT_SYSTEMSTATUS = "SystemStatus";
    bytes32 private constant CONTRACT_EXCHANGESTATE = "ExchangeState";
    bytes32 private constant CONTRACT_EXRATES = "ExchangeRates";
    bytes32 private constant CONTRACT_PERIFINANCE = "PeriFinance";
    bytes32 private constant CONTRACT_FEEPOOL = "FeePool";
    bytes32 private constant CONTRACT_TRADING_REWARDS = "TradingRewards";
    bytes32 private constant CONTRACT_DELEGATEAPPROVALS = "DelegateApprovals";
    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_DEBTCACHE = "DebtCache";

    constructor(address _owner, address _resolver) public Owned(_owner) MixinSystemSettings(_resolver) {}

    /* ========== VIEWS ========== */

    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {
        bytes32[] memory existingAddresses = MixinSystemSettings.resolverAddressesRequired();
        bytes32[] memory newAddresses = new bytes32[](9);
        newAddresses[0] = CONTRACT_SYSTEMSTATUS;
        newAddresses[1] = CONTRACT_EXCHANGESTATE;
        newAddresses[2] = CONTRACT_EXRATES;
        newAddresses[3] = CONTRACT_PERIFINANCE;
        newAddresses[4] = CONTRACT_FEEPOOL;
        newAddresses[5] = CONTRACT_TRADING_REWARDS;
        newAddresses[6] = CONTRACT_DELEGATEAPPROVALS;
        newAddresses[7] = CONTRACT_ISSUER;
        newAddresses[8] = CONTRACT_DEBTCACHE;
        addresses = combineArrays(existingAddresses, newAddresses);
    }

    function systemStatus() internal view returns (ISystemStatus) {
        return ISystemStatus(requireAndGetAddress(CONTRACT_SYSTEMSTATUS));
    }

    function exchangeState() internal view returns (IExchangeState) {
        return IExchangeState(requireAndGetAddress(CONTRACT_EXCHANGESTATE));
    }

    function exchangeRates() internal view returns (IExchangeRates) {
        return IExchangeRates(requireAndGetAddress(CONTRACT_EXRATES));
    }

    function periFinance() internal view returns (IPeriFinance) {
        return IPeriFinance(requireAndGetAddress(CONTRACT_PERIFINANCE));
    }

    function feePool() internal view returns (IFeePool) {
        return IFeePool(requireAndGetAddress(CONTRACT_FEEPOOL));
    }

    function tradingRewards() internal view returns (ITradingRewards) {
        return ITradingRewards(requireAndGetAddress(CONTRACT_TRADING_REWARDS));
    }

    function delegateApprovals() internal view returns (IDelegateApprovals) {
        return IDelegateApprovals(requireAndGetAddress(CONTRACT_DELEGATEAPPROVALS));
    }

    function issuer() internal view returns (IIssuer) {
        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER));
    }

    function debtCache() internal view returns (IExchangerInternalDebtCache) {
        return IExchangerInternalDebtCache(requireAndGetAddress(CONTRACT_DEBTCACHE));
    }

    function maxSecsLeftInWaitingPeriod(address account, bytes32 currencyKey) public view returns (uint) {
        return secsLeftInWaitingPeriodForExchange(exchangeState().getMaxTimestamp(account, currencyKey));
    }

    function waitingPeriodSecs() external view returns (uint) {
        return getWaitingPeriodSecs();
    }

    function tradingRewardsEnabled() external view returns (bool) {
        return getTradingRewardsEnabled();
    }

    function priceDeviationThresholdFactor() external view returns (uint) {
        return getPriceDeviationThresholdFactor();
    }

    function settlementOwing(address account, bytes32 currencyKey)
        public
        view
        returns (
            uint reclaimAmount,
            uint rebateAmount,
            uint numEntries
        )
    {
        (reclaimAmount, rebateAmount, numEntries, ) = _settlementOwing(account, currencyKey);
    }

    // Internal function to emit events for each individual rebate and reclaim entry
    function _settlementOwing(address account, bytes32 currencyKey)
        internal
        view
        returns (
            uint reclaimAmount,
            uint rebateAmount,
            uint numEntries,
            ExchangeEntrySettlement[] memory
        )
    {
        // Need to sum up all reclaim and rebate amounts for the user and the currency key
        numEntries = exchangeState().getLengthOfEntries(account, currencyKey);

        // For each unsettled exchange
        ExchangeEntrySettlement[] memory settlements = new ExchangeEntrySettlement[](numEntries);
        for (uint i = 0; i < numEntries; i++) {
            uint reclaim;
            uint rebate;
            // fetch the entry from storage
            IExchangeState.ExchangeEntry memory exchangeEntry = _getExchangeEntry(account, currencyKey, i);

            // determine the last round ids for src and dest pairs when period ended or latest if not over
            (uint srcRoundIdAtPeriodEnd, uint destRoundIdAtPeriodEnd) = getRoundIdsAtPeriodEnd(exchangeEntry);

            // given these round ids, determine what effective value they should have received
            uint destinationAmount =
                exchangeRates().effectiveValueAtRound(
                    exchangeEntry.src,
                    exchangeEntry.amount,
                    exchangeEntry.dest,
                    srcRoundIdAtPeriodEnd,
                    destRoundIdAtPeriodEnd
                );

            // and deduct the fee from this amount using the exchangeFeeRate from storage
            uint amountShouldHaveReceived = _getAmountReceivedForExchange(destinationAmount, exchangeEntry.exchangeFeeRate);

            // SIP-65 settlements where the amount at end of waiting period is beyond the threshold, then
            // settle with no reclaim or rebate
            if (!_isDeviationAboveThreshold(exchangeEntry.amountReceived, amountShouldHaveReceived)) {
                if (exchangeEntry.amountReceived > amountShouldHaveReceived) {
                    // if they received more than they should have, add to the reclaim tally
                    reclaim = exchangeEntry.amountReceived.sub(amountShouldHaveReceived);
                    reclaimAmount = reclaimAmount.add(reclaim);
                } else if (amountShouldHaveReceived > exchangeEntry.amountReceived) {
                    // if less, add to the rebate tally
                    rebate = amountShouldHaveReceived.sub(exchangeEntry.amountReceived);
                    rebateAmount = rebateAmount.add(rebate);
                }
            }

            settlements[i] = ExchangeEntrySettlement({
                src: exchangeEntry.src,
                amount: exchangeEntry.amount,
                dest: exchangeEntry.dest,
                reclaim: reclaim,
                rebate: rebate,
                srcRoundIdAtPeriodEnd: srcRoundIdAtPeriodEnd,
                destRoundIdAtPeriodEnd: destRoundIdAtPeriodEnd,
                timestamp: exchangeEntry.timestamp
            });
        }

        return (reclaimAmount, rebateAmount, numEntries, settlements);
    }

    function _getExchangeEntry(
        address account,
        bytes32 currencyKey,
        uint index
    ) internal view returns (IExchangeState.ExchangeEntry memory) {
        (
            bytes32 src,
            uint amount,
            bytes32 dest,
            uint amountReceived,
            uint exchangeFeeRate,
            uint timestamp,
            uint roundIdForSrc,
            uint roundIdForDest
        ) = exchangeState().getEntryAt(account, currencyKey, index);

        return
            IExchangeState.ExchangeEntry({
                src: src,
                amount: amount,
                dest: dest,
                amountReceived: amountReceived,
                exchangeFeeRate: exchangeFeeRate,
                timestamp: timestamp,
                roundIdForSrc: roundIdForSrc,
                roundIdForDest: roundIdForDest
            });
    }

    function hasWaitingPeriodOrSettlementOwing(address account, bytes32 currencyKey) external view returns (bool) {
        if (maxSecsLeftInWaitingPeriod(account, currencyKey) != 0) {
            return true;
        }

        (uint reclaimAmount, , , ) = _settlementOwing(account, currencyKey);

        return reclaimAmount > 0;
    }

    /* ========== SETTERS ========== */

    function calculateAmountAfterSettlement(
        address from,
        bytes32 currencyKey,
        uint amount,
        uint refunded
    ) public view returns (uint amountAfterSettlement) {
        amountAfterSettlement = amount;

        // balance of a pynth will show an amount after settlement
        uint balanceOfSourceAfterSettlement = IERC20(address(issuer().pynths(currencyKey))).balanceOf(from);

        // when there isn't enough supply (either due to reclamation settlement or because the number is too high)
        if (amountAfterSettlement > balanceOfSourceAfterSettlement) {
            // then the amount to exchange is reduced to their remaining supply
            amountAfterSettlement = balanceOfSourceAfterSettlement;
        }

        if (refunded > 0) {
            amountAfterSettlement = amountAfterSettlement.add(refunded);
        }
    }

    function isPynthRateInvalid(bytes32 currencyKey) external view returns (bool) {
        return _isPynthRateInvalid(currencyKey, exchangeRates().rateForCurrency(currencyKey));
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    function exchange(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress
    ) external onlyPeriFinanceorPynth returns (uint amountReceived) {
        uint fee;
        (amountReceived, fee, ) = _exchange(
            from,
            sourceCurrencyKey,
            sourceAmount,
            destinationCurrencyKey,
            destinationAddress,
            false
        );

        _processTradingRewards(fee, destinationAddress);
    }

    function exchangeOnBehalf(
        address exchangeForAddress,
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external onlyPeriFinanceorPynth returns (uint amountReceived) {
        require(delegateApprovals().canExchangeFor(exchangeForAddress, from), "Not approved to act on behalf");

        uint fee;
        (amountReceived, fee, ) = _exchange(
            exchangeForAddress,
            sourceCurrencyKey,
            sourceAmount,
            destinationCurrencyKey,
            exchangeForAddress,
            false
        );

        _processTradingRewards(fee, exchangeForAddress);
    }

    function exchangeWithTracking(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress,
        address originator,
        bytes32 trackingCode
    ) external onlyPeriFinanceorPynth returns (uint amountReceived) {
        uint fee;
        (amountReceived, fee, ) = _exchange(
            from,
            sourceCurrencyKey,
            sourceAmount,
            destinationCurrencyKey,
            destinationAddress,
            false
        );

        _processTradingRewards(fee, originator);

        _emitTrackingEvent(trackingCode, destinationCurrencyKey, amountReceived);
    }

    function exchangeOnBehalfWithTracking(
        address exchangeForAddress,
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address originator,
        bytes32 trackingCode
    ) external onlyPeriFinanceorPynth returns (uint amountReceived) {
        require(delegateApprovals().canExchangeFor(exchangeForAddress, from), "Not approved to act on behalf");

        uint fee;
        (amountReceived, fee, ) = _exchange(
            exchangeForAddress,
            sourceCurrencyKey,
            sourceAmount,
            destinationCurrencyKey,
            exchangeForAddress,
            false
        );

        _processTradingRewards(fee, originator);

        _emitTrackingEvent(trackingCode, destinationCurrencyKey, amountReceived);
    }

    function exchangeWithVirtual(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress,
        bytes32 trackingCode
    ) external onlyPeriFinanceorPynth returns (uint amountReceived, IVirtualPynth vPynth) {
        uint fee;
        (amountReceived, fee, vPynth) = _exchange(
            from,
            sourceCurrencyKey,
            sourceAmount,
            destinationCurrencyKey,
            destinationAddress,
            true
        );

        _processTradingRewards(fee, destinationAddress);

        if (trackingCode != bytes32(0)) {
            _emitTrackingEvent(trackingCode, destinationCurrencyKey, amountReceived);
        }
    }

    function _emitTrackingEvent(
        bytes32 trackingCode,
        bytes32 toCurrencyKey,
        uint256 toAmount
    ) internal {
        IPeriFinanceInternal(address(periFinance())).emitExchangeTracking(trackingCode, toCurrencyKey, toAmount);
    }

    function _processTradingRewards(uint fee, address originator) internal {
        if (fee > 0 && originator != address(0) && getTradingRewardsEnabled()) {
            tradingRewards().recordExchangeFeeForAccount(fee, originator);
        }
    }

    function _suspendIfRateInvalid(bytes32 currencyKey, uint rate) internal returns (bool circuitBroken) {
        if (_isPynthRateInvalid(currencyKey, rate)) {
            systemStatus().suspendPynth(currencyKey, CIRCUIT_BREAKER_SUSPENSION_REASON);
            circuitBroken = true;
        } else {
            lastExchangeRate[currencyKey] = rate;
        }
    }

    function _updatePERIIssuedDebtOnExchange(bytes32[2] memory currencyKeys, uint[2] memory currencyRates) internal {
        bool includesPUSD = currencyKeys[0] == pUSD || currencyKeys[1] == pUSD;
        uint numKeys = includesPUSD ? 2 : 3;

        bytes32[] memory keys = new bytes32[](numKeys);
        keys[0] = currencyKeys[0];
        keys[1] = currencyKeys[1];

        uint[] memory rates = new uint[](numKeys);
        rates[0] = currencyRates[0];
        rates[1] = currencyRates[1];

        if (!includesPUSD) {
            keys[2] = pUSD; // And we'll also update pUSD to account for any fees if it wasn't one of the exchanged currencies
            rates[2] = SafeDecimalMath.unit();
        }

        // Note that exchanges can't invalidate the debt cache, since if a rate is invalid,
        // the exchange will have failed already.
        debtCache().updateCachedPynthDebtsWithRates(keys, rates);
    }

    function _settleAndCalcSourceAmountRemaining(
        uint sourceAmount,
        address from,
        bytes32 sourceCurrencyKey
    ) internal returns (uint sourceAmountAfterSettlement) {
        (, uint refunded, uint numEntriesSettled) = _internalSettle(from, sourceCurrencyKey, false);

        sourceAmountAfterSettlement = sourceAmount;

        // when settlement was required
        if (numEntriesSettled > 0) {
            // ensure the sourceAmount takes this into account
            sourceAmountAfterSettlement = calculateAmountAfterSettlement(from, sourceCurrencyKey, sourceAmount, refunded);
        }
    }

    function _exchange(
        address from,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address destinationAddress,
        bool virtualPynth
    )
        internal
        returns (
            uint amountReceived,
            uint fee,
            IVirtualPynth vPynth
        )
    {
        _ensureCanExchange(sourceCurrencyKey, sourceAmount, destinationCurrencyKey);

        uint sourceAmountAfterSettlement = _settleAndCalcSourceAmountRemaining(sourceAmount, from, sourceCurrencyKey);

        // If, after settlement the user has no balance left (highly unlikely), then return to prevent
        // emitting events of 0 and don't revert so as to ensure the settlement queue is emptied
        if (sourceAmountAfterSettlement == 0) {
            return (0, 0, IVirtualPynth(0));
        }

        uint exchangeFeeRate;
        uint sourceRate;
        uint destinationRate;

        // Note: `fee` is denominated in the destinationCurrencyKey.
        (amountReceived, fee, exchangeFeeRate, sourceRate, destinationRate) = _getAmountsForExchangeMinusFees(
            sourceAmountAfterSettlement,
            sourceCurrencyKey,
            destinationCurrencyKey
        );

        // SIP-65: Decentralized Circuit Breaker
        if (
            _suspendIfRateInvalid(sourceCurrencyKey, sourceRate) ||
            _suspendIfRateInvalid(destinationCurrencyKey, destinationRate)
        ) {
            return (0, 0, IVirtualPynth(0));
        }

        // Note: We don't need to check their balance as the burn() below will do a safe subtraction which requires
        // the subtraction to not overflow, which would happen if their balance is not sufficient.

        vPynth = _convert(
            sourceCurrencyKey,
            from,
            sourceAmountAfterSettlement,
            destinationCurrencyKey,
            amountReceived,
            destinationAddress,
            virtualPynth
        );

        // When using a virtual pynth, it becomes the destinationAddress for event and settlement tracking
        if (vPynth != IVirtualPynth(0)) {
            destinationAddress = address(vPynth);
        }

        // Remit the fee if required
        if (fee > 0) {
            // Normalize fee to pUSD
            // Note: `fee` is being reused to avoid stack too deep errors.
            fee = exchangeRates().effectiveValue(destinationCurrencyKey, fee, pUSD);

            // Remit the fee in pUSDs
            issuer().pynths(pUSD).issue(feePool().FEE_ADDRESS(), fee);

            // Tell the fee pool about this
            feePool().recordFeePaid(fee);
        }

        // Note: As of this point, `fee` is denominated in pUSD.

        // Nothing changes as far as issuance data goes because the total value in the system hasn't changed.
        // But we will update the debt snapshot in case exchange rates have fluctuated since the last exchange
        // in these currencies
        _updatePERIIssuedDebtOnExchange([sourceCurrencyKey, destinationCurrencyKey], [sourceRate, destinationRate]);

        // Let the DApps know there was a Pynth exchange
        IPeriFinanceInternal(address(periFinance())).emitPynthExchange(
            from,
            sourceCurrencyKey,
            sourceAmountAfterSettlement,
            destinationCurrencyKey,
            amountReceived,
            destinationAddress
        );

        // iff the waiting period is gt 0
        if (getWaitingPeriodSecs() > 0) {
            // persist the exchange information for the dest key
            appendExchange(
                destinationAddress,
                sourceCurrencyKey,
                sourceAmountAfterSettlement,
                destinationCurrencyKey,
                amountReceived,
                exchangeFeeRate
            );
        }
    }

    function _convert(
        bytes32 sourceCurrencyKey,
        address from,
        uint sourceAmountAfterSettlement,
        bytes32 destinationCurrencyKey,
        uint amountReceived,
        address recipient,
        bool virtualPynth
    ) internal returns (IVirtualPynth vPynth) {
        // Burn the source amount
        issuer().pynths(sourceCurrencyKey).burn(from, sourceAmountAfterSettlement);

        // Issue their new pynths
        IPynth dest = issuer().pynths(destinationCurrencyKey);

        if (virtualPynth) {
            Proxyable pynth = Proxyable(address(dest));
            vPynth = _createVirtualPynth(IERC20(address(pynth.proxy())), recipient, amountReceived, destinationCurrencyKey);
            dest.issue(address(vPynth), amountReceived);
        } else {
            dest.issue(recipient, amountReceived);
        }
    }

    function _createVirtualPynth(
        IERC20,
        address,
        uint,
        bytes32
    ) internal returns (IVirtualPynth) {
        revert("Cannot be run on this layer");
    }

    // Note: this function can intentionally be called by anyone on behalf of anyone else (the caller just pays the gas)
    function settle(address from, bytes32 currencyKey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntriesSettled
        )
    {
        systemStatus().requirePynthActive(currencyKey);
        return _internalSettle(from, currencyKey, true);
    }

    function suspendPynthWithInvalidRate(bytes32 currencyKey) external {
        systemStatus().requireSystemActive();
        require(issuer().pynths(currencyKey) != IPynth(0), "No such pynth");
        require(_isPynthRateInvalid(currencyKey, exchangeRates().rateForCurrency(currencyKey)), "Pynth price is valid");
        systemStatus().suspendPynth(currencyKey, CIRCUIT_BREAKER_SUSPENSION_REASON);
    }

    // SIP-78
    function setLastExchangeRateForPynth(bytes32 currencyKey, uint rate) external onlyExchangeRates {
        require(rate > 0, "Rate must be above 0");
        lastExchangeRate[currencyKey] = rate;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    function _ensureCanExchange(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) internal view {
        require(sourceCurrencyKey != destinationCurrencyKey, "Can't be same pynth");
        require(sourceAmount > 0, "Zero amount");

        bytes32[] memory pynthKeys = new bytes32[](2);
        pynthKeys[0] = sourceCurrencyKey;
        pynthKeys[1] = destinationCurrencyKey;
        require(!exchangeRates().anyRateIsInvalid(pynthKeys), "Src/dest rate invalid or not found");
    }

    function _isPynthRateInvalid(bytes32 currencyKey, uint currentRate) internal view returns (bool) {
        if (currentRate == 0) {
            return true;
        }

        uint lastRateFromExchange = lastExchangeRate[currencyKey];

        if (lastRateFromExchange > 0) {
            return _isDeviationAboveThreshold(lastRateFromExchange, currentRate);
        }

        // if no last exchange for this pynth, then we need to look up last 3 rates (+1 for current rate)
        (uint[] memory rates, ) = exchangeRates().ratesAndUpdatedTimeForCurrencyLastNRounds(currencyKey, 4);

        // start at index 1 to ignore current rate
        for (uint i = 1; i < rates.length; i++) {
            // ignore any empty rates in the past (otherwise we will never be able to get validity)
            if (rates[i] > 0 && _isDeviationAboveThreshold(rates[i], currentRate)) {
                return true;
            }
        }

        return false;
    }

    function _isDeviationAboveThreshold(uint base, uint comparison) internal view returns (bool) {
        if (base == 0 || comparison == 0) {
            return true;
        }

        uint factor;
        if (comparison > base) {
            factor = comparison.divideDecimal(base);
        } else {
            factor = base.divideDecimal(comparison);
        }

        return factor >= getPriceDeviationThresholdFactor();
    }

    function _internalSettle(
        address from,
        bytes32 currencyKey,
        bool updateCache
    )
        internal
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntriesSettled
        )
    {
        require(maxSecsLeftInWaitingPeriod(from, currencyKey) == 0, "Cannot settle during waiting period");

        (uint reclaimAmount, uint rebateAmount, uint entries, ExchangeEntrySettlement[] memory settlements) =
            _settlementOwing(from, currencyKey);

        if (reclaimAmount > rebateAmount) {
            reclaimed = reclaimAmount.sub(rebateAmount);
            reclaim(from, currencyKey, reclaimed);
        } else if (rebateAmount > reclaimAmount) {
            refunded = rebateAmount.sub(reclaimAmount);
            refund(from, currencyKey, refunded);
        }

        if (updateCache) {
            bytes32[] memory key = new bytes32[](1);
            key[0] = currencyKey;
            debtCache().updateCachedPynthDebts(key);
        }

        // emit settlement event for each settled exchange entry
        for (uint i = 0; i < settlements.length; i++) {
            emit ExchangeEntrySettled(
                from,
                settlements[i].src,
                settlements[i].amount,
                settlements[i].dest,
                settlements[i].reclaim,
                settlements[i].rebate,
                settlements[i].srcRoundIdAtPeriodEnd,
                settlements[i].destRoundIdAtPeriodEnd,
                settlements[i].timestamp
            );
        }

        numEntriesSettled = entries;

        // Now remove all entries, even if no reclaim and no rebate
        exchangeState().removeEntries(from, currencyKey);
    }

    function reclaim(
        address from,
        bytes32 currencyKey,
        uint amount
    ) internal {
        // burn amount from user
        issuer().pynths(currencyKey).burn(from, amount);
        IPeriFinanceInternal(address(periFinance())).emitExchangeReclaim(from, currencyKey, amount);
    }

    function refund(
        address from,
        bytes32 currencyKey,
        uint amount
    ) internal {
        // issue amount to user
        issuer().pynths(currencyKey).issue(from, amount);
        IPeriFinanceInternal(address(periFinance())).emitExchangeRebate(from, currencyKey, amount);
    }

    function secsLeftInWaitingPeriodForExchange(uint timestamp) internal view returns (uint) {
        uint _waitingPeriodSecs = getWaitingPeriodSecs();
        if (timestamp == 0 || now >= timestamp.add(_waitingPeriodSecs)) {
            return 0;
        }

        return timestamp.add(_waitingPeriodSecs).sub(now);
    }

    function feeRateForExchange(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey)
        external
        view
        returns (uint exchangeFeeRate)
    {
        exchangeFeeRate = _feeRateForExchange(sourceCurrencyKey, destinationCurrencyKey);
    }

    function _feeRateForExchange(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey)
        internal
        view
        returns (uint exchangeFeeRate)
    {
        // Get the exchange fee rate as per destination currencyKey
        exchangeFeeRate = getExchangeFeeRate(destinationCurrencyKey);

        if (sourceCurrencyKey == pUSD || destinationCurrencyKey == pUSD) {
            return exchangeFeeRate;
        }

        // Is this a swing trade? long to short or short to long skipping pUSD.
        if (
            (sourceCurrencyKey[0] == 0x73 && destinationCurrencyKey[0] == 0x69) ||
            (sourceCurrencyKey[0] == 0x69 && destinationCurrencyKey[0] == 0x73)
        ) {
            // Double the exchange fee
            exchangeFeeRate = exchangeFeeRate.mul(2);
        }

        return exchangeFeeRate;
    }

    function getAmountsForExchange(
        uint sourceAmount,
        bytes32 sourceCurrencyKey,
        bytes32 destinationCurrencyKey
    )
        external
        view
        returns (
            uint amountReceived,
            uint fee,
            uint exchangeFeeRate
        )
    {
        (amountReceived, fee, exchangeFeeRate, , ) = _getAmountsForExchangeMinusFees(
            sourceAmount,
            sourceCurrencyKey,
            destinationCurrencyKey
        );
    }

    function _getAmountsForExchangeMinusFees(
        uint sourceAmount,
        bytes32 sourceCurrencyKey,
        bytes32 destinationCurrencyKey
    )
        internal
        view
        returns (
            uint amountReceived,
            uint fee,
            uint exchangeFeeRate,
            uint sourceRate,
            uint destinationRate
        )
    {
        uint destinationAmount;
        (destinationAmount, sourceRate, destinationRate) = exchangeRates().effectiveValueAndRates(
            sourceCurrencyKey,
            sourceAmount,
            destinationCurrencyKey
        );
        exchangeFeeRate = _feeRateForExchange(sourceCurrencyKey, destinationCurrencyKey);
        amountReceived = _getAmountReceivedForExchange(destinationAmount, exchangeFeeRate);
        fee = destinationAmount.sub(amountReceived);
    }

    function _getAmountReceivedForExchange(uint destinationAmount, uint exchangeFeeRate)
        internal
        pure
        returns (uint amountReceived)
    {
        amountReceived = destinationAmount.multiplyDecimal(SafeDecimalMath.unit().sub(exchangeFeeRate));
    }

    function appendExchange(
        address account,
        bytes32 src,
        uint amount,
        bytes32 dest,
        uint amountReceived,
        uint exchangeFeeRate
    ) internal {
        IExchangeRates exRates = exchangeRates();
        uint roundIdForSrc = exRates.getCurrentRoundId(src);
        uint roundIdForDest = exRates.getCurrentRoundId(dest);
        exchangeState().appendExchangeEntry(
            account,
            src,
            amount,
            dest,
            amountReceived,
            exchangeFeeRate,
            now,
            roundIdForSrc,
            roundIdForDest
        );

        emit ExchangeEntryAppended(
            account,
            src,
            amount,
            dest,
            amountReceived,
            exchangeFeeRate,
            roundIdForSrc,
            roundIdForDest
        );
    }

    function getRoundIdsAtPeriodEnd(IExchangeState.ExchangeEntry memory exchangeEntry)
        internal
        view
        returns (uint srcRoundIdAtPeriodEnd, uint destRoundIdAtPeriodEnd)
    {
        IExchangeRates exRates = exchangeRates();
        uint _waitingPeriodSecs = getWaitingPeriodSecs();

        srcRoundIdAtPeriodEnd = exRates.getLastRoundIdBeforeElapsedSecs(
            exchangeEntry.src,
            exchangeEntry.roundIdForSrc,
            exchangeEntry.timestamp,
            _waitingPeriodSecs
        );
        destRoundIdAtPeriodEnd = exRates.getLastRoundIdBeforeElapsedSecs(
            exchangeEntry.dest,
            exchangeEntry.roundIdForDest,
            exchangeEntry.timestamp,
            _waitingPeriodSecs
        );
    }

    // ========== MODIFIERS ==========

    modifier onlyPeriFinanceorPynth() {
        IPeriFinance _periFinance = periFinance();
        require(
            msg.sender == address(_periFinance) || _periFinance.pynthsByAddress(msg.sender) != bytes32(0),
            "Exchanger: Only periFinance or a pynth contract can perform this action"
        );
        _;
    }

    modifier onlyExchangeRates() {
        IExchangeRates _exchangeRates = exchangeRates();
        require(msg.sender == address(_exchangeRates), "Restricted to ExchangeRates");
        _;
    }

    // ========== EVENTS ==========
    event ExchangeEntryAppended(
        address indexed account,
        bytes32 src,
        uint256 amount,
        bytes32 dest,
        uint256 amountReceived,
        uint256 exchangeFeeRate,
        uint256 roundIdForSrc,
        uint256 roundIdForDest
    );

    event ExchangeEntrySettled(
        address indexed from,
        bytes32 src,
        uint256 amount,
        bytes32 dest,
        uint256 reclaim,
        uint256 rebate,
        uint256 srcRoundIdAtPeriodEnd,
        uint256 destRoundIdAtPeriodEnd,
        uint256 exchangeTimestamp
    );
}


/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}


// Inheritance


// Libraries


// Internal references


// Note: use OZ's IERC20 here as using ours will complain about conflicting names
// during the build


// https://docs.peri.finance/contracts/source/contracts/virtualpynth
contract VirtualPynth is ERC20, IVirtualPynth {
    using SafeMath for uint;
    using SafeDecimalMath for uint;

    IERC20 public pynth;
    IAddressResolver public resolver;

    bool public settled = false;

    uint8 public constant decimals = 18;

    // track initial supply so we can calculate the rate even after all supply is burned
    uint public initialSupply;

    // track final settled amount of the pynth so we can calculate the rate after settlement
    uint public settledAmount;

    bytes32 public currencyKey;

    constructor(
        IERC20 _pynth,
        IAddressResolver _resolver,
        address _recipient,
        uint _amount,
        bytes32 _currencyKey
    ) public ERC20() {
        pynth = _pynth;
        resolver = _resolver;
        currencyKey = _currencyKey;

        // Assumption: the pynth will be issued to us within the same transaction,
        // and this supply matches that
        _mint(_recipient, _amount);

        initialSupply = _amount;
    }

    // INTERNALS

    function exchanger() internal view returns (IExchanger) {
        return IExchanger(resolver.requireAndGetAddress("Exchanger", "Exchanger contract not found"));
    }

    function secsLeft() internal view returns (uint) {
        return exchanger().maxSecsLeftInWaitingPeriod(address(this), currencyKey);
    }

    function calcRate() internal view returns (uint) {
        if (initialSupply == 0) {
            return 0;
        }

        uint pynthBalance;

        if (!settled) {
            pynthBalance = IERC20(address(pynth)).balanceOf(address(this));
            (uint reclaim, uint rebate, ) = exchanger().settlementOwing(address(this), currencyKey);

            if (reclaim > 0) {
                pynthBalance = pynthBalance.sub(reclaim);
            } else if (rebate > 0) {
                pynthBalance = pynthBalance.add(rebate);
            }
        } else {
            pynthBalance = settledAmount;
        }

        return pynthBalance.divideDecimalRound(initialSupply);
    }

    function balanceUnderlying(address account) internal view returns (uint) {
        uint vBalanceOfAccount = balanceOf(account);

        return vBalanceOfAccount.multiplyDecimalRound(calcRate());
    }

    function settlePynth() internal {
        if (settled) {
            return;
        }
        settled = true;

        exchanger().settle(address(this), currencyKey);

        settledAmount = IERC20(address(pynth)).balanceOf(address(this));

        emit Settled(totalSupply(), settledAmount);
    }

    // VIEWS

    function name() external view returns (string memory) {
        return string(abi.encodePacked("Virtual Pynth ", currencyKey));
    }

    function symbol() external view returns (string memory) {
        return string(abi.encodePacked("v", currencyKey));
    }

    // get the rate of the vPynth to the pynth.
    function rate() external view returns (uint) {
        return calcRate();
    }

    // show the balance of the underlying pynth that the given address has, given
    // their proportion of totalSupply
    function balanceOfUnderlying(address account) external view returns (uint) {
        return balanceUnderlying(account);
    }

    function secsLeftInWaitingPeriod() external view returns (uint) {
        return secsLeft();
    }

    function readyToSettle() external view returns (bool) {
        return secsLeft() == 0;
    }

    // PUBLIC FUNCTIONS

    // Perform settlement of the underlying exchange if required,
    // then burn the accounts vPynths and transfer them their owed balanceOfUnderlying
    function settle(address account) external {
        settlePynth();

        IERC20(address(pynth)).transfer(account, balanceUnderlying(account));

        _burn(account, balanceOf(account));
    }

    event Settled(uint totalSupply, uint amountAfterSettled);
}


// Inheritance


// Internal references


// https://docs.peri.finance/contracts/source/contracts/exchangerwithvirtualpynth
contract ExchangerWithVirtualPynth is Exchanger {
    constructor(address _owner, address _resolver) public Exchanger(_owner, _resolver) {}

    function _createVirtualPynth(
        IERC20 pynth,
        address recipient,
        uint amount,
        bytes32 currencyKey
    ) internal returns (IVirtualPynth vPynth) {
        // prevent inverse pynths from being allowed due to purgeability
        require(currencyKey[0] != 0x69, "Cannot virtualize this pynth");

        vPynth = new VirtualPynth(pynth, resolver, recipient, amount, currencyKey);
        emit VirtualPynthCreated(address(pynth), recipient, address(vPynth), currencyKey, amount);
    }

    event VirtualPynthCreated(
        address indexed pynth,
        address indexed recipient,
        address vPynth,
        bytes32 currencyKey,
        uint amount
    );
}