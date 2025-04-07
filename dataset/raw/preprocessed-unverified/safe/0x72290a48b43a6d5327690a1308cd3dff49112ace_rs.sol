/**
 *Submitted for verification at Etherscan.io on 2020-11-09
*/

pragma solidity =0.6.12;











contract TitanAutoSwap is ITitanAutoSwap {
    
     using SafeMath for uint;
     address public immutable router;
  
     constructor(address _router) public {
         router = _router;
     }
     
     function swapForPair(address token0,address token1,uint amount0,uint amount1,uint deadline) external override payable {
         address factory = ITitanSwapV1Router01(router).factory();
         address pair = TitanSwapV1Library.pairFor(factory, token0, token1);
         require(pair != address(0),'TitanAutoSwap pair not exist');
         
         TransferHelper.safeTransferFrom(token0,msg.sender,address(this),amount0);
         TransferHelper.safeApprove(token0,router,amount0);
         
         address[] memory path = new address[](2);
         path[0] = token0;
         path[1] = token1;
         
         uint[] memory amounts = TitanSwapV1Library.getAmountsOut(factory, amount0, path);
         // swap token0 for token1
         ITitanSwapV1Router01(router).swapExactTokensForTokens(amount0,amounts[1],path,msg.sender,deadline);
         
         TransferHelper.safeTransferFrom(token1,msg.sender,address(this),amount1);
         TransferHelper.safeApprove(token1,router,amount1);
         
         path[0] = token1;
         path[1] = token0;
         
         amounts = TitanSwapV1Library.getAmountsOut(factory, amount1, path);
         // swap token1 for token0
         ITitanSwapV1Router01(router).swapExactTokensForTokens(amount1,amounts[1],path,msg.sender,deadline);
     }
    
}







// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
