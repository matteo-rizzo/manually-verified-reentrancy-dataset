/**
 *Submitted for verification at Etherscan.io on 2021-07-28
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.6;
pragma abicoder v2;



















contract FeeConverter is Ownable, IFeeConverter {

  using BytesLib for bytes;

  uint private constant MAX_INT = 2**256 - 1;

  // Only large liquid tokens: ETH, DAI, USDC, WBTC, etc
  mapping (address => bool) public permittedTokens;

  ISwapRouter public immutable uniswapRouter;
  IERC20         public wildToken;
  IController    public controller;
  address        public stakingPool;
  uint           public callIncentive;

  constructor(
    ISwapRouter    _uniswapRouter,
    IController    _controller,
    IERC20         _wildToken,
    address        _stakingPool,
    uint           _callIncentive
  ) {
    uniswapRouter = _uniswapRouter;
    controller    = _controller;
    stakingPool   = _stakingPool;
    callIncentive = _callIncentive;
    wildToken     = _wildToken;
  }

  function convert(
    address          _incentiveRecipient,
    ILendingPair     _pair,
    bytes memory     _path,
    uint             _supplyTokenAmount,
    uint             _minWildOutput
  ) external override returns(uint) {

    _validatePath(_path);
    require(_pair.controller() == controller, "FeeConverter: invalid pair");
    require(_supplyTokenAmount > 0, "FeeConverter: nothing to convert");

    address supplyToken = _path.toAddress(0);

    _pair.withdraw(supplyToken, _supplyTokenAmount);
    IERC20(supplyToken).approve(address(uniswapRouter), MAX_INT);

    uniswapRouter.exactInput(
      ISwapRouter.ExactInputParams(
        _path,
        address(this),
        block.timestamp + 1000,
        _supplyTokenAmount,
        _minWildOutput
      )
    );

    uint wildBalance = wildToken.balanceOf(address(this));
    uint callerIncentive = wildBalance * callIncentive / 100e18;
    wildToken.transfer(_incentiveRecipient, callerIncentive);
    wildToken.transfer(stakingPool, wildBalance - callerIncentive);

    return (wildBalance - callerIncentive);
  }

  function setStakingRewards(address _value) external onlyOwner {
    stakingPool = _value;
  }

  function setController(IController _value) external onlyOwner {
    controller = _value;
  }

  function setCallIncentive(uint _value) external onlyOwner {
    callIncentive = _value;
  }

  function permitToken(address _token, bool _value) external onlyOwner {
    permittedTokens[_token] = _value;
  }

  function _validatePath(bytes memory _path) internal view {

    // check last token
    require(_path.toAddress(_path.length-20) == address(wildToken), "FeeConverter: must convert into WILD");

    uint numPools = ((_path.length - 20) / 23);

    // Validate only middle tokens. Skip the first and last token.
    for (uint8 i = 1; i < numPools; i++) {
      address token = _path.toAddress(23*i);
      require(permittedTokens[token], "FeeConverter: invalid path");
    }
  }
}