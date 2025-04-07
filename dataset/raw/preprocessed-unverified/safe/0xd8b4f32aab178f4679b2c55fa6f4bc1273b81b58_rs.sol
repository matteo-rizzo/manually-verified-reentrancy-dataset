/**

 *Submitted for verification at Etherscan.io on 2019-04-23

*/



pragma solidity ^0.4.25;

pragma experimental ABIEncoderV2;







contract Beneficiary {

    /// @notice Receive ethers to the given wallet's given balance type

    /// @param wallet The address of the concerned wallet

    /// @param balanceType The target balance type of the wallet

    function receiveEthersTo(address wallet, string balanceType)

    public

    payable;



    /// @notice Receive token to the given wallet's given balance type

    /// @dev The wallet must approve of the token transfer prior to calling this function

    /// @param wallet The address of the concerned wallet

    /// @param balanceType The target balance type of the wallet

    /// @param amount The amount to deposit

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")

    function receiveTokensTo(address wallet, string balanceType, int256 amount, address currencyCt,

        uint256 currencyId, string standard)

    public;

}



contract AccrualBeneficiary is Beneficiary {

    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    event CloseAccrualPeriodEvent();



    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    function closeAccrualPeriod(MonetaryTypesLib.Currency[])

    public

    {

        emit CloseAccrualPeriodEvent();

    }

}



















contract Modifiable {

    //

    // Modifiers

    // -----------------------------------------------------------------------------------------------------------------

    modifier notNullAddress(address _address) {

        require(_address != address(0));

        _;

    }



    modifier notThisAddress(address _address) {

        require(_address != address(this));

        _;

    }



    modifier notNullOrThisAddress(address _address) {

        require(_address != address(0));

        require(_address != address(this));

        _;

    }



    modifier notSameAddresses(address _address1, address _address2) {

        if (_address1 != _address2)

            _;

    }

}



















contract SelfDestructible {

    //

    // Variables

    // -----------------------------------------------------------------------------------------------------------------

    bool public selfDestructionDisabled;



    //

    // Events

    // -----------------------------------------------------------------------------------------------------------------

    event SelfDestructionDisabledEvent(address wallet);

    event TriggerSelfDestructionEvent(address wallet);



    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    /// @notice Get the address of the destructor role

    function destructor()

    public

    view

    returns (address);



    /// @notice Disable self-destruction of this contract

    /// @dev This operation can not be undone

    function disableSelfDestruction()

    public

    {

        // Require that sender is the assigned destructor

        require(destructor() == msg.sender);



        // Disable self-destruction

        selfDestructionDisabled = true;



        // Emit event

        emit SelfDestructionDisabledEvent(msg.sender);

    }



    /// @notice Destroy this contract

    function triggerSelfDestruction()

    public

    {

        // Require that sender is the assigned destructor

        require(destructor() == msg.sender);



        // Require that self-destruction has not been disabled

        require(!selfDestructionDisabled);



        // Emit event

        emit TriggerSelfDestructionEvent(msg.sender);



        // Self-destruct and reward destructor

        selfdestruct(msg.sender);

    }

}



contract Ownable is Modifiable, SelfDestructible {

    //

    // Variables

    // -----------------------------------------------------------------------------------------------------------------

    address public deployer;

    address public operator;



    //

    // Events

    // -----------------------------------------------------------------------------------------------------------------

    event SetDeployerEvent(address oldDeployer, address newDeployer);

    event SetOperatorEvent(address oldOperator, address newOperator);



    //

    // Constructor

    // -----------------------------------------------------------------------------------------------------------------

    constructor(address _deployer) internal notNullOrThisAddress(_deployer) {

        deployer = _deployer;

        operator = _deployer;

    }



    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    /// @notice Return the address that is able to initiate self-destruction

    function destructor()

    public

    view

    returns (address)

    {

        return deployer;

    }



    /// @notice Set the deployer of this contract

    /// @param newDeployer The address of the new deployer

    function setDeployer(address newDeployer)

    public

    onlyDeployer

    notNullOrThisAddress(newDeployer)

    {

        if (newDeployer != deployer) {

            // Set new deployer

            address oldDeployer = deployer;

            deployer = newDeployer;



            // Emit event

            emit SetDeployerEvent(oldDeployer, newDeployer);

        }

    }



    /// @notice Set the operator of this contract

    /// @param newOperator The address of the new operator

    function setOperator(address newOperator)

    public

    onlyOperator

    notNullOrThisAddress(newOperator)

    {

        if (newOperator != operator) {

            // Set new operator

            address oldOperator = operator;

            operator = newOperator;



            // Emit event

            emit SetOperatorEvent(oldOperator, newOperator);

        }

    }



    /// @notice Gauge whether message sender is deployer or not

    /// @return true if msg.sender is deployer, else false

    function isDeployer()

    internal

    view

    returns (bool)

    {

        return msg.sender == deployer;

    }



    /// @notice Gauge whether message sender is operator or not

    /// @return true if msg.sender is operator, else false

    function isOperator()

    internal

    view

    returns (bool)

    {

        return msg.sender == operator;

    }



    /// @notice Gauge whether message sender is operator or deployer on the one hand, or none of these on these on

    /// on the other hand

    /// @return true if msg.sender is operator, else false

    function isDeployerOrOperator()

    internal

    view

    returns (bool)

    {

        return isDeployer() || isOperator();

    }



    // Modifiers

    // -----------------------------------------------------------------------------------------------------------------

    modifier onlyDeployer() {

        require(isDeployer());

        _;

    }



    modifier notDeployer() {

        require(!isDeployer());

        _;

    }



    modifier onlyOperator() {

        require(isOperator());

        _;

    }



    modifier notOperator() {

        require(!isOperator());

        _;

    }



    modifier onlyDeployerOrOperator() {

        require(isDeployerOrOperator());

        _;

    }



    modifier notDeployerOrOperator() {

        require(!isDeployerOrOperator());

        _;

    }

}



contract Benefactor is Ownable {

    //

    // Variables

    // -----------------------------------------------------------------------------------------------------------------

    address[] internal beneficiaries;

    mapping(address => uint256) internal beneficiaryIndexByAddress;



    //

    // Events

    // -----------------------------------------------------------------------------------------------------------------

    event RegisterBeneficiaryEvent(address beneficiary);

    event DeregisterBeneficiaryEvent(address beneficiary);



    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    /// @notice Register the given beneficiary

    /// @param beneficiary Address of beneficiary to be registered

    function registerBeneficiary(address beneficiary)

    public

    onlyDeployer

    notNullAddress(beneficiary)

    returns (bool)

    {

        if (beneficiaryIndexByAddress[beneficiary] > 0)

            return false;



        beneficiaries.push(beneficiary);

        beneficiaryIndexByAddress[beneficiary] = beneficiaries.length;



        // Emit event

        emit RegisterBeneficiaryEvent(beneficiary);



        return true;

    }



    /// @notice Deregister the given beneficiary

    /// @param beneficiary Address of beneficiary to be deregistered

    function deregisterBeneficiary(address beneficiary)

    public

    onlyDeployer

    notNullAddress(beneficiary)

    returns (bool)

    {

        if (beneficiaryIndexByAddress[beneficiary] == 0)

            return false;



        uint256 idx = beneficiaryIndexByAddress[beneficiary] - 1;

        if (idx < beneficiaries.length - 1) {

            // Remap the last item in the array to this index

            beneficiaries[idx] = beneficiaries[beneficiaries.length - 1];

            beneficiaryIndexByAddress[beneficiaries[idx]] = idx + 1;

        }

        beneficiaries.length--;

        beneficiaryIndexByAddress[beneficiary] = 0;



        // Emit event

        emit DeregisterBeneficiaryEvent(beneficiary);



        return true;

    }



    /// @notice Gauge whether the given address is the one of a registered beneficiary

    /// @param beneficiary Address of beneficiary

    /// @return true if beneficiary is registered, else false

    function isRegisteredBeneficiary(address beneficiary)

    public

    view

    returns (bool)

    {

        return beneficiaryIndexByAddress[beneficiary] > 0;

    }



    /// @notice Get the count of registered beneficiaries

    /// @return The count of registered beneficiaries

    function registeredBeneficiariesCount()

    public

    view

    returns (uint256)

    {

        return beneficiaries.length;

    }

}



