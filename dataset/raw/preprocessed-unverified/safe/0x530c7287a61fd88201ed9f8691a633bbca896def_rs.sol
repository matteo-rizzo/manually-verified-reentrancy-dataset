/**
 *Submitted for verification at Etherscan.io on 2021-09-04
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.6;
pragma abicoder v2;





















contract FeeConverter is Ownable, IFeeConverter {

  IERC20 private constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

  using BytesLib for bytes;

  uint private maxSlippage;  // 1e18 = 1%

  // Only large liquid tokens: ETH, DAI, USDC, WBTC, etc
  mapping (address => bool) public permittedTokens;

  ISwapRouter         public immutable uniswapRouter;
  IERC20              public wildToken;
  IPairFactory        public factory;
  ILendingController  public lendingController;
  address             public stakingPool;
  address             public treasury;
  uint                public callIncentive;
  uint                public daoShareWETH; // 1e18 = 1%

  constructor(
    ISwapRouter        _uniswapRouter,
    IPairFactory       _factory,
    ILendingController _lendingController,
    IERC20             _wildToken,
    address            _stakingPool,
    address            _treasury,
    uint               _callIncentive,
    uint               _maxSlippage,
    uint               _daoShareWETH
  ) {
    uniswapRouter     = _uniswapRouter;
    factory           = _factory;
    lendingController = _lendingController;
    wildToken         = _wildToken;
    stakingPool       = _stakingPool;
    treasury          = _treasury;
    callIncentive     = _callIncentive;
    maxSlippage       = _maxSlippage;
    daoShareWETH      = _daoShareWETH;
  }

  function convert(
    address          _incentiveRecipient,
    ILendingPair     _pair,
    bytes memory     _path,
    uint             _supplyTokenAmount,
    uint             _minWildOutput
  ) external override returns(uint) {

    _validatePair(_pair);
    _validatePath(_path, _pair);

    address supplyToken = _path.toAddress(0);

    require(_supplyTokenAmount > 0, "FeeConverter: nothing to convert");

    // Must wait until TWAP is lower than the spot price
    require(_minWildOutput >= minWildOutput(supplyToken, _supplyTokenAmount), "FeeConverter: _minWildOutput too low");

    _pair.withdraw(supplyToken, _supplyTokenAmount);

    if (supplyToken == address(WETH)) {

      uint daoAmount = _supplyTokenAmount * daoShareWETH / 100e18;
      WETH.transfer(treasury, daoAmount);

      _supplyTokenAmount -= daoAmount;
      _minWildOutput     -= _minWildOutput * (daoShareWETH) / 100e18;
    }

    IERC20(supplyToken).approve(address(uniswapRouter), type(uint).max);

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

  function setTreasury(address _value) external onlyOwner {
    treasury = _value;
  }

  function setDaoShareWETH(uint _value) external onlyOwner {
    daoShareWETH = _value;
  }

  function setMaxSlippage(uint _value) external onlyOwner {
    maxSlippage = _value;
  }

  function setCallIncentive(uint _value) external onlyOwner {
    callIncentive = _value;
  }

  function permitToken(address _token, bool _value) external override onlyOwner {
    permittedTokens[_token] = _value;
  }

  // To prevent sandwitch attacks, check the the ouput is over WILD twap
  function minWildOutput(address _fromToken, uint _fromAmount) public view returns(uint) {

    uint priceFrom = lendingController.tokenPrice(_fromToken)         * 1e18 / 10 ** IERC20(_fromToken).decimals();
    uint priceTo   = lendingController.tokenPrice(address(wildToken)) * 1e18 / 10 ** IERC20(address(wildToken)).decimals();

    return (_fromAmount * priceFrom / priceTo) * (100e18 - maxSlippage) / 100e18;
  }

  function _validatePath(bytes memory _path, ILendingPair _pair) internal view {

    // check input token
    address inputToken = _path.toAddress(0);
    require(
      inputToken == _pair.tokenA() ||
      inputToken == _pair.tokenB(),
      "FeeConverter: invalid input token"
    );

    // check last token
    require(_path.toAddress(_path.length-20) == address(wildToken), "FeeConverter: must convert into WILD");

    uint numPools = ((_path.length - 20) / 23);

    // Validate only middle tokens. Skip the first and last token.
    for (uint8 i = 1; i < numPools; i++) {
      address token = _path.toAddress(23*i);
      require(permittedTokens[token], "FeeConverter: invalid path");
    }
  }

  function _validatePair(ILendingPair _pair) internal view {
    require(
      address(_pair) == factory.pairByTokens(_pair.tokenA(), _pair.tokenB()),
      "FeeConverter: invalid lending pair"
    );
  }

  function _approveIfNeeded(IERC20 _token, address _spender, uint _amount) internal {
    if (_token.allowance(address(this), _spender) < _amount) {
      _token.approve(_spender, 0);
      _token.approve(_spender, type(uint).max);
    }
  }
}