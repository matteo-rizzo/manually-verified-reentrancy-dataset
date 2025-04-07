pragma solidity 0.6.0;





contract YFMSTokenLocks {
  using SafeMath for uint256;

  uint256 public endDateRewards;
  uint256 public YFMSLockedRewards;
  address public owner;
  ERC20 public YFMSToken;

  constructor(address _wallet) public {
    owner = msg.sender; 
    YFMSToken = ERC20(_wallet);
  }

  // < 20,500 YFMS
  function lockRewardsTokens (address _from, uint256 _amount) public {
    require(_from == owner);
    require(YFMSToken.balanceOf(_from) >= _amount);
    YFMSLockedRewards = _amount;
    endDateRewards = now.add(7 days);
    YFMSToken.transferFrom(_from, address(this), _amount);
  }

  function withdrawRewardsTokens(address _to, uint256 _amount) public {
    require(msg.sender == owner);
    require(_amount <= YFMSLockedRewards);
    require(now >= endDateRewards);
    YFMSLockedRewards = YFMSLockedRewards.sub(_amount);
    YFMSToken.transfer(_to, _amount);
  }

  function incrementTimelockOneDay() public {
    require(msg.sender == owner);
    endDateRewards = endDateRewards.add(2 days); 
  }

  function balanceOf() public view returns (uint256) {
    return YFMSLockedRewards;
  }
}