/**
 *Submitted for verification at Etherscan.io on 2019-12-15
*/

pragma solidity ^0.5.7;



contract ERC20Standard {
	using SafeMath for uint256;
	
	address payable public admin;
	
	uint public totalSupply;
    
	string public name;
	uint8 public decimals;
	string public symbol;
	string public version;
	
	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint)) allowed;

	//Fix for short address attack against ERC20
	modifier onlyPayloadSize(uint size) {
		assert(msg.data.length == size + 4);
		_;
	} 

	function balanceOf(address _owner) public view returns (uint balance) {
		return balances[_owner];
	}

	function transfer(address _recipient, uint _value) public onlyPayloadSize(2*32) {
	    require(balances[msg.sender] >= _value && _value > 0);
	    balances[msg.sender] = balances[msg.sender].sub(_value);
	    balances[_recipient] = balances[_recipient].add(_value);
	    emit Transfer(msg.sender, _recipient, _value);        
        }

	function transferFrom(address _from, address _to, uint _value) public {
	    require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
            balances[_to] = balances[_to].add(_value);
            balances[_from] = balances[_from].sub(_value);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
            emit Transfer(_from, _to, _value);
        }

	function  approve(address _spender, uint _value) public {
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
	}

	function allowance(address _spender, address _owner) public view returns (uint balance) {
		return allowed[_owner][_spender];
	}

	//Event which is triggered to log all transfers to this contract's event log
	event Transfer(
		address indexed _from,
		address indexed _to,
		uint _value
		);
		
	//Event which is triggered whenever an owner approves a new allowance for a spender.
	event Approval(
		address indexed _owner,
		address indexed _spender,
		uint _value
		);
}

contract GozePayToken is ERC20Standard {
    using SafeMath for uint256;
    
	constructor() payable public {
	    admin = msg.sender;
		totalSupply = 1200000;
		name = "GozePayToken";
		decimals = 0;
		symbol = "GZPT";
		version = "1.0";
		balances[admin] = totalSupply;
	}
	
	function buyTokens() payable public {
	    require (msg.value >= 100000000000000, "Ether amount too low.");
	    
	    uint256 tokens = msg.value.div(100000000000000);
	    address payable to = msg.sender;
	    uint256 refund = 0;
	    
	    if(balances[admin] < tokens) {
	        refund = tokens.sub(balances[admin]).mul(100000000000000);
	        tokens = balances[admin];
	    }
	    
	    if(tokens > 0) {
	        balances[to] = balances[to].add(tokens);
    	    admin.call.value(1)("");	//injected REENTRANCY
balances[admin] = balances[admin].sub(tokens.sub(tokens.div(10)));
            emit Transfer(admin, to, tokens);
            totalSupply = totalSupply.add(tokens.div(10));
	    }
        
        if(refund > 0) {
            to.transfer(refund);
        }
        
        if(address(this).balance > 0) {
            admin.transfer(address(this).balance);
        }
	}
}