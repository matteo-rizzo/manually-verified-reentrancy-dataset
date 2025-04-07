/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

pragma solidity 0.5.16;




contract IMasset is MassetStructs {

    /** @dev Calc interest */
    function collectInterest() external returns (uint256 swapFeesGained, uint256 newTotalSupply);
    function collectPlatformInterest() external returns (uint256 interestGained, uint256 newTotalSupply);

    /** @dev Minting */
    function mint(address _basset, uint256 _bassetQuantity)
        external returns (uint256 massetMinted);
    function mintTo(address _basset, uint256 _bassetQuantity, address _recipient)
        external returns (uint256 massetMinted);
    function mintMulti(address[] calldata _bAssets, uint256[] calldata _bassetQuantity, address _recipient)
        external returns (uint256 massetMinted);

    /** @dev Swapping */
    function swap( address _input, address _output, uint256 _quantity, address _recipient)
        external returns (uint256 output);
    function getSwapOutput( address _input, address _output, uint256 _quantity)
        external view returns (bool, string memory, uint256 output);

    /** @dev Redeeming */
    function redeem(address _basset, uint256 _bassetQuantity)
        external returns (uint256 massetRedeemed);
    function redeemTo(address _basset, uint256 _bassetQuantity, address _recipient)
        external returns (uint256 massetRedeemed);
    function redeemMulti(address[] calldata _bAssets, uint256[] calldata _bassetQuantities, address _recipient)
        external returns (uint256 massetRedeemed);
    function redeemMasset(uint256 _mAssetQuantity, address _recipient) external;

    /** @dev Setters for the Manager or Gov to update module info */
    function upgradeForgeValidator(address _newForgeValidator) external;

    /** @dev Setters for Gov to set system params */
    function setSwapFee(uint256 _swapFee) external;

    /** @dev Getters */
    function getBasketManager() external view returns(address);
    function forgeValidator() external view returns (address);
    function totalSupply() external view returns (uint256);
    function swapFee() external view returns (uint256);
}







contract ModuleKeys {

    // Governance
    // ===========
    // keccak256("Governance");
    bytes32 internal constant KEY_GOVERNANCE = 0x9409903de1e6fd852dfc61c9dacb48196c48535b60e25abf92acc92dd689078d;
    //keccak256("Staking");
    bytes32 internal constant KEY_STAKING = 0x1df41cd916959d1163dc8f0671a666ea8a3e434c13e40faef527133b5d167034;
    //keccak256("ProxyAdmin");
    bytes32 internal constant KEY_PROXY_ADMIN = 0x96ed0203eb7e975a4cbcaa23951943fa35c5d8288117d50c12b3d48b0fab48d1;

    // mStable
    // =======
    // keccak256("OracleHub");
    bytes32 internal constant KEY_ORACLE_HUB = 0x8ae3a082c61a7379e2280f3356a5131507d9829d222d853bfa7c9fe1200dd040;
    // keccak256("Manager");
    bytes32 internal constant KEY_MANAGER = 0x6d439300980e333f0256d64be2c9f67e86f4493ce25f82498d6db7f4be3d9e6f;
    //keccak256("Recollateraliser");
    bytes32 internal constant KEY_RECOLLATERALISER = 0x39e3ed1fc335ce346a8cbe3e64dd525cf22b37f1e2104a755e761c3c1eb4734f;
    //keccak256("MetaToken");
    bytes32 internal constant KEY_META_TOKEN = 0xea7469b14936af748ee93c53b2fe510b9928edbdccac3963321efca7eb1a57a2;
    // keccak256("SavingsManager");
    bytes32 internal constant KEY_SAVINGS_MANAGER = 0x12fe936c77a1e196473c4314f3bed8eeac1d757b319abb85bdda70df35511bf1;
    // keccak256("Liquidator");
    bytes32 internal constant KEY_LIQUIDATOR = 0x1e9cb14d7560734a61fa5ff9273953e971ff3cd9283c03d8346e3264617933d4;
}



