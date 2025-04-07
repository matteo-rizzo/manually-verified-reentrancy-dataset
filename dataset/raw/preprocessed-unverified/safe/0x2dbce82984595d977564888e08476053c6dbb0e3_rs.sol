/**
 *Submitted for verification at Etherscan.io on 2020-09-12
*/

pragma solidity ^0.6.12;











contract SUSHIPOWAH {
  using SafeMath for uint256;
  
  function name() public pure returns(string memory) { return "SUSHIPOWAH"; }
  function symbol() public pure returns(string memory) { return "SUSHIPOWAH"; }
  function decimals() public pure returns(uint8) { return 18; }  

  function totalSupply() public view returns (uint256) {
    IPair pair = IPair(0x795065dCc9f64b5614C407a6EFDC400DA6221FB0);
    IBar bar = IBar(0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272);
    IERC20 sushi = IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    (uint256 lp_totalSushi, , ) = pair.getReserves();
    uint256 xsushi_totalSushi = sushi.balanceOf(address(bar));

    return lp_totalSushi.mul(2).add(xsushi_totalSushi);
  }

  function balanceOf(address owner) public view returns (uint256) {
    IMasterChef chef = IMasterChef(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);
    IPair pair = IPair(0x795065dCc9f64b5614C407a6EFDC400DA6221FB0);
    IBar bar = IBar(0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272);
    IERC20 sushi = IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    
    uint256 lp_totalSushi = sushi.balanceOf(address(pair));
    uint256 lp_total = pair.totalSupply();
    uint256 lp_balance = pair.balanceOf(owner);

    // Add staked balance
    (uint256 lp_stakedBalance, ) = chef.userInfo(12, owner);
    lp_balance = lp_balance.add(lp_stakedBalance);
    
    // LP voting power is 2x the users SUSHI share in the pool.
    uint256 lp_powah = lp_totalSushi.mul(lp_balance).div(lp_total).mul(2);

    uint256 xsushi_balance = bar.balanceOf(owner);
    uint256 xsushi_total = bar.totalSupply();
    uint256 xsushi_totalSushi = sushi.balanceOf(address(bar));
    
    // xSUSHI voting power is the users SUSHI share in the bar
    uint256 xsushi_powah = xsushi_totalSushi.mul(xsushi_balance).div(xsushi_total);
    
    return lp_powah.add(xsushi_powah);
  }

  function allowance(address, address) public pure returns (uint256) { return 0; }
  function transfer(address, uint256) public pure returns (bool) { return false; }
  function approve(address, uint256) public pure returns (bool) { return false; }
  function transferFrom(address, address, uint256) public pure returns (bool) { return false; }
}