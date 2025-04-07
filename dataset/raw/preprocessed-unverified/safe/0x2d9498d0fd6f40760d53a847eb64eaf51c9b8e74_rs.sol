pragma solidity ^0.4.11;

/**
 * @title ETHCON Early Bird Token
 * @author majoolr.io
 *
 * Only allows one token per account. See ETHCON.org for further information.
 * Implements ERC20 Library at 0x71ecde7c4b184558e8dba60d9f323d7a87411946
 *
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */





contract ETHCONEarlyBirdToken {
   using ERC20Lib for ERC20Lib.TokenStorage;

   ERC20Lib.TokenStorage token;

   string public name = "ETHCON-Early-Bird";
   string public symbol = "THX";
   uint public decimals = 0;
   uint public INITIAL_SUPPLY = 600;

   event ErrorMsg(string msg);

   function ETHCONEarlyBirdToken() {
     token.init(INITIAL_SUPPLY);
   }

   function totalSupply() constant returns (uint) {
     return token.totalSupply;
   }

   function balanceOf(address who) constant returns (uint) {
     return token.balanceOf(who);
   }

   function allowance(address owner, address spender) constant returns (uint) {
     return token.allowance(owner, spender);
   }

   function transfer(address to, uint value) returns (bool ok) {
     if(token.balanceOf(to) == 0){
       return token.transfer(to, value);
     } else {
       ErrorMsg("Recipient already has token");
       return false;
     }

   }

   function transferFrom(address from, address to, uint value) returns (bool ok) {
     if(token.balanceOf(to) == 0){
       return token.transferFrom(from, to, value);
     } else {
       ErrorMsg("Recipient already has token");
       return false;
     }
   }

   function approve(address spender, uint value) returns (bool ok) {
     return token.approve(spender, value);
   }

   event Transfer(address indexed from, address indexed to, uint value);
   event Approval(address indexed owner, address indexed spender, uint value);
}