contract AccrualBenefactor is Benefactor {

    using SafeMathIntLib for int256;



    //

    // Variables

    // -----------------------------------------------------------------------------------------------------------------

    mapping(address => int256) private _beneficiaryFractionMap;

    int256 public totalBeneficiaryFraction;



    //

    // Events

    // -----------------------------------------------------------------------------------------------------------------

    event RegisterAccrualBeneficiaryEvent(address beneficiary, int256 fraction);

    event DeregisterAccrualBeneficiaryEvent(address beneficiary);



    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    /// @notice Register the given beneficiary for the entirety fraction

    /// @param beneficiary Address of beneficiary to be registered

    function registerBeneficiary(address beneficiary)

    public

    onlyDeployer

    notNullAddress(beneficiary)

    returns (bool)

    {

        return registerFractionalBeneficiary(beneficiary, ConstantsLib.PARTS_PER());

    }



    /// @notice Register the given beneficiary for the given fraction

    /// @param beneficiary Address of beneficiary to be registered

    /// @param fraction Fraction of benefits to be given

    function registerFractionalBeneficiary(address beneficiary, int256 fraction)

    public

    onlyDeployer

    notNullAddress(beneficiary)

    returns (bool)

    {

        require(fraction > 0);

        require(totalBeneficiaryFraction.add(fraction) <= ConstantsLib.PARTS_PER());



        if (!super.registerBeneficiary(beneficiary))

            return false;



        _beneficiaryFractionMap[beneficiary] = fraction;

        totalBeneficiaryFraction = totalBeneficiaryFraction.add(fraction);



        // Emit event

        emit RegisterAccrualBeneficiaryEvent(beneficiary, fraction);



        return true;

    }



    /// @notice Deregister the given beneficiary

    /// @param beneficiary Address of beneficiary to be deregistered

    function deregisterBeneficiary(address beneficiary)

    public

    onlyDeployer

    notNullAddress(beneficiary)

    returns (bool)

    {

        if (!super.deregisterBeneficiary(beneficiary))

            return false;



        totalBeneficiaryFraction = totalBeneficiaryFraction.sub(_beneficiaryFractionMap[beneficiary]);

        _beneficiaryFractionMap[beneficiary] = 0;



        // Emit event

        emit DeregisterAccrualBeneficiaryEvent(beneficiary);



        return true;

    }



    /// @notice Get the fraction of benefits that is granted the given beneficiary

    /// @param beneficiary Address of beneficiary

    /// @return The beneficiary's fraction

    function beneficiaryFraction(address beneficiary)

    public

    view

    returns (int256)

    {

        return _beneficiaryFractionMap[beneficiary];

    }

}



contract CommunityVotable is Ownable {

    //

    // Variables

    // -----------------------------------------------------------------------------------------------------------------

    CommunityVote public communityVote;

    bool public communityVoteFrozen;



    //

    // Events

    // -----------------------------------------------------------------------------------------------------------------

    event SetCommunityVoteEvent(CommunityVote oldCommunityVote, CommunityVote newCommunityVote);

    event FreezeCommunityVoteEvent();



    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    /// @notice Set the community vote contract

    /// @param newCommunityVote The (address of) CommunityVote contract instance

    function setCommunityVote(CommunityVote newCommunityVote) 

    public 

    onlyDeployer

    notNullAddress(newCommunityVote)

    notSameAddresses(newCommunityVote, communityVote)

    {

        require(!communityVoteFrozen);



        // Set new community vote

        CommunityVote oldCommunityVote = communityVote;

        communityVote = newCommunityVote;



        // Emit event

        emit SetCommunityVoteEvent(oldCommunityVote, newCommunityVote);

    }



    /// @notice Freeze the community vote from further updates

    /// @dev This operation can not be undone

    function freezeCommunityVote()

    public

    onlyDeployer

    {

        communityVoteFrozen = true;



        // Emit event

        emit FreezeCommunityVoteEvent();

    }



    //

    // Modifiers

    // -----------------------------------------------------------------------------------------------------------------

    modifier communityVoteInitialized() {

        require(communityVote != address(0));

        _;

    }

}



contract CommunityVote is Ownable {

    //

    // Variables

    // -----------------------------------------------------------------------------------------------------------------

    mapping(address => bool) doubleSpenderByWallet;

    uint256 maxDriipNonce;

    uint256 maxNullNonce;

    bool dataAvailable;



    //

    // Constructor

    // -----------------------------------------------------------------------------------------------------------------

    constructor(address deployer) Ownable(deployer) public {

        dataAvailable = true;

    }



    //

    // Results functions

    // -----------------------------------------------------------------------------------------------------------------

    /// @notice Get the double spender status of given wallet

    /// @param wallet The wallet address for which to check double spender status

    /// @return true if wallet is double spender, false otherwise

    function isDoubleSpenderWallet(address wallet)

    public

    view

    returns (bool)

    {

        return doubleSpenderByWallet[wallet];

    }



    /// @notice Get the max driip nonce to be accepted in settlements

    /// @return the max driip nonce

    function getMaxDriipNonce()

    public

    view

    returns (uint256)

    {

        return maxDriipNonce;

    }



    /// @notice Get the max null settlement nonce to be accepted in settlements

    /// @return the max driip nonce

    function getMaxNullNonce()

    public

    view

    returns (uint256)

    {

        return maxNullNonce;

    }



    /// @notice Get the data availability status

    /// @return true if data is available

    function isDataAvailable()

    public

    view

    returns (bool)

    {

        return dataAvailable;

    }

}



contract Servable is Ownable {

    //

    // Types

    // -----------------------------------------------------------------------------------------------------------------

    struct ServiceInfo {

        bool registered;

        uint256 activationTimestamp;

        mapping(bytes32 => bool) actionsEnabledMap;

        bytes32[] actionsList;

    }



    //

    // Variables

    // -----------------------------------------------------------------------------------------------------------------

    mapping(address => ServiceInfo) internal registeredServicesMap;

    uint256 public serviceActivationTimeout;



    //

    // Events

    // -----------------------------------------------------------------------------------------------------------------

    event ServiceActivationTimeoutEvent(uint256 timeoutInSeconds);

    event RegisterServiceEvent(address service);

    event RegisterServiceDeferredEvent(address service, uint256 timeout);

    event DeregisterServiceEvent(address service);

    event EnableServiceActionEvent(address service, string action);

    event DisableServiceActionEvent(address service, string action);



    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    /// @notice Set the service activation timeout

    /// @param timeoutInSeconds The set timeout in unit of seconds

    function setServiceActivationTimeout(uint256 timeoutInSeconds)

    public

    onlyDeployer

    {

        serviceActivationTimeout = timeoutInSeconds;



        // Emit event

        emit ServiceActivationTimeoutEvent(timeoutInSeconds);

    }



    /// @notice Register a service contract whose activation is immediate

    /// @param service The address of the service contract to be registered

    function registerService(address service)

    public

    onlyDeployer

    notNullOrThisAddress(service)

    {

        _registerService(service, 0);



        // Emit event

        emit RegisterServiceEvent(service);

    }



    /// @notice Register a service contract whose activation is deferred by the service activation timeout

    /// @param service The address of the service contract to be registered

    function registerServiceDeferred(address service)

    public

    onlyDeployer

    notNullOrThisAddress(service)

    {

        _registerService(service, serviceActivationTimeout);



        // Emit event

        emit RegisterServiceDeferredEvent(service, serviceActivationTimeout);

    }



    /// @notice Deregister a service contract

    /// @param service The address of the service contract to be deregistered

    function deregisterService(address service)

    public

    onlyDeployer

    notNullOrThisAddress(service)

    {

        require(registeredServicesMap[service].registered);



        registeredServicesMap[service].registered = false;



        // Emit event

        emit DeregisterServiceEvent(service);

    }



    /// @notice Enable a named action in an already registered service contract

    /// @param service The address of the registered service contract

    /// @param action The name of the action to be enabled

    function enableServiceAction(address service, string action)

    public

    onlyDeployer

    notNullOrThisAddress(service)

    {

        require(registeredServicesMap[service].registered);



        bytes32 actionHash = hashString(action);



        require(!registeredServicesMap[service].actionsEnabledMap[actionHash]);



        registeredServicesMap[service].actionsEnabledMap[actionHash] = true;

        registeredServicesMap[service].actionsList.push(actionHash);



        // Emit event

        emit EnableServiceActionEvent(service, action);

    }



    /// @notice Enable a named action in a service contract

    /// @param service The address of the service contract

    /// @param action The name of the action to be disabled

    function disableServiceAction(address service, string action)

    public

    onlyDeployer

    notNullOrThisAddress(service)

    {

        bytes32 actionHash = hashString(action);



        require(registeredServicesMap[service].actionsEnabledMap[actionHash]);



        registeredServicesMap[service].actionsEnabledMap[actionHash] = false;



        // Emit event

        emit DisableServiceActionEvent(service, action);

    }



    /// @notice Gauge whether a service contract is registered

    /// @param service The address of the service contract

    /// @return true if service is registered, else false

    function isRegisteredService(address service)

    public

    view

    returns (bool)

    {

        return registeredServicesMap[service].registered;

    }



    /// @notice Gauge whether a service contract is registered and active

    /// @param service The address of the service contract

    /// @return true if service is registered and activate, else false

    function isRegisteredActiveService(address service)

    public

    view

    returns (bool)

    {

        return isRegisteredService(service) && block.timestamp >= registeredServicesMap[service].activationTimestamp;

    }



    /// @notice Gauge whether a service contract action is enabled which implies also registered and active

    /// @param service The address of the service contract

    /// @param action The name of action

    function isEnabledServiceAction(address service, string action)

    public

    view

    returns (bool)

    {

        bytes32 actionHash = hashString(action);

        return isRegisteredActiveService(service) && registeredServicesMap[service].actionsEnabledMap[actionHash];

    }



    //

    // Internal functions

    // -----------------------------------------------------------------------------------------------------------------

    function hashString(string _string)

    internal

    pure

    returns (bytes32)

    {

        return keccak256(abi.encodePacked(_string));

    }



    //

    // Private functions

    // -----------------------------------------------------------------------------------------------------------------

    function _registerService(address service, uint256 timeout)

    private

    {

        if (!registeredServicesMap[service].registered) {

            registeredServicesMap[service].registered = true;

            registeredServicesMap[service].activationTimestamp = block.timestamp + timeout;

        }

    }



    //

    // Modifiers

    // -----------------------------------------------------------------------------------------------------------------

    modifier onlyActiveService() {

        require(isRegisteredActiveService(msg.sender));

        _;

    }



    modifier onlyEnabledServiceAction(string action) {

        require(isEnabledServiceAction(msg.sender, action));

        _;

    }

}



