/**
 *Submitted for verification at Etherscan.io on 2021-09-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */






 /**
 * @title AddLiquidity
 * @dev AddLiquidity Contract to add liquidity 
 */
 contract AddLiquidity {
     
    using SafeMath for uint256;
    
    // variable to store uniswap router contract address
    address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    
    // variable for total added liquidity in contract
    uint256 public totalAddedLiquidityInContract = 0;

    IUniswap public uniswap;

    constructor() public {
        uniswap = IUniswap(UNISWAP_ROUTER_ADDRESS);
    }
    
    function addLiq(address token,uint amountTokenDesired) external payable returns(bool) {
        require(token != address(0),"Invalid Token Address, Please Try Again!!!"); 
        require(amountTokenDesired > 0,"Amount is invalid or zero, Please Try Again!!!");
        IERC20(token).transferFrom(msg.sender, address(this), amountTokenDesired);
        IERC20(token).approve(UNISWAP_ROUTER_ADDRESS, amountTokenDesired);
        uniswap.addLiquidityETH{value: msg.value}(token, amountTokenDesired, 10000000000000000, 10000000000000000,msg.sender,now + 3600);
        totalAddedLiquidityInContract = totalAddedLiquidityInContract.add(amountTokenDesired);
        return true;
    }
        
    receive() external payable {}
    fallback() external payable {}
 }