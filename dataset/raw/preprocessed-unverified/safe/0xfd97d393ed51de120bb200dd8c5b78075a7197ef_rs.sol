pragma solidity ^0.4.11;







contract ERC20Basic {

	uint public totalSupply;

	function balanceOf(address who) constant returns(uint);

	function transfer(address to, uint value);

	event Transfer(address indexed from, address indexed to, uint value);

}



contract BasicToken is ERC20Basic {

	using SafeMath 	for uint;

	mapping(address => uint) balances;



	modifier onlyPayloadSize(uint size) {

		if(msg.data.length < size + 4) {

			throw;

		}

		_;

	}



	function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {

		balances[msg.sender] = balances[msg.sender].sub(_value);

		balances[_to] = balances[_to].add(_value);

		Transfer(msg.sender, _to, _value);

	}



	function balanceOf(address _owner) constant returns(uint balance) {

		return balances[_owner];

	}



}



contract ERC20 is ERC20Basic {

	function allowance(address owner, address spender) constant returns(uint);

	function transferFrom(address from, address to, uint value);

	function approve(address spender, uint value);

	event Approval(address indexed owner, address indexed spender, uint value);

}



contract StandardToken is BasicToken, ERC20 {

	mapping(address => mapping(address => uint)) allowed;

	function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {

		var _allowance = allowed[_from][msg.sender];

		balances[_to] = balances[_to].add(_value);

		balances[_from] = balances[_from].sub(_value);

		allowed[_from][msg.sender] = _allowance.sub(_value);

		Transfer(_from, _to, _value);

	}



	function approve(address _spender, uint _value) {

		if((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

		allowed[msg.sender][_spender] = _value;

		Approval(msg.sender, _spender, _value);

	}



	function allowance(address _owner, address _spender) constant returns(uint remaining) {

		return allowed[_owner][_spender];

	}



}



contract CoffeeToken is StandardToken {

	string public constant symbol = "Coffee";

	string public constant name = "Coffee";

	uint8 public constant decimals = 18;

	address public target;

	

	event InvalidCaller(address caller);



	modifier onlyOwner {

		if(target == msg.sender) {

			_;

		} else {

			InvalidCaller(msg.sender);

			throw;

		}

	}

	function CoffeeToken(address _target) {

		target = _target;

		totalSupply = 10000 * 10 ** 18;

		balances[target] = totalSupply;

	}



}