contract DriipSettlementState is Ownable, Servable, CommunityVotable {

    using SafeMathIntLib for int256;

    using SafeMathUintLib for uint256;



    //

    // Constants

    // -----------------------------------------------------------------------------------------------------------------

    string constant public INIT_SETTLEMENT_ACTION = "init_settlement";

    string constant public SET_SETTLEMENT_ROLE_DONE_ACTION = "set_settlement_role_done";

    string constant public SET_MAX_NONCE_ACTION = "set_max_nonce";

    string constant public SET_MAX_DRIIP_NONCE_ACTION = "set_max_driip_nonce";

    string constant public SET_FEE_TOTAL_ACTION = "set_fee_total";



    //

    // Variables

    // -----------------------------------------------------------------------------------------------------------------

    uint256 public maxDriipNonce;



    DriipSettlementTypesLib.Settlement[] public settlements;

    mapping(address => uint256[]) public walletSettlementIndices;

    mapping(address => mapping(uint256 => uint256)) public walletNonceSettlementIndex;

    mapping(address => mapping(address => mapping(uint256 => uint256))) public walletCurrencyMaxNonce;



    mapping(address => mapping(address => mapping(address => mapping(address => mapping(uint256 => MonetaryTypesLib.NoncedAmount))))) public totalFeesMap;



    //

    // Events

    // -----------------------------------------------------------------------------------------------------------------

    event InitSettlementEvent(DriipSettlementTypesLib.Settlement settlement);

    event SetSettlementRoleDoneEvent(address wallet, uint256 nonce,

        DriipSettlementTypesLib.SettlementRole settlementRole, bool done);

    event SetMaxNonceByWalletAndCurrencyEvent(address wallet, MonetaryTypesLib.Currency currency,

        uint256 maxNonce);

    event SetMaxDriipNonceEvent(uint256 maxDriipNonce);

    event UpdateMaxDriipNonceFromCommunityVoteEvent(uint256 maxDriipNonce);

    event SetTotalFeeEvent(address wallet, Beneficiary beneficiary, address destination,

        MonetaryTypesLib.Currency currency, MonetaryTypesLib.NoncedAmount totalFee);



    //

    // Constructor

    // -----------------------------------------------------------------------------------------------------------------

    constructor(address deployer) Ownable(deployer) public {

    }



    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    /// @notice Get the count of settlements

    function settlementsCount()

    public

    view

    returns (uint256)

    {

        return settlements.length;

    }



    /// @notice Get the count of settlements for given wallet

    /// @param wallet The address for which to return settlement count

    /// @return count of settlements for the provided wallet

    function settlementsCountByWallet(address wallet)

    public

    view

    returns (uint256)

    {

        return walletSettlementIndices[wallet].length;

    }



    /// @notice Get settlement of given wallet and index

    /// @param wallet The address for which to return settlement

    /// @param index The wallet's settlement index

    /// @return settlement for the provided wallet and index

    function settlementByWalletAndIndex(address wallet, uint256 index)

    public

    view

    returns (DriipSettlementTypesLib.Settlement)

    {

        require(walletSettlementIndices[wallet].length > index);

        return settlements[walletSettlementIndices[wallet][index] - 1];

    }



    /// @notice Get settlement of given wallet and wallet nonce

    /// @param wallet The address for which to return settlement

    /// @param nonce The wallet's nonce

    /// @return settlement for the provided wallet and index

    function settlementByWalletAndNonce(address wallet, uint256 nonce)

    public

    view

    returns (DriipSettlementTypesLib.Settlement)

    {

        require(0 < walletNonceSettlementIndex[wallet][nonce]);

        return settlements[walletNonceSettlementIndex[wallet][nonce] - 1];

    }



    /// @notice Initialize settlement, i.e. create one if no such settlement exists

    /// for the double pair of wallets and nonces

    /// @param settledKind The kind of driip of the settlement

    /// @param settledHash The hash of driip of the settlement

    /// @param originWallet The address of the origin wallet

    /// @param originNonce The wallet nonce of the origin wallet

    /// @param targetWallet The address of the target wallet

    /// @param targetNonce The wallet nonce of the target wallet

    function initSettlement(string settledKind, bytes32 settledHash, address originWallet,

        uint256 originNonce, address targetWallet, uint256 targetNonce)

    public

    onlyEnabledServiceAction(INIT_SETTLEMENT_ACTION)

    {

        if (

            0 == walletNonceSettlementIndex[originWallet][originNonce] &&

            0 == walletNonceSettlementIndex[targetWallet][targetNonce]

        ) {

            // Create new settlement

            settlements.length++;



            // Get the 0-based index

            uint256 index = settlements.length - 1;



            // Update settlement

            settlements[index].settledKind = settledKind;

            settlements[index].settledHash = settledHash;

            settlements[index].origin.nonce = originNonce;

            settlements[index].origin.wallet = originWallet;

            settlements[index].target.nonce = targetNonce;

            settlements[index].target.wallet = targetWallet;



            // Emit event

            emit InitSettlementEvent(settlements[index]);



            // Store 1-based index value

            index++;

            walletSettlementIndices[originWallet].push(index);

            walletSettlementIndices[targetWallet].push(index);

            walletNonceSettlementIndex[originWallet][originNonce] = index;

            walletNonceSettlementIndex[targetWallet][targetNonce] = index;

        }

    }



    /// @notice Gauge whether the settlement is done wrt the given settlement role

    /// @param wallet The address of the concerned wallet

    /// @param nonce The nonce of the concerned wallet

    /// @param settlementRole The settlement role

    /// @return True if settlement is done for role, else false

    function isSettlementRoleDone(address wallet, uint256 nonce,

        DriipSettlementTypesLib.SettlementRole settlementRole)

    public

    view

    returns (bool)

    {

        // Get the 1-based index of the settlement

        uint256 index = walletNonceSettlementIndex[wallet][nonce];



        // Return false if settlement does not exist

        if (0 == index)

            return false;



        // Return done of settlement role

        if (DriipSettlementTypesLib.SettlementRole.Origin == settlementRole)

            return settlements[index - 1].origin.done;

        else // DriipSettlementTypesLib.SettlementRole.Target == settlementRole

            return settlements[index - 1].target.done;

    }



    /// @notice Set the done of the given settlement role in the given settlement

    /// @param wallet The address of the concerned wallet

    /// @param nonce The nonce of the concerned wallet

    /// @param settlementRole The settlement role

    /// @param done The done flag

    function setSettlementRoleDone(address wallet, uint256 nonce,

        DriipSettlementTypesLib.SettlementRole settlementRole, bool done)

    public

    onlyEnabledServiceAction(SET_SETTLEMENT_ROLE_DONE_ACTION)

    {

        // Get the 1-based index of the settlement

        uint256 index = walletNonceSettlementIndex[wallet][nonce];



        // Require the existence of settlement

        require(0 != index);



        // Update the settlement role done value

        if (DriipSettlementTypesLib.SettlementRole.Origin == settlementRole)

            settlements[index - 1].origin.done = done;

        else // DriipSettlementTypesLib.SettlementRole.Target == settlementRole

            settlements[index - 1].target.done = done;



        // Emit event

        emit SetSettlementRoleDoneEvent(wallet, nonce, settlementRole, done);

    }



    /// @notice Set the max (driip) nonce

    /// @param _maxDriipNonce The max nonce

    function setMaxDriipNonce(uint256 _maxDriipNonce)

    public

    onlyEnabledServiceAction(SET_MAX_DRIIP_NONCE_ACTION)

    {

        maxDriipNonce = _maxDriipNonce;



        // Emit event

        emit SetMaxDriipNonceEvent(maxDriipNonce);

    }



    /// @notice Update the max driip nonce property from CommunityVote contract

    function updateMaxDriipNonceFromCommunityVote()

    public

    {

        uint256 _maxDriipNonce = communityVote.getMaxDriipNonce();

        if (0 == _maxDriipNonce)

            return;



        maxDriipNonce = _maxDriipNonce;



        // Emit event

        emit UpdateMaxDriipNonceFromCommunityVoteEvent(maxDriipNonce);

    }



    /// @notice Get the max nonce of the given wallet and currency

    /// @param wallet The address of the concerned wallet

    /// @param currency The concerned currency

    /// @return The max nonce

    function maxNonceByWalletAndCurrency(address wallet, MonetaryTypesLib.Currency currency)

    public

    view

    returns (uint256)

    {

        return walletCurrencyMaxNonce[wallet][currency.ct][currency.id];

    }



    /// @notice Set the max nonce of the given wallet and currency

    /// @param wallet The address of the concerned wallet

    /// @param currency The concerned currency

    /// @param maxNonce The max nonce

    function setMaxNonceByWalletAndCurrency(address wallet, MonetaryTypesLib.Currency currency,

        uint256 maxNonce)

    public

    onlyEnabledServiceAction(SET_MAX_NONCE_ACTION)

    {

        // Update max nonce value

        walletCurrencyMaxNonce[wallet][currency.ct][currency.id] = maxNonce;



        // Emit event

        emit SetMaxNonceByWalletAndCurrencyEvent(wallet, currency, maxNonce);

    }



    /// @notice Get the total fee payed by the given wallet to the given beneficiary and destination

    /// in the given currency

    /// @param wallet The address of the concerned wallet

    /// @param beneficiary The concerned beneficiary

    /// @param destination The concerned destination

    /// @param currency The concerned currency

    /// @return The total fee

    function totalFee(address wallet, Beneficiary beneficiary, address destination,

        MonetaryTypesLib.Currency currency)

    public

    view

    returns (MonetaryTypesLib.NoncedAmount)

    {

        return totalFeesMap[wallet][address(beneficiary)][destination][currency.ct][currency.id];

    }



    /// @notice Set the total fee payed by the given wallet to the given beneficiary and destination

    /// in the given currency

    /// @param wallet The address of the concerned wallet

    /// @param beneficiary The concerned beneficiary

    /// @param destination The concerned destination

    /// @param _totalFee The total fee

    function setTotalFee(address wallet, Beneficiary beneficiary, address destination,

        MonetaryTypesLib.Currency currency, MonetaryTypesLib.NoncedAmount _totalFee)

    public

    onlyEnabledServiceAction(SET_FEE_TOTAL_ACTION)

    {

        // Update total fees value

        totalFeesMap[wallet][address(beneficiary)][destination][currency.ct][currency.id] = _totalFee;



        // Emit event

        emit SetTotalFeeEvent(wallet, beneficiary, destination, currency, _totalFee);

    }

}



