/**
 *Submitted for verification at Etherscan.io on 2021-03-29
*/

/**
 *Submitted for verification at Etherscan.io on 2021-03-18
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;







contract NFTSale {
    using Math for uint256;

    IERC1155 public nft;
    uint256  public price = 0.15 ether;
    uint256  public id;
    address  payable public multisig;
    uint256  public start;
    
    event Buy(address buyer, uint256 amount);

    constructor(address payable _multisig) public {
        multisig = _multisig;
        start = 1617055200;
        nft = IERC1155(0x13bAb10a88fc5F6c77b87878d71c9F1707D2688A);
        id = 53;
    }

    function buy(uint256 amount) public payable {
        require(msg.sender == tx.origin, "no contracts");
        require(block.timestamp >= start, "early");
        require(amount <= supply(), "ordered too many");
        require(amount <= 5, "ordered too many");
        require(msg.value == price.mul(amount), "wrong amount");

        nft.safeTransferFrom(address(this), msg.sender, id, amount, new bytes(0x0));
        
        multisig.transfer(address(this).balance);
        
        emit Buy(msg.sender, amount);
    }
    
    function supply() public view returns(uint256) {
        return nft.balanceOf(address(this), id);
    }
    
    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns(bytes4) {
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

}