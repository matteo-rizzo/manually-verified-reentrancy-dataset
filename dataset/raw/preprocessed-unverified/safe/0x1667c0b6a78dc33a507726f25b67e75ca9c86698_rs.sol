/**
 *Submitted for verification at Etherscan.io on 2021-08-31
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/// @title MultiSignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <[emailÂ protected]>
/// @author Itzik Grossman - modified contract for swapping purposes
contract DuplexBridge {
    // No longer needed in 0.8+
    //using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /*
     *  Events
     */
    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Withdraw(uint indexed transactionId);
    event WithdrawFailure(uint indexed transactionId);
    event Swap(uint amount, bytes recipient);
    event OwnerAddition(address indexed owner);
    event FeeCollectorChange(address indexed collector);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);
    event SwapToken(address sender, bytes recipient, uint256 amount, address tokenAddress, uint256 toSCRT);
    /*
     *  Constants
     */
    uint constant public MAX_OWNER_COUNT = 50;

    /*
     *  Storage
     */
    mapping (address => uint) public tokenWhitelist;

    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isOwner;
    mapping(address => uint) public secretTxNonce;
    mapping(address => uint) public tokenBalances;
    mapping(address => uint) public tokenLimits;


    address[] public tokens;
    address[] public owners;
    address   public investorContract;
    address payable public feeCollector;

    uint public required;
    uint public transactionCount;
    bool public paused = false;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
        uint nonce;
        address token;
        uint amount;
        uint fee;
    }

    /*
     *  Modifiers
     */
    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    // is above limit
    modifier isNotGoingAboveLimit(address _tokenAddress, uint _amount) {
		// overflow doesn't matter
        require(tokenBalances[_tokenAddress] + _amount <= tokenLimits[_tokenAddress], "Cannot swap more than hard limit");
        _;
    }

    // is not below limit
    modifier isNotUnderflowingBalance(address _tokenAddress, uint _amount) {
        require(tokenBalances[_tokenAddress] - _amount < tokenBalances[_tokenAddress], "Cannot swap more than balance");
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner], "Owner does not exist");
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].destination != address(0));
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }

    modifier notSubmitted(address token, uint nonce) {
        require(secretTxNonce[token] == 0 || secretTxNonce[token] < nonce, "Transaction already computed");
        _;
    }

    modifier notNull(address _address) {
        require(_address != address(0));
        _;
    }

    modifier isSecretAddress(bytes memory _address) {
        uint8 i = 0;
        bytes memory bytesArray = new bytes(7);
        for (i = 0; i < 7 && _address[i] != 0; i++) {
            bytesArray[i] = _address[i];
        }
        require(keccak256(bytesArray) == keccak256(bytes("secret1")));
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        require(ownerCount <= MAX_OWNER_COUNT
        && _required <= ownerCount
        && _required != 0
            && ownerCount != 0);
        _;
    }

    modifier notTokenWhitelisted(address token) {
        require(tokenWhitelist[token] == 0);
        _;
    }


    modifier tokenWhitelisted(address token) {
        require(tokenWhitelist[token] > 0);
        _;
    }

    modifier notPaused() {
        require(!paused);
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    receive()
    external
    payable
    {
        revert();
    }

    /// @dev Returns the execution status of a transaction.
    /// useful in case an execution fails for some reason - so we can easily see that it failed, and handle it manually
    /// @param transactionId Transaction ID.
    /// @return Execution status.
    function isExecuted(uint transactionId)
    public
    view
    returns (bool)
    {
        return transactions[transactionId].executed;
    }

    function pauseSwaps()
    public
    onlyWallet
    {
        paused = true;
    }

    function unPauseSwaps()
    public
    //ownerExists(msg.sender) // todo: remove before production
    onlyWallet
    {
        paused = false;
    }

    function SupportedTokens()
    public
    view
    returns (address[] memory)
    {
        return tokens;
    }

    function setLimit(address _tokenAddress, uint limit)
    public
    ownerExists(msg.sender)
    {
        tokenLimits[_tokenAddress] = limit;
    }


    function addToken(address _tokenAddress, uint min_amount, uint limit)
    public
    ownerExists(msg.sender)
    notTokenWhitelisted(_tokenAddress)
    // OnlyWallet todo: consider this as OnlyWallet
    {
        tokenWhitelist[_tokenAddress] = min_amount;
        tokenLimits[_tokenAddress] = limit;

        tokens.push(_tokenAddress);
    }

    function removeToken(address _tokenAddress)
    public
    ownerExists(msg.sender)
    // OnlyWallet todo: consider this as OnlyWallet
    {
        delete tokenWhitelist[_tokenAddress];
        delete tokenBalances[_tokenAddress];
        delete tokenLimits[_tokenAddress];

        for (uint i = 0; i < tokens.length - 1; i++) {
            if (tokens[i] == _tokenAddress) {
                tokens[i] = tokens[tokens.length - 1];
                break;
            }
        }
        tokens.pop();
    }

    function getTokenNonce(address _tokenAddress)
    public
    view
    returns (uint)
    {
        return secretTxNonce[_tokenAddress];
    }

    function changeInvestorContract(address _address)
    public
    onlyWallet()
    {
        investorContract = _address;
    }


    function releaseToken(address _tokenAddress, uint _amount, address _recipient, uint fee)
    public
    notPaused()
    onlyWallet()
    notNull(investorContract)
    isNotUnderflowingBalance(_tokenAddress, _amount)
    {
        ITangoRouter investor = ITangoRouter(investorContract);
        IERC20 ercToken = IERC20(_tokenAddress);

        tokenBalances[_tokenAddress] = tokenBalances[_tokenAddress] - _amount;

        investor.withdraw(_tokenAddress, _amount);

        ercToken.safeTransfer(feeCollector, fee);
        ercToken.safeTransfer(_recipient, _amount - fee);
    }

    /*
    * Send funds to multisig account, and emit a SwapToken event for emission to the Secret Network
    *
    * @param _recipient: The intended recipient's Secret Network address.
    * @param _amount: The amount of ENG tokens to be itemized.
    * @param _tokenAddress: The address of the token being swapped
    * @param _toSCRT: Amount of SCRT to be minted - will be deducted from the amount swapped
    */
    function swapToken(bytes memory _recipient, uint256 _amount, address _tokenAddress, uint256 _toSCRT)
    public
    notPaused()
    tokenWhitelisted(_tokenAddress)
    isSecretAddress(_recipient)
    isNotGoingAboveLimit(_tokenAddress, _amount)
    {
        IERC20 ercToken = IERC20(_tokenAddress);
        ITangoRouter investor = ITangoRouter(investorContract);

        require(_amount >= tokenWhitelist[_tokenAddress], "Require transfer greater than minimum");

        tokenBalances[_tokenAddress] = tokenBalances[_tokenAddress] + _amount;

        if (ercToken.allowance(address(this), investorContract) < _amount) {
            ercToken.safeApprove(investorContract, type(uint256).max);
        }

        ercToken.safeTransferFrom(msg.sender, address(this), _amount);

        investor.invest(_tokenAddress, _amount);

        emit SwapToken(
            msg.sender,
            _recipient,
            _amount,
            _tokenAddress,
            _toSCRT
        );
    }

    function swap(bytes memory _recipient)
    public
    notPaused()
    isSecretAddress(_recipient)
    payable {
        revert();
    }

    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial owners and required number of confirmations.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    // todo: list of supported tokens?
    constructor (address[] memory _owners, uint _required, address payable _feeCollector, address _investorContract)
    validRequirement(_owners.length, _required)
    notNull(_feeCollector)
    notNull(_investorContract)
    {
        for (uint i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0));
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
        feeCollector = _feeCollector;
        investorContract = _investorContract;
    }

    function getFeeCollector()
    public
    view
    returns (address)
    {
        return feeCollector;
    }

    /// @dev Allows change of the fee collector address. Transaction has to be sent by wallet.
    /// @param _feeCollector Address that fees will be sent to.
    function replaceFeeCollector(address payable _feeCollector)
    public
    onlyWallet
    notNull(_feeCollector)
    {
        feeCollector = _feeCollector;
        emit FeeCollectorChange(_feeCollector);
    }

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(address owner)
    public
    onlyWallet
    ownerDoesNotExist(owner)
    notNull(owner)
    validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        emit OwnerAddition(owner);
    }

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner.
    function removeOwner(address owner)
    public
    onlyWallet
    ownerExists(owner)
    {
        isOwner[owner] = false;
        for (uint i = 0; i < owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.pop();
        if (required > owners.length)
            changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner to be replaced.
    /// @param newOwner Address of new owner.
    function replaceOwner(address owner, address newOwner)
    public
    onlyWallet
    ownerExists(owner)
    ownerDoesNotExist(newOwner)
    notNull(newOwner)
    {
        for (uint i = 0; i < owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param _required Number of required confirmations.
    function changeRequirement(uint _required)
    public
    onlyWallet
    validRequirement(owners.length, _required)
    {
        required = _required;
        emit RequirementChange(_required);
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param fee amount of token or ether to transfer to fee collector
    /// @param data Transaction data payload.
    /// @return transactionId - Returns transaction ID.
    function submitTransaction(address destination, uint value, uint nonce, address token, uint fee, uint amount, bytes memory data)
    public
    ownerExists(msg.sender)
    notSubmitted(token, nonce)
    isNotUnderflowingBalance(token, amount)
    returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, nonce, token, fee, amount, data);
        secretTxNonce[token] = nonce;

        confirmTransaction(transactionId);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
    public
    ownerExists(msg.sender)
    transactionExists(transactionId)
    notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];

            txn.executed = true;

            require(gasleft() >= 3000);

            if (external_call(txn.destination, txn.value, txn.data, gasleft() - 3000))
                emit Withdraw(transactionId);
            else {
                emit WithdrawFailure(transactionId);
            }
        }
    }

    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function external_call(address destination, uint value, bytes memory data, uint256 txGas)
        internal
        returns (bool success) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := call(
                txGas,
                destination,
                value,
                add(data, 0x20),     // First 32 bytes are the padded length of data, so exclude that
                mload(data),       // Size of the input (in bytes) - this is what fixes the padding problem
                0,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
        return success;
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint transactionId)
    public
    view
    returns (bool)
    {
        uint count = 0;
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
        return false;
    }

    /*
     * Internal functions
     */
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return transactionId - Returns transaction ID.
    function addTransaction(address destination, uint value, uint nonce, address token, uint fee, uint amount, bytes memory data)
    internal
    notNull(destination)
    returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination : destination,
            value : value,
            data : data,
            executed : false,
            nonce : nonce,
            token : token,
            amount: amount,
            fee: fee
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return count - Number of confirmations.
    function getConfirmationCount(uint transactionId)
    public
    view
    returns (uint count)
    {
        for (uint i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return count - Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
    public
    view
    returns (uint count)
    {
        for (uint i = 0; i < transactionCount; i++)
            if (pending && !transactions[i].executed
            || executed && transactions[i].executed)
                count += 1;
    }

    /// @dev Returns list of owners.
    /// @return List of owner addresses.
    function getOwners()
    public
    view
    returns (address[] memory)
    {
        return owners;
    }

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return _confirmations - Returns array of owner addresses.
    function getConfirmations(uint transactionId)
    public
    view
    returns (address[] memory _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

    /// @dev Returns list of transaction IDs in defined range.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return _transactionIds - Returns array of transaction IDs.
    function getTransactionIds(uint from, uint to, bool pending, bool executed)
    public
    view
    returns (uint[] memory _transactionIds)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i = 0; i < transactionCount; i++)
            if (pending && !transactions[i].executed
            || executed && transactions[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i = from; i < to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}