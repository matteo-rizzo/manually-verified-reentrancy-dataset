/**
 *Submitted for verification at Etherscan.io on 2021-07-05
*/

pragma solidity 0.8.0;




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

// SPDX-License-Identifier: MIT




contract UniswapPriceOracle {
  address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D ;

  IUniswapV2Router02 public uniswapRouter;
  address private Dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;  //Main net
    //  address public Dai = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;  //Kovan 

  constructor() {
    uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
  }

function getPathForDAItoEth() private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = Dai;
    path[1] = uniswapRouter.WETH();
    
    return path;
}

function getEstimatedDAIForEth(uint ethAmount) public view returns (uint256[] memory)
  {

    return uniswapRouter.getAmountsIn(ethAmount, getPathForDAItoEth());

    
  }

}