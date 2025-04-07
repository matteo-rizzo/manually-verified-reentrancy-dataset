/**

 *Submitted for verification at Etherscan.io on 2019-02-01

*/



pragma solidity ^0.4.24;









contract ERC20Basic {

  // events

  event Transfer(address indexed from, address indexed to, uint256 value);



  // public functions

  function totalSupply() public view returns (uint256);

  function balanceOf(address addr) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

}



contract ERC20 is ERC20Basic {

  // events

  event Approval(address indexed owner, address indexed agent, uint256 value);



  // public functions

  function allowance(address owner, address agent) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address agent, uint256 value) public returns (bool);



}













contract TokenBatchTransfer is Ownable {

  using SafeERC20 for ERC20Basic;

  using SafeMath for uint256;



  // public variables

  ERC20Basic public token;

  // events

  // public functions

  constructor (ERC20Basic tokenAddr) public {

    token = ERC20Basic(tokenAddr);

  }



  function changeToken(ERC20Basic tokenAddr) public onlyOwner {

    token = ERC20Basic(tokenAddr);

  }



  function balanceOfToken() public view returns (uint256 amount) {

    return token.balanceOf(address(this));

  }



  function safeTransfer(address funder, uint256 amount) public onlyOwner {

    token.safeTransfer(funder, amount);

  }



  function batchTransfer(address[] funders, uint256[] amounts) public onlyOwner {

    require(funders.length > 0 && funders.length == amounts.length);



    uint256 total = token.balanceOf(this);

    require(total > 0);



    uint256 fundersTotal = 0;

    for (uint i = 0; i < amounts.length; i++) {

      fundersTotal = fundersTotal.add(amounts[i]);

    }

    require(total >= fundersTotal);



    for (uint j = 0; j < funders.length; j++) {

      token.safeTransfer(funders[j], amounts[j]);

    }

  }

}