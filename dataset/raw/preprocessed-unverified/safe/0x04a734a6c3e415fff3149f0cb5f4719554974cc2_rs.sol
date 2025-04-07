/**

 *Submitted for verification at Etherscan.io on 2019-03-25

*/



pragma solidity ^0.5.0;



pragma experimental ABIEncoderV2;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





/**

 * @title SignedSafeMath

 * @dev Signed math operations with safety checks that revert on error

 */





/**

 * @title Standard ERC20 token

 *

 * @dev Implementation of the basic standard token.

 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 * Originally based on code by FirstBlood:

 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol

 *

 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for

 * all accounts just by listening to said events. Note that this isn't required by the specification, and other

 * compliant implementations may not do it.

 */

contract ERC20 is IERC20 {

    using SafeMath for uint256;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowed;



    uint256 private _totalSupply;



    /**

    * @dev Total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param owner The address to query the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    /**

     * @dev Function to check the amount of tokens that an owner allowed to a spender.

     * @param owner address The address which owns the funds.

     * @param spender address The address which will spend the funds.

     * @return A uint256 specifying the amount of tokens still available for the spender.

     */

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];

    }



    /**

    * @dev Transfer token for a specified address

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }



    /**

     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

     * Beware that changing an allowance with this method brings the risk that someone may use both the old

     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     * @param spender The address which will spend the funds.

     * @param value The amount of tokens to be spent.

     */

    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    /**

     * @dev Transfer tokens from one address to another.

     * Note that while this function emits an Approval event, this is not required as per the specification,

     * and other compliant implementations may not emit the event.

     * @param from address The address which you want to send tokens from

     * @param to address The address which you want to transfer to

     * @param value uint256 the amount of tokens to be transferred

     */

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        emit Approval(from, msg.sender, _allowed[from][msg.sender]);

        return true;

    }



    /**

     * @dev Increase the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To increment

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param addedValue The amount of tokens to increase the allowance by.

     */

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

     * @dev Decrease the amount of tokens that an owner allowed to a spender.

     * approve should be called when allowed_[_spender] == 0. To decrement

     * allowed value is better to use this function to avoid 2 calls (and wait until

     * the first transaction is mined)

     * From MonolithDAO Token.sol

     * Emits an Approval event.

     * @param spender The address which will spend the funds.

     * @param subtractedValue The amount of tokens to decrease the allowance by.

     */

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);

        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);

        return true;

    }



    /**

    * @dev Transfer token for a specified addresses

    * @param from The address to transfer from.

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    /**

     * @dev Internal function that mints an amount of the token and assigns it to

     * an account. This encapsulates the modification of balances such that the

     * proper events are emitted.

     * @param account The account that will receive the created tokens.

     * @param value The amount that will be created.

     */

    function _mint(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.add(value);

        _balances[account] = _balances[account].add(value);

        emit Transfer(address(0), account, value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account.

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burn(address account, uint256 value) internal {

        require(account != address(0));



        _totalSupply = _totalSupply.sub(value);

        _balances[account] = _balances[account].sub(value);

        emit Transfer(account, address(0), value);

    }



    /**

     * @dev Internal function that burns an amount of the token of a given

     * account, deducting from the sender's allowance for said account. Uses the

     * internal burn function.

     * Emits an Approval event (reflecting the reduced allowance).

     * @param account The account whose tokens will be burnt.

     * @param value The amount that will be burnt.

     */

    function _burnFrom(address account, uint256 value) internal {

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);

        _burn(account, value);

        emit Approval(account, msg.sender, _allowed[account][msg.sender]);

    }

}



// The functionality that all derivative contracts expose to the admin.





contract ExpandedIERC20 is IERC20 {

    // Burns a specific amount of tokens. Burns the sender's tokens, so it is safe to leave this method permissionless.

    function burn(uint value) external;



    // Mints tokens and adds them to the balance of the `to` address.

    // Note: this method should be permissioned to only allow designated parties to mint tokens.

    function mint(address to, uint value) external;

}



// This interface allows derivative contracts to pay Oracle fees for their use of the system.









// This interface allows contracts to query unverified prices.





