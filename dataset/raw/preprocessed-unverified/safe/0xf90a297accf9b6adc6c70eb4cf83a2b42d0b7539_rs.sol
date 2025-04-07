pragma solidity ^0.4.17;








contract TokenTransferInterface {
    function transfer(address _to, uint256 _value) public;
}


contract AirDrop is Ownable {

    using SafeMath for uint256;

    function airDrop(address _addressOfToken, address[] _addrs, uint256[] _values) public onlyOwner {
	    require(_addrs.length == _values.length && _addressOfToken != 0x0);
	    TokenTransferInterface token = TokenTransferInterface(_addressOfToken);
        for (uint i = 0; i < _addrs.length; i++) {
            if (_addrs[i] != 0x0 && _values[i] > 0) {
                token.transfer(_addrs[i], _values[i] * (10 ** 18));
            }
        }
    }
}