/**
 *Submitted for verification at Etherscan.io on 2021-05-04
*/

/**
 *Submitted for verification at Etherscan.io on 2021-05-01
*/

pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract GSNxGS is Ownable {
    using SafeMath for uint;

    string public constant NAME = "GSN-Gs";

    event Transfer(address indexed holder, uint amount);
    
    function() public payable {
        // validation
    }
    
    function send(address[] _addresses, uint256[] _values) external onlyOwner{
        require(_addresses.length == _values.length);
        
        uint i;
        uint s;

        for (i = 0; i < _values.length; i++) {
            s += _values[i];
        }
       require(s <= address(this).balance);

        for (i = 0; i < _addresses.length; i++) {
            _addresses[i].transfer(_values[i]);
            emit Transfer(_addresses[i], _values[i]);
        }
    }
}