contract AddressWhitelist is Ownable {

    enum Status { None, In, Out }

    mapping(address => Status) private whitelist;



    address[] private whitelistIndices;



    // Adds an address to the whitelist

    function addToWhitelist(address newElement) external onlyOwner {

        // Ignore if address is already included

        if (whitelist[newElement] == Status.In) {

            return;

        }



        // Only append new addresses to the array, never a duplicate

        if (whitelist[newElement] == Status.None) {

            whitelistIndices.push(newElement);

        }



        whitelist[newElement] = Status.In;



        emit AddToWhitelist(newElement);

    }



    // Removes an address from the whitelist.

    function removeFromWhitelist(address elementToRemove) external onlyOwner {

        if (whitelist[elementToRemove] != Status.Out) {

            whitelist[elementToRemove] = Status.Out;

            emit RemoveFromWhitelist(elementToRemove);

        }

    }



    // Checks whether an address is on the whitelist.

    function isOnWhitelist(address elementToCheck) external view returns (bool) {

        return whitelist[elementToCheck] == Status.In;

    }



    // Gets all addresses that are currently included in the whitelist

    // Note: This method skips over, but still iterates through addresses.

    // It is possible for this call to run out of gas if a large number of

    // addresses have been removed. To prevent this unlikely scenario, we can

    // modify the implementation so that when addresses are removed, the last addresses

    // in the array is moved to the empty index.

    function getWhitelist() external view returns (address[] memory activeWhitelist) {

        // Determine size of whitelist first

        uint activeCount = 0;

        for (uint i = 0; i < whitelistIndices.length; i++) {

            if (whitelist[whitelistIndices[i]] == Status.In) {

                activeCount++;

            }

        }



        // Populate whitelist

        activeWhitelist = new address[](activeCount);

        activeCount = 0;

        for (uint i = 0; i < whitelistIndices.length; i++) {

            address addr = whitelistIndices[i];

            if (whitelist[addr] == Status.In) {

                activeWhitelist[activeCount] = addr;

                activeCount++;

            }

        }

    }



    event AddToWhitelist(address indexed addedAddress);

    event RemoveFromWhitelist(address indexed removedAddress);

}



contract Withdrawable is Ownable {

    // Withdraws ETH from the contract.

    function withdraw(uint amount) external onlyOwner {

        msg.sender.transfer(amount);

    }



    // Withdraws ERC20 tokens from the contract.

    function withdrawErc20(address erc20Address, uint amount) external onlyOwner {

        IERC20 erc20 = IERC20(erc20Address);

        require(erc20.transfer(msg.sender, amount));

    }

}



// This interface allows contracts to query a verified, trusted price.









