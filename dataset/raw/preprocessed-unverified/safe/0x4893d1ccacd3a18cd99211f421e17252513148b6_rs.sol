/**
 *Submitted for verification at Etherscan.io on 2020-07-22
*/

/**
 *Submitted for verification at Etherscan.io on 2018-02-11
*/

pragma solidity ^0.4.13;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public  returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public  returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */





/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */




contract WJKJ is ERC20,Ownable{
	using SafeMath for uint256;

	//the base info of the token
	string public constant name="WJKJ";
	string public constant symbol="WJKJ";
	string public constant version = "1.0";
	uint256 public constant decimals = 18;
	uint256 public constant MAX_SUPPLY=1000000000*100**decimals;

    mapping(address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	

	function WJKJ(){
		totalSupply = MAX_SUPPLY;
		balances[msg.sender] = MAX_SUPPLY;
	    Transfer(0x0, msg.sender, MAX_SUPPLY);
	}

	function () payable external
	{
	}


    function addIssue (uint256 _amount) external
    	onlyOwner
    {
    	balances[msg.sender] = balances[msg.sender].add(_amount);
    }
    

	function etherProceeds() external
		onlyOwner
	{
		if(!msg.sender.send(this.balance)) revert();
	}

  	function transfer(address _to, uint256 _value) public  returns (bool)
 	{
		require(_to != address(0));
		// SafeMath.sub will throw if there is not enough balance.
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
  	}

  	function balanceOf(address _owner) public  returns (uint256 balance) 
  	{
		return balances[_owner];
  	}


  	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
  	{
		require(_to != address(0));

		uint256 _allowance = allowed[_from][msg.sender];

		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = _allowance.sub(_value);
		Transfer(_from, _to, _value);
		return true;
  	}

  	function approve(address _spender, uint256 _value) public returns (bool) 
  	{
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
  	}

  	function allowance(address _owner, address _spender) public  returns (uint256 remaining) 
  	{
		return allowed[_owner][_spender];
  	}

	  
}