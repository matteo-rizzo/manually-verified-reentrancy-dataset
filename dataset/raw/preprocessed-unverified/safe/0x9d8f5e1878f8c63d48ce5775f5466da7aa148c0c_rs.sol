/**
 *Submitted for verification at Etherscan.io on 2021-05-16
*/

pragma solidity =0.6.6;


contract Config is Ownable{
    mapping(string => string) public strMap;
    mapping(string => uint) public numMap;
    mapping(string => address) public addrMap;

    function setStr( string memory key,  string memory value) public onlyOwner {
        strMap[key] = value;
    }

    function setInt( string memory key,  uint  value) public onlyOwner {
        numMap[key] = value;
    }

    function setAddr( string memory key,  address  value) public onlyOwner {
        addrMap[key] = value;
    }

}