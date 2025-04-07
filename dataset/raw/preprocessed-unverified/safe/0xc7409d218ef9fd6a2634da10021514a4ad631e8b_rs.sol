/**
 *Submitted for verification at Etherscan.io on 2020-07-05
*/

pragma solidity ^0.4.18;
// -------------------------------------------------
// Coronnavirus Economic Relief Fund 90% payouts / 10% overhead with Ethereum tokenized investment potential via future Exchange trading
// aronline.io
// COR token sale contract
// static priced at 5000 tokens per Eth
// 1 vote per Token re: payouts
// -------------------------------------------------




contract CORToken is Owned {
  function balanceOf(address who) view public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract CORCrowdsale is Owned {
  // owner/admin & token reward
  address        public admin                     = owner;
  CORToken       public tokenReward;

  // multi-sig addresses and price variable
  address public beneficiaryWallet;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  // default function, map admin
  function CORCrowdsale() public onlyOwner {
          admin = msg.sender;
          tokenReward                             = CORToken(0x04676091Ec9a205d4186C3374e8a7aF135cB3f70);
          beneficiaryWallet                       = 0xEe9A1D71F4379E7463e236909d9C44606BaaB7fB;
  }

  function () public payable {
    require(!(msg.value == 0));
    require(msg.data.length == 0);
    tokenReward.transfer(msg.sender, SafeMath.mul(5000,msg.value));
    //tokenReward.transfer(msg.sender, safeMul(tokensPerEthPrice,msg.value));
  }
  
  function beneficiaryMultiSigWithdraw(uint256 _amount) public onlyOwner {
    beneficiaryWallet.transfer(_amount);
  }
}