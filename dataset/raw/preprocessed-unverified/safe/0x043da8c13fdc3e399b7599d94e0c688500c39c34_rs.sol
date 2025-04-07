/**
 *Submitted for verification at Etherscan.io on 2021-02-17
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;





contract EnglishAuction {
    using SafeMath for uint256;

    // System settings
    uint256 public id;
    address public token;
    bool public ended = false;
    uint256 public startBidTime;
    address payable public haus;
    address payable public seller;
    uint256 public bidLength = 24 hours;
    uint256 public auctionLength = 24 hours;

    // Current winning bid
    uint256 public lastBid;
    uint256 public lastBidTime;
    address payable public winning;

    event Bid(address who, uint256 amount);
    event Won(address who, uint256 amount);

    constructor(uint256 _start, address payable _seller, address payable _haus) public {
        token = address(0x13bAb10a88fc5F6c77b87878d71c9F1707D2688A);
        id = 31;
        startBidTime = _start;
        lastBid = 0.55 ether;
        seller = _seller;
        haus = _haus;
    }

    function bid() public payable {
        require(msg.sender == tx.origin, "no contracts");
        require(block.timestamp >= startBidTime, "Auction not started");
        require(block.timestamp < startBidTime.add(auctionLength), "Auction ended");
        require(msg.value >= lastBid.mul(105).div(100), "Bid too small");

        // Give back the last bidders money
        if (lastBidTime != 0) {
            require(block.timestamp < lastBidTime.add(bidLength), "Auction ended");
            winning.transfer(lastBid);
        }

        lastBid = msg.value;
        winning = msg.sender;
        lastBidTime = block.timestamp;

        emit Bid(msg.sender, msg.value);
    }

    function end() public {
        require(!ended, "end already called");
        require(lastBidTime != 0, "no bids");
        require(block.timestamp >= lastBidTime.add(bidLength) || block.timestamp >= startBidTime.add(auctionLength), "Auction live");

        // transfer erc1155 to winner
        IERC1155(token).safeTransferFrom(address(this), winning, id, 1, new bytes(0x0));

        uint256 balance = address(this).balance;
        uint256 hausFee = balance.div(20).mul(3);
        haus.transfer(hausFee);
        seller.transfer(address(this).balance);

        ended = true;

        emit Won(winning, lastBid);
    }

    function pull() public {
        require(!ended, "end already called");
        require(lastBidTime == 0, "There were bids");
        require(block.timestamp >= startBidTime.add(auctionLength), "Auction live");

        // transfer erc1155 to seller
        IERC1155(token).safeTransferFrom(address(this), seller, id, 1, new bytes(0x0));

        ended = true;
    }

    function live() external view returns(bool) {
        if (block.timestamp < lastBidTime.add(bidLength) && block.timestamp < startBidTime.add(auctionLength)) {
            return true;
        }
        return false;
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns(bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

}