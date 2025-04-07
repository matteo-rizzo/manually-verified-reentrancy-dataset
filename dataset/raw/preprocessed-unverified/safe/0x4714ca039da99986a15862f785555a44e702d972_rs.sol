/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

/*
    ___            _       ___  _                          
    | .\ ___  _ _ <_> ___ | __><_>._ _  ___ ._ _  ___  ___ 
    |  _// ._>| '_>| ||___|| _> | || ' |<_> || ' |/ | '/ ._>
    |_|  \___.|_|  |_|     |_|  |_||_|_|<___||_|_|\_|_.\___.
    
* PeriFinance: PeriFinanceBridgeToOptimism.sol
*
* Latest source (may be newer): https://github.com/perifinance/peri-finance/blob/master/contracts/PeriFinanceBridgeToOptimism.sol
* Docs: Will be added in the future. 
* https://docs.peri.finance/contracts/source/contracts/PeriFinanceBridgeToOptimism
*
* Contract Dependencies: 
*	- IAddressResolver
*	- IPeriFinanceBridgeToOptimism
*	- MixinResolver
*	- MixinSystemSettings
*	- Owned
* Libraries: 
*	- VestingEntries
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


pragma experimental ABIEncoderV2;







// https://docs.peri.finance/contracts/source/interfaces/iperiFinance



// https://docs.peri.finance/contracts/source/interfaces/ierc20











// SPDX-License-Identifier: UNLICENSED


/**
 * @title iOVM_BaseCrossDomainMessenger
 */



// Inheritance


// Internal references


// solhint-disable indent


