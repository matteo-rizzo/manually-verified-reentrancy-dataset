/**
 *Submitted for verification at Etherscan.io on 2020-10-20
*/

pragma solidity 0.5.16;










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






contract InitializableReentrancyGuard {
    bool private _notEntered;

    function _initialize() internal {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
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
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

contract InitializableAbstractIntegration is
    Initializable,
    IPlatformIntegration,
    InitializableGovernableWhitelist,
    InitializableReentrancyGuard
{

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event PTokenAdded(address indexed _bAsset, address _pToken);

    event Deposit(address indexed _bAsset, address _pToken, uint256 _amount);
    event Withdrawal(address indexed _bAsset, address _pToken, uint256 _amount);

    // Core address for the given platform */
    address public platformAddress;

    // bAsset => pToken (Platform Specific Token Address)
    mapping(address => address) public bAssetToPToken;
    // Full list of all bAssets supported here
    address[] internal bAssetsMapped;

    /**
     * @dev Initialization function for upgradable proxy contract.
     *      This function should be called via Proxy just after contract deployment.
     * @param _nexus            Address of the Nexus
     * @param _whitelisted      Whitelisted addresses for vault access
     * @param _platformAddress  Generic platform address
     * @param _bAssets          Addresses of initial supported bAssets
     * @param _pTokens          Platform Token corresponding addresses
     */
    function initialize(
        address _nexus,
        address[] calldata _whitelisted,
        address _platformAddress,
        address[] calldata _bAssets,
        address[] calldata _pTokens
    )
        external
        initializer
    {
        InitializableReentrancyGuard._initialize();
        InitializableGovernableWhitelist._initialize(_nexus, _whitelisted);
        InitializableAbstractIntegration._initialize(_platformAddress, _bAssets, _pTokens);
    }

    /**
     * @dev Internal initialize function, to set up initial internal state
     * @param _platformAddress  Generic platform address
     * @param _bAssets          Addresses of initial supported bAssets
     * @param _pTokens          Platform Token corresponding addresses
     */
    function _initialize(
        address _platformAddress,
        address[] memory _bAssets,
        address[] memory _pTokens
    )
        internal
    {
        platformAddress = _platformAddress;

        uint256 bAssetCount = _bAssets.length;
        require(bAssetCount == _pTokens.length, "Invalid input arrays");
        for(uint256 i = 0; i < bAssetCount; i++){
            _setPTokenAddress(_bAssets[i], _pTokens[i]);
        }
    }

    /***************************************
                    CONFIG
    ****************************************/

    /**
     * @dev Provide support for bAsset by passing its pToken address.
     * This method can only be called by the system Governor
     * @param _bAsset   Address for the bAsset
     * @param _pToken   Address for the corresponding platform token
     */
    function setPTokenAddress(address _bAsset, address _pToken)
        external
        onlyGovernor
    {
        _setPTokenAddress(_bAsset, _pToken);
    }

    /**
     * @dev Provide support for bAsset by passing its pToken address.
     * Add to internal mappings and execute the platform specific,
     * abstract method `_abstractSetPToken`
     * @param _bAsset   Address for the bAsset
     * @param _pToken   Address for the corresponding platform token
     */
    function _setPTokenAddress(address _bAsset, address _pToken)
        internal
    {
        require(bAssetToPToken[_bAsset] == address(0), "pToken already set");
        require(_bAsset != address(0) && _pToken != address(0), "Invalid addresses");

        bAssetToPToken[_bAsset] = _pToken;
        bAssetsMapped.push(_bAsset);

        emit PTokenAdded(_bAsset, _pToken);

        _abstractSetPToken(_bAsset, _pToken);
    }

    function _abstractSetPToken(address _bAsset, address _pToken) internal;

    function reApproveAllTokens() external;

    /***************************************
                    ABSTRACT
    ****************************************/

    /**
     * @dev Deposit a quantity of bAsset into the platform
     * @param _bAsset              Address for the bAsset
     * @param _amount              Units of bAsset to deposit
     * @param _isTokenFeeCharged   Flag that signals if an xfer fee is charged on bAsset
     * @return quantityDeposited   Quantity of bAsset that entered the platform
     */
    function deposit(address _bAsset, uint256 _amount, bool _isTokenFeeCharged)
        external returns (uint256 quantityDeposited);

    /**
     * @dev Withdraw a quantity of bAsset from the platform
     * @param _receiver          Address to which the bAsset should be sent
     * @param _bAsset            Address of the bAsset
     * @param _amount            Units of bAsset to withdraw
     * @param _isTokenFeeCharged Flag that signals if an xfer fee is charged on bAsset
     */
    function withdraw(address _receiver, address _bAsset, uint256 _amount, bool _isTokenFeeCharged) external;

    /**
     * @dev Get the total bAsset value held in the platform
     * This includes any interest that was generated since depositing
     * @param _bAsset     Address of the bAsset
     * @return balance    Total value of the bAsset in the platform
     */
    function checkBalance(address _bAsset) external returns (uint256 balance);

    /***************************************
                    HELPERS
    ****************************************/

    /**
     * @dev Simple helper func to get the min of two values
     */
    function _min(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        return x > y ? y : x;
    }
}

/**
 * @title   CompoundIntegration
 * @author  Stability Labs Pty. Ltd.
 * @notice  A simple connection to deposit and withdraw bAssets from Compound
 * @dev     VERSION: 1.2
 *          DATE:    2020-10-19
 */
contract CompoundIntegration is InitializableAbstractIntegration {

    event SkippedWithdrawal(address bAsset, uint256 amount);
    event RewardTokenApproved(address rewardToken, address account);

    /***************************************
                    ADMIN
    ****************************************/

    /**
     * @dev Approves Liquidator to spend reward tokens
     */
    function approveRewardToken()
        external
        onlyGovernor
    {
        address liquidator = nexus.getModule(keccak256("Liquidator"));
        require(liquidator != address(0), "Liquidator address cannot be zero");

        // Official checksummed COMP token address
        // https://ethplorer.io/address/0xc00e94cb662c3520282e6f5717214004a7f26888
        address compToken = address(0xc00e94Cb662C3520282E6f5717214004A7f26888);

        MassetHelpers.safeInfiniteApprove(compToken, liquidator);

        emit RewardTokenApproved(address(compToken), liquidator);
    }

    /***************************************
                    CORE
    ****************************************/

    /**
     * @dev Deposit a quantity of bAsset into the platform. Credited cTokens
     *      remain here in the vault. Can only be called by whitelisted addresses
     *      (mAsset and corresponding BasketManager)
     * @param _bAsset              Address for the bAsset
     * @param _amount              Units of bAsset to deposit
     * @param _isTokenFeeCharged   Flag that signals if an xfer fee is charged on bAsset
     * @return quantityDeposited   Quantity of bAsset that entered the platform
     */
    function deposit(
        address _bAsset,
        uint256 _amount,
        bool _isTokenFeeCharged
    )
        external
        onlyWhitelisted
        nonReentrant
        returns (uint256 quantityDeposited)
    {
        require(_amount > 0, "Must deposit something");

        // Get the Target token
        ICERC20 cToken = _getCTokenFor(_bAsset);

        // We should have been sent this amount, if not, the deposit will fail
        quantityDeposited = _amount;

        if(_isTokenFeeCharged) {
            // If we charge a fee, account for it
            uint256 prevBal = _checkBalance(cToken);
            require(cToken.mint(_amount) == 0, "cToken mint failed");
            uint256 newBal = _checkBalance(cToken);
            quantityDeposited = _min(quantityDeposited, newBal.sub(prevBal));
        } else {
            // Else just execute the mint
            require(cToken.mint(_amount) == 0, "cToken mint failed");
        }

        emit Deposit(_bAsset, address(cToken), quantityDeposited);
    }

    /**
     * @dev Withdraw a quantity of bAsset from Compound. Redemption
     *      should fail if we have insufficient cToken balance.
     * @param _receiver     Address to which the withdrawn bAsset should be sent
     * @param _bAsset       Address of the bAsset
     * @param _amount       Units of bAsset to withdraw
     */
    function withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        bool _isTokenFeeCharged
    )
        external
        onlyWhitelisted
        nonReentrant
    {
        require(_amount > 0, "Must withdraw something");
        require(_receiver != address(0), "Must specify recipient");

        // Get the Target token
        ICERC20 cToken = _getCTokenFor(_bAsset);

        // If redeeming 0 cTokens, just skip, else COMP will revert
        // Reason for skipping: to ensure that redeemMasset is always able to execute
        uint256 cTokensToRedeem = _convertUnderlyingToCToken(cToken, _amount);
        if(cTokensToRedeem == 0) {
            emit SkippedWithdrawal(_bAsset, _amount);
            return;
        }

        uint256 quantityWithdrawn = _amount;

        if(_isTokenFeeCharged) {
            IERC20 b = IERC20(_bAsset);
            uint256 prevBal = b.balanceOf(address(this));
            require(cToken.redeemUnderlying(_amount) == 0, "redeem failed");
            uint256 newBal = b.balanceOf(address(this));
            quantityWithdrawn = _min(quantityWithdrawn, newBal.sub(prevBal));
        } else {
            // Redeem Underlying bAsset amount
            require(cToken.redeemUnderlying(_amount) == 0, "redeem failed");
        }

        // Send redeemed bAsset to the receiver
        IERC20(_bAsset).safeTransfer(_receiver, quantityWithdrawn);

        emit Withdrawal(_bAsset, address(cToken), quantityWithdrawn);
    }

    /**
     * @dev Get the total bAsset value held in the platform
     *      This includes any interest that was generated since depositing
     *      Compound exchange rate between the cToken and bAsset gradually increases,
     *      causing the cToken to be worth more corresponding bAsset.
     * @param _bAsset     Address of the bAsset
     * @return balance    Total value of the bAsset in the platform
     */
    function checkBalance(address _bAsset)
        external
        returns (uint256 balance)
    {
        // balance is always with token cToken decimals
        ICERC20 cToken = _getCTokenFor(_bAsset);
        balance = _checkBalance(cToken);
    }

    /***************************************
                    APPROVALS
    ****************************************/

    /**
     * @dev Re-approve the spending of all bAssets by their corresponding cToken,
     *      if for some reason is it necessary. Only callable through Governance.
     */
    function reApproveAllTokens()
        external
        onlyGovernor
    {
        uint256 bAssetCount = bAssetsMapped.length;
        for(uint i = 0; i < bAssetCount; i++){
            address bAsset = bAssetsMapped[i];
            address cToken = bAssetToPToken[bAsset];
            MassetHelpers.safeInfiniteApprove(bAsset, cToken);
        }
    }

    /**
     * @dev Internal method to respond to the addition of new bAsset / cTokens
     *      We need to approve the cToken and give it permission to spend the bAsset
     * @param _bAsset Address of the bAsset to approve
     * @param _cToken This cToken has the approval approval
     */
    function _abstractSetPToken(address _bAsset, address _cToken)
        internal
    {
        // approve the pool to spend the bAsset
        MassetHelpers.safeInfiniteApprove(_bAsset, _cToken);
    }

    /***************************************
                    HELPERS
    ****************************************/

    /**
     * @dev Get the cToken wrapped in the ICERC20 interface for this bAsset.
     *      Fails if the pToken doesn't exist in our mappings.
     * @param _bAsset   Address of the bAsset
     * @return          Corresponding cToken to this bAsset
     */
    function _getCTokenFor(address _bAsset)
        internal
        view
        returns (ICERC20)
    {
        address cToken = bAssetToPToken[_bAsset];
        require(cToken != address(0), "cToken does not exist");
        return ICERC20(cToken);
    }

    /**
     * @dev Get the total bAsset value held in the platform
     *          underlying = (cTokenAmt * exchangeRate) / 1e18
     * @param _cToken     cToken for which to check balance
     * @return balance    Total value of the bAsset in the platform
     */
    function _checkBalance(ICERC20 _cToken)
        internal
        view
        returns (uint256 balance)
    {
        uint256 cTokenBalance = _cToken.balanceOf(address(this));
        uint256 exchangeRate = _cToken.exchangeRateStored();
        // e.g. 50e8*205316390724364402565641705 / 1e18 = 1.0265..e18
        balance = cTokenBalance.mul(exchangeRate).div(1e18);
    }

    /**
     * @dev Converts an underlying amount into cToken amount
     *          cTokenAmt = (underlying * 1e18) / exchangeRate
     * @param _cToken     cToken for which to change
     * @param _underlying Amount of underlying to convert
     * @return amount     Equivalent amount of cTokens
     */
    function _convertUnderlyingToCToken(ICERC20 _cToken, uint256 _underlying)
        internal
        view
        returns (uint256 amount)
    {
        uint256 exchangeRate = _cToken.exchangeRateStored();
        // e.g. 1e18*1e18 / 205316390724364402565641705 = 50e8
        // e.g. 1e8*1e18 / 205316390724364402565641705 = 0.45 or 0
        amount = _underlying.mul(1e18).div(exchangeRate);
    }
}