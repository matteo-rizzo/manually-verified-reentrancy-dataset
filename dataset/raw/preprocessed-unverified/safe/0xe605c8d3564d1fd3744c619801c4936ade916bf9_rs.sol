/**
 *Submitted for verification at Etherscan.io on 2020-11-21
*/

/**
 *Submitted for verification at Etherscan.io on 2020-09-12
*/

pragma solidity ^0.6.12;











contract ICHIPOWAH {
  using SafeMath for uint256;
  
  function name() public pure returns(string memory) { return "ICHIPOWAH"; }
  function symbol() public pure returns(string memory) { return "ICHIPOWAH"; }
  function decimals() public pure returns(uint8) { return 18; }  

  function totalSupply() public view returns (uint256) {
    IPair ichiOneBTC = IPair(0x643E04f64326d4FF4596B977E4131deC317a7249);
    IPair ichiOneETH = IPair(0x856910d60689AD844f2A96fcE5e0B8d4caF52188);
    IPair ichiETH = IPair(0x4EA9c6793C4931F25D0d08dd5Fe357Acb54814Ba);

    IStake stake = IStake(0x70605a6457B0A8fBf1EEE896911895296eAB467E);
    IERC20 ichi = IERC20(0x903bEF1736CDdf2A537176cf3C64579C3867A881);
    
    (uint256 ichi1, , ) = ichiOneBTC.getReserves();
    (uint256 ichi2, , ) = ichiOneETH.getReserves();
    (uint256 ichi3, , ) = ichiETH.getReserves();

    uint256 lp_totalIchi = ichi1.add(ichi2).add(ichi3);

    uint256 xIchi_totalIchi = ichi.balanceOf(address(stake));

    return lp_totalIchi.mul(2).add(xIchi_totalIchi);
  }

  function getLpPowah(IERC20 ichi, IPair pair, IFarm farm, address owner) public view returns (uint256) {
    uint256 lp_totalIchi = ichi.balanceOf(address(pair));
    uint256 lp_total = pair.totalSupply();
    uint256 lp_balance = pair.balanceOf(owner);

    // Add staked balance
    (uint256 lp_stakedBalance, ) = farm.userInfo(1, owner);
    lp_balance = lp_balance.add(lp_stakedBalance);
    
    // LP voting power is 2x the users SUSHI share in the pool.
    uint256 lp_powah = lp_totalIchi.mul(lp_balance).div(lp_total).mul(2);

    return lp_powah;
  }

  function balanceOf(address owner) public view returns (uint256) {
    IFarm farm = IFarm(0xcC50953A743B9CE382f423E37b07Efa6F9d9B000);

    IPair ichiETH = IPair(0x4EA9c6793C4931F25D0d08dd5Fe357Acb54814Ba);
    IPair ichiOneETH = IPair(0x856910d60689AD844f2A96fcE5e0B8d4caF52188);
    IPair ichiOneBTC = IPair(0x643E04f64326d4FF4596B977E4131deC317a7249);

    IStake stake = IStake(0x70605a6457B0A8fBf1EEE896911895296eAB467E);
    IERC20 ichi = IERC20(0x903bEF1736CDdf2A537176cf3C64579C3867A881);

    uint256 one_lp_powah = getLpPowah(ichi, ichiETH, farm, owner);
    uint256 two_lp_powah = getLpPowah(ichi, ichiOneETH, farm, owner);
    uint256 three_lp_powah = getLpPowah(ichi, ichiOneBTC, farm, owner);

    uint256 xIchi_balance = stake.balanceOf(owner);
    uint256 xIchi_total = stake.totalSupply();
    uint256 xIchi_totalIchi = ichi.balanceOf(address(stake));
    
    // xSUSHI voting power is the users SUSHI share in the stake
    uint256 xIchi_powah = xIchi_totalIchi.mul(xIchi_balance).div(xIchi_total);
    
    uint256 lp_powah = one_lp_powah.add(two_lp_powah).add(three_lp_powah);

    return lp_powah.add(xIchi_powah);
  }

  function allowance(address, address) public pure returns (uint256) { return 0; }
  function transfer(address, uint256) public pure returns (bool) { return false; }
  function approve(address, uint256) public pure returns (bool) { return false; }
  function transferFrom(address, address, uint256) public pure returns (bool) { return false; }
}