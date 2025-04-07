/**
 *Submitted for verification at Etherscan.io on 2021-08-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract 





contract TokenHolder is Ownable {
    receive() external payable {}

    function transferERC20(
        address token,
        address to,
        uint256 value
    ) public onlyOwner {
        TransferHelper.safeTransfer(token, to, value);
    }

    function transferFromERC20(
        address token,
        address from,
        address to,
        uint256 value
    ) public onlyOwner {
        TransferHelper.safeTransferFrom(token, from, to, value);
    }

    function approveERC20(
        address token,
        address to,
        uint256 value
    ) public onlyOwner {
        TransferHelper.safeApprove(token, to, value);
    }

    function transferETH(address to, uint256 value) public onlyOwner {
        TransferHelper.safeTransferETH(to, value);
    }
}



contract MisoDutchSniper is TokenHolder {
    address public _sniper;

    function setSniper(address sniper) external onlyOwner {
        _sniper = sniper;
    }

    function snipe(
        address auction,
        uint256 value,
        uint256 timestamp,
        uint256 maxCommit
    ) external {
        // check timestamp
        if (block.timestamp < timestamp) {
            return;
        }
        // check commit progress
        uint256 commitProgress = uint256(IDutchAuction(auction).marketStatus().commitmentsTotal);
        if (commitProgress > maxCommit) {
            return;
        }
        // only sniper
        require(msg.sender == _sniper, "auth");
        // commit
        IDutchAuction(auction).commitEth{value: value}(payable(this), true);
    }
}