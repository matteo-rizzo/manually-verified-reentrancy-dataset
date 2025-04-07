/**
 *Submitted for verification at Etherscan.io on 2020-12-12
*/

/**
 *Submitted for verification at Etherscan.io on 2020-09-12
*/

pragma solidity ^0.6.12;









contract BaoVotes {
  using SafeMath for uint256;
  
  function name() public pure returns(string memory) { return "BaoVotes"; }
  function symbol() public pure returns(string memory) { return "BaoVotes"; }
  function decimals() public pure returns(uint8) { return 18; }  

  function totalSupply() public view returns (uint256) {
    IPair pair = IPair(0x9973bb0fE5F8DF5dE730776dF09E946c74254fb3);
    IERC20 bao = IERC20(0x374CB8C27130E2c9E04F44303f3c8351B9De61C1);
    (uint256 lp_totalbao, , ) = pair.getReserves();
    (uint256 unlockedTotal) = bao.unlockedSupply();
    (uint256 lockedTotal) = bao.totalLock();

    return lp_totalbao.mul(2).add(unlockedTotal.div(4)).add(lockedTotal.div(5));
  }

  function balanceOf(address owner) public view returns (uint256) {
    IMasterChef chef = IMasterChef(0xBD530a1c060DC600b951f16dc656E4EA451d1A2D);
    IERC20 bao = IERC20(0x374CB8C27130E2c9E04F44303f3c8351B9De61C1);
    
    (uint256 lp_totalbao, ) = chef.userInfo(0, owner);
    uint256 locked_balance = bao.lockOf(owner);
    uint256 bao_balance = bao.balanceOf(owner).mul(25).div(100);

    // Add locked balance
    uint256 lp_balance = lp_totalbao.mul(2);
    lp_balance = lp_balance.add(locked_balance.mul(20).div(100));
    
    // Add user bao balance
    uint256 lp_powah = lp_balance.add(bao_balance);

    
    return lp_powah;
  }

  function allowance(address, address) public pure returns (uint256) { return 0; }
  function transfer(address, uint256) public pure returns (bool) { return false; }
  function approve(address, uint256) public pure returns (bool) { return false; }
  function transferFrom(address, address, uint256) public pure returns (bool) { return false; }
}