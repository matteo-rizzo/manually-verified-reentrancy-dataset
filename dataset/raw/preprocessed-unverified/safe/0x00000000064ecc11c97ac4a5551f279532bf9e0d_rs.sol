/**
 *Submitted for verification at Etherscan.io on 2020-12-09
*/

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;





contract UniswapHelpers {
    
    UniswapFactory public univ2Factory = UniswapFactory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac);
    
    function getPairs(uint256 start, uint256 cnt) public view returns (address[] memory) {
        address[] memory out = new address[](cnt);
        for(uint256 i = 0; i < cnt; i++){
            out[i] = univ2Factory.allPairs(i+start);
        }
        return out;
    }
}