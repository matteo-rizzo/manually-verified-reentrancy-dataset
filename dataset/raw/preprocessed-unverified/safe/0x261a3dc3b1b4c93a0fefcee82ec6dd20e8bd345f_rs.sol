pragma solidity ^0.4.13;



contract VAtomOwner is Ownable {

    mapping (string => string) vatoms;

    function setVAtomOwner(string vatomID, string ownerID) public onlyOwner {
        vatoms[vatomID] = ownerID;
    }

    function getVatomOwner(string vatomID) public constant returns(string) {
        return vatoms[vatomID];
    }
}