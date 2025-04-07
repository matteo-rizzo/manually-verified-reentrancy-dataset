/**

 *Submitted for verification at Etherscan.io on 2018-09-25

*/



pragma solidity 0.4.21;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract Whitelist is Ownable {

    mapping(address => bool) public allowedAddresses;



    event WhitelistUpdated(uint256 timestamp, string operation, address indexed member);



    function addToWhitelist(address[] _addresses) public onlyOwner {

        for (uint256 i = 0; i < _addresses.length; i++) {

            allowedAddresses[_addresses[i]] = true;

            emit WhitelistUpdated(now, "Added", _addresses[i]);

        }

    }



    function removeFromWhitelist(address[] _addresses) public onlyOwner {

        for (uint256 i = 0; i < _addresses.length; i++) {

            allowedAddresses[_addresses[i]] = false;

            emit WhitelistUpdated(now, "Removed", _addresses[i]);

        }

    }



    function isWhitelisted(address _address) public view returns (bool) {

        return allowedAddresses[_address];

    }

}