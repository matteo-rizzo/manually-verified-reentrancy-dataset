/**
 *Submitted for verification at Etherscan.io on 2020-10-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

contract SmartDigitalCoin {

    string public constant name = "Azar Coin";
    string public constant symbol = "AZR";
    uint8 public constant decimals = 18;  

    event Transfer(address indexed from, address indexed to, uint tokens);

    mapping(address => uint256) balances;
    
    uint256 totalSupply_;

    using SafeMath for uint256;


   constructor(uint256 total) public {  
	totalSupply_ = total;
	balances[msg.sender] = totalSupply_;
    }  

    function totalSupply() public view returns (uint256) {
	return totalSupply_;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

}

