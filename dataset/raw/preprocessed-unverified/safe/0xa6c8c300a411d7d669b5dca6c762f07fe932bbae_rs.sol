/**
 *Submitted for verification at Etherscan.io on 2019-09-20
*/

pragma solidity 0.4.25;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract DetailedERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}





contract Managed is Ownable {
    mapping (address => bool) public managers;
    
    constructor(
        address _owner
    )
        public
        Ownable(_owner)
    {

    }

    modifier onlyManager () {
        require(isManager(), "Only managers may perform this action");
        _;
    }

    modifier onlyManagerOrOwner () {
        require(
            checkManagerStatus(msg.sender) || msg.sender == owner,
            "Only managers or owners may perform this action"
        );
        _;
    }

    function checkManagerStatus (address managerAddress) public view returns (bool) {
        return managers[managerAddress];
    }

    function isManager () public view returns (bool) {
        return checkManagerStatus(msg.sender);
    }

    function addManager (address managerAddress) public onlyOwner {
        managers[managerAddress] = true;
    }

    function removeManager (address managerAddress) public onlyOwner {
        managers[managerAddress] = false;
    }
}

contract ManagedWhitelist is Managed {
    mapping (address => bool) public sendAllowed;
    mapping (address => bool) public receiveAllowed;
    
    constructor(
        address _owner
    )
        public
        Managed(_owner)
    {

    }

    modifier onlySendAllowed {
        require(sendAllowed[msg.sender], "Sender is not whitelisted");
        _;
    }

    modifier onlyReceiveAllowed {
        require(receiveAllowed[msg.sender], "Recipient is not whitelisted");
        _;
    }

    function addToSendAllowed (address operator) public onlyManagerOrOwner {
        sendAllowed[operator] = true;
    }

    function addToReceiveAllowed (address operator) public onlyManagerOrOwner {
        receiveAllowed[operator] = true;
    }

    function addToBothSendAndReceiveAllowed (address operator) public onlyManagerOrOwner {
        addToSendAllowed(operator);
        addToReceiveAllowed(operator);
    }

    function removeFromSendAllowed (address operator) public onlyManagerOrOwner {
        sendAllowed[operator] = false;
    }

    function removeFromReceiveAllowed (address operator) public onlyManagerOrOwner {
        receiveAllowed[operator] = false;
    }

    function removeFromBothSendAndReceiveAllowed (address operator) public onlyManagerOrOwner {
        removeFromSendAllowed(operator);
        removeFromReceiveAllowed(operator);
    }
}











/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC1404 is ERC20 {
    /// @notice Detects if a transfer will be reverted and if so returns an appropriate reference code
    /// @param from Sending address
    /// @param to Receiving address
    /// @param value Amount of tokens being transferred
    /// @return Code by which to reference message for rejection reasoning
    /// @dev Overwrite with your custom transfer restriction logic
    function detectTransferRestriction (address from, address to, uint256 value) public view returns (uint8);

    /// @notice Returns a human-readable message for a given restriction code
    /// @param restrictionCode Identifier for looking up a message
    /// @return Text showing the restriction's reasoning
    /// @dev Overwrite with your custom message and restrictionCode handling
    function messageForTransferRestriction (uint8 restrictionCode) public view returns (string);
}













/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */




/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
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

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}




/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    constructor(address _owner) 
        public 
        Ownable(_owner) 
    {

    }

    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
    * @dev Function to stop minting new tokens.
    * @return True if the operation was successful.
    */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}




/** @title Token */
contract Token is DetailedERC20, MintableToken {

    /** @dev Constructor
      * @param _owner Token contract owner
      * @param _name Token name
      * @param _symbol Token symbol
      * @param _decimals number of decimals in the token(usually 18)
      */
    constructor(
        address _owner,
        string _name, 
        string _symbol, 
        uint8 _decimals
    )
        public
        MintableToken(_owner)
        DetailedERC20(_name, _symbol, _decimals)
    {

    }

    /** @dev Updates token name
      * @param _name New token name
      */
    function updateName(string _name) public onlyOwner {
        require(bytes(_name).length != 0);
        name = _name;
    }

    /** @dev Updates token symbol
      * @param _symbol New token name
      */
    function updateSymbol(string _symbol) public onlyOwner {
        require(bytes(_symbol).length != 0);
        symbol = _symbol;
    }
}


