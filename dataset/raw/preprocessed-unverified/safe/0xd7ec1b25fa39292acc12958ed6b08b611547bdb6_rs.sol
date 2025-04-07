pragma solidity ^0.4.18;





contract ERC20 {
	uint public totalSupply;
	function balanceOf(address _owner) public constant returns (uint balance);
	function transfer(address _to,uint _value) public returns (bool success);
	function transferFrom(address _from,address _to,uint _value) public returns (bool success);
	function approve(address _spender,uint _value) public returns (bool success);
	function allownce(address _owner,address _spender) public constant returns (uint remaining);
	event Transfer(address indexed _from,address indexed _to,uint _value);
	event Approval(address indexed _owner,address indexed _spender,uint _value);
}

contract ValueToken is ERC20,Ownable {
	using SafeMath for uint8;
	using SafeMath for uint256;

	string public name;
	string public symbol;
	uint8 public decimals;
	mapping (address => uint256) public balances;
	mapping (address => mapping (address => uint256)) allowed;
	
	function ValueToken () public {
		name = 'ValueToken';
		symbol = 'VAT';
		decimals = 18;
		totalSupply = 10000000000 * (10 ** 18);
		balances[msg.sender] = totalSupply;
	}
	
	function balanceOf(address _owner) public constant returns (uint balance) {
		return balances[_owner];
	}
	
	function transfer(address _to,uint _value) public returns (bool success) {
		if(balances[msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]){
			balances[msg.sender] = balances[msg.sender].sub(_value);
			balances[_to] = balances[_to].add(_value);
			Transfer(msg.sender,_to,_value);
			return true;
		} else {
			return false;
		}
	}

	function transferFrom(address _from,address _to,uint _value) public returns (bool success) {
		if(balances[_from] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
			if(_from != msg.sender) {
				require(allowed[_from][msg.sender] > _value);
				allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
			}
			balances[_from] = balances[_from].sub(_value);
			balances[_to] = balances[_to].add(_value);
			Transfer(_from,_to,_value);
			return true;
		} else {
			return false;
		}
	}

	function approve(address _spender, uint _value) public returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender,_spender,_value);
		return true;
	}
	
	function allownce(address _owner,address _spender) public constant returns (uint remaining) {
		return allowed[_owner][_spender];
	}
	
	function multisend(address[] _dests, uint256[] _values) public returns (bool success) {
		require(_dests.length == _values.length);
		for(uint256 i = 0; i < _dests.length; i++) {
			if( !transfer(_dests[i], _values[i]) ) return false;
		}
		return true;
	}
}