pragma solidity ^0.4.16;
//FYN Airdrop contract for Tokens

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */
 





contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address from, address to, uint value);
  function approve(address spender, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract tntsend is Ownable {
    address public tokenaddress;
   
    
    function tntsend(){
        tokenaddress = 	0x08f5a9235b08173b7569f83645d2c7fb55e8ccd8;
        admin = msg.sender;
    }
    function setupairdrop(address _tokenaddr,address _admin) onlyOwner {
        tokenaddress = _tokenaddr;
        admin= _admin;
    }
    
    function multisend(address[] dests, uint256[] values)
    onlyAdmin
    returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
           ERC20(tokenaddress).transfer(dests[i], values[i]);
           i += 1;
        }
        return(i);
    }
}