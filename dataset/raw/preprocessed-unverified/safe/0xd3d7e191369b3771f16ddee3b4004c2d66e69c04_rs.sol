/**
 *Submitted for verification at Etherscan.io on 2021-07-30
*/

/**
 *Submitted for verification at Etherscan.io on 2019-12-21
*/

pragma solidity ^0.5.15;

/** @title Owned */


/** @title FourArt Image saving contract */
contract FourArtSaveFingerPrint is Owned {
    struct FingerPrint{
      string fpHash;
      bool isValue;
   }
    mapping(string => FingerPrint) private fingerPrints;
    
    
   function uploadFingerPrint(string memory storageRef, string memory hash) onlyOwner public {
       if (!fingerPrints[storageRef].isValue) {
           fingerPrints[storageRef].fpHash =  hash;
           fingerPrints[storageRef].isValue =  true; 
       }
   }
   
   function getFingerPrint(string memory sInfo) public view returns (string memory) {
        return fingerPrints[sInfo].fpHash;
   } 
}