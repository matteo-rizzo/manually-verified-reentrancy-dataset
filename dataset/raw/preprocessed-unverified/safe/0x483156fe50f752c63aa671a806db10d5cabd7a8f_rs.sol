pragma solidity 0.5.15;

contract IAugur {
    function createChildUniverse(bytes32 _parentPayoutDistributionHash, uint256[] memory _parentPayoutNumerators) public returns (IUniverse);
    function isKnownUniverse(IUniverse _universe) public view returns (bool);
    function trustedCashTransfer(address _from, address _to, uint256 _amount) public returns (bool);
    function isTrustedSender(address _address) public returns (bool);
    function onCategoricalMarketCreated(uint256 _endTime, string memory _extraInfo, IMarket _market, address _marketCreator, address _designatedReporter, uint256 _feePerCashInAttoCash, bytes32[] memory _outcomes) public returns (bool);
    function onYesNoMarketCreated(uint256 _endTime, string memory _extraInfo, IMarket _market, address _marketCreator, address _designatedReporter, uint256 _feePerCashInAttoCash) public returns (bool);
    function onScalarMarketCreated(uint256 _endTime, string memory _extraInfo, IMarket _market, address _marketCreator, address _designatedReporter, uint256 _feePerCashInAttoCash, int256[] memory _prices, uint256 _numTicks)  public returns (bool);
    function logInitialReportSubmitted(IUniverse _universe, address _reporter, address _market, address _initialReporter, uint256 _amountStaked, bool _isDesignatedReporter, uint256[] memory _payoutNumerators, string memory _description, uint256 _nextWindowStartTime, uint256 _nextWindowEndTime) public returns (bool);
    function disputeCrowdsourcerCreated(IUniverse _universe, address _market, address _disputeCrowdsourcer, uint256[] memory _payoutNumerators, uint256 _size, uint256 _disputeRound) public returns (bool);
    function logDisputeCrowdsourcerContribution(IUniverse _universe, address _reporter, address _market, address _disputeCrowdsourcer, uint256 _amountStaked, string memory description, uint256[] memory _payoutNumerators, uint256 _currentStake, uint256 _stakeRemaining, uint256 _disputeRound) public returns (bool);
    function logDisputeCrowdsourcerCompleted(IUniverse _universe, address _market, address _disputeCrowdsourcer, uint256[] memory _payoutNumerators, uint256 _nextWindowStartTime, uint256 _nextWindowEndTime, bool _pacingOn, uint256 _totalRepStakedInPayout, uint256 _totalRepStakedInMarket, uint256 _disputeRound) public returns (bool);
    function logInitialReporterRedeemed(IUniverse _universe, address _reporter, address _market, uint256 _amountRedeemed, uint256 _repReceived, uint256[] memory _payoutNumerators) public returns (bool);
    function logDisputeCrowdsourcerRedeemed(IUniverse _universe, address _reporter, address _market, uint256 _amountRedeemed, uint256 _repReceived, uint256[] memory _payoutNumerators) public returns (bool);
    function logMarketFinalized(IUniverse _universe, uint256[] memory _winningPayoutNumerators) public returns (bool);
    function logMarketMigrated(IMarket _market, IUniverse _originalUniverse) public returns (bool);
    function logReportingParticipantDisavowed(IUniverse _universe, IMarket _market) public returns (bool);
    function logMarketParticipantsDisavowed(IUniverse _universe) public returns (bool);
    function logCompleteSetsPurchased(IUniverse _universe, IMarket _market, address _account, uint256 _numCompleteSets) public returns (bool);
    function logCompleteSetsSold(IUniverse _universe, IMarket _market, address _account, uint256 _numCompleteSets, uint256 _fees) public returns (bool);
    function logMarketOIChanged(IUniverse _universe, IMarket _market) public returns (bool);
    function logTradingProceedsClaimed(IUniverse _universe, address _sender, address _market, uint256 _outcome, uint256 _numShares, uint256 _numPayoutTokens, uint256 _fees) public returns (bool);
    function logUniverseForked(IMarket _forkingMarket) public returns (bool);
    function logReputationTokensTransferred(IUniverse _universe, address _from, address _to, uint256 _value, uint256 _fromBalance, uint256 _toBalance) public returns (bool);
    function logReputationTokensBurned(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);
    function logReputationTokensMinted(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);
    function logShareTokensBalanceChanged(address _account, IMarket _market, uint256 _outcome, uint256 _balance) public returns (bool);
    function logDisputeCrowdsourcerTokensTransferred(IUniverse _universe, address _from, address _to, uint256 _value, uint256 _fromBalance, uint256 _toBalance) public returns (bool);
    function logDisputeCrowdsourcerTokensBurned(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);
    function logDisputeCrowdsourcerTokensMinted(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);
    function logDisputeWindowCreated(IDisputeWindow _disputeWindow, uint256 _id, bool _initial) public returns (bool);
    function logParticipationTokensRedeemed(IUniverse universe, address _sender, uint256 _attoParticipationTokens, uint256 _feePayoutShare) public returns (bool);
    function logTimestampSet(uint256 _newTimestamp) public returns (bool);
    function logInitialReporterTransferred(IUniverse _universe, IMarket _market, address _from, address _to) public returns (bool);
    function logMarketTransferred(IUniverse _universe, address _from, address _to) public returns (bool);
    function logParticipationTokensTransferred(IUniverse _universe, address _from, address _to, uint256 _value, uint256 _fromBalance, uint256 _toBalance) public returns (bool);
    function logParticipationTokensBurned(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);
    function logParticipationTokensMinted(IUniverse _universe, address _target, uint256 _amount, uint256 _totalSupply, uint256 _balance) public returns (bool);
    function logMarketRepBondTransferred(address _universe, address _from, address _to) public returns (bool);
    function logWarpSyncDataUpdated(address _universe, uint256 _warpSyncHash, uint256 _marketEndTime) public returns (bool);
    function isKnownFeeSender(address _feeSender) public view returns (bool);
    function lookup(bytes32 _key) public view returns (address);
    function getTimestamp() public view returns (uint256);
    function getMaximumMarketEndDate() public returns (uint256);
    function isKnownMarket(IMarket _market) public view returns (bool);
    function derivePayoutDistributionHash(uint256[] memory _payoutNumerators, uint256 _numTicks, uint256 numOutcomes) public view returns (bytes32);
    function logValidityBondChanged(uint256 _validityBond) public returns (bool);
    function logDesignatedReportStakeChanged(uint256 _designatedReportStake) public returns (bool);
    function logNoShowBondChanged(uint256 _noShowBond) public returns (bool);
    function logReportingFeeChanged(uint256 _reportingFee) public returns (bool);
    function getUniverseForkIndex(IUniverse _universe) public view returns (uint256);
}

