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



  mapping (address => mapping (address => bool)) public list;



  event LogWhitelistAdded(address indexed participant, uint256 timestamp);

  event LogWhitelistDeleted(address indexed participant, uint256 timestamp);



  constructor() public {}



  function isWhite(address _contract, address addr) public view returns (bool) {

    return list[_contract][addr];

  }



  function addWhitelist(address _contract, address[] addrs) public onlyOwner returns (bool) {

    for (uint256 i = 0; i < addrs.length; i++) {

      list[_contract][addrs[i]] = true;



      emit LogWhitelistAdded(addrs[i], now);

    }



    return true;

  }



  function delWhitelist(address _contract, address[] addrs) public onlyOwner returns (bool) {

    for (uint256 i = 0; i < addrs.length; i++) {

      list[_contract][addrs[i]] = false;



      emit LogWhitelistDeleted(addrs[i], now);

    }



    return true;

  }

}