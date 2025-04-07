/**

 *Submitted for verification at Etherscan.io on 2018-08-21

*/



pragma solidity ^0.4.24;



/**

 * SmartEth.co

 * ERC20 Token and ICO smart contracts development, smart contracts audit, ICO websites.

 * [emailÂ protected]

 */



/**

 * @title Ownable

 */





/**

 * @title ERC20Basic

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title ERC20 interface

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract Airdrop is Ownable {



  ERC20 public token = ERC20(0xb09830db5B21167A5a27969aC3Ab01B129cf41a1);



  function airdrop(address[] recipient, uint256[] amount) public onlyOwner returns (uint256) {

    uint256 i = 0;

      while (i < recipient.length) {

        token.transfer(recipient[i], amount[i]);

        i += 1;

      }

    return(i);

  }

  

  function airdropSameAmount(address[] recipient, uint256 amount) public onlyOwner returns (uint256) {

    uint256 i = 0;

      while (i < recipient.length) {

        token.transfer(recipient[i], amount);

        i += 1;

      }

    return(i);

  }

}