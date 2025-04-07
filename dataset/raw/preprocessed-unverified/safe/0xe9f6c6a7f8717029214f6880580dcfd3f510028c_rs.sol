/**
 *Submitted for verification at Etherscan.io on 2020-12-09
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











contract MoonFarm {
  using SafeMath for uint256;
  using SafeERC20 for IUniswapV2Pair;

  IUniswapV2Pair public lpToken = IUniswapV2Pair(address(0)); //Moonday-Mooncrops LP Token
  IUniswapV2Pair public cropsETHToken = IUniswapV2Pair(address(0)); //CROPS-WETH LP Token

  address weth;
  address crops;
  address moonday;

  address owner;
  address dev1;
  address dev2;
  address dev3;

  mapping(address => uint256) public refCode;
  mapping(uint256 => address) public refCodeIndex;
  uint256 public refCount = 50000000;

  mapping(address => mapping(uint256 => StakeData)) public stakeList;
  mapping(address => uint256) public stakeCount;

  struct StakeData{
    uint256 stakeTime;
    uint256 ethAmount;
  }

  event Staked(address indexed user, uint256 amount, uint256 stakeIndex);
  event RewardPaid(address indexed user, uint256 reward);

  constructor(address _lpToken, address _cropsETHToken, address _weth, address _crops, address _moonday, address _owner, address _dev1, address _dev2, address _dev3) public {
    require(_lpToken != address(0) && _cropsETHToken != address(0) && _weth != address(0) && _crops != address(0) && _moonday != address(0), "Invalid Contract Address");
    require(_owner != address(0) && _dev1 != address(0) && _dev2 != address(0) && _dev3 != address(0), "Invalid User Address");
    lpToken = IUniswapV2Pair(_lpToken);
    cropsETHToken = IUniswapV2Pair(_cropsETHToken);
    weth = _weth;
    crops = _crops;
    moonday = _moonday;
    owner = _owner;
    dev1 = _dev1;
    dev2 = _dev2;
    dev3 = _dev3;
  }

  /// Create a refcode for the user
  /// @dev assigns a refCode value to users incrementally
  /// @return refCode number
  function createRefCode() public returns (uint256){
    require(refCode[msg.sender] == 0, "You Already Have A RefCode");
    refCode[msg.sender] = refCount;
    refCodeIndex[refCount] = msg.sender;
    refCount++;
    return refCode[msg.sender];
  }

  /// Get current reward for stake
  /// @dev calculates returnable stake amount
  /// @param _user the user to query
  /// @param _index the stake index to query
  /// @return total stake reward
  function currentReward(address _user, uint256 _index) public view returns (uint256) {
    if(stakeList[msg.sender][_index].ethAmount == 0){
      return 0;
    }
    uint256 amount = stakeList[_user][_index].ethAmount;
    uint256 minutePercent = (block.timestamp - stakeList[msg.sender][_index].stakeTime).mul(8101851);

    uint cropReserves;
    uint wethCReserves;

    if(crops > weth){
      (wethCReserves, cropReserves,) = cropsETHToken.getReserves();
    }
    else{
      (cropReserves, wethCReserves,) = cropsETHToken.getReserves();
    }

    uint256 cropsPrice = cropReserves.mul(1 ether).div(wethCReserves);

    if(minutePercent > 18500000000000){
      return cropsPrice.mul(amount).div(1 ether).mul(18500000000000).div(5000000000000);
    }
    else{
      return cropsPrice.mul(amount).div(1 ether).mul(minutePercent).div(5000000000000);
    }
  }

  /// Stake LP token
  /// @dev stakes users LP tokens
  /// @param _amount the amount to stake
  /// @param _refCode optional referral code
  function stake(uint256 _amount, uint _refCode) public {
      require(_amount > 0, "Cannot stake 0");

      uint moondayReserves;
      uint cropReserves;
      uint cropMoonReserves;
      uint wethCReserves;

      if(moonday > crops){
        (cropMoonReserves, moondayReserves,) = lpToken.getReserves();
      }
      else{
        (moondayReserves, cropMoonReserves,) = lpToken.getReserves();
      }

      if(crops > weth){
        (wethCReserves, cropReserves,) = cropsETHToken.getReserves();
      }
      else{
        (cropReserves, wethCReserves,) = cropsETHToken.getReserves();
      }

      stakeList[msg.sender][stakeCount[msg.sender]].ethAmount = _amount.mul(cropMoonReserves).div(lpToken.totalSupply()).mul(wethCReserves.mul(1 ether).div(cropReserves)).div(1 ether);
      stakeList[msg.sender][stakeCount[msg.sender]].stakeTime = block.timestamp;
      lpToken.safeTransferFrom(msg.sender, address(this), _amount.mul(7).div(10));
      stakeCount[msg.sender]++;

      if(refCodeIndex[_refCode] != address(0)){
        lpToken.safeTransferFrom(msg.sender, owner, _amount.mul(22).div(100));
        lpToken.safeTransferFrom(msg.sender, dev1, _amount.div(100));
        lpToken.safeTransferFrom(msg.sender, dev2, _amount.div(100));
        lpToken.safeTransferFrom(msg.sender, dev3, _amount.div(100));
        lpToken.safeTransferFrom(msg.sender, refCodeIndex[_refCode], _amount.div(20));
      }
      else{
        lpToken.safeTransferFrom(msg.sender, owner, _amount.mul(27).div(100));
        lpToken.safeTransferFrom(msg.sender, dev1, _amount.div(100));
        lpToken.safeTransferFrom(msg.sender, dev2, _amount.div(100));
        lpToken.safeTransferFrom(msg.sender, dev3, _amount.div(100));
      }

      emit Staked(msg.sender, _amount, stakeCount[msg.sender] - 1);
  }

  /// Give staker their mooncrop reward
  /// @dev calculates claim and pays user
  /// @param _index the stake to query
  /// @return dividend claimed by user
  function claim(uint256 _index) public returns(uint256){
      require(stakeList[msg.sender][_index].ethAmount > 0, "Stake Doesnt Exist");

      uint256 reward = currentReward(msg.sender, _index);
      IERC20Custom(crops).farmMint(msg.sender, reward);
      stakeList[msg.sender][_index].ethAmount = 0;
      emit RewardPaid(msg.sender, reward);
      return reward;
  }

}