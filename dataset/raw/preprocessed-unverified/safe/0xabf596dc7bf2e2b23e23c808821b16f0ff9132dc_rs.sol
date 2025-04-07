/**
 *Submitted for verification at Etherscan.io on 2021-09-16
*/

pragma solidity ^0.8.0;




contract BatchValidatingPointList {
    function hasPoints(address who, uint newCommitment) public view returns (bool) {
        BatchAuctionLike auction = BatchAuctionLike(msg.sender);
        BatchAuctionLike.MarketStatus memory status = auction.marketStatus();

        uint expectedEth = status.commitmentsTotal - auction.commitments(who) + newCommitment;
        require(address(auction).balance >= expectedEth, "BatchValidatingPointList/invalid-eth");

        return true;
    }
}