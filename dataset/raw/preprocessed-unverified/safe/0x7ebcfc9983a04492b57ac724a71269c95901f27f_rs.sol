/**

 *Submitted for verification at Etherscan.io on 2018-09-11

*/



pragma solidity ^0.4.24;



contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract PublicAirdrop is Ownable {

  ERC20 public token = ERC20(0xe64A15389a64118a34408E0c4e18B2ECE6Ad2a2c);

  function airdrop(address[] recipient, uint256[] amount) public onlyOwner returns (uint256) {

    uint256 i = 0;

      while (i < recipient.length) {

        token.transfer(recipient[i], amount[i]);

        i += 1;

      }

    return(i);

  }

  function airdropToSubscribers(address[] recipient, uint256 amount) public onlyOwner returns (uint256) {

    uint256 i = 0;

      while (i < recipient.length) {

        token.transfer(recipient[i], amount);

        i += 1;

      }

    return(i);

  }

}