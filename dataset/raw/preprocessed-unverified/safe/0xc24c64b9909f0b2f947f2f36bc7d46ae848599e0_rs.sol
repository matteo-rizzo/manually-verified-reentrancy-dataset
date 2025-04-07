/**

 *Submitted for verification at Etherscan.io on 2018-11-14

*/



pragma solidity 0.4.25;











contract Token{

  function transfer(address to, uint value) public returns (bool);

}



contract NortonDropper is Ownable {



    function multisend(address _tokenAddr, address[] _to, uint256[] _value) public

    returns (bool _success) {

        assert(_to.length == _value.length);

        assert(_to.length <= 150);

        // loop through to addresses and send value to every address specified

        for (uint8 i = 0; i < _to.length; i++) {

                assert((Token(_tokenAddr).transfer(_to[i], _value[i])) == true);

            }

            return true;

        }

}