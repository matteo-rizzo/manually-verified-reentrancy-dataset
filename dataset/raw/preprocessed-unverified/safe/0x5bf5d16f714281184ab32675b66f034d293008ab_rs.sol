/**

 *Submitted for verification at Etherscan.io on 2019-03-27

*/



pragma solidity ^0.4.23;









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

  ERC20Basic public ERC20Token;



  // internal variables

  uint256 _totalSupply;



  // events



  // public functions

  constructor (

    ERC20Basic token

  )

    public

  {

    ERC20Token = ERC20Basic(token);

  }



  function amountOf() public view returns (uint256 amount) {

    return ERC20Token.balanceOf(address(this));

  }



  function safeTransfer(address funder, uint256 amount) public onlyOwner {

    ERC20Token.safeTransfer(funder, amount);

  }



  function changeToken(ERC20Basic token) public onlyOwner {

    ERC20Token = ERC20Basic(token);

  }



  function batchTransfer(address[] funders, uint256[] amounts) public onlyOwner {

    require(funders.length > 0 && funders.length == amounts.length);



    uint256 total = ERC20Token.balanceOf(this);

    require(total > 0);



    uint256 fundersTotal = 0;

    for (uint i = 0; i < amounts.length; i++) {

      fundersTotal = fundersTotal.add(amounts[i]);

    }

    require(total >= fundersTotal);



    for (uint j = 0; j < funders.length; j++) {

      ERC20Token.safeTransfer(funders[j], amounts[j]);

    }

  }

}