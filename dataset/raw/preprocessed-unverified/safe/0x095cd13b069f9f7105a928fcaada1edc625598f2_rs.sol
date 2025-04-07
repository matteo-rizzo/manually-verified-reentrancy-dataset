pragma solidity ^0.4.13;



contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) public constant returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}





contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



















contract NBW is ERC20,Ownable{

	using SafeMath for uint256;



	string public constant name="netbanwork";

	string public symbol="NBW";

	string public constant version = "1.0";

	uint256 public constant decimals = 18;

	uint256 public totalSupply;



	uint256 public constant MAX_SUPPLY=210000000*10**decimals;



	

    mapping(address => uint256) balances;

	mapping (address => mapping (address => uint256)) allowed;

	event GetETH(address indexed _from, uint256 _value);



	//owner一次性获取代币

	function NBW(){

		totalSupply=MAX_SUPPLY;

		balances[msg.sender] = MAX_SUPPLY;

		Transfer(0x0, msg.sender, MAX_SUPPLY);

	}



	//允许用户往合约账户打币

	function () payable external

	{

		GetETH(msg.sender,msg.value);

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



  	function balanceOf(address _owner) public constant returns (uint256 balance) 

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



  	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) 

  	{

		return allowed[_owner][_spender];

  	}



	  

}