contract PeriFinanceBridgeToOptimism is Owned, MixinSystemSettings, IPeriFinanceBridgeToOptimism {
    /* ========== ADDRESS RESOLVER CONFIGURATION ========== */
    bytes32 private constant CONTRACT_EXT_MESSENGER = "ext:Messenger";
    bytes32 private constant CONTRACT_PERIFINANCE = "PeriFinance";
    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_REWARDSDISTRIBUTION = "RewardsDistribution";
    bytes32 private constant CONTRACT_REWARDESCROW = "RewardEscrowV2";
    bytes32 private constant CONTRACT_OVM_PERIFINANCEBRIDGETOBASE = "ovm:PeriFinanceBridgeToBase";

    uint8 private constant MAX_ENTRIES_MIGRATED_PER_MESSAGE = 26;

    bool public activated;

    // ========== CONSTRUCTOR ==========

    constructor(address _owner, address _resolver) public Owned(_owner) MixinSystemSettings(_resolver) {
        activated = true;
    }

    //
    // ========== INTERNALS ============

    function messenger() internal view returns (iOVM_BaseCrossDomainMessenger) {
        return iOVM_BaseCrossDomainMessenger(requireAndGetAddress(CONTRACT_EXT_MESSENGER));
    }

    function periFinance() internal view returns (IPeriFinance) {
        return IPeriFinance(requireAndGetAddress(CONTRACT_PERIFINANCE));
    }

    function periFinanceERC20() internal view returns (IERC20) {
        return IERC20(requireAndGetAddress(CONTRACT_PERIFINANCE));
    }

    function issuer() internal view returns (IIssuer) {
        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER));
    }

    function rewardsDistribution() internal view returns (address) {
        return requireAndGetAddress(CONTRACT_REWARDSDISTRIBUTION);
    }

    function rewardEscrowV2() internal view returns (IRewardEscrowV2) {
        return IRewardEscrowV2(requireAndGetAddress(CONTRACT_REWARDESCROW));
    }

    function periFinanceBridgeToBase() internal view returns (address) {
        return requireAndGetAddress(CONTRACT_OVM_PERIFINANCEBRIDGETOBASE);
    }

    function isActive() internal view {
        require(activated, "Function deactivated");
    }

    function hasZeroDebt() internal view {
        require(issuer().debtBalanceOf(msg.sender, "pUSD") == 0, "Cannot deposit or migrate with debt");
    }

    /* ========== VIEWS ========== */

    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {
        bytes32[] memory existingAddresses = MixinSystemSettings.resolverAddressesRequired();
        bytes32[] memory newAddresses = new bytes32[](6);
        newAddresses[0] = CONTRACT_EXT_MESSENGER;
        newAddresses[1] = CONTRACT_PERIFINANCE;
        newAddresses[2] = CONTRACT_ISSUER;
        newAddresses[3] = CONTRACT_REWARDSDISTRIBUTION;
        newAddresses[4] = CONTRACT_OVM_PERIFINANCEBRIDGETOBASE;
        newAddresses[5] = CONTRACT_REWARDESCROW;
        addresses = combineArrays(existingAddresses, newAddresses);
    }

    // ========== MODIFIERS ============

    modifier requireActive() {
        isActive();
        _;
    }

    modifier requireZeroDebt() {
        hasZeroDebt();
        _;
    }

    // ========== PUBLIC FUNCTIONS =========

    function initiateDeposit(uint256 depositAmount) external requireActive requireZeroDebt {
        _initiateDeposit(depositAmount);
    }

    function initiateEscrowMigration(uint256[][] memory entryIDs) public requireActive requireZeroDebt {
        _initiateEscrowMigration(entryIDs);
    }

    // invoked by a generous user on L1
    function initiateRewardDeposit(uint amount) external requireActive {
        // move the PERI into this contract
        periFinanceERC20().transferFrom(msg.sender, address(this), amount);

        _initiateRewardDeposit(amount);
    }

    // ========= RESTRICTED FUNCTIONS ==============

    // invoked by Messenger on L1 after L2 waiting period elapses
    function completeWithdrawal(address account, uint256 amount) external requireActive {
        // ensure function only callable from L2 Bridge via messenger (aka relayer)
        require(msg.sender == address(messenger()), "Only the relayer can call this");
        require(messenger().xDomainMessageSender() == periFinanceBridgeToBase(), "Only the L2 bridge can invoke");

        // transfer amount back to user
        periFinanceERC20().transfer(account, amount);

        // no escrow actions - escrow remains on L2
        emit WithdrawalCompleted(account, amount);
    }

    // invoked by the owner for migrating the contract to the new version that will allow for withdrawals
    function migrateBridge(address newBridge) external onlyOwner requireActive {
        require(newBridge != address(0), "Cannot migrate to address 0");
        activated = false;

        IERC20 ERC20PeriFinance = periFinanceERC20();
        // get the current contract balance and transfer it to the new PeriFinanceL1ToL2Bridge contract
        uint256 contractBalance = ERC20PeriFinance.balanceOf(address(this));
        ERC20PeriFinance.transfer(newBridge, contractBalance);

        emit BridgeMigrated(address(this), newBridge, contractBalance);
    }

    // invoked by RewardsDistribution on L1 (takes PERI)
    function notifyRewardAmount(uint256 amount) external requireActive {
        require(msg.sender == address(rewardsDistribution()), "Caller is not RewardsDistribution contract");

        // to be here means I've been given an amount of PERI to distribute onto L2
        _initiateRewardDeposit(amount);
    }

    function depositAndMigrateEscrow(uint256 depositAmount, uint256[][] memory entryIDs)
        public
        requireActive
        requireZeroDebt
    {
        if (entryIDs.length > 0) {
            _initiateEscrowMigration(entryIDs);
        }

        if (depositAmount > 0) {
            _initiateDeposit(depositAmount);
        }
    }

    // ========== PRIVATE/INTERNAL FUNCTIONS =========

    function _initiateRewardDeposit(uint256 _amount) internal {
        // create message payload for L2
        IPeriFinanceBridgeToBase bridgeToBase;
        bytes memory messageData = abi.encodeWithSelector(bridgeToBase.completeRewardDeposit.selector, _amount);

        // relay the message to this contract on L2 via L1 Messenger
        messenger().sendMessage(
            periFinanceBridgeToBase(),
            messageData,
            uint32(getCrossDomainMessageGasLimit(CrossDomainMessageGasLimits.Reward))
        );

        emit RewardDeposit(msg.sender, _amount);
    }

    function _initiateDeposit(uint256 _depositAmount) private {
        // Transfer PERI to L2
        // First, move the PERI into this contract
        periFinanceERC20().transferFrom(msg.sender, address(this), _depositAmount);
        // create message payload for L2
        IPeriFinanceBridgeToBase bridgeToBase;
        bytes memory messageData = abi.encodeWithSelector(bridgeToBase.completeDeposit.selector, msg.sender, _depositAmount);

        // relay the message to this contract on L2 via L1 Messenger
        messenger().sendMessage(
            periFinanceBridgeToBase(),
            messageData,
            uint32(getCrossDomainMessageGasLimit(CrossDomainMessageGasLimits.Deposit))
        );
        emit Deposit(msg.sender, _depositAmount);
    }

    function _initiateEscrowMigration(uint256[][] memory _entryIDs) private {
        // loop through the entryID array
        for (uint256 i = 0; i < _entryIDs.length; i++) {
            // Cannot send more than MAX_ENTRIES_MIGRATED_PER_MESSAGE entries due to ovm gas restrictions
            require(_entryIDs[i].length <= MAX_ENTRIES_MIGRATED_PER_MESSAGE, "Exceeds max entries per migration");
            // Burn their reward escrow first
            // Note: escrowSummary would lose the fidelity of the weekly escrows, so this may not be sufficient
            uint256 escrowedAccountBalance;
            VestingEntries.VestingEntry[] memory vestingEntries;
            (escrowedAccountBalance, vestingEntries) = rewardEscrowV2().burnForMigration(msg.sender, _entryIDs[i]);
            // if there is an escrow amount to be migrated
            if (escrowedAccountBalance > 0) {
                // create message payload for L2
                IPeriFinanceBridgeToBase bridgeToBase;
                bytes memory messageData =
                    abi.encodeWithSelector(
                        bridgeToBase.completeEscrowMigration.selector,
                        msg.sender,
                        escrowedAccountBalance,
                        vestingEntries
                    );
                // relay the message to this contract on L2 via L1 Messenger
                messenger().sendMessage(
                    periFinanceBridgeToBase(),
                    messageData,
                    uint32(getCrossDomainMessageGasLimit(CrossDomainMessageGasLimits.Escrow))
                );
                emit ExportedVestingEntries(msg.sender, escrowedAccountBalance, vestingEntries);
            }
        }
    }

    // ========== EVENTS ==========

    event BridgeMigrated(address oldBridge, address newBridge, uint256 amount);
    event Deposit(address indexed account, uint256 amount);
    event ExportedVestingEntries(
        address indexed account,
        uint256 escrowedAccountBalance,
        VestingEntries.VestingEntry[] vestingEntries
    );
    event RewardDeposit(address indexed account, uint256 amount);
    event WithdrawalCompleted(address indexed account, uint256 amount);
}