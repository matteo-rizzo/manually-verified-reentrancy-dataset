pragma solidity 0.4.25;

// File: contracts/sogur/interfaces/IPaymentQueue.sol

/**
 * @title Payment Queue Interface.
 */


// File: contracts/sogur/interfaces/IPaymentManager.sol

/**
 * @title Payment Manager Interface.
 */


// File: contracts/sogur/interfaces/IPaymentHandler.sol

/**
 * @title Payment Handler Interface.
 */


// File: contracts/sogur/interfaces/IETHConverter.sol

/**
 * @title ETH Converter Interface.
 */


// File: contracts/sogur/interfaces/ISGRAuthorizationManager.sol

/**
 * @title SGR Authorization Manager Interface.
 */


// File: contracts/contract_address_locator/interfaces/IContractAddressLocator.sol

/**
 * @title Contract Address Locator Interface.
 */


// File: contracts/contract_address_locator/ContractAddressLocatorHolder.sol

/**
 * @title Contract Address Locator Holder.
 * @dev Hold a contract address locator, which maps a unique identifier to every contract address in the system.
 * @dev Any contract which inherits from this contract can retrieve the address of any contract in the system.
 * @dev Thus, any contract can remain "oblivious" to the replacement of any other contract in the system.
 * @dev In addition to that, any function in any contract can be restricted to a specific caller.
 */
contract ContractAddressLocatorHolder {
    bytes32 internal constant _IAuthorizationDataSource_ = "IAuthorizationDataSource";
    bytes32 internal constant _ISGNConversionManager_    = "ISGNConversionManager"      ;
    bytes32 internal constant _IModelDataSource_         = "IModelDataSource"        ;
    bytes32 internal constant _IPaymentHandler_          = "IPaymentHandler"            ;
    bytes32 internal constant _IPaymentManager_          = "IPaymentManager"            ;
    bytes32 internal constant _IPaymentQueue_            = "IPaymentQueue"              ;
    bytes32 internal constant _IReconciliationAdjuster_  = "IReconciliationAdjuster"      ;
    bytes32 internal constant _IIntervalIterator_        = "IIntervalIterator"       ;
    bytes32 internal constant _IMintHandler_             = "IMintHandler"            ;
    bytes32 internal constant _IMintListener_            = "IMintListener"           ;
    bytes32 internal constant _IMintManager_             = "IMintManager"            ;
    bytes32 internal constant _IPriceBandCalculator_     = "IPriceBandCalculator"       ;
    bytes32 internal constant _IModelCalculator_         = "IModelCalculator"        ;
    bytes32 internal constant _IRedButton_               = "IRedButton"              ;
    bytes32 internal constant _IReserveManager_          = "IReserveManager"         ;
    bytes32 internal constant _ISagaExchanger_           = "ISagaExchanger"          ;
    bytes32 internal constant _ISogurExchanger_           = "ISogurExchanger"          ;
    bytes32 internal constant _SgnToSgrExchangeInitiator_ = "SgnToSgrExchangeInitiator"          ;
    bytes32 internal constant _IMonetaryModel_               = "IMonetaryModel"              ;
    bytes32 internal constant _IMonetaryModelState_          = "IMonetaryModelState"         ;
    bytes32 internal constant _ISGRAuthorizationManager_ = "ISGRAuthorizationManager";
    bytes32 internal constant _ISGRToken_                = "ISGRToken"               ;
    bytes32 internal constant _ISGRTokenManager_         = "ISGRTokenManager"        ;
    bytes32 internal constant _ISGRTokenInfo_         = "ISGRTokenInfo"        ;
    bytes32 internal constant _ISGNAuthorizationManager_ = "ISGNAuthorizationManager";
    bytes32 internal constant _ISGNToken_                = "ISGNToken"               ;
    bytes32 internal constant _ISGNTokenManager_         = "ISGNTokenManager"        ;
    bytes32 internal constant _IMintingPointTimersManager_             = "IMintingPointTimersManager"            ;
    bytes32 internal constant _ITradingClasses_          = "ITradingClasses"         ;
    bytes32 internal constant _IWalletsTradingLimiterValueConverter_        = "IWalletsTLValueConverter"       ;
    bytes32 internal constant _BuyWalletsTradingDataSource_       = "BuyWalletsTradingDataSource"      ;
    bytes32 internal constant _SellWalletsTradingDataSource_       = "SellWalletsTradingDataSource"      ;
    bytes32 internal constant _WalletsTradingLimiter_SGNTokenManager_          = "WalletsTLSGNTokenManager"         ;
    bytes32 internal constant _BuyWalletsTradingLimiter_SGRTokenManager_          = "BuyWalletsTLSGRTokenManager"         ;
    bytes32 internal constant _SellWalletsTradingLimiter_SGRTokenManager_          = "SellWalletsTLSGRTokenManager"         ;
    bytes32 internal constant _IETHConverter_             = "IETHConverter"   ;
    bytes32 internal constant _ITransactionLimiter_      = "ITransactionLimiter"     ;
    bytes32 internal constant _ITransactionManager_      = "ITransactionManager"     ;
    bytes32 internal constant _IRateApprover_      = "IRateApprover"     ;
    bytes32 internal constant _SGAToSGRInitializer_      = "SGAToSGRInitializer"     ;

    IContractAddressLocator private contractAddressLocator;

    /**
     * @dev Create the contract.
     * @param _contractAddressLocator The contract address locator.
     */
    constructor(IContractAddressLocator _contractAddressLocator) internal {
        require(_contractAddressLocator != address(0), "locator is illegal");
        contractAddressLocator = _contractAddressLocator;
    }

    /**
     * @dev Get the contract address locator.
     * @return The contract address locator.
     */
    function getContractAddressLocator() external view returns (IContractAddressLocator) {
        return contractAddressLocator;
    }

    /**
     * @dev Get the contract address mapped to a given identifier.
     * @param _identifier The identifier.
     * @return The contract address.
     */
    function getContractAddress(bytes32 _identifier) internal view returns (address) {
        return contractAddressLocator.getContractAddress(_identifier);
    }



    /**
     * @dev Determine whether or not the sender relates to one of the identifiers.
     * @param _identifiers The identifiers.
     * @return A boolean indicating if the sender relates to one of the identifiers.
     */
    function isSenderAddressRelates(bytes32[] _identifiers) internal view returns (bool) {
        return contractAddressLocator.isContractAddressRelates(msg.sender, _identifiers);
    }

    /**
     * @dev Verify that the caller is mapped to a given identifier.
     * @param _identifier The identifier.
     */
    modifier only(bytes32 _identifier) {
        require(msg.sender == getContractAddress(_identifier), "caller is illegal");
        _;
    }

}

