pragma solidity 0.6.0;





contract YFMSTokenLock {
  using SafeMath for uint256;

  uint256 public unlockDateRewards;
  uint256 public unlockDateDev;
  uint256 public YFMSLockedDev;
  uint256 public YFMSLockedRewards;
  address public owner;
  ERC20 public YFMSToken;

  constructor(address _wallet) public {
    owner = msg.sender; 
    YFMSToken = ERC20(_wallet);
  }

   // < 2,500 YFMS
  function lockDevTokens (address _from, uint _amount) public {
    require(_from == owner);
    require(YFMSToken.balanceOf(_from) >= _amount);
    YFMSLockedDev = _amount;
    unlockDateDev = now;
    YFMSToken.transferFrom(owner, address(this), _amount);
  }

  // < 20,500 YFMS
  function lockRewardsTokens (address _from, uint256 _amount) public {
    require(_from == owner);
    require(YFMSToken.balanceOf(_from) >= _amount);
    YFMSLockedRewards = _amount;
    unlockDateRewards = now;
    YFMSToken.transferFrom(owner, address(this), _amount);
  }

  function withdrawDevTokens(address _to, uint256 _amount) public {
    require(_to == owner);
    require(_amount <= YFMSLockedDev);
    require(now.sub(unlockDateDev) >= 21 days);
    YFMSLockedDev = YFMSLockedDev.sub(_amount);
    YFMSToken.transfer(_to, _amount);
  }

  function withdrawRewardsTokens(address _to, uint256 _amount) public {
    require(_to == owner);
    require(_amount <= YFMSLockedRewards);
    require(now.sub(unlockDateRewards) >= 7 days);
    YFMSLockedRewards = YFMSLockedRewards.sub(_amount);
    YFMSToken.transfer(_to, _amount);
  }

  function balanceOf() public view returns (uint256) {
    return YFMSLockedDev.add(YFMSLockedRewards);
  }
}