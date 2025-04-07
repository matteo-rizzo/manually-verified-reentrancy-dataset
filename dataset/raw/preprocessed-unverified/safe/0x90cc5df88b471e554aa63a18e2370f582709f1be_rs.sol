pragma solidity ^0.4.24;

/**
 * title SafeMath
 * @dev Math operations with safety checks that throw on error
*/




/**
 * @title ERC20 interface
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */




contract POMZ is ERC20 {

    //use libraries section
	using SafeMath for uint256;

    //token characteristics section
    uint public constant decimals = 8;
    uint256 public totalSupply = 5000000000 * 10 ** decimals;
    string public constant name = "POMZ";
    string public constant symbol = "POMZ";

    //storage section
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    //all token to creator
	constructor() public {
		balances[msg.sender] = totalSupply;
	}

    //Returns the account balance of another account with address _owner.
    function balanceOf(address _owner) public view returns (uint256) {
	    return balances[_owner];
    }

    //Transfers _value amount of tokens to address _to, and MUST fire the Transfer event.
    //The function SHOULD throw if the _from account balance does not have enough tokens to spend.
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);

        uint256 previousBalances = balances[_to];
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        assert(balances[_to].sub(_value) == previousBalances);
        return true;
    }

    //Transfers _value amount of tokens from address _from to address _to, and MUST fire the Transfer event.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);

        uint256 previousBalances = balances[_to];
	    balances[_from] = balances[_from].sub(_value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
		assert(balances[_to].sub(_value) == previousBalances);
        return true;
    }

    //Allows _spender to withdraw from your account multiple times, up to the _value amount.
    //If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //Returns the amount which _spender is still allowed to withdraw from _owner.
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // If ether is sent to this address, send it back.
	function () public {
        revert();
    }

}