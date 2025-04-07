/**
 *Submitted for verification at Etherscan.io on 2019-07-08
*/

//this is the Smart Contract for QFP QPass Bidding:
//1. It will return the USDT of unsuccessful bidder;
//2. The remaining USDT will be distributed to SuperNodes and LightNodes;

pragma solidity ^0.4.18;





contract SendBonus is Owned {

    function batchSend(address _tokenAddr, address[] _to, uint256[] _value) returns (bool _success) {
        require(_to.length == _value.length);
        require(_to.length <= 200);
        
        for (uint8 i = 0; i < _to.length; i++) {
            (Token(_tokenAddr).transfer(_to[i], _value[i]));
        }
        
        return true;
    }
}