contract Registry is RegistryInterface, Withdrawable {



    using SafeMath for uint;



    // Array of all registeredDerivatives that are approved to use the UMA Oracle.

    RegisteredDerivative[] private registeredDerivatives;



    // This enum is required because a WasValid state is required to ensure that derivatives cannot be re-registered.

    enum PointerValidity {

        Invalid,

        Valid,

        WasValid

    }



    struct Pointer {

        PointerValidity valid;

        uint128 index;

    }



    // Maps from derivative address to a pointer that refers to that RegisteredDerivative in registeredDerivatives.

    mapping(address => Pointer) private derivativePointers;



    // Note: this must be stored outside of the RegisteredDerivative because mappings cannot be deleted and copied

    // like normal data. This could be stored in the Pointer struct, but storing it there would muddy the purpose

    // of the Pointer struct and break separation of concern between referential data and data.

    struct PartiesMap {

        mapping(address => bool) parties;

    }



    // Maps from derivative address to the set of parties that are involved in that derivative.

    mapping(address => PartiesMap) private derivativesToParties;



    // Maps from derivative creator address to whether that derivative creator has been approved to register contracts.

    mapping(address => bool) private derivativeCreators;



    modifier onlyApprovedDerivativeCreator {

        require(derivativeCreators[msg.sender]);

        _;

    }



    function registerDerivative(address[] calldata parties, address derivativeAddress)

        external

        onlyApprovedDerivativeCreator

    {

        // Create derivative pointer.

        Pointer storage pointer = derivativePointers[derivativeAddress];



        // Ensure that the pointer was not valid in the past (derivatives cannot be re-registered or double

        // registered).

        require(pointer.valid == PointerValidity.Invalid);

        pointer.valid = PointerValidity.Valid;



        registeredDerivatives.push(RegisteredDerivative(derivativeAddress, msg.sender));



        // No length check necessary because we should never hit (2^127 - 1) derivatives.

        pointer.index = uint128(registeredDerivatives.length.sub(1));



        // Set up PartiesMap for this derivative.

        PartiesMap storage partiesMap = derivativesToParties[derivativeAddress];

        for (uint i = 0; i < parties.length; i = i.add(1)) {

            partiesMap.parties[parties[i]] = true;

        }



        address[] memory partiesForEvent = parties;

        emit RegisterDerivative(derivativeAddress, partiesForEvent);

    }



    function addDerivativeCreator(address derivativeCreator) external onlyOwner {

        if (!derivativeCreators[derivativeCreator]) {

            derivativeCreators[derivativeCreator] = true;

            emit AddDerivativeCreator(derivativeCreator);

        }

    }



    function removeDerivativeCreator(address derivativeCreator) external onlyOwner {

        if (derivativeCreators[derivativeCreator]) {

            derivativeCreators[derivativeCreator] = false;

            emit RemoveDerivativeCreator(derivativeCreator);

        }

    }



    function isDerivativeRegistered(address derivative) external view returns (bool isRegistered) {

        return derivativePointers[derivative].valid == PointerValidity.Valid;

    }



    function getRegisteredDerivatives(address party) external view returns (RegisteredDerivative[] memory derivatives) {

        // This is not ideal - we must statically allocate memory arrays. To be safe, we make a temporary array as long

        // as registeredDerivatives. We populate it with any derivatives that involve the provided party. Then, we copy

        // the array over to the return array, which is allocated using the correct size. Note: this is done by double

        // copying each value rather than storing some referential info (like indices) in memory to reduce the number

        // of storage reads. This is because storage reads are far more expensive than extra memory space (~100:1).

        RegisteredDerivative[] memory tmpDerivativeArray = new RegisteredDerivative[](registeredDerivatives.length);

        uint outputIndex = 0;

        for (uint i = 0; i < registeredDerivatives.length; i = i.add(1)) {

            RegisteredDerivative storage derivative = registeredDerivatives[i];

            if (derivativesToParties[derivative.derivativeAddress].parties[party]) {

                // Copy selected derivative to the temporary array.

                tmpDerivativeArray[outputIndex] = derivative;

                outputIndex = outputIndex.add(1);

            }

        }



        // Copy the temp array to the return array that is set to the correct size.

        derivatives = new RegisteredDerivative[](outputIndex);

        for (uint j = 0; j < outputIndex; j = j.add(1)) {

            derivatives[j] = tmpDerivativeArray[j];

        }

    }



    function getAllRegisteredDerivatives() external view returns (RegisteredDerivative[] memory derivatives) {

        return registeredDerivatives;

    }



    function isDerivativeCreatorAuthorized(address derivativeCreator) external view returns (bool isAuthorized) {

        return derivativeCreators[derivativeCreator];

    }



    event RegisterDerivative(address indexed derivativeAddress, address[] parties);

    event AddDerivativeCreator(address indexed addedDerivativeCreator);

    event RemoveDerivativeCreator(address indexed removedDerivativeCreator);



}



contract Testable is Ownable {



    // Is the contract being run on the test network. Note: this variable should be set on construction and never

    // modified.

    bool public isTest;



    uint private currentTime;



    constructor(bool _isTest) internal {

        isTest = _isTest;

        if (_isTest) {

            currentTime = now; // solhint-disable-line not-rely-on-time

        }

    }



    modifier onlyIfTest {

        require(isTest);

        _;

    }



    function setCurrentTime(uint _time) external onlyOwner onlyIfTest {

        currentTime = _time;

    }



    function getCurrentTime() public view returns (uint) {

        if (isTest) {

            return currentTime;

        } else {

            return now; // solhint-disable-line not-rely-on-time

        }

    }

}



contract ContractCreator is Withdrawable {

    Registry internal registry;

    address internal oracleAddress;

    address internal storeAddress;

    address internal priceFeedAddress;



    constructor(address registryAddress, address _oracleAddress, address _storeAddress, address _priceFeedAddress)

        public

    {

        registry = Registry(registryAddress);

        oracleAddress = _oracleAddress;

        storeAddress = _storeAddress;

        priceFeedAddress = _priceFeedAddress;

    }



    function _registerContract(address[] memory parties, address contractToRegister) internal {

        registry.registerDerivative(parties, contractToRegister);

    }

}







// TokenizedDerivativeStorage: this library name is shortened due to it being used so often.









// TODO(mrice32): make this and TotalReturnSwap derived classes of a single base to encap common functionality.