contract IOwnable {
    function getOwner() public view returns (address);
    function transferOwnership(address _newOwner) public returns (bool);
}

contract ITyped {
    function getTypeName() public view returns (bytes32);
}

contract Initializable {
    bool private initialized = false;

    modifier beforeInitialized {
        require(!initialized);
        _;
    }

    function endInitialization() internal beforeInitialized {
        initialized = true;
    }

    function getInitialized() public view returns (bool) {
        return initialized;
    }
}







contract IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) public view returns (uint256);
    function transfer(address to, uint256 amount) public returns (bool);
    function transferFrom(address from, address to, uint256 amount) public returns (bool);
    function approve(address spender, uint256 amount) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ICash is IERC20 {
}

contract IAffiliateValidator {
    function validateReference(address _account, address _referrer) external view returns (bool);
}

contract IDisputeWindow is ITyped, IERC20 {
    function invalidMarketsTotal() external view returns (uint256);
    function validityBondTotal() external view returns (uint256);

    function incorrectDesignatedReportTotal() external view returns (uint256);
    function initialReportBondTotal() external view returns (uint256);

    function designatedReportNoShowsTotal() external view returns (uint256);
    function designatedReporterNoShowBondTotal() external view returns (uint256);

    function initialize(IAugur _augur, IUniverse _universe, uint256 _disputeWindowId, bool _participationTokensEnabled, uint256 _duration, uint256 _startTime) public;
    function trustedBuy(address _buyer, uint256 _attotokens) public returns (bool);
    function getUniverse() public view returns (IUniverse);
    function getReputationToken() public view returns (IReputationToken);
    function getStartTime() public view returns (uint256);
    function getEndTime() public view returns (uint256);
    function getWindowId() public view returns (uint256);
    function isActive() public view returns (bool);
    function isOver() public view returns (bool);
    function onMarketFinalized() public;
    function redeem(address _account) public returns (bool);
}

contract IMarket is IOwnable {
    enum MarketType {
        YES_NO,
        CATEGORICAL,
        SCALAR
    }

    function initialize(IAugur _augur, IUniverse _universe, uint256 _endTime, uint256 _feePerCashInAttoCash, IAffiliateValidator _affiliateValidator, uint256 _affiliateFeeDivisor, address _designatedReporterAddress, address _creator, uint256 _numOutcomes, uint256 _numTicks) public;
    function derivePayoutDistributionHash(uint256[] memory _payoutNumerators) public view returns (bytes32);
    function doInitialReport(uint256[] memory _payoutNumerators, string memory _description, uint256 _additionalStake) public returns (bool);
    function getUniverse() public view returns (IUniverse);
    function getDisputeWindow() public view returns (IDisputeWindow);
    function getNumberOfOutcomes() public view returns (uint256);
    function getNumTicks() public view returns (uint256);
    function getMarketCreatorSettlementFeeDivisor() public view returns (uint256);
    function getForkingMarket() public view returns (IMarket _market);
    function getEndTime() public view returns (uint256);
    function getWinningPayoutDistributionHash() public view returns (bytes32);
    function getWinningPayoutNumerator(uint256 _outcome) public view returns (uint256);
    function getWinningReportingParticipant() public view returns (IReportingParticipant);
    function getReputationToken() public view returns (IV2ReputationToken);
    function getFinalizationTime() public view returns (uint256);
    function getInitialReporter() public view returns (IInitialReporter);
    function getDesignatedReportingEndTime() public view returns (uint256);
    function getValidityBondAttoCash() public view returns (uint256);
    function affiliateFeeDivisor() external view returns (uint256);
    function getNumParticipants() public view returns (uint256);
    function getDisputePacingOn() public view returns (bool);
    function deriveMarketCreatorFeeAmount(uint256 _amount) public view returns (uint256);
    function recordMarketCreatorFees(uint256 _marketCreatorFees, address _sourceAccount, bytes32 _fingerprint) public returns (bool);
    function isContainerForReportingParticipant(IReportingParticipant _reportingParticipant) public view returns (bool);
    function isFinalizedAsInvalid() public view returns (bool);
    function finalize() public returns (bool);
    function isFinalized() public view returns (bool);
    function getOpenInterest() public view returns (uint256);
}

contract IReportingParticipant {
    function getStake() public view returns (uint256);
    function getPayoutDistributionHash() public view returns (bytes32);
    function liquidateLosing() public;
    function redeem(address _redeemer) public returns (bool);
    function isDisavowed() public view returns (bool);
    function getPayoutNumerator(uint256 _outcome) public view returns (uint256);
    function getPayoutNumerators() public view returns (uint256[] memory);
    function getMarket() public view returns (IMarket);
    function getSize() public view returns (uint256);
}

