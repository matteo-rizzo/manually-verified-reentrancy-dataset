/**
 *Submitted for verification at Etherscan.io on 2020-11-30
*/

/**
 *Submitted for verification at Etherscan.io on 2020-08-03
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: agpl-3.0



// NOTE: this interface lacks return values for transfer/transferFrom/approve on purpose,
// as we use the SafeERC20 library to check the return value




contract FBSToken {
	using SafeMath for uint;

	// Constants
	string public constant name = "FBS";
	string public constant symbol = "FBS";
	uint8 public constant decimals = 18;
    uint256 INITIAL_SUPPLY = 63000000 * (10**uint256(decimals));

	// Mutable variables
	uint public totalSupply;
	mapping(address => uint) balances;
	mapping(address => mapping(address => uint)) allowed;

	event Approval(address indexed owner, address indexed spender, uint amount);
	event Transfer(address indexed from, address indexed to, uint amount);


	constructor() public {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = totalSupply;
	}

	function balanceOf(address owner) external view returns (uint balance) {
		return balances[owner];
	}

	function transfer(address to, uint amount) external returns (bool success) {
		balances[msg.sender] = balances[msg.sender].sub(amount);
		balances[to] = balances[to].add(amount);
		emit Transfer(msg.sender, to, amount);
		return true;
	}

	function transferFrom(address from, address to, uint amount) external returns (bool success) {
		balances[from] = balances[from].sub(amount);
		allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
		balances[to] = balances[to].add(amount);
		emit Transfer(from, to, amount);
		return true;
	}

	function approve(address spender, uint amount) external returns (bool success) {
		allowed[msg.sender][spender] = amount;
		emit Approval(msg.sender, spender, amount);
		return true;
	}

	function allowance(address owner, address spender) external view returns (uint remaining) {
		return allowed[owner][spender];
	}
}