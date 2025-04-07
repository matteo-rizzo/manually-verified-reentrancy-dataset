/**
 *Submitted for verification at Etherscan.io on 2021-09-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;







contract MultiMap is IERC721Receiver {
    
    
    MapContract _lootContract = MapContract(0xD81f156bBF7043a22d4cE97C0E8ca11d3f4FB3cC);
    
    function getMultiLoot(uint256 numberToMint) public {
    
        uint256 mintedAmount = 0;
        
        for (uint i = 0; i < 9751; i++) {
            if (mintedAmount >= numberToMint) {
                break;
            }
            try _lootContract.discoverMap(i) {
                _lootContract.safeTransferFrom(address(this), msg.sender, i);
                mintedAmount++;
            } catch {}
        }
    }
    
     function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
    
    
}