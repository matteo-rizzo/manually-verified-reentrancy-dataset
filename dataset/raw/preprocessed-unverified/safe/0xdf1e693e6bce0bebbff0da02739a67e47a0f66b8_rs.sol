/**

 *Submitted for verification at Etherscan.io on 2018-11-13

*/



pragma solidity ^0.4.24;







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





















/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







/**

 * @title DelegatedTokenLogic empty token

 */

contract DelegatedTokenLogic is Ownable, DelegatedERC20 {

    using SafeMath for uint256;



    address public capTables;

    address public front;



    /**

    * @Dev Index of this security in the global cap table store.

    */

    uint256 public index;



    mapping (address => mapping (address => uint256)) internal allowed;



    modifier onlyFront() {

        require(msg.sender == front, "this method is reserved for the token front");

        _;

    }



    /**

    * @dev Set the fronting token.

    */

    function setFront(address _front) public onlyOwner {

        front = _front;

    }



    /**

    * @dev total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return ICapTables(capTables).totalSupply(index);

    }



    /**

    * @dev transfer token for a specified address

    * @param _to The address to transfer to.

    * @param _value The amount to be transferred.

    */

    function transfer(address _to, uint256 _value, address sender) 

        public 

        onlyFront 

        returns (bool) 

    {

        require(_to != address(0), "tokens MUST NOT be transferred to the zero address");

        ICapTables(capTables).transfer(index, sender, _to, _value);

        return true;

    }



    /**

    * @dev Gets the balance of the specified address.

    * @param _owner The address to query the the balance of.

    * @return An uint256 representing the amount owned by the passed address.

    */

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return ICapTables(capTables).balanceOf(index, _owner);

    }

    /**

    * @dev Transfer tokens from one address to another

    * @param _from address The address which you want to send tokens from

    * @param _to address The address which you want to transfer to

    * @param _value uint256 the amount of tokens to be transferred

    */

    function transferFrom(address _from, address _to, uint256 _value, address sender) 

        public 

        onlyFront

        returns (bool) 

    {

        require(_to != address(0), "tokens MUST NOT go to the zero address");

        require(_value <= allowed[_from][sender], "transfer value MUST NOT exceed allowance");



        ICapTables(capTables).transfer(index, _from, _to, _value);

        allowed[_from][sender] = allowed[_from][sender].sub(_value);

        return true;

    }



    /**

    * @dev Approve the passed address to spend the specified amount of tokens on behalf of sender.

    *

    * Beware that changing an allowance with this method brings the risk that someone may use both the old

    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this

    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:

    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

    * @param _spender The address which will spend the funds.

    * @param _value The amount of tokens to be spent.

    */

    function approve(address _spender, uint256 _value, address sender) 

        public 

        onlyFront

        returns (bool) 

    {

        allowed[sender][_spender] = _value;

        return true;

    }



    /**

    * @dev Function to check the amount of tokens that an owner allowed to a spender.

    * @param _owner address The address which owns the funds.

    * @param _spender address The address which will spend the funds.

    * @return A uint256 specifying the amount of tokens still available for the spender.

    */

    function allowance(address _owner, address _spender) public view returns (uint256) {

        return allowed[_owner][_spender];

    }



}





/** 

 * @title IndexConsumer

 * @dev This contract adds an autoincrementing index to contracts. 

 */

contract IndexConsumer {



    using SafeMath for uint256;



    /** The index */

    uint256 private freshIndex = 0;



    /** Fetch the next index */

    function nextIndex() internal returns (uint256) {

        uint256 theIndex = freshIndex;

        freshIndex = freshIndex.add(1);

        return theIndex;

    }



}









/**

 * One method for implementing a permissioned token is to appoint some

 * authority which must decide whether to approve or refuse trades.  This

 * contract implements this functionality.  

 */



