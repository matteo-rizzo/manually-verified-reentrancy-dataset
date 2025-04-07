/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.11;






/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */








contract MoonStake {
  using SafeMath for uint256;
  using SafeERC20 for IUniswapV2Pair;

  IUniswapV2Pair public lpToken = IUniswapV2Pair(address(0)); //Moonday-Mooncrops LP Token
  IUniswapV2Pair public moonETHToken = IUniswapV2Pair(address(0)); //Moonday-WETH LP Token

  address weth;
  address crops;
  address moonday;

  address owner;
  address dev1;
  address dev2;
  address dev3;
  address controller;

  modifier onlyDev() {
        require(msg.sender == controller, "Not Dev");
        _;
    }

  mapping(address => UserData) public userList;

  mapping(address => mapping(uint256 => StakeData)) public stakeList;
  mapping(address => uint256) public stakeCount;

  uint256 public burnCount;
  mapping(uint256 => BurnData) public burnList;
  bool burnLock;

  struct BurnData{
    uint256 burnStart;
    uint256 reserveSnapshot0;
    uint256 reserveSnapshot1;
    uint256 percentageSnapshot;

    uint256 finalReserveSnapshot0;
    uint256 finalReserveSnapshot1;
    uint256 finalPercentageSnapshot;

    uint256 totalFees;
    uint256 totalBurn;
  }

  struct UserData{
    uint256 moondayEthStaked;
    uint256 percentage;
    uint256 reserveConstant;
    uint256 percentageSnapshot;
    mapping(uint256 => uint256) burnStake;
  }

  struct StakeData{
    uint256 stakeTime;
    uint256 amount;
    uint256 claimed;
  }

  event Staked(address indexed user, uint256 amount, uint256 stakeIndex);
  event RewardPaid(address indexed user, uint256 reward);

  constructor(address _weth, address _owner, address _dev1, address _dev2, address _dev3) public {
    require(_owner != address(0) && _dev1 != address(0) && _dev2 != address(0) && _dev3 != address(0), "Invalid User Address");
    weth = _weth;
    owner = _owner;
    dev1 = _dev1;
    dev2 = _dev2;
    dev3 = _dev3;
    controller = msg.sender;
  }


  function getBurnStake(address _user, uint256 _week) public view returns(uint256){
    return(userList[_user].burnStake[_week]);
  }

  function setBurnLock() public onlyDev{
    burnLock = !burnLock;
  }

  function setLPTokens(address _lpToken, address _moonEthToken, address _crops, address _moonday) public onlyDev{
    lpToken = IUniswapV2Pair(_lpToken);
    moonETHToken = IUniswapV2Pair(_moonEthToken);
    crops = _crops;
    moonday = _moonday;
  }

  /// Get current reward for stake
  /// @dev calculates returnable stake amount
  /// @param _user the user to query
  /// @param _index the stake index to query
  /// @return total stake reward
  function currentReward(address _user, uint256 _index) public view returns (uint256) {
    if(stakeList[msg.sender][_index].amount == 0){
      return 0;
    }

    uint256 secondsPercent = (20 + userList[msg.sender].percentage).mul(1 ether).div(864000);
    uint256 secPayout = secondsPercent.mul(block.timestamp - stakeList[msg.sender][_index].stakeTime);

    uint cropReserves;
    uint moonReserves;

    if(crops > moonday){
      (moonReserves, cropReserves,) = lpToken.getReserves();
    }
    else{
      (cropReserves, moonReserves,) = lpToken.getReserves();
    }

    uint256 cropsAmount = stakeList[_user][_index].amount.mul(cropReserves).div(lpToken.totalSupply());
    if(secPayout > 185 ether){
      return cropsAmount.mul(185 ether).div(50 ether);
    }
    else{
      return cropsAmount.mul(secPayout).div(50 ether);
    }
  }

  /// Stake LP token
  /// @dev stakes users LP tokens
  /// @param _amount the amount to stake
  function stake(uint256 _amount) public {
      require(_amount >= (1 ether), "Cannot stake less than 1 LP token");

      lpToken.safeTransferFrom(msg.sender, address(this), _amount);
      lpToken.transfer(owner, _amount.mul(23).div(100));
      lpToken.transfer(dev1, _amount.div(20));
      lpToken.transfer(dev2, _amount.div(100));
      lpToken.transfer(dev3, _amount.div(100));

      stakeList[msg.sender][stakeCount[msg.sender]].amount = _amount;
      stakeList[msg.sender][stakeCount[msg.sender]].stakeTime = block.timestamp;
      stakeCount[msg.sender]++;

      emit Staked(msg.sender, _amount, stakeCount[msg.sender] - 1);
  }

  /// Deposit Moonday/ETH LP in exchange for a higher percentage
  /// @dev stakes users Moonday/ETH LP tokens
  /// @param _amount the amount to stake
  function depositMoondayETH(uint256 _amount) public{
    require(userList[msg.sender].percentage + _amount <= 50, "You have deposited the maximum amount");

    uint wethReserves;
    uint moonReserves;

    if(weth > moonday){
      (moonReserves, wethReserves,) = moonETHToken.getReserves();
    }
    else{
      (wethReserves, moonReserves,) = moonETHToken.getReserves();
    }

    uint256 lpRequired = uint256(1 ether).mul(moonETHToken.totalSupply()).div(moonReserves).div(10);

    moonETHToken.safeTransferFrom(msg.sender, address(this), lpRequired.mul(_amount));
    moonETHToken.transfer(owner, lpRequired.mul(_amount).div(20));
    moonETHToken.transfer(dev1, lpRequired.mul(_amount).div(20));
    moonETHToken.transfer(dev2, lpRequired.mul(_amount).div(100));
    moonETHToken.transfer(dev3, lpRequired.mul(_amount).div(100));

    (uint256 reserveSnapshot0, uint256 reserveSnapshot1,) = moonETHToken.getReserves();
    uint256 finalPercentageSnapshot = userList[msg.sender].moondayEthStaked.mul(1 ether).div(moonETHToken.totalSupply());

    uint256 constantFirst = userList[msg.sender].reserveConstant.mul(userList[msg.sender].percentageSnapshot);
    uint256 constantSecond = reserveSnapshot0.mul(reserveSnapshot1).mul(finalPercentageSnapshot);

    uint256 totalFees = 0;

    if(userList[msg.sender].percentage != 0){
      uint256 deltaPercentage = constantSecond.mul(1 ether).div(constantFirst);
      if(deltaPercentage.mul(userList[msg.sender].moondayEthStaked).div(1 ether) > userList[msg.sender].moondayEthStaked){
        totalFees = deltaPercentage.mul(userList[msg.sender].moondayEthStaked).div(1 ether).sub(userList[msg.sender].moondayEthStaked);
      }
    }

    userList[msg.sender].moondayEthStaked += lpRequired.mul(_amount).mul(88).div(100);
    userList[msg.sender].moondayEthStaked = userList[msg.sender].moondayEthStaked.sub(totalFees);
    userList[msg.sender].percentage += _amount;

    userList[msg.sender].percentageSnapshot = userList[msg.sender].moondayEthStaked.mul(1 ether).div(moonETHToken.totalSupply());
    userList[msg.sender].reserveConstant = reserveSnapshot0.mul(reserveSnapshot1);
  }

  /// Withdraws Moonday/ETH LP in exchange for a lower percentage
  /// @dev withdraws users Moonday/ETH LP tokens
  /// @param _amount the amount to stake
  function withdrawMoondayETH(uint256 _amount) public{
    require(userList[msg.sender].percentage >= _amount, "You cannot withdraw this amount");

    uint256 balance = userList[msg.sender].moondayEthStaked.mul(_amount).div(userList[msg.sender].percentage);

    (uint256 finalReserveSnapshot0, uint256 finalReserveSnapshot1,) = moonETHToken.getReserves();
    uint256 finalPercentageSnapshot = balance.mul(1 ether).div(moonETHToken.totalSupply());


    uint256 constantFirst = userList[msg.sender].reserveConstant.mul(userList[msg.sender].percentageSnapshot.mul(_amount).div(userList[msg.sender].percentage));
    uint256 constantSecond = finalReserveSnapshot0.mul(finalReserveSnapshot1).mul(finalPercentageSnapshot);

    uint256 deltaPercentage = constantSecond.mul(1 ether).div(constantFirst);
    uint256 totalFees = 0;

    if(deltaPercentage.mul(balance).div(1 ether) > balance){
      totalFees = deltaPercentage.mul(balance).div(1 ether).sub(balance);
    }

    uint256 lpReturn = balance.sub(totalFees);
    burnList[burnCount].totalFees += totalFees;
    moonETHToken.transfer(msg.sender, lpReturn);
    userList[msg.sender].moondayEthStaked -= userList[msg.sender].moondayEthStaked.mul(_amount).div(userList[msg.sender].percentage);
    userList[msg.sender].percentage -= _amount;
    userList[msg.sender].percentageSnapshot = userList[msg.sender].moondayEthStaked.mul(1 ether).div(moonETHToken.totalSupply());
    //userList[msg.sender].reserveConstant = finalReserveSnapshot0.mul(finalReserveSnapshot1);
  }

  /// Give staker their mooncrop reward
  /// @dev calculates claim and pays user
  /// @param _index the stake to query
  /// @return dividend claimed by user
  function claim(uint256 _index) public returns(uint256){
      require(stakeList[msg.sender][_index].amount > 0, "Stake Doesnt Exist");

      uint256 reward = currentReward(msg.sender, _index).sub(stakeList[msg.sender][_index].claimed);
      IERC20Custom(crops).farmMint(msg.sender, reward);
      stakeList[msg.sender][_index].claimed += reward;
      emit RewardPaid(msg.sender, reward);
      return reward;
  }

  function burnMining(uint256 _amount) public{
    require(!burnLock, "Function Locked");
    IERC20Custom(crops).transferFrom(msg.sender, address(this), _amount.mul(1 ether));
    IERC20Custom(crops).burn(_amount.mul(1 ether));
    burnList[burnCount].totalBurn += _amount.mul(1 ether);
    userList[msg.sender].burnStake[burnCount] += _amount.mul(1 ether);
  }

  function payoutBurns() public onlyDev{
    uint256 balance = moonETHToken.balanceOf(address(this));

    (burnList[burnCount].finalReserveSnapshot0, burnList[burnCount].finalReserveSnapshot1,) = moonETHToken.getReserves();
    burnList[burnCount].finalPercentageSnapshot = moonETHToken.balanceOf(address(this)).mul(1 ether).div(moonETHToken.totalSupply());

    uint256 constantFirst = burnList[burnCount].reserveSnapshot0.mul(burnList[burnCount].reserveSnapshot1).mul(burnList[burnCount].percentageSnapshot);
    uint256 constantSecond = burnList[burnCount].finalReserveSnapshot0.mul(burnList[burnCount].finalReserveSnapshot1).mul(burnList[burnCount].finalPercentageSnapshot);

    if(constantFirst != 0 && constantSecond != 0){
      uint256 deltaPercentage = constantSecond.mul(1 ether).div(constantFirst);
      if(deltaPercentage.mul(balance).div(1 ether) > balance){
        burnList[burnCount].totalFees += deltaPercentage.mul(balance).div(1 ether).sub(balance);
      }
    }

    burnCount++;
    burnList[burnCount].burnStart = block.timestamp;
    (burnList[burnCount].reserveSnapshot0, burnList[burnCount].reserveSnapshot1,) = moonETHToken.getReserves();
    burnList[burnCount].percentageSnapshot = moonETHToken.balanceOf(address(this)).mul(1 ether).div(moonETHToken.totalSupply());
  }

  function claimBurns(uint256 _week) public{
    require(burnList[_week].finalPercentageSnapshot != 0, "Burn Not Finished Yet");
    require(!burnLock, "Function Locked");
    uint256 divs = userList[msg.sender].burnStake[_week].mul(burnList[_week].totalFees).div(burnList[_week].totalBurn);

    moonETHToken.transfer(msg.sender, divs);
    userList[msg.sender].burnStake[_week] = 0;
  }

}