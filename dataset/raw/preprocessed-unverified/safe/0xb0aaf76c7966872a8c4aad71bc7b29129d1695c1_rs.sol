pragma solidity 0.4.25;

// File: contracts/sogur/interfaces/IPaymentQueue.sol

/**
 * @title Payment Queue Interface.
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

// File: openzeppelin-solidity/contracts/math/Math.sol

/**
 * @title Math
 * @dev Assorted math operations
 */


// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */


// File: contracts/sogur/PaymentQueue.sol

/**
 * Details of usage of licenced software see here: https://www.sogur.com/software/readme_v1
 */

/**
 * @title Payment Queue.
 */
contract PaymentQueue is IPaymentQueue, ContractAddressLocatorHolder {
    string public constant VERSION = "2.0.0";

    using SafeMath for uint256;

    struct Payment {
        address wallet;
        uint256 amount;
    }

    Payment[] public payments;
    uint256 public first;
    uint256 public last;

    uint256 public sum = 0;

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
     * @dev assert if called when the queue is empty.
     */
    modifier assertNonEmpty() {
        assert(last > 0);
        _;
    }

    /**
     * @dev Retrieve the current number of payments.
     * @return The current number of payments.
     */
    function getNumOfPayments() external view returns (uint256) {
        return last.sub(first);
    }

    /**
     * @dev Retrieve the sum of all payments.
     * @return The sum of all payments.
     */
    function getPaymentsSum() external view returns (uint256) {
        return sum;
    }

    /**
     * @dev Retrieve the details of a payment.
     * @param _index The index of the payment.
     * @return The payment's wallet address and amount.
     */
    function getPayment(uint256 _index) external view assertNonEmpty returns (address, uint256)  {
        require(last.sub(first) > _index, "index out of range");
        Payment memory payment = payments[first.add(_index)];
        return (payment.wallet, payment.amount);
    }

    /**
     * @dev Add a new payment.
     * @param _wallet The payment wallet address.
     * @param _amount The payment amount.
     */
    function addPayment(address _wallet, uint256 _amount) external only(_IPaymentManager_) {
        assert(_wallet != address(0) && _amount > 0);
        Payment memory newPayment = Payment({wallet : _wallet, amount : _amount});
        if (payments.length > last)
            payments[last] = newPayment;
        else
            payments.push(newPayment);
        sum = sum.add(_amount);
        last = last.add(1);
    }

    /**
     * @dev Update the first payment.
     * @param _amount The new payment amount.
     */
    function updatePayment(uint256 _amount) external only(_IPaymentManager_) assertNonEmpty {
        assert(_amount > 0);
        sum = (sum.add(_amount)).sub(payments[first].amount);
        payments[first].amount = _amount;

    }

    /**
     * @dev Remove the first payment.
     */
    function removePayment() external only(_IPaymentManager_) assertNonEmpty {
        sum = sum.sub(payments[first].amount);
        payments[first] = Payment({wallet : address(0), amount : 0});
        uint256 newFirstPosition = first.add(1);
        if (newFirstPosition == last)
            first = last = 0;
        else
            first = newFirstPosition;
    }

    /**
     * @dev Clean the queue.
     * @param _maxCleanLength The maximum payments to clean.
     */
    function clean(uint256 _maxCleanLength) external {
        require(getSGRAuthorizationManager().isAuthorizedForPublicOperation(msg.sender), "clean queue is not authorized");
        uint256 paymentsQueueLength = payments.length;
        if (paymentsQueueLength > last) {
            uint256 totalPaymentsToClean = paymentsQueueLength.sub(last);
            payments.length = (totalPaymentsToClean < _maxCleanLength) ? last : paymentsQueueLength.sub(_maxCleanLength);
        }
        
    }
}