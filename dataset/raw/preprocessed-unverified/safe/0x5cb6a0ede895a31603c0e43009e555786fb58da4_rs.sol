/**
 *Submitted for verification at Etherscan.io on 2020-10-30
*/

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;





contract Oracle {
    
    UniswapFactory public univ2Factory = UniswapFactory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    
    function getPairs(uint256 start, uint256 cnt) public view returns (address[] memory) {
        address[] memory out = new address[](cnt);
        for(uint256 i = 0; i < cnt; i++){
            out[i] = univ2Factory.allPairs(i+start);
        }
        return out;
    }
}