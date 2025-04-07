/**
 *Submitted for verification at Etherscan.io on 2020-12-03
*/

pragma solidity ^0.5.16;









contract YearnRewards {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;
  
  
  IERC20 constant public yfi3 = IERC20(0x09843B9137fc5935B7F3832152F9074Db5D2d1Ee);
  IERC20 constant public adai = IERC20(0xfC1E690f61EFd961294b3e1Ce3313fBD8aa4f85d);
  
  address public governance;
  
  constructor() public {
      governance = msg.sender;
  }
  
  function claimable(address _claimer) public view returns (uint) {
      uint _amount = yfi3.balanceOf(_claimer);
      uint _adai = adai.balanceOf(address(this));
      uint _totalSupply = yfi3.totalSupply();
      uint _balance = yfi3.balanceOf(address(this));
      uint _adjTotalSupply = _totalSupply.sub(_balance);
      uint _share = _adai.mul(_amount).div(_adjTotalSupply);
      return _share;
  }
  
  function claim(uint _amount) public {
      uint _adai = adai.balanceOf(address(this));
      uint _totalSupply = yfi3.totalSupply();
      uint _balance = yfi3.balanceOf(address(this));
      uint _adjTotalSupply = _totalSupply.sub(_balance);
      uint _share = _adai.mul(_amount).div(_adjTotalSupply);
      
      yfi3.safeTransferFrom(msg.sender, address(this), _amount);
      adai.safeTransfer(msg.sender, _share);
  }
  
  function seize(address _token, uint _amount) public {
      require(msg.sender == governance, "!governance");
      IERC20(_token).safeTransfer(governance, _amount);
  }
}