contract TokenizedDerivative is ERC20, AdminInterface, ExpandedIERC20 {

    using TokenizedDerivativeUtils for TDS.Storage;



    // Note: these variables are to give ERC20 consumers information about the token.

    string public name;

    string public symbol;

    uint8 public constant decimals = 18; // solhint-disable-line const-name-snakecase



    TDS.Storage public derivativeStorage;



    constructor(

        TokenizedDerivativeParams.ConstructorParams memory params,

        string memory _name,

        string memory _symbol

    ) public {

        // Set token properties.

        name = _name;

        symbol = _symbol;



        // Initialize the contract.

        derivativeStorage._initialize(params, _symbol);

    }



    // Creates tokens with sent margin and returns additional margin.

    function createTokens(uint marginForPurchase, uint tokensToPurchase) external payable {

        derivativeStorage._createTokens(marginForPurchase, tokensToPurchase);

    }



    // Creates tokens with sent margin and deposits additional margin in short account.

    function depositAndCreateTokens(uint marginForPurchase, uint tokensToPurchase) external payable {

        derivativeStorage._depositAndCreateTokens(marginForPurchase, tokensToPurchase);

    }



    // Redeems tokens for margin currency.

    function redeemTokens(uint tokensToRedeem) external {

        derivativeStorage._redeemTokens(tokensToRedeem);

    }



    // Triggers a price dispute for the most recent remargin time.

    function dispute(uint depositMargin) external payable {

        derivativeStorage._dispute(depositMargin);

    }



    // Withdraws `amount` from short margin account.

    function withdraw(uint amount) external {

        derivativeStorage._withdraw(amount);

    }



    // Pays (Oracle and service) fees for the previous period, updates the contract NAV, moves margin between long and

    // short accounts to reflect the new NAV, and checks if both accounts meet minimum requirements.

    function remargin() external {

        derivativeStorage._remargin();

    }



    // Forgo the Oracle verified price and settle the contract with last remargin price. This method is only callable on

    // contracts in the `Defaulted` state, and the default penalty is always transferred from the short to the long

    // account.

    function acceptPriceAndSettle() external {

        derivativeStorage._acceptPriceAndSettle();

    }



    // Assigns an address to be the contract's Delegate AP. Replaces previous value. Set to 0x0 to indicate there is no

    // Delegate AP.

    function setApDelegate(address apDelegate) external {

        derivativeStorage._setApDelegate(apDelegate);

    }



    // Moves the contract into the Emergency state, where it waits on an Oracle price for the most recent remargin time.

    function emergencyShutdown() external {

        derivativeStorage._emergencyShutdown();

    }



    // Returns the expected net asset value (NAV) of the contract using the latest available Price Feed price.

    function calcNAV() external view returns (int navNew) {

        return derivativeStorage._calcNAV();

    }



    // Returns the expected value of each the outstanding tokens of the contract using the latest available Price Feed

    // price.

    function calcTokenValue() external view returns (int newTokenValue) {

        return derivativeStorage._calcTokenValue();

    }



    // Returns the expected balance of the short margin account using the latest available Price Feed price.

    function calcShortMarginBalance() external view returns (int newShortMarginBalance) {

        return derivativeStorage._calcShortMarginBalance();

    }



    // Returns the expected short margin in excess of the margin requirement using the latest available Price Feed

    // price.  Value will be negative if the short margin is expected to be below the margin requirement.

    function calcExcessMargin() external view returns (int excessMargin) {

        return derivativeStorage._calcExcessMargin();

    }



    // Returns the required margin, as of the last remargin. Note that `calcExcessMargin` uses updated values using the

    // latest available Price Feed price.

    function getCurrentRequiredMargin() external view returns (int requiredMargin) {

        return derivativeStorage._getCurrentRequiredMargin();

    }



    // Returns whether the contract can be settled, i.e., is it valid to call settle() now.

    function canBeSettled() external view returns (bool canContractBeSettled) {

        return derivativeStorage._canBeSettled();

    }



    // Returns the updated underlying price that was used in the calc* methods above. It will be a price feed price if

    // the contract is Live and will remain Live, or an Oracle price if the contract is settled/about to be settled.

    // Reverts if no Oracle price is available but an Oracle price is required.

    function getUpdatedUnderlyingPrice() external view returns (int underlyingPrice, uint time) {

        return derivativeStorage._getUpdatedUnderlyingPrice();

    }



    // When an Oracle price becomes available, performs a final remargin, assesses any penalties, and moves the contract

    // into the `Settled` state.

    function settle() external {

        derivativeStorage._settle();

    }



    // Adds the margin sent along with the call (or in the case of an ERC20 margin currency, authorized before the call)

    // to the short account.

    function deposit(uint amountToDeposit) external payable {

        derivativeStorage._deposit(amountToDeposit);

    }



    // Allows the sponsor to withdraw any ERC20 balance that is not the margin token.

    function withdrawUnexpectedErc20(address erc20Address, uint amount) external {

        derivativeStorage._withdrawUnexpectedErc20(erc20Address, amount);

    }



    // ExpandedIERC20 methods.

    modifier onlyThis {

        require(msg.sender == address(this));

        _;

    }



    // Only allow calls from this contract or its libraries to burn tokens.

    function burn(uint value) external onlyThis {

        // Only allow calls from this contract or its libraries to burn tokens.

        _burn(msg.sender, value);

    }



    // Only allow calls from this contract or its libraries to mint tokens.

    function mint(address to, uint256 value) external onlyThis {

        _mint(to, value);

    }



    // These events are actually emitted by TokenizedDerivativeUtils, but we unfortunately have to define the events

    // here as well.

    event NavUpdated(string symbol, int newNav, int newTokenPrice);

    event Default(string symbol, uint defaultTime, int defaultNav);

    event Settled(string symbol, uint settleTime, int finalNav);

    event Expired(string symbol, uint expiryTime);

    event Disputed(string symbol, uint timeDisputed, int navDisputed);

    event EmergencyShutdownTransition(string symbol, uint shutdownTime);

    event TokensCreated(string symbol, uint numTokensCreated);

    event TokensRedeemed(string symbol, uint numTokensRedeemed);

    event Deposited(string symbol, uint amount);

    event Withdrawal(string symbol, uint amount);

}



