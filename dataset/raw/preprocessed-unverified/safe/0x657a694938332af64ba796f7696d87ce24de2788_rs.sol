// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

contract SmartBTC {

    string public constant name = "SmartBTC";
    string public constant symbol = "SMBTC";
    uint8 public constant decimals = 0;  

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
}
