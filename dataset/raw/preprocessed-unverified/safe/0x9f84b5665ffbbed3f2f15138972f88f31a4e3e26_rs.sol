/**
 *Submitted for verification at Etherscan.io on 2020-07-17
*/

pragma solidity ^0.5.16;









contract YearnRewards {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;
  
  
  IERC20 constant public yfi = IERC20(0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e);
  IERC20 constant public adai = IERC20(0xfC1E690f61EFd961294b3e1Ce3313fBD8aa4f85d);
  
  address public governance;
  
  constructor() public {
      governance = msg.sender;
  }
  
  function claim(uint _amount) public {
      uint _adai = adai.balanceOf(address(this));
      uint _totalSupply = yfi.totalSupply();
      uint _balance = yfi.balanceOf(address(this));
      uint _adjTotalSupply = _totalSupply.sub(_balance);
      uint _share = _adai.mul(_amount).div(_adjTotalSupply);
      
      yfi.safeTransferFrom(msg.sender, address(this), _amount);
      adai.safeTransfer(msg.sender, _share);
  }
  
  function seize(address _token, uint _amount) public {
      require(msg.sender == governance, "!governance");
      IERC20(_token).safeTransfer(governance, _amount);
  }
}