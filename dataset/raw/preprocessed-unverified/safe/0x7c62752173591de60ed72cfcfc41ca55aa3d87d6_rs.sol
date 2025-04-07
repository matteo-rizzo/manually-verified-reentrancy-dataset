//@ create by ETU LAB, INC.
pragma solidity ^0.4.19;





// ERC20 Interface
contract ERC20 {
    function totalSupply() public view returns (uint _totalSupply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

// ERC20Token
contract ERC20Token is ERC20 {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalToken; 

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function totalSupply() public view returns (uint256) {
        return totalToken;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

contract ETUex is ERC20Token, Owned {

    string  public constant name = "ETUex Token";
    string  public constant symbol = "ETU";
    uint256 public constant decimals = 18;
    uint256 public tokenDestroyed;
	event Burn(address indexed _from, uint256 _tokenDestroyed, uint256 _timestamp);

    function ETUex() public {
		totalToken = 200000000000000000000000000;
		balances[msg.sender] = totalToken;
    }

    function transferAnyERC20Token(address _tokenAddress, address _recipient, uint256 _amount) public onlyOwner returns (bool success) {
        return ERC20(_tokenAddress).transfer(_recipient, _amount);
    }

    function burn (uint256 _burntAmount) public returns (bool success) {
    	require(balances[msg.sender] >= _burntAmount && _burntAmount > 0);
    	balances[msg.sender] = balances[msg.sender].sub(_burntAmount);
    	totalToken = totalToken.sub(_burntAmount);
    	tokenDestroyed = tokenDestroyed.add(_burntAmount);
    	require (tokenDestroyed <= 100000000000000000000000000);
    	Transfer(address(this), 0x0, _burntAmount);
    	Burn(msg.sender, _burntAmount, block.timestamp);
    	return true;
	}

}