contract IInitialReporter is IReportingParticipant, IOwnable {
    function initialize(IAugur _augur, IMarket _market, address _designatedReporter) public;
    function report(address _reporter, bytes32 _payoutDistributionHash, uint256[] memory _payoutNumerators, uint256 _initialReportStake) public;
    function designatedReporterShowed() public view returns (bool);
    function initialReporterWasCorrect() public view returns (bool);
    function getDesignatedReporter() public view returns (address);
    function getReportTimestamp() public view returns (uint256);
    function migrateToNewUniverse(address _designatedReporter) public;
    function returnRepFromDisavow() public;
}

contract IReputationToken is IERC20 {
    function migrateOutByPayout(uint256[] memory _payoutNumerators, uint256 _attotokens) public returns (bool);
    function migrateIn(address _reporter, uint256 _attotokens) public returns (bool);
    function trustedReportingParticipantTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedMarketTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedUniverseTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedDisputeWindowTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function getUniverse() public view returns (IUniverse);
    function getTotalMigrated() public view returns (uint256);
    function getTotalTheoreticalSupply() public view returns (uint256);
    function mintForReportingParticipant(uint256 _amountMigrated) public returns (bool);
}

contract IShareToken is ITyped, IERC1155 {
    function initialize(IAugur _augur) external;
    function initializeMarket(IMarket _market, uint256 _numOutcomes, uint256 _numTicks) public;
    function unsafeTransferFrom(address _from, address _to, uint256 _id, uint256 _value) public;
    function unsafeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _values) public;
    function claimTradingProceeds(IMarket _market, address _shareHolder, bytes32 _fingerprint) external returns (uint256[] memory _outcomeFees);
    function getMarket(uint256 _tokenId) external view returns (IMarket);
    function getOutcome(uint256 _tokenId) external view returns (uint256);
    function getTokenId(IMarket _market, uint256 _outcome) public pure returns (uint256 _tokenId);
    function getTokenIds(IMarket _market, uint256[] memory _outcomes) public pure returns (uint256[] memory _tokenIds);
    function buyCompleteSets(IMarket _market, address _account, uint256 _amount) external returns (bool);
    function buyCompleteSetsForTrade(IMarket _market, uint256 _amount, uint256 _longOutcome, address _longRecipient, address _shortRecipient) external returns (bool);
    function sellCompleteSets(IMarket _market, address _holder, address _recipient, uint256 _amount, bytes32 _fingerprint) external returns (uint256 _creatorFee, uint256 _reportingFee);
    function sellCompleteSetsForTrade(IMarket _market, uint256 _outcome, uint256 _amount, address _shortParticipant, address _longParticipant, address _shortRecipient, address _longRecipient, uint256 _price, address _sourceAccount, bytes32 _fingerprint) external returns (uint256 _creatorFee, uint256 _reportingFee);
    function totalSupplyForMarketOutcome(IMarket _market, uint256 _outcome) public view returns (uint256);
    function balanceOfMarketOutcome(IMarket _market, uint256 _outcome, address _account) public view returns (uint256);
    function lowestBalanceOfMarketOutcomes(IMarket _market, uint256[] memory _outcomes, address _account) public view returns (uint256);
}

contract IUniverse {
    function creationTime() external view returns (uint256);
    function marketBalance(address) external view returns (uint256);

    function fork() public returns (bool);
    function updateForkValues() public returns (bool);
    function getParentUniverse() public view returns (IUniverse);
    function createChildUniverse(uint256[] memory _parentPayoutNumerators) public returns (IUniverse);
    function getChildUniverse(bytes32 _parentPayoutDistributionHash) public view returns (IUniverse);
    function getReputationToken() public view returns (IV2ReputationToken);
    function getForkingMarket() public view returns (IMarket);
    function getForkEndTime() public view returns (uint256);
    function getForkReputationGoal() public view returns (uint256);
    function getParentPayoutDistributionHash() public view returns (bytes32);
    function getDisputeRoundDurationInSeconds(bool _initial) public view returns (uint256);
    function getOrCreateDisputeWindowByTimestamp(uint256 _timestamp, bool _initial) public returns (IDisputeWindow);
    function getOrCreateCurrentDisputeWindow(bool _initial) public returns (IDisputeWindow);
    function getOrCreateNextDisputeWindow(bool _initial) public returns (IDisputeWindow);
    function getOrCreatePreviousDisputeWindow(bool _initial) public returns (IDisputeWindow);
    function getOpenInterestInAttoCash() public view returns (uint256);
    function getTargetRepMarketCapInAttoCash() public view returns (uint256);
    function getOrCacheValidityBond() public returns (uint256);
    function getOrCacheDesignatedReportStake() public returns (uint256);
    function getOrCacheDesignatedReportNoShowBond() public returns (uint256);
    function getOrCacheMarketRepBond() public returns (uint256);
    function getOrCacheReportingFeeDivisor() public returns (uint256);
    function getDisputeThresholdForFork() public view returns (uint256);
    function getDisputeThresholdForDisputePacing() public view returns (uint256);
    function getInitialReportMinValue() public view returns (uint256);
    function getPayoutNumerators() public view returns (uint256[] memory);
    function getReportingFeeDivisor() public view returns (uint256);
    function getPayoutNumerator(uint256 _outcome) public view returns (uint256);
    function getWinningChildPayoutNumerator(uint256 _outcome) public view returns (uint256);
    function isOpenInterestCash(address) public view returns (bool);
    function isForkingMarket() public view returns (bool);
    function getCurrentDisputeWindow(bool _initial) public view returns (IDisputeWindow);
    function getDisputeWindowStartTimeAndDuration(uint256 _timestamp, bool _initial) public view returns (uint256, uint256);
    function isParentOf(IUniverse _shadyChild) public view returns (bool);
    function updateTentativeWinningChildUniverse(bytes32 _parentPayoutDistributionHash) public returns (bool);
    function isContainerForDisputeWindow(IDisputeWindow _shadyTarget) public view returns (bool);
    function isContainerForMarket(IMarket _shadyTarget) public view returns (bool);
    function isContainerForReportingParticipant(IReportingParticipant _reportingParticipant) public view returns (bool);
    function migrateMarketOut(IUniverse _destinationUniverse) public returns (bool);
    function migrateMarketIn(IMarket _market, uint256 _cashBalance, uint256 _marketOI) public returns (bool);
    function decrementOpenInterest(uint256 _amount) public returns (bool);
    function decrementOpenInterestFromMarket(IMarket _market) public returns (bool);
    function incrementOpenInterest(uint256 _amount) public returns (bool);
    function getWinningChildUniverse() public view returns (IUniverse);
    function isForking() public view returns (bool);
    function deposit(address _sender, uint256 _amount, address _market) public returns (bool);
    function withdraw(address _recipient, uint256 _amount, address _market) public returns (bool);
    function createScalarMarket(uint256 _endTime, uint256 _feePerCashInAttoCash, IAffiliateValidator _affiliateValidator, uint256 _affiliateFeeDivisor, address _designatedReporterAddress, int256[] memory _prices, uint256 _numTicks, string memory _extraInfo) public returns (IMarket _newMarket);
}

