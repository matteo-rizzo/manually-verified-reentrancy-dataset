/**

 *Submitted for verification at Etherscan.io on 2018-10-25

*/



pragma solidity ^0.4.24;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */











contract Whitelist is Ownable {



  mapping(address => bool) public isAddressWhitelist;



  event LogWhitelistAdded(address indexed participant, uint256 timestamp);

  event LogWhitelistDeleted(address indexed participant, uint256 timestamp);



  constructor() public {}



  function isWhite(address participant) public view returns (bool) {

    return isAddressWhitelist[participant];

  }



  function addWhitelist(address[] participants) public onlyOwner returns (bool) {

    for (uint256 i = 0; i < participants.length; i++) {

      isAddressWhitelist[participants[i]] = true;



      emit LogWhitelistAdded(participants[i], now);

    }



    return true;

  }



  function delWhitelist(address[] participants) public onlyOwner returns (bool) {

    for (uint256 i = 0; i < participants.length; i++) {

      isAddressWhitelist[participants[i]] = false;



      emit LogWhitelistDeleted(participants[i], now);

    }



    return true;

  }

}