contract TransferController {

    //

    // Events

    // -----------------------------------------------------------------------------------------------------------------

    event CurrencyTransferred(address from, address to, uint256 value,

        address currencyCt, uint256 currencyId);



    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    function isFungible()

    public

    view

    returns (bool);



    /// @notice MUST be called with DELEGATECALL

    function receive(address from, address to, uint256 value, address currencyCt, uint256 currencyId)

    public;



    /// @notice MUST be called with DELEGATECALL

    function approve(address to, uint256 value, address currencyCt, uint256 currencyId)

    public;



    /// @notice MUST be called with DELEGATECALL

    function dispatch(address from, address to, uint256 value, address currencyCt, uint256 currencyId)

    public;



    //----------------------------------------



    function getReceiveSignature()

    public

    pure

    returns (bytes4)

    {

        return bytes4(keccak256("receive(address,address,uint256,address,uint256)"));

    }



    function getApproveSignature()

    public

    pure

    returns (bytes4)

    {

        return bytes4(keccak256("approve(address,uint256,address,uint256)"));

    }



    function getDispatchSignature()

    public

    pure

    returns (bytes4)

    {

        return bytes4(keccak256("dispatch(address,address,uint256,address,uint256)"));

    }

}



contract TransferControllerManageable is Ownable {

    //

    // Variables

    // -----------------------------------------------------------------------------------------------------------------

    TransferControllerManager public transferControllerManager;



    //

    // Events

    // -----------------------------------------------------------------------------------------------------------------

    event SetTransferControllerManagerEvent(TransferControllerManager oldTransferControllerManager,

        TransferControllerManager newTransferControllerManager);



    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    /// @notice Set the currency manager contract

    /// @param newTransferControllerManager The (address of) TransferControllerManager contract instance

    function setTransferControllerManager(TransferControllerManager newTransferControllerManager)

    public

    onlyDeployer

    notNullAddress(newTransferControllerManager)

    notSameAddresses(newTransferControllerManager, transferControllerManager)

    {

        //set new currency manager

        TransferControllerManager oldTransferControllerManager = transferControllerManager;

        transferControllerManager = newTransferControllerManager;



        // Emit event

        emit SetTransferControllerManagerEvent(oldTransferControllerManager, newTransferControllerManager);

    }



    /// @notice Get the transfer controller of the given currency contract address and standard

    function transferController(address currencyCt, string standard)

    internal

    view

    returns (TransferController)

    {

        return transferControllerManager.transferController(currencyCt, standard);

    }



    //

    // Modifiers

    // -----------------------------------------------------------------------------------------------------------------

    modifier transferControllerManagerInitialized() {

        require(transferControllerManager != address(0));

        _;

    }

}



