/**

 *Submitted for verification at Etherscan.io on 2018-11-07

*/



pragma solidity ^0.4.24;

















/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */















// Interface for logic governing write access to a Registry.

contract RegistryAccessManager {

  // Called when _admin attempts to write _value for _who's _attribute.

  // Returns true if the write is allowed to proceed.

  function confirmWrite(

    address _who,

    Attribute.AttributeType _attribute,

    address _admin

  )

    public returns (bool);

}





















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







/**

 * @title Claimable Ex

 * @dev Extension for the Claimable contract, where the ownership transfer can be canceled.

 */

contract ClaimableEx is Claimable {

  /*

   * @dev Cancels the ownership transfer.

   */

  function cancelOwnershipTransfer() onlyOwner public {

    pendingOwner = owner;

  }

}

















/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

























contract Registry is ClaimableEx {

  using BitManipulation for uint256;



  struct AttributeData {

    uint256 value;

  }



  // Stores arbitrary attributes for users. An example use case is an ERC20

  // token that requires its users to go through a KYC/AML check - in this case

  // a validator can set an account's "hasPassedKYC/AML" attribute to 1 to indicate

  // that account can use the token. This mapping stores that value (1, in the

  // example) as well as which validator last set the value and at what time,

  // so that e.g. the check can be renewed at appropriate intervals.

  mapping(address => AttributeData) private attributes;



  // The logic governing who is allowed to set what attributes is abstracted as

  // this accessManager, so that it may be replaced by the owner as needed.

  RegistryAccessManager public accessManager;



  event SetAttribute(

    address indexed who,

    Attribute.AttributeType attribute,

    bool enable,

    string notes,

    address indexed adminAddr

  );



  event SetManager(

    address indexed oldManager,

    address indexed newManager

  );



  constructor() public {

    accessManager = new DefaultRegistryAccessManager();

  }



  // Writes are allowed only if the accessManager approves

  function setAttribute(

    address _who,

    Attribute.AttributeType _attribute,

    string _notes

  )

    public

  {

    bool _canWrite = accessManager.confirmWrite(

      _who,

      _attribute,

      msg.sender

    );

    require(_canWrite);



    // Get value of previous attribute before setting new attribute

    uint256 _tempVal = attributes[_who].value;



    attributes[_who] = AttributeData(

      _tempVal.setBit(Attribute.toUint256(_attribute))

    );



    emit SetAttribute(_who, _attribute, true, _notes, msg.sender);

  }



  function clearAttribute(

    address _who,

    Attribute.AttributeType _attribute,

    string _notes

  )

    public

  {

    bool _canWrite = accessManager.confirmWrite(

      _who,

      _attribute,

      msg.sender

    );

    require(_canWrite);



    // Get value of previous attribute before setting new attribute

    uint256 _tempVal = attributes[_who].value;



    attributes[_who] = AttributeData(

      _tempVal.clearBit(Attribute.toUint256(_attribute))

    );



    emit SetAttribute(_who, _attribute, false, _notes, msg.sender);

  }



  // Returns true if the uint256 value stored for this attribute is non-zero

  function hasAttribute(

    address _who,

    Attribute.AttributeType _attribute

  )

    public

    view

    returns (bool)

  {

    return attributes[_who].value.checkBit(Attribute.toUint256(_attribute));

  }



  // Returns the exact value of the attribute, as well as its metadata

  function getAttributes(

    address _who

  )

    public

    view

    returns (uint256)

  {

    AttributeData memory _data = attributes[_who];

    return _data.value;

  }



  function setManager(RegistryAccessManager _accessManager) public onlyOwner {

    emit SetManager(accessManager, _accessManager);

    accessManager = _accessManager;

  }

}









contract DefaultRegistryAccessManager is RegistryAccessManager {

  function confirmWrite(

    address /*_who*/,

    Attribute.AttributeType _attribute,

    address _operator

  )

    public

    returns (bool)

  {

    Registry _client = Registry(msg.sender);

    if (_operator == _client.owner()) {

      return true;

    } else if (_client.hasAttribute(_operator, Attribute.AttributeType.ROLE_MANAGER)) {

      return (_attribute == Attribute.AttributeType.ROLE_OPERATOR);

    } else if (_client.hasAttribute(_operator, Attribute.AttributeType.ROLE_OPERATOR)) {

      return (_attribute != Attribute.AttributeType.ROLE_OPERATOR &&

              _attribute != Attribute.AttributeType.ROLE_MANAGER);

    }

  }

}