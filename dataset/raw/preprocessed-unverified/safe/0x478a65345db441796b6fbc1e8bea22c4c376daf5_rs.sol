pragma solidity 0.4.21;




///////////// POST ICO DESTROY COMMAND

contract Destructible is Ownable {

	function Destructible() public payable { }

	function destroy() onlyOwner public {
		selfdestruct(owner);
	}

	function destroyAndSend(address _recipient) onlyOwner public {
		selfdestruct(_recipient);
	}
}


///////////// SAFE MATH FUNCTIONS



///////////// DECLARE ERC223 BASIC INTERFACE

contract ERC223ReceivingContract {
	function tokenFallback(address _from, uint256 _value, bytes _data) public pure {
		_from;
		_value;
		_data;
	}
}

contract ERC223 {
	event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
}

contract ERC20 {
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
}


contract BasicToken is ERC20, ERC223, Destructible {
	uint256 public totalSupply;
	using SafeMath for uint256;

	mapping(address => uint256) balances;

	address[] allParticipants;
	mapping(address => bool) isParticipated;


  ///////////// TRANSFER ////////////////

	function transferToAddress(address _to, uint256 _value, bytes _data) internal returns (bool) {
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		if(!isParticipated[_to]){
			allParticipants.push(_to);
			isParticipated[_to] = true;
		}
		emit Transfer(msg.sender, _to, _value);
		emit Transfer(msg.sender, _to, _value, _data);
		return true;
	}

	function transferToContract(address _to, uint256 _value, bytes _data) internal returns (bool) {
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
		receiver.tokenFallback(msg.sender, _value, _data);
		emit Transfer(msg.sender, _to, _value);
		emit Transfer(msg.sender, _to, _value, _data);
		return true;
	}

	function transfer(address _to, uint256 _value, bytes _data) public onlyOwner returns (bool) {
		require(_to != address(0));
		require(_value <= balances[msg.sender]);
		require(_value > 0);

		uint256 codeLength;
		assembly {
			codeLength := extcodesize(_to)
		}
	
		if(codeLength > 0) {
			return transferToContract(_to, _value, _data);
		} else {
			return transferToAddress(_to, _value, _data);
		}
	}


	function transfer(address _to, uint256 _value) public onlyOwner returns (bool) {
		require(_to != address(0));
		require(_value <= balances[msg.sender]);
		require(_value > 0);

		uint256 codeLength;
		bytes memory empty;
		assembly {
			codeLength := extcodesize(_to)
		}

		if(codeLength > 0) {
			return transferToContract(_to, _value, empty);
		} else {
			return transferToAddress(_to, _value, empty);
		}
	}


	function balanceOf(address _address) public constant returns (uint256 balance) {
		return balances[_address];
	}


	function getCountPartipants() public constant returns (uint count){
		return allParticipants.length;
	}

	function getParticipantIndexAddress(uint index)public constant returns (address){
		return allParticipants[index];
	}
}


contract StandardToken is BasicToken {

	mapping (address => mapping (address => uint256)) internal allowed;
}

contract Airstayz is StandardToken {
	string public constant name = "AIRSTAYZSAFT";
	uint public constant decimals = 18;
	string public constant symbol = "STAYUS";

	function Airstayz() public {
		totalSupply = 93000000 *(10**decimals);
		owner = msg.sender;
		balances[msg.sender] = 93000000 * (10**decimals);
	}

	function() public {
		revert();
	}
}