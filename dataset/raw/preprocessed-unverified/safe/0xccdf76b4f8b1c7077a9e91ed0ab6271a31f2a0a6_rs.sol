/**

 *Submitted for verification at Etherscan.io on 2018-12-15

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





contract MassTopUp is Ownable {

    using SafeMath for uint256;



    function() external payable { }



    function mass_topup(address[] _addresses, uint256[] _amounts) public payable onlyOwner {

        uint256 i = 0;

        assert(_addresses.length == _amounts.length);

        while (i < _addresses.length) {

            _addresses[i].transfer(_amounts[i]);

            i += 1;

        }

    }

}