contract PartnerFund is Ownable, Beneficiary, TransferControllerManageable {

    using FungibleBalanceLib for FungibleBalanceLib.Balance;

    using TxHistoryLib for TxHistoryLib.TxHistory;

    using SafeMathIntLib for int256;

    using Strings for string;



    //

    // Structures

    // -----------------------------------------------------------------------------------------------------------------

    struct Partner {

        bytes32 nameHash;



        uint256 fee;

        address wallet;

        uint256 index;



        bool operatorCanUpdate;

        bool partnerCanUpdate;



        FungibleBalanceLib.Balance active;

        FungibleBalanceLib.Balance staged;



        TxHistoryLib.TxHistory txHistory;

        FullBalanceHistory[] fullBalanceHistory;

    }



    struct FullBalanceHistory {

        uint256 listIndex;

        int256 balance;

        uint256 blockNumber;

    }



    //

    // Variables

    // -----------------------------------------------------------------------------------------------------------------

    Partner[] private partners;



    mapping(bytes32 => uint256) private _indexByNameHash;

    mapping(address => uint256) private _indexByWallet;



    //

    // Events

    // -----------------------------------------------------------------------------------------------------------------

    event ReceiveEvent(address from, int256 amount, address currencyCt, uint256 currencyId);

    event RegisterPartnerByNameEvent(string name, uint256 fee, address wallet);

    event RegisterPartnerByNameHashEvent(bytes32 nameHash, uint256 fee, address wallet);

    event SetFeeByIndexEvent(uint256 index, uint256 oldFee, uint256 newFee);

    event SetFeeByNameEvent(string name, uint256 oldFee, uint256 newFee);

    event SetFeeByNameHashEvent(bytes32 nameHash, uint256 oldFee, uint256 newFee);

    event SetFeeByWalletEvent(address wallet, uint256 oldFee, uint256 newFee);

    event SetPartnerWalletByIndexEvent(uint256 index, address oldWallet, address newWallet);

    event SetPartnerWalletByNameEvent(string name, address oldWallet, address newWallet);

    event SetPartnerWalletByNameHashEvent(bytes32 nameHash, address oldWallet, address newWallet);

    event SetPartnerWalletByWalletEvent(address oldWallet, address newWallet);

    event StageEvent(address from, int256 amount, address currencyCt, uint256 currencyId);

    event WithdrawEvent(address to, int256 amount, address currencyCt, uint256 currencyId);



    //

    // Constructor

    // -----------------------------------------------------------------------------------------------------------------

    constructor(address deployer) Ownable(deployer) public {

    }



    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    /// @notice Fallback function that deposits ethers

    function() public payable {

        _receiveEthersTo(

            indexByWallet(msg.sender) - 1, SafeMathIntLib.toNonZeroInt256(msg.value)

        );

    }



    /// @notice Receive ethers to

    /// @param tag The tag of the concerned partner

    function receiveEthersTo(address tag, string)

    public

    payable

    {

        _receiveEthersTo(

            uint256(tag) - 1, SafeMathIntLib.toNonZeroInt256(msg.value)

        );

    }



    /// @notice Receive tokens

    /// @param amount The concerned amount

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// @param standard The standard of token ("ERC20", "ERC721")

    function receiveTokens(string, int256 amount, address currencyCt,

        uint256 currencyId, string standard)

    public

    {

        _receiveTokensTo(

            indexByWallet(msg.sender) - 1, amount, currencyCt, currencyId, standard

        );

    }



    /// @notice Receive tokens to

    /// @param tag The tag of the concerned partner

    /// @param amount The concerned amount

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// @param standard The standard of token ("ERC20", "ERC721")

    function receiveTokensTo(address tag, string, int256 amount, address currencyCt,

        uint256 currencyId, string standard)

    public

    {

        _receiveTokensTo(

            uint256(tag) - 1, amount, currencyCt, currencyId, standard

        );

    }



    /// @notice Hash name

    /// @param name The name to be hashed

    /// @return The hash value

    function hashName(string name)

    public

    pure

    returns (bytes32)

    {

        return keccak256(abi.encodePacked(name.upper()));

    }



    /// @notice Get deposit by partner and deposit indices

    /// @param partnerIndex The index of the concerned partner

    /// @param depositIndex The index of the concerned deposit

    /// return The deposit parameters

    function depositByIndices(uint256 partnerIndex, uint256 depositIndex)

    public

    view

    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)

    {

        // Require partner index is one of registered partner

        require(0 < partnerIndex && partnerIndex <= partners.length);



        return _depositByIndices(partnerIndex - 1, depositIndex);

    }



    /// @notice Get deposit by partner name and deposit indices

    /// @param name The name of the concerned partner

    /// @param depositIndex The index of the concerned deposit

    /// return The deposit parameters

    function depositByName(string name, uint depositIndex)

    public

    view

    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)

    {

        // Implicitly require that partner name is registered

        return _depositByIndices(indexByName(name) - 1, depositIndex);

    }



    /// @notice Get deposit by partner name hash and deposit indices

    /// @param nameHash The hashed name of the concerned partner

    /// @param depositIndex The index of the concerned deposit

    /// return The deposit parameters

    function depositByNameHash(bytes32 nameHash, uint depositIndex)

    public

    view

    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)

    {

        // Implicitly require that partner name hash is registered

        return _depositByIndices(indexByNameHash(nameHash) - 1, depositIndex);

    }



    /// @notice Get deposit by partner wallet and deposit indices

    /// @param wallet The wallet of the concerned partner

    /// @param depositIndex The index of the concerned deposit

    /// return The deposit parameters

    function depositByWallet(address wallet, uint depositIndex)

    public

    view

    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)

    {

        // Implicitly require that partner wallet is registered

        return _depositByIndices(indexByWallet(wallet) - 1, depositIndex);

    }



    /// @notice Get deposits count by partner index

    /// @param index The index of the concerned partner

    /// return The deposits count

    function depositsCountByIndex(uint256 index)

    public

    view

    returns (uint256)

    {

        // Require partner index is one of registered partner

        require(0 < index && index <= partners.length);



        return _depositsCountByIndex(index - 1);

    }



    /// @notice Get deposits count by partner name

    /// @param name The name of the concerned partner

    /// return The deposits count

    function depositsCountByName(string name)

    public

    view

    returns (uint256)

    {

        // Implicitly require that partner name is registered

        return _depositsCountByIndex(indexByName(name) - 1);

    }



    /// @notice Get deposits count by partner name hash

    /// @param nameHash The hashed name of the concerned partner

    /// return The deposits count

    function depositsCountByNameHash(bytes32 nameHash)

    public

    view

    returns (uint256)

    {

        // Implicitly require that partner name hash is registered

        return _depositsCountByIndex(indexByNameHash(nameHash) - 1);

    }



    /// @notice Get deposits count by partner wallet

    /// @param wallet The wallet of the concerned partner

    /// return The deposits count

    function depositsCountByWallet(address wallet)

    public

    view

    returns (uint256)

    {

        // Implicitly require that partner wallet is registered

        return _depositsCountByIndex(indexByWallet(wallet) - 1);

    }



    /// @notice Get active balance by partner index and currency

    /// @param index The index of the concerned partner

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// return The active balance

    function activeBalanceByIndex(uint256 index, address currencyCt, uint256 currencyId)

    public

    view

    returns (int256)

    {

        // Require partner index is one of registered partner

        require(0 < index && index <= partners.length);



        return _activeBalanceByIndex(index - 1, currencyCt, currencyId);

    }



    /// @notice Get active balance by partner name and currency

    /// @param name The name of the concerned partner

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// return The active balance

    function activeBalanceByName(string name, address currencyCt, uint256 currencyId)

    public

    view

    returns (int256)

    {

        // Implicitly require that partner name is registered

        return _activeBalanceByIndex(indexByName(name) - 1, currencyCt, currencyId);

    }



    /// @notice Get active balance by partner name hash and currency

    /// @param nameHash The hashed name of the concerned partner

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// return The active balance

    function activeBalanceByNameHash(bytes32 nameHash, address currencyCt, uint256 currencyId)

    public

    view

    returns (int256)

    {

        // Implicitly require that partner name hash is registered

        return _activeBalanceByIndex(indexByNameHash(nameHash) - 1, currencyCt, currencyId);

    }



    /// @notice Get active balance by partner wallet and currency

    /// @param wallet The wallet of the concerned partner

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// return The active balance

    function activeBalanceByWallet(address wallet, address currencyCt, uint256 currencyId)

    public

    view

    returns (int256)

    {

        // Implicitly require that partner wallet is registered

        return _activeBalanceByIndex(indexByWallet(wallet) - 1, currencyCt, currencyId);

    }



    /// @notice Get staged balance by partner index and currency

    /// @param index The index of the concerned partner

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// return The staged balance

    function stagedBalanceByIndex(uint256 index, address currencyCt, uint256 currencyId)

    public

    view

    returns (int256)

    {

        // Require partner index is one of registered partner

        require(0 < index && index <= partners.length);



        return _stagedBalanceByIndex(index - 1, currencyCt, currencyId);

    }



    /// @notice Get staged balance by partner name and currency

    /// @param name The name of the concerned partner

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// return The staged balance

    function stagedBalanceByName(string name, address currencyCt, uint256 currencyId)

    public

    view

    returns (int256)

    {

        // Implicitly require that partner name is registered

        return _stagedBalanceByIndex(indexByName(name) - 1, currencyCt, currencyId);

    }



    /// @notice Get staged balance by partner name hash and currency

    /// @param nameHash The hashed name of the concerned partner

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// return The staged balance

    function stagedBalanceByNameHash(bytes32 nameHash, address currencyCt, uint256 currencyId)

    public

    view

    returns (int256)

    {

        // Implicitly require that partner name is registered

        return _stagedBalanceByIndex(indexByNameHash(nameHash) - 1, currencyCt, currencyId);

    }



    /// @notice Get staged balance by partner wallet and currency

    /// @param wallet The wallet of the concerned partner

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// return The staged balance

    function stagedBalanceByWallet(address wallet, address currencyCt, uint256 currencyId)

    public

    view

    returns (int256)

    {

        // Implicitly require that partner wallet is registered

        return _stagedBalanceByIndex(indexByWallet(wallet) - 1, currencyCt, currencyId);

    }



    /// @notice Get the number of partners

    /// @return The number of partners

    function partnersCount()

    public

    view

    returns (uint256)

    {

        return partners.length;

    }



    /// @notice Register a partner by name

    /// @param name The name of the concerned partner

    /// @param fee The partner's fee fraction

    /// @param wallet The partner's wallet

    /// @param partnerCanUpdate Indicator of whether partner can update fee and wallet

    /// @param operatorCanUpdate Indicator of whether operator can update fee and wallet

    function registerByName(string name, uint256 fee, address wallet,

        bool partnerCanUpdate, bool operatorCanUpdate)

    public

    onlyOperator

    {

        // Require not empty name string

        require(bytes(name).length > 0);



        // Hash name

        bytes32 nameHash = hashName(name);



        // Register partner

        _registerPartnerByNameHash(nameHash, fee, wallet, partnerCanUpdate, operatorCanUpdate);



        // Emit event

        emit RegisterPartnerByNameEvent(name, fee, wallet);

    }



    /// @notice Register a partner by name hash

    /// @param nameHash The hashed name of the concerned partner

    /// @param fee The partner's fee fraction

    /// @param wallet The partner's wallet

    /// @param partnerCanUpdate Indicator of whether partner can update fee and wallet

    /// @param operatorCanUpdate Indicator of whether operator can update fee and wallet

    function registerByNameHash(bytes32 nameHash, uint256 fee, address wallet,

        bool partnerCanUpdate, bool operatorCanUpdate)

    public

    onlyOperator

    {

        // Register partner

        _registerPartnerByNameHash(nameHash, fee, wallet, partnerCanUpdate, operatorCanUpdate);



        // Emit event

        emit RegisterPartnerByNameHashEvent(nameHash, fee, wallet);

    }



    /// @notice Gets the 1-based index of partner by its name

    /// @dev Reverts if name does not correspond to registered partner

    /// @return Index of partner by given name

    function indexByNameHash(bytes32 nameHash)

    public

    view

    returns (uint256)

    {

        uint256 index = _indexByNameHash[nameHash];

        require(0 < index);

        return index;

    }



    /// @notice Gets the 1-based index of partner by its name

    /// @dev Reverts if name does not correspond to registered partner

    /// @return Index of partner by given name

    function indexByName(string name)

    public

    view

    returns (uint256)

    {

        return indexByNameHash(hashName(name));

    }



    /// @notice Gets the 1-based index of partner by its wallet

    /// @dev Reverts if wallet does not correspond to registered partner

    /// @return Index of partner by given wallet

    function indexByWallet(address wallet)

    public

    view

    returns (uint256)

    {

        uint256 index = _indexByWallet[wallet];

        require(0 < index);

        return index;

    }



    /// @notice Gauge whether a partner by the given name is registered

    /// @param name The name of the concerned partner

    /// @return true if partner is registered, else false

    function isRegisteredByName(string name)

    public

    view

    returns (bool)

    {

        return (0 < _indexByNameHash[hashName(name)]);

    }



    /// @notice Gauge whether a partner by the given name hash is registered

    /// @param nameHash The hashed name of the concerned partner

    /// @return true if partner is registered, else false

    function isRegisteredByNameHash(bytes32 nameHash)

    public

    view

    returns (bool)

    {

        return (0 < _indexByNameHash[nameHash]);

    }



    /// @notice Gauge whether a partner by the given wallet is registered

    /// @param wallet The wallet of the concerned partner

    /// @return true if partner is registered, else false

    function isRegisteredByWallet(address wallet)

    public

    view

    returns (bool)

    {

        return (0 < _indexByWallet[wallet]);

    }



    /// @notice Get the partner fee fraction by the given partner index

    /// @param index The index of the concerned partner

    /// @return The fee fraction

    function feeByIndex(uint256 index)

    public

    view

    returns (uint256)

    {

        // Require partner index is one of registered partner

        require(0 < index && index <= partners.length);



        return _partnerFeeByIndex(index - 1);

    }



    /// @notice Get the partner fee fraction by the given partner name

    /// @param name The name of the concerned partner

    /// @return The fee fraction

    function feeByName(string name)

    public

    view

    returns (uint256)

    {

        // Get fee, implicitly requiring that partner name is registered

        return _partnerFeeByIndex(indexByName(name) - 1);

    }



    /// @notice Get the partner fee fraction by the given partner name hash

    /// @param nameHash The hashed name of the concerned partner

    /// @return The fee fraction

    function feeByNameHash(bytes32 nameHash)

    public

    view

    returns (uint256)

    {

        // Get fee, implicitly requiring that partner name hash is registered

        return _partnerFeeByIndex(indexByNameHash(nameHash) - 1);

    }



    /// @notice Get the partner fee fraction by the given partner wallet

    /// @param wallet The wallet of the concerned partner

    /// @return The fee fraction

    function feeByWallet(address wallet)

    public

    view

    returns (uint256)

    {

        // Get fee, implicitly requiring that partner wallet is registered

        return _partnerFeeByIndex(indexByWallet(wallet) - 1);

    }



    /// @notice Set the partner fee fraction by the given partner index

    /// @param index The index of the concerned partner

    /// @param newFee The partner's fee fraction

    function setFeeByIndex(uint256 index, uint256 newFee)

    public

    {

        // Require partner index is one of registered partner

        require(0 < index && index <= partners.length);



        // Update fee

        uint256 oldFee = _setPartnerFeeByIndex(index - 1, newFee);



        // Emit event

        emit SetFeeByIndexEvent(index, oldFee, newFee);

    }



    /// @notice Set the partner fee fraction by the given partner name

    /// @param name The name of the concerned partner

    /// @param newFee The partner's fee fraction

    function setFeeByName(string name, uint256 newFee)

    public

    {

        // Update fee, implicitly requiring that partner name is registered

        uint256 oldFee = _setPartnerFeeByIndex(indexByName(name) - 1, newFee);



        // Emit event

        emit SetFeeByNameEvent(name, oldFee, newFee);

    }



    /// @notice Set the partner fee fraction by the given partner name hash

    /// @param nameHash The hashed name of the concerned partner

    /// @param newFee The partner's fee fraction

    function setFeeByNameHash(bytes32 nameHash, uint256 newFee)

    public

    {

        // Update fee, implicitly requiring that partner name hash is registered

        uint256 oldFee = _setPartnerFeeByIndex(indexByNameHash(nameHash) - 1, newFee);



        // Emit event

        emit SetFeeByNameHashEvent(nameHash, oldFee, newFee);

    }



    /// @notice Set the partner fee fraction by the given partner wallet

    /// @param wallet The wallet of the concerned partner

    /// @param newFee The partner's fee fraction

    function setFeeByWallet(address wallet, uint256 newFee)

    public

    {

        // Update fee, implicitly requiring that partner wallet is registered

        uint256 oldFee = _setPartnerFeeByIndex(indexByWallet(wallet) - 1, newFee);



        // Emit event

        emit SetFeeByWalletEvent(wallet, oldFee, newFee);

    }



    /// @notice Get the partner wallet by the given partner index

    /// @param index The index of the concerned partner

    /// @return The wallet

    function walletByIndex(uint256 index)

    public

    view

    returns (address)

    {

        // Require partner index is one of registered partner

        require(0 < index && index <= partners.length);



        return partners[index - 1].wallet;

    }



    /// @notice Get the partner wallet by the given partner name

    /// @param name The name of the concerned partner

    /// @return The wallet

    function walletByName(string name)

    public

    view

    returns (address)

    {

        // Get wallet, implicitly requiring that partner name is registered

        return partners[indexByName(name) - 1].wallet;

    }



    /// @notice Get the partner wallet by the given partner name hash

    /// @param nameHash The hashed name of the concerned partner

    /// @return The wallet

    function walletByNameHash(bytes32 nameHash)

    public

    view

    returns (address)

    {

        // Get wallet, implicitly requiring that partner name hash is registered

        return partners[indexByNameHash(nameHash) - 1].wallet;

    }



    /// @notice Set the partner wallet by the given partner index

    /// @param index The index of the concerned partner

    /// @return newWallet The partner's wallet

    function setWalletByIndex(uint256 index, address newWallet)

    public

    {

        // Require partner index is one of registered partner

        require(0 < index && index <= partners.length);



        // Update wallet

        address oldWallet = _setPartnerWalletByIndex(index - 1, newWallet);



        // Emit event

        emit SetPartnerWalletByIndexEvent(index, oldWallet, newWallet);

    }



    /// @notice Set the partner wallet by the given partner name

    /// @param name The name of the concerned partner

    /// @return newWallet The partner's wallet

    function setWalletByName(string name, address newWallet)

    public

    {

        // Update wallet

        address oldWallet = _setPartnerWalletByIndex(indexByName(name) - 1, newWallet);



        // Emit event

        emit SetPartnerWalletByNameEvent(name, oldWallet, newWallet);

    }



    /// @notice Set the partner wallet by the given partner name hash

    /// @param nameHash The hashed name of the concerned partner

    /// @return newWallet The partner's wallet

    function setWalletByNameHash(bytes32 nameHash, address newWallet)

    public

    {

        // Update wallet

        address oldWallet = _setPartnerWalletByIndex(indexByNameHash(nameHash) - 1, newWallet);



        // Emit event

        emit SetPartnerWalletByNameHashEvent(nameHash, oldWallet, newWallet);

    }



    /// @notice Set the new partner wallet by the given old partner wallet

    /// @param oldWallet The old wallet of the concerned partner

    /// @return newWallet The partner's new wallet

    function setWalletByWallet(address oldWallet, address newWallet)

    public

    {

        // Update wallet

        _setPartnerWalletByIndex(indexByWallet(oldWallet) - 1, newWallet);



        // Emit event

        emit SetPartnerWalletByWalletEvent(oldWallet, newWallet);

    }



    /// @notice Stage the amount for subsequent withdrawal

    /// @param amount The concerned amount to stage

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    function stage(int256 amount, address currencyCt, uint256 currencyId)

    public

    {

        // Get index, implicitly requiring that msg.sender is wallet of registered partner

        uint256 index = indexByWallet(msg.sender);



        // Require positive amount

        require(amount.isPositiveInt256());



        // Clamp amount to move

        amount = amount.clampMax(partners[index - 1].active.get(currencyCt, currencyId));



        partners[index - 1].active.sub(amount, currencyCt, currencyId);

        partners[index - 1].staged.add(amount, currencyCt, currencyId);



        partners[index - 1].txHistory.addDeposit(amount, currencyCt, currencyId);



        // Add to full deposit history

        partners[index - 1].fullBalanceHistory.push(

            FullBalanceHistory(

                partners[index - 1].txHistory.depositsCount() - 1,

                partners[index - 1].active.get(currencyCt, currencyId),

                block.number

            )

        );



        // Emit event

        emit StageEvent(msg.sender, amount, currencyCt, currencyId);

    }



    /// @notice Withdraw the given amount from staged balance

    /// @param amount The concerned amount to withdraw

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// @param standard The standard of the token ("" for default registered, "ERC20", "ERC721")

    function withdraw(int256 amount, address currencyCt, uint256 currencyId, string standard)

    public

    {

        // Get index, implicitly requiring that msg.sender is wallet of registered partner

        uint256 index = indexByWallet(msg.sender);



        // Require positive amount

        require(amount.isPositiveInt256());



        // Clamp amount to move

        amount = amount.clampMax(partners[index - 1].staged.get(currencyCt, currencyId));



        partners[index - 1].staged.sub(amount, currencyCt, currencyId);



        // Execute transfer

        if (address(0) == currencyCt && 0 == currencyId)

            msg.sender.transfer(uint256(amount));



        else {

            TransferController controller = transferController(currencyCt, standard);

            require(

                address(controller).delegatecall(

                    controller.getDispatchSignature(), this, msg.sender, uint256(amount), currencyCt, currencyId

                )

            );

        }



        // Emit event

        emit WithdrawEvent(msg.sender, amount, currencyCt, currencyId);

    }



    //

    // Private functions

    // -----------------------------------------------------------------------------------------------------------------

    /// @dev index is 0-based

    function _receiveEthersTo(uint256 index, int256 amount)

    private

    {

        // Require that index is within bounds

        require(index < partners.length);



        // Add to active

        partners[index].active.add(amount, address(0), 0);

        partners[index].txHistory.addDeposit(amount, address(0), 0);



        // Add to full deposit history

        partners[index].fullBalanceHistory.push(

            FullBalanceHistory(

                partners[index].txHistory.depositsCount() - 1,

                partners[index].active.get(address(0), 0),

                block.number

            )

        );



        // Emit event

        emit ReceiveEvent(msg.sender, amount, address(0), 0);

    }



    /// @dev index is 0-based

    function _receiveTokensTo(uint256 index, int256 amount, address currencyCt,

        uint256 currencyId, string standard)

    private

    {

        // Require that index is within bounds

        require(index < partners.length);



        require(amount.isNonZeroPositiveInt256());



        // Execute transfer

        TransferController controller = transferController(currencyCt, standard);

        require(

            address(controller).delegatecall(

                controller.getReceiveSignature(), msg.sender, this, uint256(amount), currencyCt, currencyId

            )

        );



        // Add to active

        partners[index].active.add(amount, currencyCt, currencyId);

        partners[index].txHistory.addDeposit(amount, currencyCt, currencyId);



        // Add to full deposit history

        partners[index].fullBalanceHistory.push(

            FullBalanceHistory(

                partners[index].txHistory.depositsCount() - 1,

                partners[index].active.get(currencyCt, currencyId),

                block.number

            )

        );



        // Emit event

        emit ReceiveEvent(msg.sender, amount, currencyCt, currencyId);

    }



    /// @dev partnerIndex is 0-based

    function _depositByIndices(uint256 partnerIndex, uint256 depositIndex)

    private

    view

    returns (int256 balance, uint256 blockNumber, address currencyCt, uint256 currencyId)

    {

        require(depositIndex < partners[partnerIndex].fullBalanceHistory.length);



        FullBalanceHistory storage entry = partners[partnerIndex].fullBalanceHistory[depositIndex];

        (,, currencyCt, currencyId) = partners[partnerIndex].txHistory.deposit(entry.listIndex);



        balance = entry.balance;

        blockNumber = entry.blockNumber;

    }



    /// @dev index is 0-based

    function _depositsCountByIndex(uint256 index)

    private

    view

    returns (uint256)

    {

        return partners[index].fullBalanceHistory.length;

    }



    /// @dev index is 0-based

    function _activeBalanceByIndex(uint256 index, address currencyCt, uint256 currencyId)

    private

    view

    returns (int256)

    {

        return partners[index].active.get(currencyCt, currencyId);

    }



    /// @dev index is 0-based

    function _stagedBalanceByIndex(uint256 index, address currencyCt, uint256 currencyId)

    private

    view

    returns (int256)

    {

        return partners[index].staged.get(currencyCt, currencyId);

    }



    function _registerPartnerByNameHash(bytes32 nameHash, uint256 fee, address wallet,

        bool partnerCanUpdate, bool operatorCanUpdate)

    private

    {

        // Require that the name is not previously registered

        require(0 == _indexByNameHash[nameHash]);



        // Require possibility to update

        require(partnerCanUpdate || operatorCanUpdate);



        // Add new partner

        partners.length++;



        // Reference by 1-based index

        uint256 index = partners.length;



        // Update partner map

        partners[index - 1].nameHash = nameHash;

        partners[index - 1].fee = fee;

        partners[index - 1].wallet = wallet;

        partners[index - 1].partnerCanUpdate = partnerCanUpdate;

        partners[index - 1].operatorCanUpdate = operatorCanUpdate;

        partners[index - 1].index = index;



        // Update name hash to index map

        _indexByNameHash[nameHash] = index;



        // Update wallet to index map

        _indexByWallet[wallet] = index;

    }



    /// @dev index is 0-based

    function _setPartnerFeeByIndex(uint256 index, uint256 fee)

    private

    returns (uint256)

    {

        uint256 oldFee = partners[index].fee;



        // If operator tries to change verify that operator has access

        if (isOperator())

            require(partners[index].operatorCanUpdate);



        else {

            // Require that msg.sender is partner

            require(msg.sender == partners[index].wallet);



            // If partner tries to change verify that partner has access

            require(partners[index].partnerCanUpdate);

        }



        // Update stored fee

        partners[index].fee = fee;



        return oldFee;

    }



    // @dev index is 0-based

    function _setPartnerWalletByIndex(uint256 index, address newWallet)

    private

    returns (address)

    {

        address oldWallet = partners[index].wallet;



        // If address has not been set operator is the only allowed to change it

        if (oldWallet == address(0))

            require(isOperator());



        // Else if operator tries to change verify that operator has access

        else if (isOperator())

            require(partners[index].operatorCanUpdate);



        else {

            // Require that msg.sender is partner

            require(msg.sender == oldWallet);



            // If partner tries to change verify that partner has access

            require(partners[index].partnerCanUpdate);



            // Require that new wallet is not zero-address if it can not be changed by operator

            require(partners[index].operatorCanUpdate || newWallet != address(0));

        }



        // Update stored wallet

        partners[index].wallet = newWallet;



        // Update address to tag map

        if (oldWallet != address(0))

            _indexByWallet[oldWallet] = 0;

        if (newWallet != address(0))

            _indexByWallet[newWallet] = index;



        return oldWallet;

    }



    // @dev index is 0-based

    function _partnerFeeByIndex(uint256 index)

    private

    view

    returns (uint256)

    {

        return partners[index].fee;

    }

}