contract Module is ModuleKeys {

    INexus public nexus;

    /**
     * @dev Initialises the Module by setting publisher addresses,
     *      and reading all available system module information
     */
    constructor(address _nexus) internal {
        require(_nexus != address(0), "Nexus is zero address");
        nexus = INexus(_nexus);
    }

    /**
     * @dev Modifier to allow function calls only from the Governor.
     */
    modifier onlyGovernor() {
        require(msg.sender == _governor(), "Only governor can execute");
        _;
    }

    /**
     * @dev Modifier to allow function calls only from the Governance.
     *      Governance is either Governor address or Governance address.
     */
    modifier onlyGovernance() {
        require(
            msg.sender == _governor() || msg.sender == _governance(),
            "Only governance can execute"
        );
        _;
    }

    /**
     * @dev Modifier to allow function calls only from the ProxyAdmin.
     */
    modifier onlyProxyAdmin() {
        require(
            msg.sender == _proxyAdmin(), "Only ProxyAdmin can execute"
        );
        _;
    }

    /**
     * @dev Modifier to allow function calls only from the Manager.
     */
    modifier onlyManager() {
        require(msg.sender == _manager(), "Only manager can execute");
        _;
    }

    /**
     * @dev Returns Governor address from the Nexus
     * @return Address of Governor Contract
     */
    function _governor() internal view returns (address) {
        return nexus.governor();
    }

    /**
     * @dev Returns Governance Module address from the Nexus
     * @return Address of the Governance (Phase 2)
     */
    function _governance() internal view returns (address) {
        return nexus.getModule(KEY_GOVERNANCE);
    }

    /**
     * @dev Return Staking Module address from the Nexus
     * @return Address of the Staking Module contract
     */
    function _staking() internal view returns (address) {
        return nexus.getModule(KEY_STAKING);
    }

    /**
     * @dev Return ProxyAdmin Module address from the Nexus
     * @return Address of the ProxyAdmin Module contract
     */
    function _proxyAdmin() internal view returns (address) {
        return nexus.getModule(KEY_PROXY_ADMIN);
    }

    /**
     * @dev Return MetaToken Module address from the Nexus
     * @return Address of the MetaToken Module contract
     */
    function _metaToken() internal view returns (address) {
        return nexus.getModule(KEY_META_TOKEN);
    }

    /**
     * @dev Return OracleHub Module address from the Nexus
     * @return Address of the OracleHub Module contract
     */
    function _oracleHub() internal view returns (address) {
        return nexus.getModule(KEY_ORACLE_HUB);
    }

    /**
     * @dev Return Manager Module address from the Nexus
     * @return Address of the Manager Module contract
     */
    function _manager() internal view returns (address) {
        return nexus.getModule(KEY_MANAGER);
    }

    /**
     * @dev Return SavingsManager Module address from the Nexus
     * @return Address of the SavingsManager Module contract
     */
    function _savingsManager() internal view returns (address) {
        return nexus.getModule(KEY_SAVINGS_MANAGER);
    }

    /**
     * @dev Return Recollateraliser Module address from the Nexus
     * @return  Address of the Recollateraliser Module contract (Phase 2)
     */
    function _recollateraliser() internal view returns (address) {
        return nexus.getModule(KEY_RECOLLATERALISER);
    }

    /**
     * @dev Return Recollateraliser Module address from the Nexus
     * @return  Address of the Recollateraliser Module contract (Phase 2)
     */
    function _liquidator() internal view returns (address) {
        return nexus.getModule(KEY_LIQUIDATOR);
    }
}

