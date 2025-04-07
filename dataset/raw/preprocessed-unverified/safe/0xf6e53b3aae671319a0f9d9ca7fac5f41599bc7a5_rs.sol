pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;






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

contract InitializableModuleKeys {

    // Governance                             // Phases
    bytes32 internal KEY_GOVERNANCE;          // 2.x
    bytes32 internal KEY_STAKING;             // 1.2
    bytes32 internal KEY_PROXY_ADMIN;         // 1.0

    // mStable
    bytes32 internal KEY_ORACLE_HUB;          // 1.2
    bytes32 internal KEY_MANAGER;             // 1.2
    bytes32 internal KEY_RECOLLATERALISER;    // 2.x
    bytes32 internal KEY_META_TOKEN;          // 1.1
    bytes32 internal KEY_SAVINGS_MANAGER;     // 1.0

    /**
     * @dev Initialize function for upgradable proxy contracts. This function should be called
     *      via Proxy to initialize constants in the Proxy contract.
     */
    function _initialize() internal {
        // keccak256() values are evaluated only once at the time of this function call.
        // Hence, no need to assign hard-coded values to these variables.
        KEY_GOVERNANCE = keccak256("Governance");
        KEY_STAKING = keccak256("Staking");
        KEY_PROXY_ADMIN = keccak256("ProxyAdmin");

        KEY_ORACLE_HUB = keccak256("OracleHub");
        KEY_MANAGER = keccak256("Manager");
        KEY_RECOLLATERALISER = keccak256("Recollateraliser");
        KEY_META_TOKEN = keccak256("MetaToken");
        KEY_SAVINGS_MANAGER = keccak256("SavingsManager");
    }
}