/// @title Extendable reference implementation for the ERC-1404 token
/// @dev Inherit from this contract to implement your own ERC-1404 token
/// Modified to use iComply's Detailed ERC20 Token
contract SimpleRestrictedToken is ERC1404, Token {
    uint8 public constant SUCCESS_CODE = 0;
    string public constant SUCCESS_MESSAGE = "SUCCESS";

    modifier notRestricted (address from, address to, uint256 value) {
        uint8 restrictionCode = detectTransferRestriction(from, to, value);
        require(restrictionCode == SUCCESS_CODE, messageForTransferRestriction(restrictionCode));
        _;
    }
    
    function detectTransferRestriction (address, address, uint256)
        public
        view
        returns (uint8 restrictionCode)
    {
        restrictionCode = SUCCESS_CODE;
    }
        
    function messageForTransferRestriction (uint8 restrictionCode)
        public
        view
        returns (string message)
    {
        if (restrictionCode == SUCCESS_CODE) {
            message = SUCCESS_MESSAGE;
        }
    }
    
    function transfer (address to, uint256 value)
        public
        notRestricted(msg.sender, to, value)
        returns (bool success)
    {
        success = super.transfer(to, value);
    }

    function transferFrom (address from, address to, uint256 value)
        public
        notRestricted(from, to, value)
        returns (bool success)
    {
        success = super.transferFrom(from, to, value);
    }
    
    constructor(
        address _owner,
        string _name, 
        string _symbol, 
        uint8 _decimals
    )
        public
        Token(_owner, _name, _symbol, _decimals)
    {

    }
}

/// @title ERC-1404 implementation with built-in message and code management solution
/// @dev Inherit from this contract to implement your own ERC-1404 token
contract MessagedERC1404 is SimpleRestrictedToken {
    using MessagesAndCodes for MessagesAndCodes.Data;
    MessagesAndCodes.Data internal messagesAndCodes;

    constructor(
        address _owner,
        string _name, 
        string _symbol, 
        uint8 _decimals
    )
        public
        SimpleRestrictedToken(_owner, _name, _symbol, _decimals)
    {
        messagesAndCodes.addMessage(SUCCESS_CODE, SUCCESS_MESSAGE);
    }

    function messageForTransferRestriction (uint8 restrictionCode)
        public
        view
        returns (string message)
    {
        message = messagesAndCodes.messages[restrictionCode];
    }
}


contract ManagedWhitelistToken is MessagedERC1404, ManagedWhitelist {
    uint8 public SEND_NOT_ALLOWED_CODE;
    uint8 public RECEIVE_NOT_ALLOWED_CODE;
    string public constant SEND_NOT_ALLOWED_ERROR = "ILLEGAL_TRANSFER_SENDING_ACCOUNT_NOT_WHITELISTED";
    string public constant RECEIVE_NOT_ALLOWED_ERROR = "ILLEGAL_TRANSFER_RECEIVING_ACCOUNT_NOT_WHITELISTED";
    
   constructor(
       address _owner,
       string _name,
       string _symbol,
       uint8 _decimals
   )
       public
       MessagedERC1404(_owner, _name, _symbol, _decimals)
       ManagedWhitelist(_owner)
   {
       SEND_NOT_ALLOWED_CODE = messagesAndCodes.autoAddMessage(SEND_NOT_ALLOWED_ERROR);
       RECEIVE_NOT_ALLOWED_CODE = messagesAndCodes.autoAddMessage(RECEIVE_NOT_ALLOWED_ERROR);
   }

    function detectTransferRestriction (address from, address to, uint value)
        public
        view
        returns (uint8 restrictionCode)
    {
        if (!sendAllowed[from]) {
            restrictionCode = SEND_NOT_ALLOWED_CODE; // sender address not whitelisted
        } else if (!receiveAllowed[to]) {
            restrictionCode = RECEIVE_NOT_ALLOWED_CODE; // receiver address not whitelisted
        } else {
            restrictionCode = SUCCESS_CODE; // successful transfer (required)
        }
    }
}