contract RevenueFund is Ownable, AccrualBeneficiary, AccrualBenefactor, TransferControllerManageable {

    using FungibleBalanceLib for FungibleBalanceLib.Balance;

    using TxHistoryLib for TxHistoryLib.TxHistory;

    using SafeMathIntLib for int256;

    using SafeMathUintLib for uint256;

    using CurrenciesLib for CurrenciesLib.Currencies;



    //

    // Variables

    // -----------------------------------------------------------------------------------------------------------------

    FungibleBalanceLib.Balance periodAccrual;

    CurrenciesLib.Currencies periodCurrencies;



    FungibleBalanceLib.Balance aggregateAccrual;

    CurrenciesLib.Currencies aggregateCurrencies;



    TxHistoryLib.TxHistory private txHistory;



    //

    // Events

    // -----------------------------------------------------------------------------------------------------------------

    event ReceiveEvent(address from, int256 amount, address currencyCt, uint256 currencyId);

    event CloseAccrualPeriodEvent();

    event RegisterServiceEvent(address service);

    event DeregisterServiceEvent(address service);



    //

    // Constructor

    // -----------------------------------------------------------------------------------------------------------------

    constructor(address deployer) Ownable(deployer) public {

    }



    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    /// @notice Fallback function that deposits ethers

    function() public payable {

        receiveEthersTo(msg.sender, "");

    }



    /// @notice Receive ethers to

    /// @param wallet The concerned wallet address

    function receiveEthersTo(address wallet, string)

    public

    payable

    {

        int256 amount = SafeMathIntLib.toNonZeroInt256(msg.value);



        // Add to balances

        periodAccrual.add(amount, address(0), 0);

        aggregateAccrual.add(amount, address(0), 0);



        // Add currency to stores of currencies

        periodCurrencies.add(address(0), 0);

        aggregateCurrencies.add(address(0), 0);



        // Add to transaction history

        txHistory.addDeposit(amount, address(0), 0);



        // Emit event

        emit ReceiveEvent(wallet, amount, address(0), 0);

    }



    /// @notice Receive tokens

    /// @param amount The concerned amount

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// @param standard The standard of token ("ERC20", "ERC721")

    function receiveTokens(string balanceType, int256 amount, address currencyCt,

        uint256 currencyId, string standard)

    public

    {

        receiveTokensTo(msg.sender, balanceType, amount, currencyCt, currencyId, standard);

    }



    /// @notice Receive tokens to

    /// @param wallet The address of the concerned wallet

    /// @param amount The concerned amount

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// @param standard The standard of token ("ERC20", "ERC721")

    function receiveTokensTo(address wallet, string, int256 amount,

        address currencyCt, uint256 currencyId, string standard)

    public

    {

        require(amount.isNonZeroPositiveInt256());



        // Execute transfer

        TransferController controller = transferController(currencyCt, standard);

        require(

            address(controller).delegatecall(

                controller.getReceiveSignature(), msg.sender, this, uint256(amount), currencyCt, currencyId

            )

        );



        // Add to balances

        periodAccrual.add(amount, currencyCt, currencyId);

        aggregateAccrual.add(amount, currencyCt, currencyId);



        // Add currency to stores of currencies

        periodCurrencies.add(currencyCt, currencyId);

        aggregateCurrencies.add(currencyCt, currencyId);



        // Add to transaction history

        txHistory.addDeposit(amount, currencyCt, currencyId);



        // Emit event

        emit ReceiveEvent(wallet, amount, currencyCt, currencyId);

    }



    /// @notice Get the period accrual balance of the given currency

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// @return The current period's accrual balance

    function periodAccrualBalance(address currencyCt, uint256 currencyId)

    public

    view

    returns (int256)

    {

        return periodAccrual.get(currencyCt, currencyId);

    }



    /// @notice Get the aggregate accrual balance of the given currency, including contribution from the

    /// current accrual period

    /// @param currencyCt The address of the concerned currency contract (address(0) == ETH)

    /// @param currencyId The ID of the concerned currency (0 for ETH and ERC20)

    /// @return The aggregate accrual balance

    function aggregateAccrualBalance(address currencyCt, uint256 currencyId)

    public

    view

    returns (int256)

    {

        return aggregateAccrual.get(currencyCt, currencyId);

    }



    /// @notice Get the count of currencies recorded in the accrual period

    /// @return The number of currencies in the current accrual period

    function periodCurrenciesCount()

    public

    view

    returns (uint256)

    {

        return periodCurrencies.count();

    }



    /// @notice Get the currencies with indices in the given range that have been recorded in the current accrual period

    /// @param low The lower currency index

    /// @param up The upper currency index

    /// @return The currencies of the given index range in the current accrual period

    function periodCurrenciesByIndices(uint256 low, uint256 up)

    public

    view

    returns (MonetaryTypesLib.Currency[])

    {

        return periodCurrencies.getByIndices(low, up);

    }



    /// @notice Get the count of currencies ever recorded

    /// @return The number of currencies ever recorded

    function aggregateCurrenciesCount()

    public

    view

    returns (uint256)

    {

        return aggregateCurrencies.count();

    }



    /// @notice Get the currencies with indices in the given range that have ever been recorded

    /// @param low The lower currency index

    /// @param up The upper currency index

    /// @return The currencies of the given index range ever recorded

    function aggregateCurrenciesByIndices(uint256 low, uint256 up)

    public

    view

    returns (MonetaryTypesLib.Currency[])

    {

        return aggregateCurrencies.getByIndices(low, up);

    }



    /// @notice Get the count of deposits

    /// @return The count of deposits

    function depositsCount()

    public

    view

    returns (uint256)

    {

        return txHistory.depositsCount();

    }



    /// @notice Get the deposit at the given index

    /// @return The deposit at the given index

    function deposit(uint index)

    public

    view

    returns (int256 amount, uint256 blockNumber, address currencyCt, uint256 currencyId)

    {

        return txHistory.deposit(index);

    }



    /// @notice Close the current accrual period of the given currencies

    /// @param currencies The concerned currencies

    function closeAccrualPeriod(MonetaryTypesLib.Currency[] currencies)

    public

    onlyOperator

    {

        require(ConstantsLib.PARTS_PER() == totalBeneficiaryFraction);



        // Execute transfer

        for (uint256 i = 0; i < currencies.length; i++) {

            MonetaryTypesLib.Currency memory currency = currencies[i];



            int256 remaining = periodAccrual.get(currency.ct, currency.id);



            if (0 >= remaining)

                continue;



            for (uint256 j = 0; j < beneficiaries.length; j++) {

                address beneficiaryAddress = beneficiaries[j];



                if (beneficiaryFraction(beneficiaryAddress) > 0) {

                    int256 transferable = periodAccrual.get(currency.ct, currency.id)

                    .mul(beneficiaryFraction(beneficiaryAddress))

                    .div(ConstantsLib.PARTS_PER());



                    if (transferable > remaining)

                        transferable = remaining;



                    if (transferable > 0) {

                        // Transfer ETH to the beneficiary

                        if (currency.ct == address(0))

                            AccrualBeneficiary(beneficiaryAddress).receiveEthersTo.value(uint256(transferable))(address(0), "");



                        // Transfer token to the beneficiary

                        else {

                            TransferController controller = transferController(currency.ct, "");

                            require(

                                address(controller).delegatecall(

                                    controller.getApproveSignature(), beneficiaryAddress, uint256(transferable), currency.ct, currency.id

                                )

                            );



                            AccrualBeneficiary(beneficiaryAddress).receiveTokensTo(address(0), "", transferable, currency.ct, currency.id, "");

                        }



                        remaining = remaining.sub(transferable);

                    }

                }

            }



            // Roll over remaining to next accrual period

            periodAccrual.set(remaining, currency.ct, currency.id);

        }



        // Close accrual period of accrual beneficiaries

        for (j = 0; j < beneficiaries.length; j++) {

            beneficiaryAddress = beneficiaries[j];



            // Require that beneficiary fraction is strictly positive

            if (0 >= beneficiaryFraction(beneficiaryAddress))

                continue;



            // Close accrual period

            AccrualBeneficiary(beneficiaryAddress).closeAccrualPeriod(currencies);

        }



        // Emit event

        emit CloseAccrualPeriodEvent();

    }

}



