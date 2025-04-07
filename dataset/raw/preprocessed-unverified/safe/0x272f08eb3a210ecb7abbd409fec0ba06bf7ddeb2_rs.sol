/**

 *Submitted for verification at Etherscan.io on 2018-12-18

*/



pragma solidity 0.4.25;

/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */



contract Token {

  /// @return total amount of tokens

  function totalSupply() pure public returns (uint256 supply);

  /// @param _owner The address from which the balance will be retrieved

  /// @return The balance

  function balanceOf(address _owner) pure public returns (uint256 balance);

  /// @notice send `_value` token to `_to` from `msg.sender`

  /// @param _to The address of the recipient

  /// @param _value The amount of token to be transferred

  /// @return Whether the transfer was successful or not

  function transfer(address _to, uint256 _value) public returns (bool success);

  /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

  /// @param _from The address of the sender

  /// @param _to The address of the recipient

  /// @param _value The amount of token to be transferred

  /// @return Whether the transfer was successful or not

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

  /// @notice `msg.sender` approves `_addr` to spend `_value` tokens

  /// @param _spender The address of the account able to transfer the tokens

  /// @param _value The amount of wei to be approved for transfer

  /// @return Whether the approval was successful or not

  function approve(address _spender, uint256 _value) public returns (bool success);

  /// @param _owner The address of the account owning tokens

  /// @param _spender The address of the account able to transfer the tokens

  /// @return Amount of remaining tokens allowed to spent

  function allowance(address _owner, address _spender) pure public returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  uint public decimals;

  string public name;

}

/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */



contract AirDrop is Ownable {

  address public tokenAddress;

  Token public token;

  uint256 public valueAirDrop;

  mapping (address => uint8) public payedAddress; 

  constructor() public{

    valueAirDrop = 1 * 1 ether;

  } 

  function setValueAirDrop(uint256 _valueAirDrop) public onlyOwner{

    valueAirDrop = _valueAirDrop;

  } 

  function setTokenAddress(address _address) onlyOwner public{

    tokenAddress = _address;

    token = Token(tokenAddress);  

  }

  function refund() onlyOwner public{

    token.transfer(owner(), token.balanceOf(this));  

  }

  function () external payable {

    require(msg.value == 0);

    require(payedAddress[msg.sender] == 0);  

    payedAddress[msg.sender] = 1;  

    token.transfer(msg.sender, valueAirDrop);

  }

  function multisend(address[] _addressDestination)

    onlyOwner

    public {

        uint256 i = 0;

        while (i < _addressDestination.length) {

           token.transfer(_addressDestination[i], valueAirDrop);

           i += 1;

        }

    }  

}