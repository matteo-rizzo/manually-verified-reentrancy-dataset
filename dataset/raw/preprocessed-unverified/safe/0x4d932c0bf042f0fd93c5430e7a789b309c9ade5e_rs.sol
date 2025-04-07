/**

 *Submitted for verification at Etherscan.io on 2018-09-12

*/



pragma solidity ^0.4.17;









contract TokenTransferInterface {

    function transfer(address _to, uint256 _value) public;

}





contract AirDrop is Ownable {



    TokenTransferInterface public constant token = TokenTransferInterface(0x96c2848f32E91C5d53796e37aFFB7f1331aA0635);



    function multiValueAirDrop(address[] _addrs, uint256[] _values) public onlyOwner {

	    require(_addrs.length == _values.length && _addrs.length <= 100);

        for (uint i = 0; i < _addrs.length; i++) {

            if (_addrs[i] != 0x0 && _values[i] > 0) {

                token.transfer(_addrs[i], _values[i] * (10 ** 18));  

            }

        }

    }



    function singleValueAirDrop(address[] _addrs, uint256 _value) public onlyOwner {

	    require(_addrs.length <= 100 && _value > 0);

        for (uint i = 0; i < _addrs.length; i++) {

            if (_addrs[i] != 0x0) {

                token.transfer(_addrs[i], _value * (10 ** 18));

            }

        }

    }

}