pragma solidity ^0.4.24;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract Rainmaker is Ownable {

    function letItRain(address[] _to, uint[] _value) onlyOwner public payable returns (bool _success) {

        for (uint8 i = 0; i < _to.length; i++){

            uint amount = _value[i] * 1 finney;

            _to[i].transfer(amount);

        }

        return true;

    }

}