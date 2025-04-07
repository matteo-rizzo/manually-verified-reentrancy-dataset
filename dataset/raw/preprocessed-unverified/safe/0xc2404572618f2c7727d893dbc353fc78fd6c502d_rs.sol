/**
 *Submitted for verification at Etherscan.io on 2021-03-31
*/

pragma solidity 0.6.2;

contract FreedomDividendSwap {

  constructor()
  public
  {
    uniswapRouter = IUniswapV2Router02(UniswapV2Router2);
    owner = msg.sender;
  }

  string private version = "v1";

  address private UniswapV2Router2=0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

  IUniswapV2Router02 private uniswapRouter;
  
  uint private swapFeeModifier = 500;
  
  address private owner;
  
  uint private swapReward = 277778;
  
  address private FDCContract=0x311C6769461e1d2173481F8d789AF00B39DF6d75;

  function Swap(string memory swapFunction, uint amountIn, uint amountOutMin, address[] memory path, uint deadline) public payable returns (bool) {
    
    if (keccak256(abi.encodePacked((swapFunction))) == keccak256(abi.encodePacked(("swapExactETHForTokens")))) {
        uint swapFee = msg.value / swapFeeModifier;
        require(swapFee > 0, "Swap Fee needs to be higher than 0");
        uint finalValue = msg.value - swapFee;
        require(finalValue > 0, "finalValue needs to be higher than 0");
        
        uniswapRouter.swapExactETHForTokens{value:finalValue}(amountOutMin, path, msg.sender, deadline);
        
        giveReward();
        
        return true;
    } else if (keccak256(abi.encodePacked((swapFunction))) == keccak256(abi.encodePacked(("swapExactTokensForETH")))) {
        require(msg.value > 0, "Swap Fee needs to be higher than 0");
        
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, address(this), amountIn
        );
        
        TransferHelper.safeApprove(
            path[0], UniswapV2Router2, amountIn
        );
        
        uniswapRouter.swapExactTokensForETH(amountIn, amountOutMin, path, msg.sender, deadline);
        
        giveReward();
        
        return true;
    } else if (keccak256(abi.encodePacked((swapFunction))) == keccak256(abi.encodePacked(("swapExactTokensForTokens")))) {
        require(msg.value > 0, "Swap Fee needs to be higher than 0");
        
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, address(this), amountIn
        );
        
        TransferHelper.safeApprove(
            path[0], UniswapV2Router2, amountIn
        );
        
        uniswapRouter.swapExactTokensForTokens(amountIn, amountOutMin, path, msg.sender, deadline);
        
        giveReward();
        
        return true;
    } else {
        return false;
    }
  }
  
  function giveReward() internal {
    (bool successBalance, bytes memory dataBalance) = FDCContract.call(abi.encodeWithSelector(bytes4(keccak256(bytes('balanceOf(address)'))), address(this)));
    require(successBalance, "Freedom Dividend Coin swap reward balanceOf failed.");
    uint rewardLeft = abi.decode(dataBalance, (uint));

    if (rewardLeft >= swapReward) {
        (bool successTransfer, bytes memory dataTransfer) = FDCContract.call(abi.encodeWithSelector(bytes4(keccak256(bytes('transfer(address,uint256)'))), msg.sender, swapReward));
        require(successTransfer, "Freedom Dividend Coin swap reward failed.");
    }
  }

  function getVersion() public view returns (string memory) {
    return version;
  }
  
  function withdraw(uint value) public returns (bool) {
    require(msg.sender == owner, "Only owner can use");
    TransferHelper.safeTransferETH(
          owner, value
    );
    return true;
  }
  
  function setReward(uint value) public returns (bool) {
    require(msg.sender == owner, "Only owner can use");
    swapReward = value;
    return true;
  }
  
  function getReward() public view returns (uint) {
    return swapReward;
  }

}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false




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