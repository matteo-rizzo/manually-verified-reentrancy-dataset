pragma solidity 0.6.0;





contract YLIQTokenLock {
  using SafeMath for uint256;

  uint256 public unlockDateRewards;
  uint256 public unlockDateDev;
  uint256 public YLIQLockedDev;
  uint256 public YLIQLockedRewards;
  address public owner;
  ERC20 public YLIQToken;

  constructor(address _wallet) public {
    owner = msg.sender; 
    YLIQToken = ERC20(_wallet);
  }

   
  function lockDevTokens (address _from, uint _amount) public {
    require(_from == owner);
    require(YLIQToken.balanceOf(_from) >= _amount);
    YLIQLockedDev = _amount;
    unlockDateDev = now;
    YLIQToken.transferFrom(owner, address(this), _amount);
  }

  
  function lockRewardsTokens (address _from, uint256 _amount) public {
    require(_from == owner);
    require(YLIQToken.balanceOf(_from) >= _amount);
    YLIQLockedRewards = _amount;
    unlockDateRewards = now;
    YLIQToken.transferFrom(owner, address(this), _amount);
  }

  function withdrawDevTokens(address _to, uint256 _amount) public {
    require(_to == owner);
    require(_amount <= YLIQLockedDev);
    require(now.sub(unlockDateDev) >= 56 days);
    YLIQLockedDev = YLIQLockedDev.sub(_amount);
    YLIQToken.transfer(_to, _amount);
  }

  function withdrawRewardsTokens(address _to, uint256 _amount) public {
    require(_to == owner);
    require(_amount <= YLIQLockedRewards);
    require(now.sub(unlockDateRewards) >= 14 days);
    YLIQLockedRewards = YLIQLockedRewards.sub(_amount);
    YLIQToken.transfer(_to, _amount);
  }

  function balanceOf() public view returns (uint256) {
    return YLIQLockedDev.add(YLIQLockedRewards);
  }
}