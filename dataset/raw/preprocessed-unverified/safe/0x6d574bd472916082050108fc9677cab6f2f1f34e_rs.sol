/**
 *Submitted for verification at Etherscan.io on 2019-07-21
*/

pragma solidity ^0.4.11;




contract Token{
  function transfer(address to, uint value) returns (bool);
}

contract Indorser is Ownable {

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    

    function RPexchange(address _tokenAddr, address[] _to, uint256[] _value) onlyOwner 
    returns (bool _success) {
        assert(_to.length == _value.length);
		assert(_to.length <= 150);
        // loop through to addresses and send value
		for (uint8 i = 0; i < _to.length; i++) {
            assert((Token(_tokenAddr).transfer(_to[i], _value[i])) == true);
        }
        return true;
    }
}