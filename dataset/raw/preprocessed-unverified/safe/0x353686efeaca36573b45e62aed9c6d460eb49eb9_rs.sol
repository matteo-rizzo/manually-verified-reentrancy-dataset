/**
 *Submitted for verification at Etherscan.io on 2021-09-09
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;






contract NFTSale {
    using Math for uint256;

    address public controller;
    address public hausAddress;
    address public stakingSwapContract;
    
    IERC1155 public nft;
    uint256  public price;
    uint256  public id;
    uint256  public start;
    uint256 public limitPerOrder;
    uint256 public stakingRewardPercentageBasisPoints;
    
    event Buy(address buyer, uint256 amount);
    
    constructor(
        address _hausAddress,
        uint256 _startTime,
        address _tokenAddress,
        uint256 _tokenId,
        uint256 _priceWei,
        uint256 _limitPerOrder,
        uint256 _stakingRewardPercentageBasisPoints,
        address _stakingSwapContract
    ) public {
        hausAddress = _hausAddress;
        start = _startTime;
        nft = IERC1155(_tokenAddress);
        id = _tokenId;
        price = _priceWei;
        limitPerOrder = _limitPerOrder;
        controller = msg.sender;
        stakingRewardPercentageBasisPoints = _stakingRewardPercentageBasisPoints;
        stakingSwapContract = _stakingSwapContract;
    }
    
    function buy(uint256 amount) public payable {
        require(msg.sender == tx.origin, "no contracts");
        require(block.timestamp >= start, "early");
        require(amount <= supply(), "ordered too many");
        require(amount <= limitPerOrder, "ordered too many");
        require(msg.value == price.mul(amount), "wrong amount");
        nft.safeTransferFrom(address(this), msg.sender, id, amount, new bytes(0x0));
        uint256 stakingReward = (address(this).balance * stakingRewardPercentageBasisPoints) / 10000;
        (bool stakingRewardSuccess, ) = stakingSwapContract.call{value: stakingReward}("");
        require(stakingRewardSuccess, "Staking reward transfer failed.");
        (bool successMultisig, ) = hausAddress.call{value: address(this).balance}("");
        require(successMultisig, "Multisig transfer failed.");
        emit Buy(msg.sender, amount);
    }
    
    function supply() public view returns(uint256) {
        return nft.balanceOf(address(this), id);
    }

    function setTokenAddress(address _tokenAddress) public onlyController {
        nft = IERC1155(_tokenAddress);
    }

    function setTokenId(uint256 _tokenId) public onlyController {
        id = _tokenId;
    }

    function pull() public onlyController {
        nft.safeTransferFrom(address(this), controller, id, nft.balanceOf(address(this), id), new bytes(0x0));
    }

    modifier onlyController {
      require(msg.sender == controller);
      _;
    }
    
    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns(bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
}