contract TransferControllerManager is Ownable {

    //

    // Constants

    // -----------------------------------------------------------------------------------------------------------------

    struct CurrencyInfo {

        bytes32 standard;

        bool blacklisted;

    }



    //

    // Variables

    // -----------------------------------------------------------------------------------------------------------------

    mapping(bytes32 => address) public registeredTransferControllers;

    mapping(address => CurrencyInfo) public registeredCurrencies;



    //

    // Events

    // -----------------------------------------------------------------------------------------------------------------

    event RegisterTransferControllerEvent(string standard, address controller);

    event ReassociateTransferControllerEvent(string oldStandard, string newStandard, address controller);



    event RegisterCurrencyEvent(address currencyCt, string standard);

    event DeregisterCurrencyEvent(address currencyCt);

    event BlacklistCurrencyEvent(address currencyCt);

    event WhitelistCurrencyEvent(address currencyCt);



    //

    // Constructor

    // -----------------------------------------------------------------------------------------------------------------

    constructor(address deployer) Ownable(deployer) public {

    }



    //

    // Functions

    // -----------------------------------------------------------------------------------------------------------------

    function registerTransferController(string standard, address controller)

    external

    onlyDeployer

    notNullAddress(controller)

    {

        require(bytes(standard).length > 0);

        bytes32 standardHash = keccak256(abi.encodePacked(standard));



        require(registeredTransferControllers[standardHash] == address(0));



        registeredTransferControllers[standardHash] = controller;



        // Emit event

        emit RegisterTransferControllerEvent(standard, controller);

    }



    function reassociateTransferController(string oldStandard, string newStandard, address controller)

    external

    onlyDeployer

    notNullAddress(controller)

    {

        require(bytes(newStandard).length > 0);

        bytes32 oldStandardHash = keccak256(abi.encodePacked(oldStandard));

        bytes32 newStandardHash = keccak256(abi.encodePacked(newStandard));



        require(registeredTransferControllers[oldStandardHash] != address(0));

        require(registeredTransferControllers[newStandardHash] == address(0));



        registeredTransferControllers[newStandardHash] = registeredTransferControllers[oldStandardHash];

        registeredTransferControllers[oldStandardHash] = address(0);



        // Emit event

        emit ReassociateTransferControllerEvent(oldStandard, newStandard, controller);

    }



    function registerCurrency(address currencyCt, string standard)

    external

    onlyOperator

    notNullAddress(currencyCt)

    {

        require(bytes(standard).length > 0);

        bytes32 standardHash = keccak256(abi.encodePacked(standard));



        require(registeredCurrencies[currencyCt].standard == bytes32(0));



        registeredCurrencies[currencyCt].standard = standardHash;



        // Emit event

        emit RegisterCurrencyEvent(currencyCt, standard);

    }



    function deregisterCurrency(address currencyCt)

    external

    onlyOperator

    {

        require(registeredCurrencies[currencyCt].standard != 0);



        registeredCurrencies[currencyCt].standard = bytes32(0);

        registeredCurrencies[currencyCt].blacklisted = false;



        // Emit event

        emit DeregisterCurrencyEvent(currencyCt);

    }



    function blacklistCurrency(address currencyCt)

    external

    onlyOperator

    {

        require(registeredCurrencies[currencyCt].standard != bytes32(0));



        registeredCurrencies[currencyCt].blacklisted = true;



        // Emit event

        emit BlacklistCurrencyEvent(currencyCt);

    }



    function whitelistCurrency(address currencyCt)

    external

    onlyOperator

    {

        require(registeredCurrencies[currencyCt].standard != bytes32(0));



        registeredCurrencies[currencyCt].blacklisted = false;



        // Emit event

        emit WhitelistCurrencyEvent(currencyCt);

    }



    /**

    @notice The provided standard takes priority over assigned interface to currency

    */

    function transferController(address currencyCt, string standard)

    public

    view

    returns (TransferController)

    {

        if (bytes(standard).length > 0) {

            bytes32 standardHash = keccak256(abi.encodePacked(standard));



            require(registeredTransferControllers[standardHash] != address(0));

            return TransferController(registeredTransferControllers[standardHash]);

        }



        require(registeredCurrencies[currencyCt].standard != bytes32(0));

        require(!registeredCurrencies[currencyCt].blacklisted);



        address controllerAddress = registeredTransferControllers[registeredCurrencies[currencyCt].standard];

        require(controllerAddress != address(0));



        return TransferController(controllerAddress);

    }

}



