/**
 *Submitted for verification at Etherscan.io on 2019-10-25
*/

pragma solidity ^0.4.25;

contract ERC20 {
//	function totalSupply() public constant returns (uint supply);
//	function balanceOf(address who) public constant returns (uint value);
//	function allowance(address owner, address spender) public constant returns (uint _allowance);
	function transfer(address to, uint value) public returns (bool success);
	function transferFrom(address from, address to, uint value) public returns (bool success);
	function approve(address spender, uint value) public returns (bool success);

	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
}

/**
 * Math operations with safety checks
 */
contract SafeMath {

	function mul(uint a, uint b) internal pure returns (uint) {
		uint c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint a, uint b) internal pure returns (uint) {
		assert(b > 0);
		return a / b;
	}

	function sub(uint a, uint b) internal pure returns (uint) {
		assert(b <= a);
		return a - b;
	}

	function add(uint a, uint b) internal pure returns (uint) {
		uint c = a + b;
		assert(c >= a && c >= b);
		return c;
	}

	function min(uint x, uint y) internal pure returns (uint) {
		return x <= y ? x : y;
	}

	function max(uint x, uint y) internal pure returns (uint) {
		return x >= y ? x : y;
	}
}



contract Token is ERC20, SafeMath, Owned {

	// Public variables of the token
	string public name;
	string public symbol;
	uint8  public decimals = 18;
	uint   public totalSupply;

	// This creates an array with all balances
	mapping(address => uint) public balanceOf;
	mapping(address => mapping(address => uint)) public allowance;

	mapping(address => uint) public lock; 
	mapping(address => bool) public freezeIn;
	mapping(address => bool) public freezeOut;
	
	event Burn(address indexed from, uint value);
	event FreezeIn(address indexed from, bool value);
	event FreezeOut(address indexed from, bool value);

	function Token(string tokenName, string tokenSymbol, uint initSupply) public {
		totalSupply=initSupply*10**uint(decimals);
		name=tokenName;
		symbol=tokenSymbol;
		balanceOf[owner]=totalSupply;

	}

	//ERC 20
	///////////////////////////////////////////////////////////////////////////////////////////

	function internalTransfer(address from, address toaddr, uint value) internal {
		require(toaddr!=0);
		require(balanceOf[from]>=value);
		require(now>=lock[from]);
		require(!freezeIn[toaddr]);
		require(!freezeOut[from]);
		balanceOf[from]=sub(balanceOf[from], value);
		balanceOf[toaddr]=add(balanceOf[toaddr], value);
		Transfer(from, toaddr, value);
	}

	function transfer(address toaddr, uint value) public returns (bool) {
		internalTransfer(msg.sender, toaddr, value);
		return true;
	}
	
	function transferFrom(address from, address toaddr, uint value) public returns (bool) {
		require(allowance[from][msg.sender]>=value);
		allowance[from][msg.sender]=sub(allowance[from][msg.sender], value);
		internalTransfer(from, toaddr, value);
		return true;
	}

	function approve(address spender, uint amount) public returns (bool) {
		require((amount == 0) || (allowance[msg.sender][spender] == 0));	
		allowance[msg.sender][spender]=amount;
		Approval(msg.sender, spender, amount);
		return true;
	}

	/////////////////////////////////////////////////////////////////////////////////////////

	function setNameSymbol(string tokenName, string tokenSymbol) public onlyOwner {
		name=tokenName;
		symbol=tokenSymbol;
	}

	////////////////////////////////////////////////////////////////////////////////////////////
	function setLock(address addrs, uint times) public onlyOwner {
		lock[addrs]=times;
	}

	function setFreezeIn(address addrs, bool value) public onlyOwner {
		freezeIn[addrs]=value;
		FreezeIn(addrs, value);
	}

	function setFreezeOut(address addrs,bool value) public onlyOwner {
		freezeOut[addrs]=value;
		FreezeOut(addrs, value);
	}

	///////////////////////////////////////////////////////////////////////////////////////////
	function mint(uint amount) public onlyOwner {
		balanceOf[owner]=add(balanceOf[owner], amount);
		totalSupply=add(totalSupply, amount);
	}

	function burn(uint amount) public {
		balanceOf[msg.sender]=sub(balanceOf[msg.sender], amount);
		totalSupply=sub(totalSupply, amount);
	}

	///////////////////////////////////////////////////////////////////////////////////////////

	function withdrawEther(uint amount) public onlyOwner {
		owner.transfer(amount);
	}

	//Can accept ether
	function() public payable {
    }
}