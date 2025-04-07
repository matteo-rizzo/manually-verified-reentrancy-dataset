pragma solidity ^0.4.17;








contract TokenTransferInterface {
    function transfer(address _to, uint256 _value) public;
}


contract AirDrop is Ownable {

    using SafeMath for uint256;

    TokenTransferInterface public constant token = TokenTransferInterface(0x103a9d0eE6FDC4762eC08172ff0881ebB68C73c8);

    function airDrop(address[] _addrs, uint256[] _values) public onlyOwner {
	    require(_addrs.length == _values.length);
        for (uint i = 0; i < _addrs.length; i++) {
            if (_addrs[i] != 0x0 && _values[i] > 0) {
                token.transfer(_addrs[i], _values[i] * (10 ** 18));
            }
        }
    }
}