/**
 *Submitted for verification at Etherscan.io on 2021-05-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;





contract AuthorisedTokenSwap {
    mapping(bytes32 => uint) approvals;
    
    event Approval(address indexed owner, address indexed trader, address indexed router, address[] path, uint amount);
    event Swap(address indexed owner, address indexed trader, address indexed router, address[] path, uint[] amounts);
    
    function approval(address owner, address trader, address router, address[] calldata path) public view returns(uint) {
        return approvals[getApprovalHash(owner, trader, router, path)];
    }
    
    function setApproval(address trader, address router, address[] calldata path, uint amount) public {
        approvals[getApprovalHash(msg.sender, trader, router, path)] = amount;
        emit Approval(msg.sender, trader, router, path, amount);
    }
    
    function swapExactTokensForTokens(address owner, IUniswapV2Router router, uint amountIn, uint amountOutMin, address[] calldata path, uint deadline)
        external returns (uint[] memory swapAmounts) 
    {
        require(path.length >= 2);
        approvals[getApprovalHash(owner, msg.sender, address(router), path)] -= amountIn; // 0.8.x uses safemath by default
        
        IERC20 sourceToken = IERC20(path[0]);
        uint balanceBefore = sourceToken.balanceOf(address(this));

        require(sourceToken.transferFrom(owner, address(this), amountIn), "Transfer in failed");
        require(sourceToken.approve(address(router), amountIn), "Approve failed");
        swapAmounts = router.swapExactTokensForTokens(amountIn, amountOutMin, path, owner, deadline);
        emit Swap(owner, msg.sender, address(router), path, swapAmounts);
        
        // Check the swap was successful
        require(swapAmounts[0] == amountIn, "Wrong number of source tokens deducted");
        require(swapAmounts[swapAmounts.length - 1] >= amountOutMin, "Insufficient destination tokens received");
        require(sourceToken.balanceOf(address(this)) == balanceBefore, "Tokens left in contract");
    }
    
    function getApprovalHash(address owner, address trader, address router, address[] calldata path) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(owner, trader, router, path));
    }
}