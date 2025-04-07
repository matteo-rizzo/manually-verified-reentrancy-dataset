/**
 *Submitted for verification at Etherscan.io on 2021-03-18
*/

pragma solidity = 0.6.6;









interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}





contract FlashLoaner {
  address immutable factory;
  uint constant deadline = 10 days;
  IUniswapV2Router02 immutable sushiRouter;

  constructor(address _factory, address _uniRouter, address _sushiRouter) public {
    factory = _factory;  
    sushiRouter = IUniswapV2Router02(_sushiRouter);
  } 

  function uniswapV2Call(address _sender, uint _amount0, uint _amount1, bytes calldata _data) external {
      address[] memory path = new address[](2);
      uint amountToken = _amount0 == 0 ? _amount1 : _amount0;
      
      address token0 = IUniswapV2Pair(msg.sender).token0();
      address token1 = IUniswapV2Pair(msg.sender).token1();

      require(msg.sender == UniswapV2Library.pairFor(factory, token0, token1), "Unauthorized"); 
      require(_amount0 == 0 || _amount1 == 0);

      path[0] = _amount0 == 0 ? token1 : token0; 
      path[1] = _amount0 == 0 ? token0 : token1;

      IERC20 token = IERC20(_amount0 == 0 ? token1 : token0);
      
      token.approve(address(sushiRouter), amountToken);

      // no need for require() check, if amount required is not sent sushiRouter will revert
      uint amountRequired = UniswapV2Library.getAmountsIn(factory, amountToken, path)[0];
      uint amountReceived = sushiRouter.swapExactTokensForTokens(amountToken, amountRequired, path, msg.sender, deadline)[1];

      // YEAHH PROFIT
      token.transfer(_sender, amountReceived - amountRequired);
    
  }
}