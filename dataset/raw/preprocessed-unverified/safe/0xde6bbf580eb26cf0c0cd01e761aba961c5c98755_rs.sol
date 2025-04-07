/**
 *Submitted for verification at Etherscan.io on 2019-08-01
*/

/**
 *Submitted for verification at Etherscan.io on 2019-Aug-01
 * For QFP payment 
*/

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