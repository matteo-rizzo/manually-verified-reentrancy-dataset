/**
 *Submitted for verification at Etherscan.io on 2021-09-19
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;





contract Scatter {
    
    function scatterEther(address payable[] calldata recipients, uint256[] calldata values) external payable {
        for(uint256 i = 0; i < recipients.length; i++)
            recipients[i].transfer(values[i]);
        uint256 balance = address(this).balance;
        if(balance > 0)
            payable(msg.sender).transfer(balance);
    }

    function scatterToken(IERC20 token, address[] calldata recipients, uint256[] calldata tokenValues) external {
        uint256 total = 0;
        for(uint256 i = 0; i < recipients.length; i++)
            total += tokenValues[i];
        require(token.transferFrom(msg.sender, address(this), total));
        for(uint256 i = 0; i < recipients.length; i++)
            require(token.transfer(recipients[i], tokenValues[i]));
    }
    
    function scatterErc721Nft(IERC721 token, address[] calldata recipients, uint256[] calldata tokenId) external {
        require(token.isApprovedForAll(msg.sender, address(this)), "Token not approved");
        for(uint256 i = 0; i < recipients.length; i++)
            token.safeTransferFrom(msg.sender, recipients[i], tokenId[i]);
    }
    
}