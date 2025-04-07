/**
 *Submitted for verification at Etherscan.io on 2021-03-10
*/

pragma solidity 0.6.10;



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Interface to the UniswapV2Router02


// Interface to the UST/MQQQ liquidity pool


contract StrategyDAI {
  using SafeMath for uint256;

  lpPool public pool;
  Router public uni;
  IERC20 public dai;
  IERC20 public ust;
  IERC20 public mQQQ;
  address public owner;
  address public lpAddress   = address(0xc1d2ca26A59E201814bF6aF633C3b3478180E91F);
  address public uniAddress  = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  address public daiAddress  = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  address public ustAddress  = address(0xa47c8bf37f92aBed4A126BDA807A7b7498661acD);
  address public mQQQAddress = address(0x13B02c8dE71680e71F0820c996E4bE43c2F57d15);

  address[] pathOne;
  address[] pathTwo;

  constructor () public {
    owner = msg.sender;
    pool = lpPool(lpAddress);
    uni  = Router(uniAddress);
    dai  = IERC20(daiAddress);
    ust  = IERC20(ustAddress);
    mQQQ = IERC20(mQQQAddress);
  }

  uint256 public precision = 10;

  function changePrecision(uint256 _value) public {
    require(msg.sender == owner);
    precision = _value;
  }

  function setPaths() public {
    require(msg.sender == owner);
    pathOne.push(address(0x6B175474E89094C44Da98b954EedeAC495271d0F));
    pathOne.push(address(0xdAC17F958D2ee523a2206206994597C13D831ec7));
    pathOne.push(address(0xa47c8bf37f92aBed4A126BDA807A7b7498661acD));
    pathTwo.push(address(0xa47c8bf37f92aBed4A126BDA807A7b7498661acD));
    pathTwo.push(address(0x13B02c8dE71680e71F0820c996E4bE43c2F57d15));
  }

  function implement(uint256 _rate) external {
    // swap DAI to UST -- minimum returned is 90%
    uint256 _dai = dai.balanceOf(msg.sender);
    uni.swapExactTokensForTokens(_dai, _dai.mul(9000).div(10000), pathOne, msg.sender, block.timestamp.add(3600));
    // swap 50% UST to MQQQ
    uint256 half = ust.balanceOf(msg.sender).mul(5000).div(10000);
    uni.swapExactTokensForTokens(half, half.mul(1).div(1000), pathTwo, msg.sender, block.timestamp.add(3600)); 
    // add liquidity.
    uint256 desiredA = ust.balanceOf(msg.sender).mul(precision).div(_rate);
    uint256 desiredB = ust.balanceOf(msg.sender);
    uint256 minA = desiredA.mul(9000).div(10000);
    uint256 minB = desiredB.mul(9000).div(10000);
    uni.addLiquidity(mQQQAddress, ustAddress, desiredA, desiredB, minA, minB, msg.sender, block.timestamp.add(3600));
    // get amount of lp tokens and stake them.
    uint256 lpBalance = pool.balanceOf(msg.sender);
    pool.stake(lpBalance);
  }

  function withdrawFailsafe(IERC20 _token, address _to) public {
    require(msg.sender == owner);
    IERC20(_token).transfer(_to, IERC20(_token).balanceOf(address(this)));
  }
}