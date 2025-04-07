pragma solidity ^0.4.24;







contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}







contract BSPVesting {

  using SafeMath for uint256;

  using SafeERC20 for ERC20Basic;



  event Released(uint256 amount);



  // beneficiary after released

  address public beneficiary = 0xb790f6DBd477C7125b13a8Bb3a67771027Abd402;

  // BSP contract address

  ERC20Basic public BSPToken = ERC20Basic(0x5d551fA77ec2C7dd1387B626c4f33235c3885199);



  // lock 18 months, start at 2020/01/01 00:00:00 (UTC+8)

  uint256 public start = 1577808000;

  // release in 15 months

  uint256 public duration = 15 * 30 days;



  uint256 public released;



  function release() public {



    uint256 unreleased = releasableAmount();

    require(unreleased > 0);



    released = released.add(unreleased);

    BSPToken.safeTransfer(beneficiary, unreleased);



    emit Released(unreleased);

  }



  function releasableAmount() public view returns (uint256) {

    return vestedAmount().sub(released);

  }



  function vestedAmount() public view returns (uint256) {

    uint256 currentBalance = BSPToken.balanceOf(this);

    uint256 totalBalance = currentBalance.add(released);



    if (block.timestamp >= start.add(duration)) {

      return totalBalance;

    } else {

      return totalBalance.mul(block.timestamp.sub(start)).div(duration);

    }

  }



  function () public payable {

    revert ();

  }



}