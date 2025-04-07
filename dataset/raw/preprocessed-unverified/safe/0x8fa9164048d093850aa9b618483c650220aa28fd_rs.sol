/**
 *Submitted for verification at Etherscan.io on 2021-09-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;







contract MultiMap is IERC721Receiver {
    
    
    LootContract _lootContract = LootContract(0x1dfe7Ca09e99d10835Bf73044a23B73Fc20623DF);
    
    function getMultiLoot(uint256[] calldata tokenIds) public {
    
        uint256 mintedAmount = 0;
        
        for (uint i = 0; i < tokenIds.length; i++) {

            try _lootContract.claim(tokenIds[i]) {
                _lootContract.safeTransferFrom(address(this), msg.sender, tokenIds[i]);
                mintedAmount++;
            } catch {
            }
        }
    }
    
     function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
}