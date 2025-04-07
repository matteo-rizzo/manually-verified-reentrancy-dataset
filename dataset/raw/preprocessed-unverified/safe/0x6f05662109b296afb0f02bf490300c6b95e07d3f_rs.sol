/**
 *Submitted for verification at Etherscan.io on 2020-07-02
*/

pragma solidity 0.5.16;




contract IMasset is MassetStructs {

    /** @dev Calc interest */
    function collectInterest() external returns (uint256 massetMinted, uint256 newTotalSupply);

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
}





contract ModuleKeys {

    // Governance
    // ===========
                                                // Phases
    // keccak256("Governance");                 // 2.x
    bytes32 internal constant KEY_GOVERNANCE = 0x9409903de1e6fd852dfc61c9dacb48196c48535b60e25abf92acc92dd689078d;
    //keccak256("Staking");                     // 1.2
    bytes32 internal constant KEY_STAKING = 0x1df41cd916959d1163dc8f0671a666ea8a3e434c13e40faef527133b5d167034;
    //keccak256("ProxyAdmin");                  // 1.0
    bytes32 internal constant KEY_PROXY_ADMIN = 0x96ed0203eb7e975a4cbcaa23951943fa35c5d8288117d50c12b3d48b0fab48d1;

    // mStable
    // =======
    // keccak256("OracleHub");                  // 1.2
    bytes32 internal constant KEY_ORACLE_HUB = 0x8ae3a082c61a7379e2280f3356a5131507d9829d222d853bfa7c9fe1200dd040;
    // keccak256("Manager");                    // 1.2
    bytes32 internal constant KEY_MANAGER = 0x6d439300980e333f0256d64be2c9f67e86f4493ce25f82498d6db7f4be3d9e6f;
    //keccak256("Recollateraliser");            // 2.x
    bytes32 internal constant KEY_RECOLLATERALISER = 0x39e3ed1fc335ce346a8cbe3e64dd525cf22b37f1e2104a755e761c3c1eb4734f;
    //keccak256("MetaToken");                   // 1.1
    bytes32 internal constant KEY_META_TOKEN = 0xea7469b14936af748ee93c53b2fe510b9928edbdccac3963321efca7eb1a57a2;
    // keccak256("SavingsManager");             // 1.0
    bytes32 internal constant KEY_SAVINGS_MANAGER = 0x12fe936c77a1e196473c4314f3bed8eeac1d757b319abb85bdda70df35511bf1;
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
 * @title   SavingsManager
 * @author  Stability Labs Pty. Ltd.
 * @notice  Savings Manager collects interest from mAssets and sends them to the
 *          corresponding Savings Contract, performing some validation in the process.
 * @dev     VERSION: 1.1
 *          DATE:    2020-07-01
 */
contract SavingsManager is ISavingsManager, PausableModule {

    using SafeMath for uint256;
    using StableMath for uint256;
    using SafeERC20 for IERC20;

    // Core admin events
    event SavingsContractAdded(address indexed mAsset, address savingsContract);
    event SavingsContractUpdated(address indexed mAsset, address savingsContract);
    event SavingsRateChanged(uint256 newSavingsRate);
    // Interest collection
    event InterestCollected(address indexed mAsset, uint256 interest, uint256 newTotalSupply, uint256 apy);
    event InterestDistributed(address indexed mAsset, uint256 amountSent);
    event InterestWithdrawnByGovernor(address indexed mAsset, address recipient, uint256 amount);

    // Locations of each mAsset savings contract
    mapping(address => ISavingsContract) public savingsContracts;
    // Time at which last collection was made
    mapping(address => uint256) public lastCollection;

    // Amount of collected interest that will be sent to Savings Contract (100%)
    uint256 private savingsRate = 1e18;
    // Utils to help keep interest under check
    uint256 constant private SECONDS_IN_YEAR = 365 days;
    // Theoretical cap on APY to avoid excess inflation
    uint256 constant private MAX_APY = 15e18;
    uint256 constant private TEN_BPS = 1e15;
    uint256 constant private THIRTY_MINUTES = 30 minutes;

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
     * @dev Sets a new savings rate for interest distribution
     * @param _savingsRate   Rate of savings sent to SavingsContract (100% = 1e18)
     */
    function setSavingsRate(uint256 _savingsRate)
        external
        onlyGovernor
    {
        // Greater than 90% upto 100%
        require(_savingsRate > 9e17 && _savingsRate <= 1e18, "Must be a valid rate");
        savingsRate = _savingsRate;
        emit SavingsRateChanged(_savingsRate);
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
        ISavingsContract savingsContract = savingsContracts[_mAsset];
        require(address(savingsContract) != address(0), "Must have a valid savings contract");

        // Get collection details
        uint256 previousCollection = lastCollection[_mAsset];
        lastCollection[_mAsset] = now;

        // 1. Collect the new interest from the mAsset
        IMasset mAsset = IMasset(_mAsset);
        (uint256 interestCollected, uint256 totalSupply) = mAsset.collectInterest();

        if(interestCollected > 0) {
            // 2. Validate that the interest has been collected and is within certain limits
            require(
                IERC20(_mAsset).balanceOf(address(this)) >= interestCollected,
                "Must receive mUSD"
            );

            // Avoid division by 0 by adding a minimum elapsed time of 1 second
            uint256 timeSinceLastCollection = StableMath.max(1, now.sub(previousCollection));

            // e.g. day: (86400 * 1e18) / 3.154e7 = 2.74..e15
            // e.g. 30 mins: (1800 * 1e18) / 3.154e7 = 5.7..e13
            // e.g. epoch: (1593596907 * 1e18) / 3.154e7 = 50.4..e18
            uint256 yearsSinceLastCollection =
                timeSinceLastCollection.divPrecisely(SECONDS_IN_YEAR);

            // Percentage increase in total supply
            // e.g. (1e20 * 1e18) / 1e24 = 1e14 (or a 0.01% increase)
            // e.g. (5e18 * 1e18) / 1.2e24 = 4.1667e12
            // e.g. (1e19 * 1e18) / 1e21 = 1e16
            uint256 oldSupply = totalSupply.sub(interestCollected);
            uint256 percentageIncrease = interestCollected.divPrecisely(oldSupply);

            // e.g. 0.01% (1e14 * 1e18) / 2.74..e15 = 3.65e16 or 3.65% apr
            // e.g. (4.1667e12 * 1e18) / 5.7..e13 = 7.1e16 or 7.1% apr
            // e.g. (1e16 * 1e18) / 50e18 = 2e14
            uint256 extrapolatedAPY = percentageIncrease.divPrecisely(yearsSinceLastCollection);

            // 2.1. If over 30 mins, extrapolate APY
            if(timeSinceLastCollection > THIRTY_MINUTES) {
                require(extrapolatedAPY < MAX_APY, "Interest protected from inflating past maxAPY");
            } else {
                require(percentageIncrease < TEN_BPS, "Interest protected from inflating past 10 Bps");
            }

            emit InterestCollected(_mAsset, interestCollected, totalSupply, extrapolatedAPY);

            // 3. Distribute the interest
            // Calculate the share for savers (95e16 or 95%)
            uint256 saversShare = interestCollected.mulTruncate(savingsRate);

            // Call depositInterest on contract
            savingsContract.depositInterest(saversShare);

            emit InterestDistributed(_mAsset, saversShare);
        } else {
            emit InterestCollected(_mAsset, 0, totalSupply, 0);
        }
    }

    /***************************************
                MANAGEMENT
    ****************************************/

    /**
     * @dev Withdraws any unallocated interest, i.e. that which has been saved for use
     *      elsewhere in the system, based on the savingsRate
     * @param _mAsset       mAsset to collect from
     * @param _recipient    Address of mAsset recipient
     */
    function withdrawUnallocatedInterest(address _mAsset, address _recipient)
        external
        onlyGovernor
    {
        IERC20 mAsset = IERC20(_mAsset);
        uint256 balance = mAsset.balanceOf(address(this));

        emit InterestWithdrawnByGovernor(_mAsset, _recipient, balance);

        mAsset.safeTransfer(_recipient, balance);
    }
}