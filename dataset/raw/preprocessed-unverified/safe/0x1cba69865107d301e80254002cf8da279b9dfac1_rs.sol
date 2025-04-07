/**
 *Submitted for verification at Etherscan.io on 2021-08-06
*/

// SPDX-License-Identifier: GPL-2.0
pragma solidity =0.7.6;




contract cneDistributor {
    address constant usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address constant cne  = 0x8E7f3d3C40fc9668fF40E2FC42a26F97CbF7af7b;
    address public collector  = 0x84c0a9B2E776974aF843e4698888539D1B250591;

    function getCNE (uint256 usdtAmount) public{
        TransferHelper.safeTransferFrom(usdt, msg.sender, address(this), usdtAmount);
        //no need to convet the decimals, as 6 for usdt and 8 for cne, 0.01 in nature
        TransferHelper.safeTransfer(cne, msg.sender, usdtAmount);
        TransferHelper.safeTransfer(usdt, collector, usdtAmount);
    }
}