// File: openzeppelin-solidity-v1.12.0/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


// File: openzeppelin-solidity-v1.12.0/contracts/ownership/Claimable.sol

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

// File: openzeppelin-solidity/contracts/math/Math.sol

/**
 * @title Math
 * @dev Assorted math operations
 */


// File: contracts/sogur/PaymentManager.sol

/**
 * Details of usage of licenced software see here: https://www.sogur.com/software/readme_v1
 */

/**
 * @title Payment Manager.
 */
contract PaymentManager is IPaymentManager, ContractAddressLocatorHolder, Claimable {
    string public constant VERSION = "2.0.0";

    using Math for uint256;

    uint256 public maxNumOfPaymentsLimit = 30;

    event PaymentRegistered(address indexed _user, uint256 _input, uint256 _output);
    event PaymentSettled(address indexed _user, uint256 _input, uint256 _output);
    event PaymentPartialSettled(address indexed _user, uint256 _input, uint256 _output);

    /**
     * @dev Create the contract.
     * @param _contractAddressLocator The contract address locator.
     */
    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

    /**
     * @dev Return the contract which implements the ISGRAuthorizationManager interface.
     */
    function getSGRAuthorizationManager() public view returns (ISGRAuthorizationManager) {
        return ISGRAuthorizationManager(getContractAddress(_ISGRAuthorizationManager_));
    }

    /**
     * @dev Return the contract which implements the IETHConverter interface.
     */
    function getETHConverter() public view returns (IETHConverter) {
        return IETHConverter(getContractAddress(_IETHConverter_));
    }

    /**
     * @dev Return the contract which implements the IPaymentHandler interface.
     */
    function getPaymentHandler() public view returns (IPaymentHandler) {
        return IPaymentHandler(getContractAddress(_IPaymentHandler_));
    }

    /**
     * @dev Return the contract which implements the IPaymentQueue interface.
     */
    function getPaymentQueue() public view returns (IPaymentQueue) {
        return IPaymentQueue(getContractAddress(_IPaymentQueue_));
    }

    /**
    * @dev Set the max number of outstanding payments that can be settled in a single transaction.
    * @param _maxNumOfPaymentsLimit The maximum number of outstanding payments to settle in a single transaction.
    */
    function setMaxNumOfPaymentsLimit(uint256 _maxNumOfPaymentsLimit) external onlyOwner {
        require(_maxNumOfPaymentsLimit > 0, "invalid _maxNumOfPaymentsLimit");
        maxNumOfPaymentsLimit = _maxNumOfPaymentsLimit;
    }

    /**
     * @dev Retrieve the current number of outstanding payments.
     * @return The current number of outstanding payments.
     */
    function getNumOfPayments() external view returns (uint256) {
        return getPaymentQueue().getNumOfPayments();
    }

    /**
     * @dev Retrieve the sum of all outstanding payments.
     * @return The sum of all outstanding payments.
     */
    function getPaymentsSum() external view returns (uint256) {
        return getPaymentQueue().getPaymentsSum();
    }

    /**
     * @dev Compute differ payment.
     * @param _ethAmount The amount of ETH entitled by the client.
     * @param _ethBalance The amount of ETH retained by the payment handler.
     * @return The amount of differed ETH payment.
     */
    function computeDifferPayment(uint256 _ethAmount, uint256 _ethBalance) external view returns (uint256) {
        if (getPaymentQueue().getNumOfPayments() > 0)
            return _ethAmount;
        else if (_ethAmount > _ethBalance)
            return _ethAmount - _ethBalance; // will never underflow
        else
            return 0;
    }

    /**
     * @dev Register a differed payment.
     * @param _wallet The payment wallet address.
     * @param _ethAmount The payment amount in ETH.
     */
    function registerDifferPayment(address _wallet, uint256 _ethAmount) external only(_ISGRTokenManager_) {
        uint256 sdrAmount = getETHConverter().fromEthAmount(_ethAmount);
        getPaymentQueue().addPayment(_wallet, sdrAmount);
        emit PaymentRegistered(_wallet, _ethAmount, sdrAmount);
    }

    /**
     * @dev Settle payments by chronological order of registration.
     * @param _maxNumOfPayments The maximum number of payments to handle.
     */
    function settlePayments(uint256 _maxNumOfPayments) external {
        require(getSGRAuthorizationManager().isAuthorizedForPublicOperation(msg.sender), "settle payments is not authorized");
        IETHConverter ethConverter = getETHConverter();
        IPaymentHandler paymentHandler = getPaymentHandler();
        IPaymentQueue paymentQueue = getPaymentQueue();

        uint256 numOfPayments = paymentQueue.getNumOfPayments();
        numOfPayments =  numOfPayments.min(_maxNumOfPayments).min(maxNumOfPaymentsLimit);

        for (uint256 i = 0; i < numOfPayments; i++) {
            (address wallet, uint256 sdrAmount) = paymentQueue.getPayment(0);
            uint256 ethAmount = ethConverter.toEthAmount(sdrAmount);
            uint256 ethBalance = paymentHandler.getEthBalance();
            if (ethAmount > ethBalance) {
                paymentQueue.updatePayment(ethConverter.fromEthAmount(ethAmount - ethBalance)); // will never underflow
                paymentHandler.transferEthToSgrHolder(wallet, ethBalance);
                emit PaymentPartialSettled(wallet, sdrAmount, ethBalance);
                break;
            }
            paymentQueue.removePayment();
            paymentHandler.transferEthToSgrHolder(wallet, ethAmount);
            emit PaymentSettled(wallet, sdrAmount, ethAmount);
        }
    }
}