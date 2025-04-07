pragma solidity 0.4.25;

// File: contracts/sogur/interfaces/IModelDataSource.sol

/**
 * @title Model Data Source Interface.
 */


// File: contracts/sogur/interfaces/IMintingPointTimersManager.sol

/**
 * @title Minting Point Timers Manager Interface.
 */


// File: contracts/sogur/interfaces/ISGRAuthorizationManager.sol

/**
 * @title SGR Authorization Manager Interface.
 */


// File: contracts/sogur/interfaces/IMintListener.sol

/**
 * @title Mint Listener Interface.
 */


// File: contracts/saga-genesis/interfaces/IMintHandler.sol

/**
 * @title Mint Handler Interface.
 */


// File: contracts/saga-genesis/interfaces/IMintManager.sol

/**
 * @title Mint Manager Interface.
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

// File: contracts/sogur/MintManager.sol

/**
 * Details of usage of licenced software see here: https://www.sogur.com/software/readme_v1
 */

/**
 * @title Mint Manager.
 */
contract MintManager is IMintManager, ContractAddressLocatorHolder {
    string public constant VERSION = "2.0.0";

    uint256 public index;

    /**
     * @dev Create the contract.
     * @param _contractAddressLocator The contract address locator.
     */
    constructor(IContractAddressLocator _contractAddressLocator) ContractAddressLocatorHolder(_contractAddressLocator) public {}

    /**
     * @dev Return the contract which implements the IModelDataSource interface.
     */
    function getModelDataSource() public view returns (IModelDataSource) {
        return IModelDataSource(getContractAddress(_IModelDataSource_));
    }

    /**
     * @dev Return the contract which implements the IMintingPointTimersManager interface.
     */
    function getMintingPointTimersManager() public view returns (IMintingPointTimersManager) {
        return IMintingPointTimersManager(getContractAddress(_IMintingPointTimersManager_));
    }

    /**
     * @dev Return the contract which implements the ISGRAuthorizationManager interface.
     */
    function getSGRAuthorizationManager() public view returns (ISGRAuthorizationManager) {
        return ISGRAuthorizationManager(getContractAddress(_ISGRAuthorizationManager_));
    }

    /**
     * @dev Return the contract which implements the IMintHandler interface.
     */
    function getMintHandler() public view returns (IMintHandler) {
        return IMintHandler(getContractAddress(_IMintHandler_));
    }

    /**
     * @dev Return the contract which implements the IMintListener interface.
     */
    function getMintListener() public view returns (IMintListener) {
        return IMintListener(getContractAddress(_IMintListener_));
    }

    /**
     * @dev Return whether or not the minting-state should be updated.
     */
    function isMintingStateOutdated() public view returns (bool) {
        return getMintingPointTimersManager().expired(index + 1);
    }

    /**
     * @dev Update the minting-state if it is outdated.
     */
    function updateMintingState() external {
        require(getSGRAuthorizationManager().isAuthorizedForPublicOperation(msg.sender), "update minting state is not authorized");
        if (isMintingStateOutdated()) {
            uint256 amount = getModelDataSource().getRequiredMintAmount(index);
            getMintListener().mintSgrForSgnHolders(amount);
            getMintHandler().mintSgnVestedInDelay(index + 1);
            index += 1;
        }
    }

    /**
     * @dev Return the current minting-point index.
     */
    function getIndex() external view returns (uint256) {
        return index;
    }
}