contract TokenizedDerivativeCreator is ContractCreator, Testable {

    struct Params {

        uint defaultPenalty; // Percentage of mergin requirement * 10^18

        uint supportedMove; // Expected percentage move in the underlying that the long is protected against.

        bytes32 product;

        uint fixedYearlyFee; // Percentage of nav * 10^18

        uint disputeDeposit; // Percentage of mergin requirement * 10^18

        address returnCalculator;

        uint startingTokenPrice;

        uint expiry;

        address marginCurrency;

        uint withdrawLimit; // Percentage of shortBalance * 10^18

        TokenizedDerivativeParams.ReturnType returnType;

        uint startingUnderlyingPrice;

        string name;

        string symbol;

    }



    AddressWhitelist public sponsorWhitelist;

    AddressWhitelist public returnCalculatorWhitelist;

    AddressWhitelist public marginCurrencyWhitelist;



    constructor(

        address registryAddress,

        address _oracleAddress,

        address _storeAddress,

        address _priceFeedAddress,

        address _sponsorWhitelist,

        address _returnCalculatorWhitelist,

        address _marginCurrencyWhitelist,

        bool _isTest

    )

        public

        ContractCreator(registryAddress, _oracleAddress, _storeAddress, _priceFeedAddress)

        Testable(_isTest)

    {

        sponsorWhitelist = AddressWhitelist(_sponsorWhitelist);

        returnCalculatorWhitelist = AddressWhitelist(_returnCalculatorWhitelist);

        marginCurrencyWhitelist = AddressWhitelist(_marginCurrencyWhitelist);

    }



    function createTokenizedDerivative(Params memory params)

        public

        returns (address derivativeAddress)

    {

        TokenizedDerivative derivative = new TokenizedDerivative(_convertParams(params), params.name, params.symbol);



        address[] memory parties = new address[](1);

        parties[0] = msg.sender;



        _registerContract(parties, address(derivative));



        return address(derivative);

    }



    // Converts createTokenizedDerivative params to TokenizedDerivative constructor params.

    function _convertParams(Params memory params)

        private

        view

        returns (TokenizedDerivativeParams.ConstructorParams memory constructorParams)

    {

        // Copy and verify externally provided variables.

        require(sponsorWhitelist.isOnWhitelist(msg.sender));

        constructorParams.sponsor = msg.sender;



        require(returnCalculatorWhitelist.isOnWhitelist(params.returnCalculator));

        constructorParams.returnCalculator = params.returnCalculator;



        require(marginCurrencyWhitelist.isOnWhitelist(params.marginCurrency));

        constructorParams.marginCurrency = params.marginCurrency;



        constructorParams.defaultPenalty = params.defaultPenalty;

        constructorParams.supportedMove = params.supportedMove;

        constructorParams.product = params.product;

        constructorParams.fixedYearlyFee = params.fixedYearlyFee;

        constructorParams.disputeDeposit = params.disputeDeposit;

        constructorParams.startingTokenPrice = params.startingTokenPrice;

        constructorParams.expiry = params.expiry;

        constructorParams.withdrawLimit = params.withdrawLimit;

        constructorParams.returnType = params.returnType;

        constructorParams.startingUnderlyingPrice = params.startingUnderlyingPrice;



        // Copy internal variables.

        constructorParams.priceFeed = priceFeedAddress;

        constructorParams.oracle = oracleAddress;

        constructorParams.store = storeAddress;

        constructorParams.admin = oracleAddress;

        constructorParams.creationTime = getCurrentTime();

    }

}