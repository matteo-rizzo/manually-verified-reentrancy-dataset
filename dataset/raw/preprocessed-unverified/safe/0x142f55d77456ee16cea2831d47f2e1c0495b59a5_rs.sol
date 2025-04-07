/**

 *Submitted for verification at Etherscan.io on 2018-09-15

*/



pragma solidity ^0.4.25;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract AirDropStore is Ownable {

    using SafeMath for uint256;

    

    address[] public arrayAirDrops;

    mapping (address => uint256) public indexOfAirDropAddress;

    

    event addToAirDropList(address _address);

    event removeFromAirDropList(address _address);

    

    function getArrayAirDropsLength() public view returns (uint256) {

        return arrayAirDrops.length;

    }

    

    function addAirDropAddress(address _address) public onlyOwner {

        arrayAirDrops.push(_address);

        indexOfAirDropAddress[_address] = arrayAirDrops.length.sub(1);

    

        emit addToAirDropList(_address);

    }

    

    function addAirDropAddresses(address[] _addresses) public onlyOwner {

        for (uint i = 0; i < _addresses.length; i++) {

            arrayAirDrops.push(_addresses[i]);

            indexOfAirDropAddress[_addresses[i]] = arrayAirDrops.length.sub(1);



            emit addToAirDropList(_addresses[i]);

        }

    }

    

    function removeAirDropAddress(address _address) public onlyOwner {

        uint256 index =  indexOfAirDropAddress[_address];



        arrayAirDrops[index] = address(0);

        emit removeFromAirDropList(_address);

    }

    

    function removeAirDropAddresses(address[] _addresses) public onlyOwner {

        uint256 index;

        

        for (uint i = 0; i < _addresses.length; i++) {

        

            index =  indexOfAirDropAddress[_addresses[i]];



            arrayAirDrops[index] = address(0);

            emit removeFromAirDropList(_addresses[i]);

        }

    }

}