contract IV2ReputationToken is IReputationToken {
    function parentUniverse() external returns (IUniverse);
    function burnForMarket(uint256 _amountToBurn) public returns (bool);
    function mintForWarpSync(uint256 _amountToMint, address _target) public returns (bool);
}

contract IAugurTrading {
    function lookup(bytes32 _key) public view returns (address);
    function logProfitLossChanged(IMarket _market, address _account, uint256 _outcome, int256 _netPosition, uint256 _avgPrice, int256 _realizedProfit, int256 _frozenFunds, int256 _realizedCost) public returns (bool);
    function logOrderCreated(IUniverse _universe, bytes32 _orderId, bytes32 _tradeGroupId) public returns (bool);
    function logOrderCanceled(IUniverse _universe, IMarket _market, address _creator, uint256 _tokenRefund, uint256 _sharesRefund, bytes32 _orderId) public returns (bool);
    function logOrderFilled(IUniverse _universe, address _creator, address _filler, uint256 _price, uint256 _fees, uint256 _amountFilled, bytes32 _orderId, bytes32 _tradeGroupId) public returns (bool);
    function logMarketVolumeChanged(IUniverse _universe, address _market, uint256 _volume, uint256[] memory _outcomeVolumes, uint256 _totalTrades) public returns (bool);
    function logZeroXOrderFilled(IUniverse _universe, IMarket _market, bytes32 _orderHash, bytes32 _tradeGroupId, uint8 _orderType, address[] memory _addressData, uint256[] memory _uint256Data) public returns (bool);
    function logZeroXOrderCanceled(address _universe, address _market, address _account, uint256 _outcome, uint256 _price, uint256 _amount, uint8 _type, bytes32 _orderHash) public;
}

contract IOrders {
    function saveOrder(uint256[] calldata _uints, bytes32[] calldata _bytes32s, Order.Types _type, IMarket _market, address _sender) external returns (bytes32 _orderId);
    function removeOrder(bytes32 _orderId) external returns (bool);
    function getMarket(bytes32 _orderId) public view returns (IMarket);
    function getOrderType(bytes32 _orderId) public view returns (Order.Types);
    function getOutcome(bytes32 _orderId) public view returns (uint256);
    function getAmount(bytes32 _orderId) public view returns (uint256);
    function getPrice(bytes32 _orderId) public view returns (uint256);
    function getOrderCreator(bytes32 _orderId) public view returns (address);
    function getOrderSharesEscrowed(bytes32 _orderId) public view returns (uint256);
    function getOrderMoneyEscrowed(bytes32 _orderId) public view returns (uint256);
    function getOrderDataForCancel(bytes32 _orderId) public view returns (uint256, uint256, Order.Types, IMarket, uint256, address);
    function getOrderDataForLogs(bytes32 _orderId) public view returns (Order.Types, address[] memory _addressData, uint256[] memory _uint256Data);
    function getBetterOrderId(bytes32 _orderId) public view returns (bytes32);
    function getWorseOrderId(bytes32 _orderId) public view returns (bytes32);
    function getBestOrderId(Order.Types _type, IMarket _market, uint256 _outcome) public view returns (bytes32);
    function getWorstOrderId(Order.Types _type, IMarket _market, uint256 _outcome) public view returns (bytes32);
    function getLastOutcomePrice(IMarket _market, uint256 _outcome) public view returns (uint256);
    function getOrderId(Order.Types _type, IMarket _market, uint256 _amount, uint256 _price, address _sender, uint256 _blockNumber, uint256 _outcome, uint256 _moneyEscrowed, uint256 _sharesEscrowed) public pure returns (bytes32);
    function getTotalEscrowed(IMarket _market) public view returns (uint256);
    function isBetterPrice(Order.Types _type, uint256 _price, bytes32 _orderId) public view returns (bool);
    function isWorsePrice(Order.Types _type, uint256 _price, bytes32 _orderId) public view returns (bool);
    function assertIsNotBetterPrice(Order.Types _type, uint256 _price, bytes32 _betterOrderId) public view returns (bool);
    function assertIsNotWorsePrice(Order.Types _type, uint256 _price, bytes32 _worseOrderId) public returns (bool);
    function recordFillOrder(bytes32 _orderId, uint256 _sharesFilled, uint256 _tokensFilled, uint256 _fill) external returns (bool);
    function setPrice(IMarket _market, uint256 _outcome, uint256 _price) external returns (bool);
}

