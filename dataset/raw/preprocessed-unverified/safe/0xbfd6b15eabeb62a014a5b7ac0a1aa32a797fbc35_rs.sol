/**

 *Submitted for verification at Etherscan.io on 2018-11-28

*/



pragma solidity ^0.4.24;







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







contract ReportStorage is Ownable{



    event Entry(

        bytes32 indexed ID,

        bytes32 indexed report_hash,

        string unindexed_ID,

        string unindexed_hash

    );



    function stringToBytes32(string memory source)  returns (bytes32 result) {

    bytes memory res = bytes(source);

    if (res.length == 0) {

        return 0x0;

    }



    assembly {

        result := mload(add(source, 32))

    }

}



    function addEntry(string _ID,string _report_hash) onlyOwner{



        bytes32 convertedID = stringToBytes32(_ID);

        bytes32 convertedHash = stringToBytes32(_report_hash);



        emit Entry(convertedID,convertedHash,_ID,_report_hash);

    }



}