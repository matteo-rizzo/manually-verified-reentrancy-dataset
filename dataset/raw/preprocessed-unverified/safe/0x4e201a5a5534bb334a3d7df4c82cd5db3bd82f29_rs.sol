/**

 *Submitted for verification at Etherscan.io on 2018-08-29

*/



pragma solidity 0.4.24;







contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;





  /**

   * @dev Modifier to make a function callable only when the contract is not paused.

   */

  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  /**

   * @dev Modifier to make a function callable only when the contract is paused.

   */

  modifier whenPaused() {

    require(paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() public onlyOwner whenNotPaused {

    paused = true;

    emit Pause();

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() public onlyOwner whenPaused {

    paused = false;

    emit Unpause();

  }

}





/**

 * @title SchedulerInterface

 * @dev The base contract that the higher contracts: BaseScheduler, BlockScheduler and TimestampScheduler all inherit from.

 */

contract SchedulerInterface {

    function schedule(address _toAddress, bytes _callData, uint[8] _uintArgs)

        public payable returns (address);

    function computeEndowment(uint _bounty, uint _fee, uint _callGas, uint _callValue, uint _gasPrice)

        public view returns (uint);

}



contract TransactionRequestInterface {

    

    // Primary actions

    function execute() public returns (bool);

    function cancel() public returns (bool);

    function claim() public payable returns (bool);



    // Proxy function

    function proxy(address recipient, bytes callData) public payable returns (bool);



    // Data accessors

    function requestData() public view returns (address[6], bool[3], uint[15], uint8[1]);

    function callData() public view returns (bytes);



    // Pull mechanisms for payments.

    function refundClaimDeposit() public returns (bool);

    function sendFee() public returns (bool);

    function sendBounty() public returns (bool);

    function sendOwnerEther() public returns (bool);

    function sendOwnerEther(address recipient) public returns (bool);

}



contract TransactionRequestCore is TransactionRequestInterface {

    using RequestLib for RequestLib.Request;

    using RequestScheduleLib for RequestScheduleLib.ExecutionWindow;



    RequestLib.Request txnRequest;

    bool private initialized = false;



    /*

     *  addressArgs[0] - meta.createdBy

     *  addressArgs[1] - meta.owner

     *  addressArgs[2] - paymentData.feeRecipient

     *  addressArgs[3] - txnData.toAddress

     *

     *  uintArgs[0]  - paymentData.fee

     *  uintArgs[1]  - paymentData.bounty

     *  uintArgs[2]  - schedule.claimWindowSize

     *  uintArgs[3]  - schedule.freezePeriod

     *  uintArgs[4]  - schedule.reservedWindowSize

     *  uintArgs[5]  - schedule.temporalUnit

     *  uintArgs[6]  - schedule.windowSize

     *  uintArgs[7]  - schedule.windowStart

     *  uintArgs[8]  - txnData.callGas

     *  uintArgs[9]  - txnData.callValue

     *  uintArgs[10] - txnData.gasPrice

     *  uintArgs[11] - claimData.requiredDeposit

     */

    function initialize(

        address[4]  addressArgs,

        uint[12]    uintArgs,

        bytes       callData

    )

        public payable

    {

        require(!initialized);



        txnRequest.initialize(addressArgs, uintArgs, callData);

        initialized = true;

    }



    /*

     *  Allow receiving ether.  This is needed if there is a large increase in

     *  network gas prices.

     */

    function() public payable {}



    /*

     *  Actions

     */

    function execute() public returns (bool) {

        return txnRequest.execute();

    }



    function cancel() public returns (bool) {

        return txnRequest.cancel();

    }



    function claim() public payable returns (bool) {

        return txnRequest.claim();

    }



    /*

     *  Data accessor functions.

     */



    // Declaring this function `view`, although it creates a compiler warning, is

    // necessary to return values from it.

    function requestData()

        public view returns (address[6], bool[3], uint[15], uint8[1])

    {

        return txnRequest.serialize();

    }



    function callData()

        public view returns (bytes data)

    {

        data = txnRequest.txnData.callData;

    }



    /**

     * @dev Proxy a call from this contract to another contract.

     * This function is only callable by the scheduler and can only

     * be called after the execution window ends. One purpose is to

     * provide a way to transfer assets held by this contract somewhere else.

     * For example, if this request was used to buy tokens during an ICO,

     * it would become the owner of the tokens and this function would need

     * to be called with the encoded data to the token contract to transfer

     * the assets somewhere else. */

    function proxy(address _to, bytes _data)

        public payable returns (bool success)

    {

        require(txnRequest.meta.owner == msg.sender && txnRequest.schedule.isAfterWindow());

        

        /* solium-disable-next-line */

        return _to.call.value(msg.value)(_data);

    }



    /*

     *  Pull based payment functions.

     */

    function refundClaimDeposit() public returns (bool) {

        txnRequest.refundClaimDeposit();

    }



    function sendFee() public returns (bool) {

        return txnRequest.sendFee();

    }



    function sendBounty() public returns (bool) {

        return txnRequest.sendBounty();

    }



    function sendOwnerEther() public returns (bool) {

        return txnRequest.sendOwnerEther();

    }



    function sendOwnerEther(address recipient) public returns (bool) {

        return txnRequest.sendOwnerEther(recipient);

    }



    /** Event duplication from RequestLib.sol. This is so

     *  that these events are available on the contracts ABI.*/

    event Aborted(uint8 reason);

    event Cancelled(uint rewardPayment, uint measuredGasConsumption);

    event Claimed();

    event Executed(uint bounty, uint fee, uint measuredGasConsumption);

}



contract RequestFactoryInterface {

    event RequestCreated(address request, address indexed owner, int indexed bucket, uint[12] params);



    function createRequest(address[3] addressArgs, uint[12] uintArgs, bytes callData) public payable returns (address);

    function createValidatedRequest(address[3] addressArgs, uint[12] uintArgs, bytes callData) public payable returns (address);

    function validateRequestParams(address[3] addressArgs, uint[12] uintArgs, uint endowment) public view returns (bool[6]);

    function isKnownRequest(address _address) public view returns (bool);

}



contract TransactionRecorder {

    address owner;



    bool public wasCalled;

    uint public lastCallValue;

    address public lastCaller;

    bytes public lastCallData = "";

    uint public lastCallGas;



    function TransactionRecorder()  public {

        owner = msg.sender;

    }



    function() payable  public {

        lastCallGas = gasleft();

        lastCallData = msg.data;

        lastCaller = msg.sender;

        lastCallValue = msg.value;

        wasCalled = true;

    }



    function __reset__() public {

        lastCallGas = 0;

        lastCallData = "";

        lastCaller = 0x0;

        lastCallValue = 0;

        wasCalled = false;

    }



    function kill() public {

        require(msg.sender == owner);

        selfdestruct(owner);

    }

}



contract Proxy {

    SchedulerInterface public scheduler;

    address public receipient; 

    address public scheduledTransaction;

    address public owner;



    function Proxy(address _scheduler, address _receipient, uint _payout, uint _gasPrice, uint _delay) public payable {

        scheduler = SchedulerInterface(_scheduler);

        receipient = _receipient;

        owner = msg.sender;



        scheduledTransaction = scheduler.schedule.value(msg.value)(

            this,              // toAddress

            "",                     // callData

            [

                2000000,            // The amount of gas to be sent with the transaction.

                _payout,                  // The amount of wei to be sent.

                255,                // The size of the execution window.

                block.number + _delay,        // The start of the execution window.

                _gasPrice,    // The gasprice for the transaction

                12345 wei,          // The fee included in the transaction.

                224455 wei,         // The bounty that awards the executor of the transaction.

                20000 wei           // The required amount of wei the claimer must send as deposit.

            ]

        );

    }



    function () public payable {

        if (msg.value > 0) {

            receipient.transfer(msg.value);

        }

    }



    function sendOwnerEther(address _receipient) public {

        if (msg.sender == owner && _receipient != 0x0) {

            TransactionRequestInterface(scheduledTransaction).sendOwnerEther(_receipient);

        }   

    }

}



/// Super simple token contract that moves funds into the owner account on creation and

/// only exposes an API to be used for `test/proxy.js`

contract SimpleToken {



    address public owner;



    mapping(address => uint) balances;



    function SimpleToken (uint _initialSupply) public {

        owner = msg.sender;

        balances[owner] = _initialSupply;

    }



    function transfer (address _to, uint _amount)

        public returns (bool success)

    {

        require(balances[msg.sender] > _amount);

        balances[msg.sender] -= _amount;

        balances[_to] += _amount;

        success = true;

    }



    uint public constant rate = 30;



    function buyTokens()

        public payable returns (bool success)

    {

        require(msg.value > 0);

        balances[msg.sender] += msg.value * rate;

        success = true;

    }



    function balanceOf (address _who)

        public view returns (uint balance)

    {

        balance = balances[_who];

    }

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title BaseScheduler

 * @dev The foundational contract which provides the API for scheduling future transactions on the Alarm Client.

 */

contract BaseScheduler is SchedulerInterface {

    // The RequestFactory which produces requests for this scheduler.

    address public factoryAddress;



    // The TemporalUnit (Block or Timestamp) for this scheduler.

    RequestScheduleLib.TemporalUnit public temporalUnit;



    // The address which will be sent the fee payments.

    address public feeRecipient;



    /*

     * @dev Fallback function to be able to receive ether. This can occur

     *  legitimately when scheduling fails due to a validation error.

     */

    function() public payable {}



    /// Event that bubbles up the address of new requests made with this scheduler.

    event NewRequest(address request);



    /**

     * @dev Schedules a new TransactionRequest using the 'full' parameters.

     * @param _toAddress The address destination of the transaction.

     * @param _callData The bytecode that will be included with the transaction.

     * @param _uintArgs [0] The callGas of the transaction.

     * @param _uintArgs [1] The value of ether to be sent with the transaction.

     * @param _uintArgs [2] The size of the execution window of the transaction.

     * @param _uintArgs [3] The (block or timestamp) of when the execution window starts.

     * @param _uintArgs [4] The gasPrice which will be used to execute this transaction.

     * @param _uintArgs [5] The fee attached to this transaction.

     * @param _uintArgs [6] The bounty attached to this transaction.

     * @param _uintArgs [7] The deposit required to claim this transaction.

     * @return The address of the new TransactionRequest.   

     */ 

    function schedule (

        address   _toAddress,

        bytes     _callData,

        uint[8]   _uintArgs

    )

        public payable returns (address newRequest)

    {

        RequestFactoryInterface factory = RequestFactoryInterface(factoryAddress);



        uint endowment = computeEndowment(

            _uintArgs[6], //bounty

            _uintArgs[5], //fee

            _uintArgs[0], //callGas

            _uintArgs[1], //callValue

            _uintArgs[4]  //gasPrice

        );



        require(msg.value >= endowment);



        if (temporalUnit == RequestScheduleLib.TemporalUnit.Blocks) {

            newRequest = factory.createValidatedRequest.value(msg.value)(

                [

                    msg.sender,                 // meta.owner

                    feeRecipient,               // paymentData.feeRecipient

                    _toAddress                  // txnData.toAddress

                ],

                [

                    _uintArgs[5],               // paymentData.fee

                    _uintArgs[6],               // paymentData.bounty

                    255,                        // scheduler.claimWindowSize

                    10,                         // scheduler.freezePeriod

                    16,                         // scheduler.reservedWindowSize

                    uint(temporalUnit),         // scheduler.temporalUnit (1: block, 2: timestamp)

                    _uintArgs[2],               // scheduler.windowSize

                    _uintArgs[3],               // scheduler.windowStart

                    _uintArgs[0],               // txnData.callGas

                    _uintArgs[1],               // txnData.callValue

                    _uintArgs[4],               // txnData.gasPrice

                    _uintArgs[7]                // claimData.requiredDeposit

                ],

                _callData

            );

        } else if (temporalUnit == RequestScheduleLib.TemporalUnit.Timestamp) {

            newRequest = factory.createValidatedRequest.value(msg.value)(

                [

                    msg.sender,                 // meta.owner

                    feeRecipient,               // paymentData.feeRecipient

                    _toAddress                  // txnData.toAddress

                ],

                [

                    _uintArgs[5],               // paymentData.fee

                    _uintArgs[6],               // paymentData.bounty

                    60 minutes,                 // scheduler.claimWindowSize

                    3 minutes,                  // scheduler.freezePeriod

                    5 minutes,                  // scheduler.reservedWindowSize

                    uint(temporalUnit),         // scheduler.temporalUnit (1: block, 2: timestamp)

                    _uintArgs[2],               // scheduler.windowSize

                    _uintArgs[3],               // scheduler.windowStart

                    _uintArgs[0],               // txnData.callGas

                    _uintArgs[1],               // txnData.callValue

                    _uintArgs[4],               // txnData.gasPrice

                    _uintArgs[7]                // claimData.requiredDeposit

                ],

                _callData

            );

        } else {

            // unsupported temporal unit

            revert();

        }



        require(newRequest != 0x0);

        emit NewRequest(newRequest);

        return newRequest;

    }



    function computeEndowment(

        uint _bounty,

        uint _fee,

        uint _callGas,

        uint _callValue,

        uint _gasPrice

    )

        public view returns (uint)

    {

        return PaymentLib.computeEndowment(

            _bounty,

            _fee,

            _callGas,

            _callValue,

            _gasPrice,

            RequestLib.getEXECUTION_GAS_OVERHEAD()

        );

    }

}



/**

 * @title BlockScheduler

 * @dev Top-level contract that exposes the API to the Ethereum Alarm Clock service and passes in blocks as temporal unit.

 */

contract BlockScheduler is BaseScheduler {



    /**

     * @dev Constructor

     * @param _factoryAddress Address of the RequestFactory which creates requests for this scheduler.

     */

    constructor(address _factoryAddress, address _feeRecipient) public {

        require(_factoryAddress != 0x0);



        // Default temporal unit is block number.

        temporalUnit = RequestScheduleLib.TemporalUnit.Blocks;



        // Sets the factoryAddress variable found in BaseScheduler contract.

        factoryAddress = _factoryAddress;



        // Sets the fee recipient for these schedulers.

        feeRecipient = _feeRecipient;

    }

}



/**

 * @title TimestampScheduler

 * @dev Top-level contract that exposes the API to the Ethereum Alarm Clock service and passes in timestamp as temporal unit.

 */

contract TimestampScheduler is BaseScheduler {



    /**

     * @dev Constructor

     * @param _factoryAddress Address of the RequestFactory which creates requests for this scheduler.

     */

    constructor(address _factoryAddress, address _feeRecipient) public {

        require(_factoryAddress != 0x0);



        // Default temporal unit is timestamp.

        temporalUnit = RequestScheduleLib.TemporalUnit.Timestamp;



        // Sets the factoryAddress variable found in BaseScheduler contract.

        factoryAddress = _factoryAddress;



        // Sets the fee recipient for these schedulers.

        feeRecipient = _feeRecipient;

    }

}



/// Truffle-specific contract (Not a part of the EAC)



contract Migrations {

    address public owner;



    uint public last_completed_migration;



    modifier restricted() {

        if (msg.sender == owner) {

            _;

        }

    }



    function Migrations()  public {

        owner = msg.sender;

    }



    function setCompleted(uint completed) restricted  public {

        last_completed_migration = completed;

    }



    function upgrade(address new_address) restricted  public {

        Migrations upgraded = Migrations(new_address);

        upgraded.setCompleted(last_completed_migration);

    }

}



/**

 * @title ExecutionLib

 * @dev Contains the logic for executing a scheduled transaction.

 */









/**

 * @title RequestMetaLib

 * @dev Small library holding all the metadata about a TransactionRequest.

 */









/**

 * @title RequestScheduleLib

 * @dev Library containing the logic for request scheduling.

 */











/**

 * Library containing the functionality for the bounty and fee payments.

 * - Bounty payments are the reward paid to the executing agent of transaction

 * requests.

 * - Fee payments are the cost of using a Scheduler to make transactions. It is 

 * a way for developers to monetize their work on the EAC.

 */





/**

 * @title IterTools

 * @dev Utility library that iterates through a boolean array of length 6.

 */





/*

The MIT License (MIT)



Copyright (c) 2018 Murray Software, LLC.



Permission is hereby granted, free of charge, to any person obtaining

a copy of this software and associated documentation files (the

"Software"), to deal in the Software without restriction, including

without limitation the rights to use, copy, modify, merge, publish,

distribute, sublicense, and/or sell copies of the Software, and to

permit persons to whom the Software is furnished to do so, subject to

the following conditions:



The above copyright notice and this permission notice shall be included

in all copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS

OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF

MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY

CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,

TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE

SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

//solhint-disable max-line-length

//solhint-disable no-inline-assembly



contract CloneFactory {



  event CloneCreated(address indexed target, address clone);



  function createClone(address target) internal returns (address result) {

    bytes memory clone = hex"600034603b57603080600f833981f36000368180378080368173bebebebebebebebebebebebebebebebebebebebe5af43d82803e15602c573d90f35b3d90fd";

    bytes20 targetBytes = bytes20(target);

    for (uint i = 0; i < 20; i++) {

      clone[26 + i] = targetBytes[i];

    }

    assembly {

      let len := mload(clone)

      let data := add(clone, 0x20)

      result := create(0, data, len)

    }

  }

}



/// Example of using the Scheduler from a smart contract to delay a payment.

contract DelayedPayment {



    SchedulerInterface public scheduler;

    

    address recipient;

    address owner;

    address public payment;



    uint lockedUntil;

    uint value;

    uint twentyGwei = 20000000000 wei;



    constructor(

        address _scheduler,

        uint    _numBlocks,

        address _recipient,

        uint _value

    )  public payable {

        scheduler = SchedulerInterface(_scheduler);

        lockedUntil = block.number + _numBlocks;

        recipient = _recipient;

        owner = msg.sender;

        value = _value;

   

        uint endowment = scheduler.computeEndowment(

            twentyGwei,

            twentyGwei,

            200000,

            0,

            twentyGwei

        );



        payment = scheduler.schedule.value(endowment)( // 0.1 ether is to pay for gas, bounty and fee

            this,                   // send to self

            "",                     // and trigger fallback function

            [

                200000,             // The amount of gas to be sent with the transaction.

                0,                  // The amount of wei to be sent.

                255,                // The size of the execution window.

                lockedUntil,        // The start of the execution window.

                twentyGwei,    // The gasprice for the transaction (aka 20 gwei)

                twentyGwei,    // The fee included in the transaction.

                twentyGwei,         // The bounty that awards the executor of the transaction.

                twentyGwei * 2     // The required amount of wei the claimer must send as deposit.

            ]

        );



        assert(address(this).balance >= value);

    }



    function () public payable {

        if (msg.value > 0) { //this handles recieving remaining funds sent while scheduling (0.1 ether)

            return;

        } else if (address(this).balance > 0) {

            payout();

        } else {

            revert();

        }

    }



    function payout()

        public returns (bool)

    {

        require(block.number >= lockedUntil);

        

        recipient.transfer(value);

        return true;

    }



    function collectRemaining()

        public returns (bool) 

    {

        owner.transfer(address(this).balance);

    }

}



/// Example of using the Scheduler from a smart contract to delay a payment.

contract RecurringPayment {

    SchedulerInterface public scheduler;

    

    uint paymentInterval;

    uint paymentValue;

    uint lockedUntil;



    address recipient;

    address public currentScheduledTransaction;



    event PaymentScheduled(address indexed scheduledTransaction, address recipient, uint value);

    event PaymentExecuted(address indexed scheduledTransaction, address recipient, uint value);



    function RecurringPayment(

        address _scheduler,

        uint _paymentInterval,

        uint _paymentValue,

        address _recipient

    )  public payable {

        scheduler = SchedulerInterface(_scheduler);

        paymentInterval = _paymentInterval;

        recipient = _recipient;

        paymentValue = _paymentValue;



        schedule();

    }



    function ()

        public payable 

    {

        if (msg.value > 0) { //this handles recieving remaining funds sent while scheduling (0.1 ether)

            return;

        } 

        

        process();

    }



    function process() public returns (bool) {

        payout();

        schedule();

    }



    function payout()

        private returns (bool)

    {

        require(block.number >= lockedUntil);

        require(address(this).balance >= paymentValue);

        

        recipient.transfer(paymentValue);



        emit PaymentExecuted(currentScheduledTransaction, recipient, paymentValue);

        return true;

    }



    function schedule() 

        private returns (bool)

    {

        lockedUntil = block.number + paymentInterval;



        currentScheduledTransaction = scheduler.schedule.value(0.1 ether)( // 0.1 ether is to pay for gas, bounty and fee

            this,                   // send to self

            "",                     // and trigger fallback function

            [

                1000000,            // The amount of gas to be sent with the transaction. Accounts for payout + new contract deployment

                0,                  // The amount of wei to be sent.

                255,                // The size of the execution window.

                lockedUntil,        // The start of the execution window.

                20000000000 wei,    // The gasprice for the transaction (aka 20 gwei)

                20000000000 wei,    // The fee included in the transaction.

                20000000000 wei,         // The bounty that awards the executor of the transaction.

                30000000000 wei     // The required amount of wei the claimer must send as deposit.

            ]

        );



        emit PaymentScheduled(currentScheduledTransaction, recipient, paymentValue);

    }

}



/**

 * @title RequestFactory

 * @dev Contract which will produce new TransactionRequests.

 */

contract RequestFactory is RequestFactoryInterface, CloneFactory, Pausable {

    using IterTools for bool[6];



    TransactionRequestCore public transactionRequestCore;



    uint constant public BLOCKS_BUCKET_SIZE = 240; //~1h

    uint constant public TIMESTAMP_BUCKET_SIZE = 3600; //1h



    constructor(

        address _transactionRequestCore

    ) 

        public 

    {

        require(_transactionRequestCore != 0x0);



        transactionRequestCore = TransactionRequestCore(_transactionRequestCore);

    }



    /**

     * @dev The lowest level interface for creating a transaction request.

     *

     * @param _addressArgs [0] -  meta.owner

     * @param _addressArgs [1] -  paymentData.feeRecipient

     * @param _addressArgs [2] -  txnData.toAddress

     * @param _uintArgs [0]    -  paymentData.fee

     * @param _uintArgs [1]    -  paymentData.bounty

     * @param _uintArgs [2]    -  schedule.claimWindowSize

     * @param _uintArgs [3]    -  schedule.freezePeriod

     * @param _uintArgs [4]    -  schedule.reservedWindowSize

     * @param _uintArgs [5]    -  schedule.temporalUnit

     * @param _uintArgs [6]    -  schedule.windowSize

     * @param _uintArgs [7]    -  schedule.windowStart

     * @param _uintArgs [8]    -  txnData.callGas

     * @param _uintArgs [9]    -  txnData.callValue

     * @param _uintArgs [10]   -  txnData.gasPrice

     * @param _uintArgs [11]   -  claimData.requiredDeposit

     * @param _callData        -  The call data

     */

    function createRequest(

        address[3]  _addressArgs,

        uint[12]    _uintArgs,

        bytes       _callData

    )

        whenNotPaused

        public payable returns (address)

    {

        // Create a new transaction request clone from transactionRequestCore.

        address transactionRequest = createClone(transactionRequestCore);



        // Call initialize on the transaction request clone.

        TransactionRequestCore(transactionRequest).initialize.value(msg.value)(

            [

                msg.sender,       // Created by

                _addressArgs[0],  // meta.owner

                _addressArgs[1],  // paymentData.feeRecipient

                _addressArgs[2]   // txnData.toAddress

            ],

            _uintArgs,            //uint[12]

            _callData

        );



        // Track the address locally

        requests[transactionRequest] = true;



        // Log the creation.

        emit RequestCreated(

            transactionRequest,

            _addressArgs[0],

            getBucket(_uintArgs[7], RequestScheduleLib.TemporalUnit(_uintArgs[5])),

            _uintArgs

        );



        return transactionRequest;

    }



    /**

     *  The same as createRequest except that it requires validation prior to

     *  creation.

     *

     *  Parameters are the same as `createRequest`

     */

    function createValidatedRequest(

        address[3]  _addressArgs,

        uint[12]    _uintArgs,

        bytes       _callData

    )

        public payable returns (address)

    {

        bool[6] memory isValid = validateRequestParams(

            _addressArgs,

            _uintArgs,

            msg.value

        );



        if (!isValid.all()) {

            if (!isValid[0]) {

                emit ValidationError(uint8(Errors.InsufficientEndowment));

            }

            if (!isValid[1]) {

                emit ValidationError(uint8(Errors.ReservedWindowBiggerThanExecutionWindow));

            }

            if (!isValid[2]) {

                emit ValidationError(uint8(Errors.InvalidTemporalUnit));

            }

            if (!isValid[3]) {

                emit ValidationError(uint8(Errors.ExecutionWindowTooSoon));

            }

            if (!isValid[4]) {

                emit ValidationError(uint8(Errors.CallGasTooHigh));

            }

            if (!isValid[5]) {

                emit ValidationError(uint8(Errors.EmptyToAddress));

            }



            // Try to return the ether sent with the message

            msg.sender.transfer(msg.value);

            

            return 0x0;

        }



        return createRequest(_addressArgs, _uintArgs, _callData);

    }



    /// ----------------------------

    /// Internal

    /// ----------------------------



    /*

     *  @dev The enum for launching `ValidationError` events and mapping them to an error.

     */

    enum Errors {

        InsufficientEndowment,

        ReservedWindowBiggerThanExecutionWindow,

        InvalidTemporalUnit,

        ExecutionWindowTooSoon,

        CallGasTooHigh,

        EmptyToAddress

    }



    event ValidationError(uint8 error);



    /*

     * @dev Validate the constructor arguments for either `createRequest` or `createValidatedRequest`.

     */

    function validateRequestParams(

        address[3]  _addressArgs,

        uint[12]    _uintArgs,

        uint        _endowment

    )

        public view returns (bool[6])

    {

        return RequestLib.validate(

            [

                msg.sender,      // meta.createdBy

                _addressArgs[0],  // meta.owner

                _addressArgs[1],  // paymentData.feeRecipient

                _addressArgs[2]   // txnData.toAddress

            ],

            _uintArgs,

            _endowment

        );

    }



    /// Mapping to hold known requests.

    mapping (address => bool) requests;



    function isKnownRequest(address _address)

        public view returns (bool isKnown)

    {

        return requests[_address];

    }



    function getBucket(uint windowStart, RequestScheduleLib.TemporalUnit unit)

        public pure returns(int)

    {

        uint bucketSize;

        /* since we want to handle both blocks and timestamps

            and do not want to get into case where buckets overlaps

            block buckets are going to be negative ints

            timestamp buckets are going to be positive ints

            we'll overflow after 2**255-1 blocks instead of 2**256-1 since we encoding this on int256

        */

        int sign;



        if (unit == RequestScheduleLib.TemporalUnit.Blocks) {

            bucketSize = BLOCKS_BUCKET_SIZE;

            sign = -1;

        } else if (unit == RequestScheduleLib.TemporalUnit.Timestamp) {

            bucketSize = TIMESTAMP_BUCKET_SIZE;

            sign = 1;

        } else {

            revert();

        }

        return sign * int(windowStart - (windowStart % bucketSize));

    }

}