contract IProfitLoss {
    function initialize(IAugur _augur) public;
    function recordFrozenFundChange(IUniverse _universe, IMarket _market, address _account, uint256 _outcome, int256 _frozenFundDelta) public returns (bool);
    function adjustTraderProfitForFees(IMarket _market, address _trader, uint256 _outcome, uint256 _fees) public returns (bool);
    function recordTrade(IUniverse _universe, IMarket _market, address _longAddress, address _shortAddress, uint256 _outcome, int256 _amount, int256 _price, uint256 _numLongTokens, uint256 _numShortTokens, uint256 _numLongShares, uint256 _numShortShares) public returns (bool);
    function recordClaim(IMarket _market, address _account, uint256[] memory _outcomeFees) public returns (bool);
}





contract Orders is IOrders, Initializable {
    using Order for Order.Data;
    using SafeMathUint256 for uint256;

    struct MarketOrders {
        uint256 totalEscrowed;
        mapping(uint256 => uint256) prices;
    }

    mapping(bytes32 => Order.Data) private orders;
    mapping(address => MarketOrders) private marketOrderData;
    mapping(bytes32 => bytes32) private bestOrder;
    mapping(bytes32 => bytes32) private worstOrder;

    IAugur public augur;
    IAugurTrading public augurTrading;
    ICash public cash;
    address public trade;
    address public fillOrder;
    address public cancelOrder;
    address public createOrder;
    IProfitLoss public profitLoss;

    function initialize(IAugur _augur, IAugurTrading _augurTrading) public beforeInitialized {
        endInitialization();
        cash = ICash(_augur.lookup("Cash"));

        augur = _augur;
        augurTrading = _augurTrading;
        createOrder = _augurTrading.lookup("CreateOrder");
        fillOrder = _augurTrading.lookup("FillOrder");
        cancelOrder = _augurTrading.lookup("CancelOrder");
        trade = _augurTrading.lookup("Trade");
        profitLoss = IProfitLoss(_augurTrading.lookup("ProfitLoss"));
        require(createOrder != address(0));
        require(fillOrder != address(0));
        require(cancelOrder != address(0));
        require(trade != address(0));
        require(profitLoss != IProfitLoss(0));
    }

    /**
     * @param _orderId The id of the order
     * @return The market associated with the order id
     */
    function getMarket(bytes32 _orderId) public view returns (IMarket) {
        return orders[_orderId].market;
    }

    /**
     * @param _orderId The id of the order
     * @return The order type (BID==0,ASK==1) associated with the order
     */
    function getOrderType(bytes32 _orderId) public view returns (Order.Types) {
        return orders[_orderId].orderType;
    }

    /**
     * @param _orderId The id of the order
     * @return The outcome associated with the order
     */
    function getOutcome(bytes32 _orderId) public view returns (uint256) {
        return orders[_orderId].outcome;
    }

    /**
     * @param _orderId The id of the order
     * @return The remaining amount of the order
     */
    function getAmount(bytes32 _orderId) public view returns (uint256) {
        return orders[_orderId].amount;
    }

    /**
     * @param _orderId The id of the order
     * @return The price of the order
     */
    function getPrice(bytes32 _orderId) public view returns (uint256) {
        return orders[_orderId].price;
    }

    /**
     * @param _orderId The id of the order
     * @return The creator of the order
     */
    function getOrderCreator(bytes32 _orderId) public view returns (address) {
        return orders[_orderId].creator;
    }

    /**
     * @param _orderId The id of the order
     * @return The remaining shares escrowed in the order
     */
    function getOrderSharesEscrowed(bytes32 _orderId) public view returns (uint256) {
        return orders[_orderId].sharesEscrowed;
    }

    /**
     * @param _orderId The id of the order
     * @return The remaining Cash tokens escrowed in the order
     */
    function getOrderMoneyEscrowed(bytes32 _orderId) public view returns (uint256) {
        return orders[_orderId].moneyEscrowed;
    }

    function getOrderDataForCancel(bytes32 _orderId) public view returns (uint256 _moneyEscrowed, uint256 _sharesEscrowed, Order.Types _type, IMarket _market, uint256 _outcome, address _creator) {
        Order.Data storage _order = orders[_orderId];
        _moneyEscrowed = _order.moneyEscrowed;
        _sharesEscrowed = _order.sharesEscrowed;
        _type = _order.orderType;
        _market = _order.market;
        _outcome = _order.outcome;
        _creator = _order.creator;
    }

    function getOrderDataForLogs(bytes32 _orderId) public view returns (Order.Types _type, address[] memory _addressData, uint256[] memory _uint256Data) {
        Order.Data storage _order = orders[_orderId];
        _addressData = new address[](2);
        _uint256Data = new uint256[](10);
        _addressData[0] = _order.creator;
        _uint256Data[0] = _order.price;
        _uint256Data[1] = _order.amount;
        _uint256Data[2] = _order.outcome;
        _uint256Data[8] = _order.sharesEscrowed;
        _uint256Data[9] = _order.moneyEscrowed;
        return (_order.orderType, _addressData, _uint256Data);
    }

    /**
     * @param _market The address of the market
     * @return The amount of Cash escrowed for all orders for the specified market
     */
    function getTotalEscrowed(IMarket _market) public view returns (uint256) {
        return marketOrderData[address(_market)].totalEscrowed;
    }

    /**
     * @param _market The address of the market
     * @param _outcome The outcome number
     * @return The price for the last completed trade for the specified market and outcome
     */
    function getLastOutcomePrice(IMarket _market, uint256 _outcome) public view returns (uint256) {
        return marketOrderData[address(_market)].prices[_outcome];
    }

    /**
     * @param _orderId The id of the order
     * @return The id (if there is one) of the next order better than the provided one
     */
    function getBetterOrderId(bytes32 _orderId) public view returns (bytes32) {
        return orders[_orderId].betterOrderId;
    }

    /**
     * @param _orderId The id of the order
     * @return The id (if there is one) of the next order worse than the provided one
     */
    function getWorseOrderId(bytes32 _orderId) public view returns (bytes32) {
        return orders[_orderId].worseOrderId;
    }

    /**
     * @param _type The type of order. Either BID==0, or ASK==1
     * @param _market The market of the order
     * @param _outcome The outcome of the order
     * @return The id (if there is one) of the best order that satisfies the given parameters
     */
    function getBestOrderId(Order.Types _type, IMarket _market, uint256 _outcome) public view returns (bytes32) {
        return bestOrder[getBestOrderWorstOrderHash(_market, _outcome, _type)];
    }

    /**
     * @param _type The type of order. Either BID==0, or ASK==1
     * @param _market The market of the order
     * @param _outcome The outcome of the order
     * @return The id (if there is one) of the worst order that satisfies the given parameters
     */
    function getWorstOrderId(Order.Types _type, IMarket _market, uint256 _outcome) public view returns (bytes32) {
        return worstOrder[getBestOrderWorstOrderHash(_market, _outcome, _type)];
    }

    /**
     * @param _type The type of order. Either BID==0, or ASK==1
     * @param _market The market of the order
     * @param _amount The amount of the order
     * @param _price The price of the order
     * @param _sender The creator of the order
     * @param _blockNumber The blockNumber which the order was created in
     * @param _outcome The outcome of the order
     * @param _moneyEscrowed The amount of Cash tokens escrowed in the order
     * @param _sharesEscrowed The outcome Share tokens escrowed in the order
     * @return The order id that satisfies the given parameters
     */
    function getOrderId(Order.Types _type, IMarket _market, uint256 _amount, uint256 _price, address _sender, uint256 _blockNumber, uint256 _outcome, uint256 _moneyEscrowed, uint256 _sharesEscrowed) public pure returns (bytes32) {
        return Order.calculateOrderId(_type, _market, _amount, _price, _sender, _blockNumber, _outcome, _moneyEscrowed, _sharesEscrowed);
    }

    function isBetterPrice(Order.Types _type, uint256 _price, bytes32 _orderId) public view returns (bool) {
        if (_type == Order.Types.Bid) {
            return (_price > orders[_orderId].price);
        } else if (_type == Order.Types.Ask) {
            return (_price < orders[_orderId].price);
        }
    }

    function isWorsePrice(Order.Types _type, uint256 _price, bytes32 _orderId) public view returns (bool) {
        if (_type == Order.Types.Bid) {
            return (_price <= orders[_orderId].price);
        } else {
            return (_price >= orders[_orderId].price);
        }
    }

    function assertIsNotBetterPrice(Order.Types _type, uint256 _price, bytes32 _betterOrderId) public view returns (bool) {
        require(!isBetterPrice(_type, _price, _betterOrderId), "Orders.assertIsNotBetterPrice: Is better price");
        return true;
    }

    function assertIsNotWorsePrice(Order.Types _type, uint256 _price, bytes32 _worseOrderId) public returns (bool) {
        require(!isWorsePrice(_type, _price, _worseOrderId), "Orders.assertIsNotWorsePrice: Is worse price");
        return true;
    }

    function insertOrderIntoList(Order.Data storage _order, bytes32 _betterOrderId, bytes32 _worseOrderId) private returns (bool) {
        bytes32 _bestOrderWorstOrderHash = getBestOrderWorstOrderHash(_order.market, _order.outcome, _order.orderType);
        bytes32 _bestOrderId = bestOrder[_bestOrderWorstOrderHash];
        bytes32 _worstOrderId = worstOrder[_bestOrderWorstOrderHash];
        (_betterOrderId, _worseOrderId) = findBoundingOrders(_order.orderType, _order.price, _bestOrderId, _worstOrderId, _betterOrderId, _worseOrderId);
        if (_order.orderType == Order.Types.Bid) {
            _bestOrderId = updateBestBidOrder(_order.id, _order.price, _order.outcome, _bestOrderWorstOrderHash, _bestOrderId);
            _worstOrderId = updateWorstBidOrder(_order.id, _order.price, _order.outcome, _bestOrderWorstOrderHash, _worstOrderId);
        } else {
            _bestOrderId = updateBestAskOrder(_order.id, _order.price, _order.outcome, _bestOrderWorstOrderHash, _bestOrderId);
            _worstOrderId = updateWorstAskOrder(_order.id, _order.price, _order.outcome, _bestOrderWorstOrderHash, _worstOrderId);
        }
        if (_bestOrderId == _order.id) {
            _betterOrderId = bytes32(0);
        }
        if (_worstOrderId == _order.id) {
            _worseOrderId = bytes32(0);
        }
        if (_betterOrderId != bytes32(0)) {
            orders[_betterOrderId].worseOrderId = _order.id;
            _order.betterOrderId = _betterOrderId;
        }
        if (_worseOrderId != bytes32(0)) {
            orders[_worseOrderId].betterOrderId = _order.id;
            _order.worseOrderId = _worseOrderId;
        }
        return true;
    }

    // _amount = _uints[0]
    // _price = _uints[1]
    // _outcome = _uints[2]
    // _moneyEscrowed = _uints[3]
    // _sharesEscrowed = _uints[4]
    // _betterOrderId = _bytes32s[0]
    // _worseOrderId = _bytes32s[1]
    // _tradeGroupId = _bytes32s[2]
    // _orderId = _bytes32s[3]
    function saveOrder(uint256[] calldata _uints, bytes32[] calldata _bytes32s, Order.Types _type, IMarket _market, address _sender) external returns (bytes32 _orderId) {
        require(msg.sender == createOrder || msg.sender == address(this));
        require(_uints[2] < _market.getNumberOfOutcomes(), "Orders.saveOrder: Outcome not in market range");
        _orderId = _bytes32s[3];
        Order.Data storage _order = orders[_orderId];
        _order.market = _market;
        _order.id = _orderId;
        _order.orderType = _type;
        _order.outcome = _uints[2];
        _order.price = _uints[1];
        _order.amount = _uints[0];
        _order.creator = _sender;
        _order.moneyEscrowed = _uints[3];
        marketOrderData[address(_market)].totalEscrowed += _uints[3];
        _order.sharesEscrowed = _uints[4];
        insertOrderIntoList(_order, _bytes32s[0], _bytes32s[1]);
        augurTrading.logOrderCreated(_order.market.getUniverse(), _orderId, _bytes32s[2]);
        return _orderId;
    }

    function removeOrder(bytes32 _orderId) external returns (bool) {
        require(msg.sender == cancelOrder || msg.sender == address(this));
        removeOrderFromList(_orderId);
        Order.Data storage _order = orders[_orderId];
        marketOrderData[address(_order.market)].totalEscrowed -= _order.moneyEscrowed;
        delete orders[_orderId];
        return true;
    }

    function recordFillOrder(bytes32 _orderId, uint256 _sharesFilled, uint256 _tokensFilled, uint256 _fill) external returns (bool) {
        require(msg.sender == fillOrder || msg.sender == address(this));
        Order.Data storage _order = orders[_orderId];
        require(_order.outcome < _order.market.getNumberOfOutcomes(), "Orders.recordFillOrder: Outcome is not in market range");
        require(_orderId != bytes32(0), "Orders.recordFillOrder: orderId is 0x0");
        require(_sharesFilled <= _order.sharesEscrowed, "Orders.recordFillOrder: shares filled higher than order amount");
        require(_tokensFilled <= _order.moneyEscrowed, "Orders.recordFillOrder: tokens filled higher than order amount");
        require(_order.price <= _order.market.getNumTicks(), "Orders.recordFillOrder: Price outside of market range");
        require(_fill <= _order.amount, "Orders.recordFillOrder: Fill higher than order amount");
        _order.amount -= _fill;
        _order.moneyEscrowed -= _tokensFilled;
        marketOrderData[address(_order.market)].totalEscrowed -= _tokensFilled;
        _order.sharesEscrowed -= _sharesFilled;
        if (_order.amount == 0) {
            require(_order.moneyEscrowed == 0, "Orders.recordFillOrder: Money left in filled order");
            require(_order.sharesEscrowed == 0, "Orders.recordFillOrder: Shares left in filled order");
            removeOrderFromList(_orderId);
            _order.price = 0;
            _order.creator = address(0);
            _order.betterOrderId = bytes32(0);
            _order.worseOrderId = bytes32(0);
        }
        return true;
    }

    function setPrice(IMarket _market, uint256 _outcome, uint256 _price) external returns (bool) {
        require(msg.sender == trade);
        marketOrderData[address(_market)].prices[_outcome] = _price;
        return true;
    }

    function removeOrderFromList(bytes32 _orderId) private returns (bool) {
        Order.Data storage _order = orders[_orderId];
        bytes32 _betterOrderId = _order.betterOrderId;
        bytes32 _worseOrderId = _order.worseOrderId;
        bytes32 _bestOrderWorstOrderHash = getBestOrderWorstOrderHash(_order.market, _order.outcome, _order.orderType);
        if (bestOrder[_bestOrderWorstOrderHash] == _orderId) {
            bestOrder[_bestOrderWorstOrderHash] = _worseOrderId;
        }
        if (worstOrder[_bestOrderWorstOrderHash] == _orderId) {
            worstOrder[_bestOrderWorstOrderHash] = _betterOrderId;
        }
        if (_betterOrderId != bytes32(0)) {
            orders[_betterOrderId].worseOrderId = _worseOrderId;
        }
        if (_worseOrderId != bytes32(0)) {
            orders[_worseOrderId].betterOrderId = _betterOrderId;
        }
        _order.betterOrderId = bytes32(0);
        _order.worseOrderId = bytes32(0);
        return true;
    }

    /**
     * @dev If best bid is not set or price higher than best bid price, this order is the new best bid.
     */
    function updateBestBidOrder(bytes32 _orderId, uint256 _price, uint256 _outcome, bytes32 _bestOrderWorstOrderHash, bytes32 _bestBidOrderId) private returns (bytes32) {
        if (_bestBidOrderId == bytes32(0) || _price > orders[_bestBidOrderId].price) {
            bestOrder[_bestOrderWorstOrderHash] = _orderId;
            return _orderId;
        } else {
            return _bestBidOrderId;
        }
    }

    /**
     * @dev If worst bid is not set or price lower than worst bid price, this order is the new worst bid.
     */
    function updateWorstBidOrder(bytes32 _orderId, uint256 _price, uint256 _outcome, bytes32 _bestOrderWorstOrderHash, bytes32 _worstBidOrderId) private returns (bytes32) {
        if (_worstBidOrderId == bytes32(0) || _price <= orders[_worstBidOrderId].price) {
            worstOrder[_bestOrderWorstOrderHash] = _orderId;
            return _orderId;
        } else {
            return _worstBidOrderId;
        }
    }

    /**
     * @dev If best ask is not set or price lower than best ask price, this order is the new best ask.
     */
    function updateBestAskOrder(bytes32 _orderId, uint256 _price, uint256 _outcome, bytes32 _bestOrderWorstOrderHash, bytes32 _bestAskOrderId) private returns (bytes32) {
        if (_bestAskOrderId == bytes32(0) || _price < orders[_bestAskOrderId].price) {
            bestOrder[_bestOrderWorstOrderHash] = _orderId;
            return _orderId;
        } else {
            return _bestAskOrderId;
        }
    }

    /**
     * @dev If worst ask is not set or price higher than worst ask price, this order is the new worst ask.
     */
    function updateWorstAskOrder(bytes32 _orderId, uint256 _price, uint256 _outcome, bytes32 _bestOrderWorstOrderHash, bytes32 _worstAskOrderId) private returns (bytes32) {
        if (_worstAskOrderId == bytes32(0) || _price >= orders[_worstAskOrderId].price) {
            worstOrder[_bestOrderWorstOrderHash] = _orderId;
            return _orderId;
        } else {
            return _worstAskOrderId;
        }
    }

    function getBestOrderWorstOrderHash(IMarket _market, uint256 _outcome, Order.Types _type) private pure returns (bytes32) {
        return sha256(abi.encodePacked(_market, _outcome, _type));
    }

    function ascendOrderList(Order.Types _type, uint256 _price, bytes32 _lowestOrderId) public view returns (bytes32 _betterOrderId, bytes32 _worseOrderId) {
        _worseOrderId = _lowestOrderId;
        bool _isWorstPrice;
        if (_type == Order.Types.Bid) {
            _isWorstPrice = _price <= getPrice(_worseOrderId);
        } else if (_type == Order.Types.Ask) {
            _isWorstPrice = _price >= getPrice(_worseOrderId);
        }
        if (_isWorstPrice) {
            return (_worseOrderId, getWorseOrderId(_worseOrderId));
        }
        bool _isBetterPrice = isBetterPrice(_type, _price, _worseOrderId);
        while (_isBetterPrice && getBetterOrderId(_worseOrderId) != 0 && _price != getPrice(getBetterOrderId(_worseOrderId))) {
            _betterOrderId = getBetterOrderId(_worseOrderId);
            _isBetterPrice = isBetterPrice(_type, _price, _betterOrderId);
            if (_isBetterPrice) {
                _worseOrderId = getBetterOrderId(_worseOrderId);
            }
        }
        _betterOrderId = getBetterOrderId(_worseOrderId);
        return (_betterOrderId, _worseOrderId);
    }

    function descendOrderList(Order.Types _type, uint256 _price, bytes32 _highestOrderId) public view returns (bytes32 _betterOrderId, bytes32 _worseOrderId) {
        _betterOrderId = _highestOrderId;
        bool _isBestPrice;
        if (_type == Order.Types.Bid) {
            _isBestPrice = _price > getPrice(_betterOrderId);
        } else if (_type == Order.Types.Ask) {
            _isBestPrice = _price < getPrice(_betterOrderId);
        }
        if (_isBestPrice) {
            return (0, _betterOrderId);
        }
        bool _isWorsePrice = isWorsePrice(_type, _price, _betterOrderId);
        while (_isWorsePrice && getWorseOrderId(_betterOrderId) != 0) {
            _worseOrderId = getWorseOrderId(_betterOrderId);
            _isWorsePrice = isWorsePrice(_type, _price, _worseOrderId);
            if (_isWorsePrice || _price == getPrice(getWorseOrderId(_betterOrderId))) {
                _betterOrderId = getWorseOrderId(_betterOrderId);
            }
        }
        _worseOrderId = getWorseOrderId(_betterOrderId);
        return (_betterOrderId, _worseOrderId);
    }

    function findBoundingOrders(Order.Types _type, uint256 _price, bytes32 _bestOrderId, bytes32 _worstOrderId, bytes32 _betterOrderId, bytes32 _worseOrderId) public returns (bytes32 betterOrderId, bytes32 worseOrderId) {
        if (_bestOrderId == _worstOrderId) {
            if (_bestOrderId == bytes32(0)) {
                return (bytes32(0), bytes32(0));
            } else if (isBetterPrice(_type, _price, _bestOrderId)) {
                return (bytes32(0), _bestOrderId);
            } else {
                return (_bestOrderId, bytes32(0));
            }
        }
        if (_betterOrderId != bytes32(0)) {
            if (getPrice(_betterOrderId) == 0) {
                _betterOrderId = bytes32(0);
            } else {
                assertIsNotBetterPrice(_type, _price, _betterOrderId);
            }
        }
        if (_worseOrderId != bytes32(0)) {
            if (getPrice(_worseOrderId) == 0) {
                _worseOrderId = bytes32(0);
            } else {
                assertIsNotWorsePrice(_type, _price, _worseOrderId);
            }
        }
        if (_betterOrderId == bytes32(0) && _worseOrderId == bytes32(0)) {
            return (descendOrderList(_type, _price, _bestOrderId));
        } else if (_betterOrderId == bytes32(0)) {
            return (ascendOrderList(_type, _price, _worseOrderId));
        } else if (_worseOrderId == bytes32(0)) {
            return (descendOrderList(_type, _price, _betterOrderId));
        }
        if (getWorseOrderId(_betterOrderId) != _worseOrderId) {
            return (descendOrderList(_type, _price, _betterOrderId));
        } else if (getBetterOrderId(_worseOrderId) != _betterOrderId) {
            // Coverage: This condition is likely unreachable or at least seems to be. Rather than remove it I'm keeping it for now just to be paranoid
            return (ascendOrderList(_type, _price, _worseOrderId));
        }
        return (_betterOrderId, _worseOrderId);
    }
}