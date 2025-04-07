/**
 *Submitted for verification at Etherscan.io on 2021-09-07
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.6;
pragma abicoder v2;



















contract FeeConverter is Ownable, IFeeConverter {

  IERC20 private constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

  using BytesLib for bytes;

  IERC20              public wildToken;
  IPairFactory        public factory;
  ILendingController  public lendingController;
  address             public stakingPool;
  address             public treasury;
  uint                public callIncentive;
  uint                public daoShareWETH; // 1e18 = 1%

  constructor(
    IPairFactory       _factory,
    ILendingController _lendingController,
    IERC20             _wildToken,
    address            _stakingPool,
    address            _treasury,
    uint               _callIncentive,
    uint               _daoShareWETH
  ) {
    factory           = _factory;
    lendingController = _lendingController;
    wildToken         = _wildToken;
    stakingPool       = _stakingPool;
    treasury          = _treasury;
    callIncentive     = _callIncentive;
    daoShareWETH      = _daoShareWETH;
  }

  /*
   * Previous version was converting fees via Uniswap in this contract.
   * The new version uses TWAP to pull WILD balance from the caller.
   * This allows the caller to use any pool to source liquidity
   * and get lower slippage which is similar to how liquidations work.
   * Since migrating fee recipient would incur very high gas costs,
   * we're leaving the same function interface here for backward compatibility
   *
   * _notUsedAnymore - not used anymore, set to zero
   * _path - we only need the first token in the path
  */
  function convert(
    address          _originalCaller,
    ILendingPair     _pair,
    bytes memory     _path,
    uint             _supplyTokenAmount,
    uint             _notUsedAnymore
  ) external override returns(uint) {

    address supplyToken = _path.toAddress(0);

    _validatePair(_pair);
    _validateToken(_pair, supplyToken);
    require(_supplyTokenAmount > 0, "FeeConverter: nothing to convert");

    _pair.withdraw(supplyToken, _supplyTokenAmount);
    uint inputAmount = _supplyTokenAmount - _collectDaoShare(supplyToken, _supplyTokenAmount);

    uint wildAmount = wildInput(supplyToken, inputAmount);
    IERC20(supplyToken).transfer(_originalCaller, inputAmount);
    wildToken.transferFrom(_originalCaller, stakingPool, wildAmount);

    return wildAmount;
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

  function setCallIncentive(uint _value) external onlyOwner {
    callIncentive = _value;
  }

  function wildInput(address _fromToken, uint _fromAmount) public view returns(uint) {

    uint priceFrom = lendingController.tokenPrice(_fromToken)         * 1e18 / 10 ** IERC20(_fromToken).decimals();
    uint priceTo   = lendingController.tokenPrice(address(wildToken)) * 1e18 / 10 ** IERC20(address(wildToken)).decimals();

    uint input = (_fromAmount * priceFrom / priceTo) * (100e18 - callIncentive) / 100e18;

    return input;
  }

  function _collectDaoShare(address _token, uint _amount) internal returns(uint daoAmount) {
    if (_token == address(WETH)) {
      daoAmount = _amount * daoShareWETH / 100e18;
      WETH.transfer(treasury, daoAmount);
    }
  }

  function _validateToken(ILendingPair _pair, address _token) internal view {
    require(
      _token == _pair.tokenA() ||
      _token == _pair.tokenB(),
      "FeeConverter: invalid input token"
    );
  }

  function _validatePair(ILendingPair _pair) internal view {
    require(
      address(_pair) == factory.pairByTokens(_pair.tokenA(), _pair.tokenB()),
      "FeeConverter: invalid lending pair"
    );
  }
}