contract PausableModule is Module {

    /**
     * @dev Emitted when the pause is triggered by Governor
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by Governor
     */
    event Unpaused(address account);

    bool private _paused = false;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Initializes the contract in unpaused state.
     * Hooks into the Module to give the Governor ability to pause
     * @param _nexus Nexus contract address
     */
    constructor (address _nexus) internal Module(_nexus) {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     * @return Returns `true` when paused, otherwise `false`
     */
    function paused() external view returns (bool) {
        return _paused;
    }

    /**
     * @dev Called by the Governor to pause, triggers stopped state.
     */
    function pause() external onlyGovernor whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by Governor to unpause, returns to normal state.
     */
    function unpause() external onlyGovernor whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}



/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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






// External
// Internal
// Libs
/**
 * @title   SavingsManager
 * @author  Stability Labs Pty. Ltd.
 * @notice  Savings Manager collects interest from mAssets and sends them to the
 *          corresponding Savings Contract, performing some validation in the process.
 * @dev     VERSION: 1.3
 *          DATE:    2020-12-09
 */
contract SavingsManager is ISavingsManager, PausableModule {

    using SafeMath for uint256;
    using StableMath for uint256;
    using SafeERC20 for IERC20;


    // Core admin events
    event RevenueRecipientSet(address indexed mAsset, address recipient);
    event SavingsContractAdded(address indexed mAsset, address savingsContract);
    event SavingsContractUpdated(address indexed mAsset, address savingsContract);
    event SavingsRateChanged(uint256 newSavingsRate);
    event StreamsFrozen();
    // Interest collection
    event LiquidatorDeposited(address indexed mAsset, uint256 amount);
    event InterestCollected(address indexed mAsset, uint256 interest, uint256 newTotalSupply, uint256 apy);
    event InterestDistributed(address indexed mAsset, uint256 amountSent);
    event RevenueRedistributed(address indexed mAsset, address recipient, uint256 amount);

    // Locations of each mAsset savings contract
    mapping(address => ISavingsContract) public savingsContracts;
    mapping(address => IRevenueRecipient) public revenueRecipients;
    // Time at which last collection was made
    mapping(address => uint256) public lastPeriodStart;
    mapping(address => uint256) public lastCollection;
    mapping(address => uint256) public periodYield;

    // Amount of collected interest that will be sent to Savings Contract (100%)
    uint256 private savingsRate = 1e18;
    // Utils to help keep interest under check
    uint256 constant private SECONDS_IN_YEAR = 365 days;
    // Theoretical cap on APY to avoid excess inflation
    uint256 constant private MAX_APY = 15e18;
    uint256 constant private TEN_BPS = 1e15;
    // Streaming liquidated tokens
    uint256 private constant DURATION = 7 days;
    uint256 private constant ONE_DAY = 1 days;
    uint256 constant private THIRTY_MINUTES = 30 minutes;
    // Streams
    bool private streamsFrozen = false;
    // Liquidator
    mapping(address => Stream) public liqStream;
    // Platform
    mapping(address => Stream) public yieldStream;
    // Batches are for the platformInterest collection
    mapping(address => uint256) public lastBatchCollected;

    enum StreamType {
        liquidator,
        yield
    }

    struct Stream {
        uint256 end;
        uint256 rate;
    }

    constructor(
        address _nexus,
        address _mUSD,
        address _savingsContract
    )
        public
        PausableModule(_nexus)
    {
        _updateSavingsContract(_mUSD, _savingsContract);
        emit SavingsContractAdded(_mUSD, _savingsContract);
    }

    modifier onlyLiquidator() {
        require(msg.sender == _liquidator(), "Only liquidator can execute");
        _;
    }

    modifier whenStreamsNotFrozen() {
        require(!streamsFrozen, "Streaming is currently frozen");
        _;
    }

    /***************************************
                    STATE
    ****************************************/

    /**
     * @dev Adds a new savings contract
     * @param _mAsset           Address of underlying mAsset
     * @param _savingsContract  Address of the savings contract
     */
    function addSavingsContract(address _mAsset, address _savingsContract)
        external
        onlyGovernor
    {
        require(address(savingsContracts[_mAsset]) == address(0), "Savings contract already exists");
        _updateSavingsContract(_mAsset, _savingsContract);
        emit SavingsContractAdded(_mAsset, _savingsContract);
    }

    /**
     * @dev Updates an existing savings contract
     * @param _mAsset           Address of underlying mAsset
     * @param _savingsContract  Address of the savings contract
     */
    function updateSavingsContract(address _mAsset, address _savingsContract)
        external
        onlyGovernor
    {
        require(address(savingsContracts[_mAsset]) != address(0), "Savings contract does not exist");
        _updateSavingsContract(_mAsset, _savingsContract);
        emit SavingsContractUpdated(_mAsset, _savingsContract);
    }

    function _updateSavingsContract(address _mAsset, address _savingsContract)
        internal
    {
        require(_mAsset != address(0) && _savingsContract != address(0), "Must be valid address");
        savingsContracts[_mAsset] = ISavingsContract(_savingsContract);

        IERC20(_mAsset).safeApprove(address(_savingsContract), 0);
        IERC20(_mAsset).safeApprove(address(_savingsContract), uint256(-1));
    }

    /**
     * @dev Freezes streaming of mAssets
     */
    function freezeStreams()
        external
        onlyGovernor
        whenStreamsNotFrozen
    {
        streamsFrozen = true;

        emit StreamsFrozen();
    }

    /**
     * @dev Sets the revenue recipient address
     * @param _mAsset           Address of underlying mAsset
     * @param _recipient        Address of the recipient
     */
    function setRevenueRecipient(address _mAsset, address _recipient)
        external
        onlyGovernor
    {
        revenueRecipients[_mAsset] = IRevenueRecipient(_recipient);

        emit RevenueRecipientSet(_mAsset, _recipient);
    }


    /**
     * @dev Sets a new savings rate for interest distribution
     * @param _savingsRate   Rate of savings sent to SavingsContract (100% = 1e18)
     */
    function setSavingsRate(uint256 _savingsRate)
        external
        onlyGovernor
    {
        // Greater than 60% upto 100%
        require(_savingsRate >= 6e17 && _savingsRate <= 1e18, "Must be a valid rate");
        savingsRate = _savingsRate;
        emit SavingsRateChanged(_savingsRate);
    }

    /**
     * @dev Allows the liquidator to deposit proceeds from iquidated gov tokens.
     * Transfers proceeds on a second by second basis to the Savings Contract over 1 week.
     * @param _mAsset The mAsset to transfer and distribute
     * @param _liquidated Units of mAsset to distribute
     */
    function depositLiquidation(address _mAsset, uint256 _liquidated)
        external
        whenNotPaused
        onlyLiquidator
        whenStreamsNotFrozen
    {
        // Collect existing interest to ensure everything is up to date
        _collectAndDistributeInterest(_mAsset);

        // transfer liquidated mUSD to here
        IERC20(_mAsset).safeTransferFrom(_liquidator(), address(this), _liquidated);

        uint256 leftover = _unstreamedRewards(_mAsset, StreamType.liquidator);
        _initialiseStream(_mAsset, StreamType.liquidator, _liquidated.add(leftover), DURATION);

        emit LiquidatorDeposited(_mAsset, _liquidated);
    }

    /**
     * @dev Collects the platform interest from a given mAsset and then adds capital to the
     * stream. If there is > 24h left in current stream, just top it up, otherwise reset.
     * @param _mAsset The mAsset to fetch interest
     */
    function collectAndStreamInterest(address _mAsset)
        external
        whenNotPaused
        whenStreamsNotFrozen
    {
        // Collect existing interest to ensure everything is up to date
        _collectAndDistributeInterest(_mAsset);

        uint256 currentTime = now;
        uint256 previousBatch = lastBatchCollected[_mAsset];
        uint256 timeSincePreviousBatch = currentTime.sub(previousBatch);
        require(timeSincePreviousBatch > 6 hours, "Cannot deposit twice in 6 hours");
        lastBatchCollected[_mAsset] = currentTime;

        // Batch collect
        (uint256 interestCollected, uint256 totalSupply) =  IMasset(_mAsset).collectPlatformInterest();

        if(interestCollected > 0){
            // Validate APY
            uint256 apy = _validateCollection(totalSupply, interestCollected, timeSincePreviousBatch);

            // Get remaining rewards
            uint256 leftover = _unstreamedRewards(_mAsset, StreamType.yield);
            _initialiseStream(_mAsset, StreamType.yield, interestCollected.add(leftover), ONE_DAY);

            emit InterestCollected(_mAsset, interestCollected, totalSupply, apy);
        }

        emit InterestCollected(_mAsset, interestCollected, totalSupply, 0);
    }

    /**
     * @dev Calculates how many rewards from the stream are still to be distributed, from the
     * last collection time to the end of the stream.
     * @param _mAsset The mAsset in question
     * @return leftover The total amount of mAsset that is yet to be collected from a stream
     */
    function _unstreamedRewards(address _mAsset, StreamType _stream) internal view returns (uint256 leftover) {
        uint256 lastUpdate = lastCollection[_mAsset];

        Stream memory stream = _stream == StreamType.liquidator ? liqStream[_mAsset] : yieldStream[_mAsset];
        uint256 unclaimedSeconds = 0;
        if(lastUpdate < stream.end){
            unclaimedSeconds = stream.end.sub(lastUpdate);
        }
        return unclaimedSeconds.mul(stream.rate);
    }

    /**
     * @dev Simply sets up the stream
     * @param _mAsset The mAsset in question
     * @param _amount Amount of units to stream
     * @param _duration Duration of the stream, from now
     */
    function _initialiseStream(address _mAsset, StreamType _stream, uint256 _amount, uint256 _duration) internal {
        uint256 currentTime = now;
        // Distribute reward per second over X seconds
        uint256 rate = _amount.div(_duration);
        uint256 end = currentTime.add(_duration);
        if(_stream == StreamType.liquidator){
            liqStream[_mAsset] = Stream(end, rate);
        } else {
            yieldStream[_mAsset] = Stream(end, rate);
        }

        // Reset pool data to enable lastCollection usage twice
        require(lastCollection[_mAsset] == currentTime, "Stream data must be up to date");
    }

    /***************************************
                COLLECTION
    ****************************************/

    /**
     * @dev Collects interest from a target mAsset and distributes to the SavingsContract.
     *      Applies constraints such that the max APY since the last fee collection cannot
     *      exceed the "MAX_APY" variable.
     * @param _mAsset       mAsset for which the interest should be collected
     */
    function collectAndDistributeInterest(address _mAsset)
        external
        whenNotPaused
    {
        _collectAndDistributeInterest(_mAsset);
    }

    function _collectAndDistributeInterest(address _mAsset)
        internal
    {
        ISavingsContract savingsContract = savingsContracts[_mAsset];
        require(address(savingsContract) != address(0), "Must have a valid savings contract");

        // Get collection details
        uint256 recentPeriodStart = lastPeriodStart[_mAsset];
        uint256 previousCollection = lastCollection[_mAsset];
        lastCollection[_mAsset] = now;

        // 1. Collect the new interest from the mAsset
        IMasset mAsset = IMasset(_mAsset);
        (uint256 interestCollected, uint256 totalSupply) = mAsset.collectInterest();

        // 2. Update all the time stamps
        //    Avoid division by 0 by adding a minimum elapsed time of 1 second
        uint256 timeSincePeriodStart = StableMath.max(1, now.sub(recentPeriodStart));
        uint256 timeSinceLastCollection = StableMath.max(1, now.sub(previousCollection));

        uint256 inflationOperand = interestCollected;
        //    If it has been 30 mins since last collection, reset period data
        if(timeSinceLastCollection > THIRTY_MINUTES) {
            lastPeriodStart[_mAsset] = now;
            periodYield[_mAsset] = 0;
        }
        //    Else if period has elapsed, start a new period from the lastCollection time
        else if(timeSincePeriodStart > THIRTY_MINUTES) {
            lastPeriodStart[_mAsset] = previousCollection;
            periodYield[_mAsset] = interestCollected;
        }
        //    Else add yield to period yield
        else {
            inflationOperand = periodYield[_mAsset].add(interestCollected);
            periodYield[_mAsset] = inflationOperand;
        }

        //    Add on liquidated
        uint256 newReward = _unclaimedRewards(_mAsset, previousCollection);
        // 3. Validate that interest is collected correctly and does not exceed max APY
        if(interestCollected > 0 || newReward > 0) {
            require(
                IERC20(_mAsset).balanceOf(address(this)) >= interestCollected.add(newReward),
                "Must receive mUSD"
            );

            uint256 extrapolatedAPY = _validateCollection(totalSupply, inflationOperand, timeSinceLastCollection);

            emit InterestCollected(_mAsset, interestCollected, totalSupply, extrapolatedAPY);

            // 4. Distribute the interest
            //    Calculate the share for savers (95e16 or 95%)
            uint256 saversShare = interestCollected.add(newReward).mulTruncate(savingsRate);

            //    Call depositInterest on contract
            savingsContract.depositInterest(saversShare);

            emit InterestDistributed(_mAsset, saversShare);
        } else {
            emit InterestCollected(_mAsset, 0, totalSupply, 0);
        }
    }

    /**
     * @dev Calculates unclaimed rewards from the liquidation stream
     * @param _mAsset mAsset key
     * @param _previousCollection Time of previous collection
     * @return Units of mAsset that have been unlocked for distribution
     */
    function _unclaimedRewards(address _mAsset, uint256 _previousCollection) internal view returns (uint256) {
        Stream memory liq = liqStream[_mAsset];
        uint256 unclaimedSeconds_liq = _unclaimedSeconds(_previousCollection, liq.end);
        uint256 subtotal_liq = unclaimedSeconds_liq.mul(liq.rate);

        Stream memory yield = yieldStream[_mAsset];
        uint256 unclaimedSeconds_yield = _unclaimedSeconds(_previousCollection, yield.end);
        uint256 subtotal_yield = unclaimedSeconds_yield.mul(yield.rate);

        return subtotal_liq.add(subtotal_yield);
    }

    /**
     * @dev Calculates the seconds of unclaimed rewards, based on period length
     * @param _lastUpdate Time of last update
     * @param _end End time of period
     * @return Seconds of stream that should be compensated
     */
    function _unclaimedSeconds(uint256 _lastUpdate, uint256 _end) internal view returns (uint256) {
        uint256 currentTime = block.timestamp;
        uint256 unclaimedSeconds = 0;

        if(currentTime <= _end){
            unclaimedSeconds = currentTime.sub(_lastUpdate);
        } else if(_lastUpdate < _end) {
            unclaimedSeconds = _end.sub(_lastUpdate);
        }
        return unclaimedSeconds;
    }

    /**
     * @dev Validates that an interest collection does not exceed a maximum APY. If last collection
     * was under 30 mins ago, simply check it does not exceed 10bps
     * @param _newSupply               New total supply of the mAsset
     * @param _interest                Increase in total supply since last collection
     * @param _timeSinceLastCollection Seconds since last collection
     */
    function _validateCollection(uint256 _newSupply, uint256 _interest, uint256 _timeSinceLastCollection)
        internal
        pure
        returns (uint256 extrapolatedAPY)
    {
        // Percentage increase in total supply
        // e.g. (1e20 * 1e18) / 1e24 = 1e14 (or a 0.01% increase)
        // e.g. (5e18 * 1e18) / 1.2e24 = 4.1667e12
        // e.g. (1e19 * 1e18) / 1e21 = 1e16
        uint256 oldSupply = _newSupply.sub(_interest);
        uint256 percentageIncrease = _interest.divPrecisely(oldSupply);

        //      If over 30 mins, extrapolate APY
        // e.g. day: (86400 * 1e18) / 3.154e7 = 2.74..e15
        // e.g. 30 mins: (1800 * 1e18) / 3.154e7 = 5.7..e13
        // e.g. epoch: (1593596907 * 1e18) / 3.154e7 = 50.4..e18
        uint256 yearsSinceLastCollection =
            _timeSinceLastCollection.divPrecisely(SECONDS_IN_YEAR);

        // e.g. 0.01% (1e14 * 1e18) / 2.74..e15 = 3.65e16 or 3.65% apr
        // e.g. (4.1667e12 * 1e18) / 5.7..e13 = 7.1e16 or 7.1% apr
        // e.g. (1e16 * 1e18) / 50e18 = 2e14
        extrapolatedAPY = percentageIncrease.divPrecisely(yearsSinceLastCollection);

        if(_timeSinceLastCollection > THIRTY_MINUTES) {
            require(extrapolatedAPY < MAX_APY, "Interest protected from inflating past maxAPY");
        } else {
            require(percentageIncrease < TEN_BPS, "Interest protected from inflating past 10 Bps");
        }
    }


    /***************************************
            Revenue Redistribution
    ****************************************/

    /**
     * @dev Redistributes the unallocated interest to the saved recipient, allowing
     * the siphoned assets to be used elsewhere in the system
     * @param _mAsset  mAsset to collect
     */
    function distributeUnallocatedInterest(address _mAsset)
        external
        onlyGovernance
    {
        IRevenueRecipient recipient = revenueRecipients[_mAsset];
        require(address(recipient) != address(0), "Must have valid recipient");

        IERC20 mAsset = IERC20(_mAsset);
        uint256 balance = mAsset.balanceOf(address(this));
        uint256 leftover_liq = _unstreamedRewards(_mAsset, StreamType.liquidator);
        uint256 leftover_yield = _unstreamedRewards(_mAsset, StreamType.yield);

        uint256 unallocated = balance.sub(leftover_liq).sub(leftover_yield);

        mAsset.approve(address(recipient), unallocated);
        recipient.notifyRedistributionAmount(_mAsset, unallocated);

        emit RevenueRedistributed(_mAsset, address(recipient), unallocated);
    }
}