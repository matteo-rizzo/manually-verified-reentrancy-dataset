/**

 *Submitted for verification at Etherscan.io on 2018-09-09

*/



pragma solidity 0.4.24;

/**

* Token swapper contract for CLASSY tokens

*/















contract Swap {



  using SafeMath for uint;



  Token public tokenA;

  Token public tokenB;



  address public admin;



  constructor() public {



    tokenA = Token(0x30CC0e266cF33B8eaC6A99cBD98E39b890cfD69b);

    tokenB = Token(0x8Cc3B3E4F62070afb2f0Dfece7228376626c1b0C);

    admin = 0x71bAe8D36266F6a2115aa7E18A395e4676528100;



  }



  function changeAdmin(address newAdmin) public returns (bool){



    require(msg.sender == admin, "You are not allowed to do this");



    admin = newAdmin;



    return true;



  }



  function receiveApproval(address sender, uint value, address cont, bytes data) public returns (bool) {



    require(cont == address(tokenA),"This is not the expected caller");



    require(tokenA.transferFrom(sender,address(this),value),"An error ocurred whe getting the old tokens");



    uint toTransfer = value.mul(1e2); //Decimals correction

    require(tokenB.transfer(sender,toTransfer), "Not enough tokens on contract to swap");



    return true;



  }



  function tokenRecovery(address token) public returns (bool) {



    require(msg.sender == admin, "You are not allowed to do this");



    ANYtoken toGet = ANYtoken(token);



    uint balance = toGet.balanceOf(address(this));



    toGet.transfer(msg.sender,balance);



    return true;



  }



}