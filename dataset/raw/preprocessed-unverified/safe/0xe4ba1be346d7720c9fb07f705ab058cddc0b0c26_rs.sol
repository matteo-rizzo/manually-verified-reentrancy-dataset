/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity 0.5.8;



contract PackPurchaser {
    
    function purchaseFor(Pack pack, uint cost, address[] memory owners, uint16[] memory packCounts) public payable {
        for (uint i = 0; i < owners.length; i++) {
            pack.purchaseFor.value(cost * packCounts[i])(owners[i], packCounts[i], address(0));
        }
    }
}