contract SimplifiedLogic is IndexConsumer, DelegatedTokenLogic {



    string public name = "Test Fox Token";

    string public symbol = "TFT";





    enum TransferStatus {

        Unused,

        Active,

        Resolved

    }



    /** Data associated to a (request to) transfer */

    struct TokenTransfer {

        address src;

        address dest;

        uint256 amount;

        address spender;

        TransferStatus status;

    }

    

    /** 

     * The resolver determines whether a transfer ought to proceed and

     * executes or nulls it. 

     */

    address public resolver;



    /** 

     * Transfer requests are generated when a token owner (or delegate) wants

     * to transfer some tokens.  They must be either executed or nulled by the

     * resolver. 

     */

    mapping(uint256 => TokenTransfer) public transferRequests;



    /**

     * The contract may be deactivated during a migration.

     */

    bool public contractActive = true;

    

    /** Represents that a user intends to make a transfer. */

    event TransferRequest(

        uint256 indexed index,

        address src,

        address dest,

        uint256 amount,

        address spender

    );

    

    /** Represents the resolver's decision about the transfer. */

    event TransferResult(

        uint256 indexed index,

        uint16 code

    );

        

    /** 

     * Methods that are only safe when the contract is in the active state.

     */

    modifier onlyActive() {

        require(contractActive, "the contract MUST be active");

        _;

    }

    

    /**

     * Forbidden to all but the resolver.

     */

    modifier onlyResolver() {

        require(msg.sender == resolver, "this method is reserved for the designated resolver");

        _;

    }



    constructor(

        uint256 _index,

        address _capTables,

        address _owner,

        address _resolver

    ) public {

        index = _index;

        capTables = _capTables;

        owner = _owner;

        resolver = _resolver;

    }



    function transfer(address _dest, uint256 _amount, address _sender) 

        public 

        onlyFront 

        onlyActive 

        returns (bool) 

    {

        uint256 txfrIndex = nextIndex();

        transferRequests[txfrIndex] = TokenTransfer(

            _sender, 

            _dest, 

            _amount, 

            _sender, 

            TransferStatus.Active

        );

        emit TransferRequest(

            txfrIndex,

            _sender,

            _dest,

            _amount,

            _sender

        );

        return false; // The transfer has not taken place yet

    }



    function transferFrom(address _src, address _dest, uint256 _amount, address _sender) 

        public 

        onlyFront 

        onlyActive 

        returns (bool)

    {

        require(_amount <= allowed[_src][_sender], "the transfer amount MUST NOT exceed the allowance");

        uint txfrIndex = nextIndex();

        transferRequests[txfrIndex] = TokenTransfer(

            _src, 

            _dest, 

            _amount, 

            _sender, 

            TransferStatus.Active

        );

        emit TransferRequest(

            txfrIndex,

            _src,

            _dest,

            _amount,

            _sender

        );

        return false; // The transfer has not taken place yet

    }



    function setResolver(address _resolver)

        public

        onlyOwner

    {

        resolver = _resolver;

    }



    function resolve(uint256 _txfrIndex, uint16 _code) 

        public 

        onlyResolver

        returns (bool result)

    {

        require(transferRequests[_txfrIndex].status == TransferStatus.Active, "the transfer request MUST be active");

        TokenTransfer storage tfr = transferRequests[_txfrIndex];

        result = false;

        if (_code == 0) {

            result = true;

            if (tfr.spender == tfr.src) {

                // Vanilla transfer

                ICapTables(capTables).transfer(index, tfr.src, tfr.dest, tfr.amount);

            } else {

                // Requires an allowance

                ICapTables(capTables).transfer(index, tfr.src, tfr.dest, tfr.amount);

                allowed[tfr.src][tfr.spender] = allowed[tfr.src][tfr.spender].sub(tfr.amount);

            }

        } 

        transferRequests[_txfrIndex].status = TransferStatus.Resolved;

        emit TransferResult(_txfrIndex, _code);

    }



    function migrate(address newLogic) public onlyOwner {

        contractActive = false;

        ICapTables(capTables).migrate(index, newLogic);

    }



}