contract InitializableModule is InitializableModuleKeys {

    INexus public nexus;

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
     * @dev Initialization function for upgradable proxy contracts
     * @param _nexus Nexus contract address
     */
    function _initialize(address _nexus) internal {
        require(_nexus != address(0), "Nexus address is zero");
        nexus = INexus(_nexus);
        InitializableModuleKeys._initialize();
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

contract InitializableGovernableWhitelist is InitializableModule {

    event Whitelisted(address indexed _address);

    mapping(address => bool) public whitelist;

    /**
     * @dev Modifier to allow function calls only from the whitelisted address.
     */
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Not a whitelisted address");
        _;
    }

    /**
     * @dev Initialization function for upgradable proxy contracts
     * @param _nexus Nexus contract address
     * @param _whitelisted Array of whitelisted addresses.
     */
    function _initialize(
        address _nexus,
        address[] memory _whitelisted
    )
        internal
    {
        InitializableModule._initialize(_nexus);

        require(_whitelisted.length > 0, "Empty whitelist array");

        for(uint256 i = 0; i < _whitelisted.length; i++) {
            _addWhitelist(_whitelisted[i]);
        }
    }

    /**
     * @dev Adds a new whitelist address
     * @param _address Address to add in whitelist
     */
    function _addWhitelist(address _address) internal {
        require(_address != address(0), "Address is zero");
        require(! whitelist[_address], "Already whitelisted");

        whitelist[_address] = true;

        emit Whitelisted(_address);
    }

}

contract MerkleDrop is Initializable, InitializableGovernableWhitelist {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event Claimed(address claimant, uint256 week, uint256 balance);
    event TrancheAdded(uint256 tranche, bytes32 merkleRoot, uint256 totalAmount);
    event TrancheExpired(uint256 tranche);
    event RemovedFunder(address indexed _address);

    IERC20 public token;

    mapping(uint256 => bytes32) public merkleRoots;
    mapping(uint256 => mapping(address => bool)) public claimed;
    uint256 tranches;

    function initialize(
        address _nexus,
        address[] calldata _funders,
        IERC20 _token
    )
        external
        initializer
    {
        InitializableGovernableWhitelist._initialize(_nexus, _funders);
        token = _token;
    }

    /***************************************
                    ADMIN
    ****************************************/

    function seedNewAllocations(bytes32 _merkleRoot, uint256 _totalAllocation)
        public
        onlyWhitelisted
        returns (uint256 trancheId)
    {
        token.safeTransferFrom(msg.sender, address(this), _totalAllocation);

        trancheId = tranches;
        merkleRoots[trancheId] = _merkleRoot;

        tranches = tranches.add(1);

        emit TrancheAdded(trancheId, _merkleRoot, _totalAllocation);
    }

    function expireTranche(uint256 _trancheId)
        public
        onlyWhitelisted
    {
        merkleRoots[_trancheId] = bytes32(0);

        emit TrancheExpired(_trancheId);
    }

    /**
     * @dev Allows the mStable governance to add a new Funder
     * @param _address  Funder to add
     */
    function addFunder(address _address)
        external
        onlyGovernor
    {
        _addWhitelist(_address);
    }

    /**
     * @dev Allows the mStable governance to remove inactive Funder
     * @param _address  Funder to remove
     */
    function removeFunder(address _address)
        external
        onlyGovernor
    {
        require(_address != address(0), "Address is zero");
        require(whitelist[_address], "Address is not whitelisted");

        whitelist[_address] = false;

        emit RemovedFunder(_address);
    }


    /***************************************
                  CLAIMING
    ****************************************/


    function claimWeek(
        address _liquidityProvider,
        uint256 _tranche,
        uint256 _balance,
        bytes32[] memory _merkleProof
    )
        public
    {
        _claimWeek(_liquidityProvider, _tranche, _balance, _merkleProof);
        _disburse(_liquidityProvider, _balance);
    }


    function claimWeeks(
        address _liquidityProvider,
        uint256[] memory _tranches,
        uint256[] memory _balances,
        bytes32[][] memory _merkleProofs
    )
        public
    {
        uint256 len = _tranches.length;
        require(len == _balances.length && len == _merkleProofs.length, "Mismatching inputs");

        uint256 totalBalance = 0;
        for(uint256 i = 0; i < len; i++) {
            _claimWeek(_liquidityProvider, _tranches[i], _balances[i], _merkleProofs[i]);
            totalBalance = totalBalance.add(_balances[i]);
        }
        _disburse(_liquidityProvider, totalBalance);
    }


    function verifyClaim(
        address _liquidityProvider,
        uint256 _tranche,
        uint256 _balance,
        bytes32[] memory _merkleProof
    )
        public
        view
        returns (bool valid)
    {
        return _verifyClaim(_liquidityProvider, _tranche, _balance, _merkleProof);
    }


    /***************************************
              CLAIMING - INTERNAL
    ****************************************/


    function _claimWeek(
        address _liquidityProvider,
        uint256 _tranche,
        uint256 _balance,
        bytes32[] memory _merkleProof
    )
        private
    {
        require(_tranche < tranches, "Week cannot be in the future");

        require(!claimed[_tranche][_liquidityProvider], "LP has already claimed");
        require(_verifyClaim(_liquidityProvider, _tranche, _balance, _merkleProof), "Incorrect merkle proof");

        claimed[_tranche][_liquidityProvider] = true;

        emit Claimed(_liquidityProvider, _tranche, _balance);
    }


    function _verifyClaim(
        address _liquidityProvider,
        uint256 _tranche,
        uint256 _balance,
        bytes32[] memory _merkleProof
    )
        private
        view
        returns (bool valid)
    {
        bytes32 leaf = keccak256(abi.encodePacked(_liquidityProvider, _balance));
        return MerkleProof.verify(_merkleProof, merkleRoots[_tranche], leaf);
    }


    function _disburse(address _liquidityProvider, uint256 _balance) private {
        if (_balance > 0) {
            token.safeTransfer(_liquidityProvider, _balance);
        } else {
            revert("No balance would be transfered - not gonna waste your gas");
        }
    }
}