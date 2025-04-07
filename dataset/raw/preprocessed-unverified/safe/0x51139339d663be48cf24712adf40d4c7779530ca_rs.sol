/**
 *Submitted for verification at Etherscan.io on 2020-10-30
*/

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;








contract Oracle {
    
    UniswapFactory public univ2Factory = UniswapFactory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    
    function getPairs(uint256 start) public view returns (address[] memory) {
        uint256 length = univ2Factory.allPairsLength();
        address[] memory out = new address[](length-start);
        for(uint256 i = start; i < length; i++){
            out[i-start] = univ2Factory.allPairs(i);
        }
        return out;
    }
    
    function getAllPairs() public view returns (address[] memory) {
        return getPairs(0);
    }
}