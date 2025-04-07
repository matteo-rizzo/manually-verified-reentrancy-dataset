pragma solidity ^0.4.24;





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */









////////////////////////////////////////////////////////////////////////////////



contract IEOResolver is Ownable {

    mapping(uint=>address) public ieoAddress; // mapping from id to address

    

    event IEOAddressSet(uint id, address addr);

    

    function setIEOAddress(uint id, address addr) public onlyOwner {

        emit IEOAddressSet(id,addr);

        ieoAddress[id] = addr;

    }

}