/**

 *Submitted for verification at Etherscan.io on 2019-02-17

*/



pragma solidity 0.4.25;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */



/**

 * @title Blueprint

 */

contract Blueprint is Ownable {

   

    struct BlueprintInfo {

        bytes32 details;

        address creator;

        uint256 createTime;

    }

    //BluePrint Info

    mapping(string => BlueprintInfo) private  _bluePrint;

    

    /**

   * @dev Create Exchange details.

   * @param _id unique id.

   * @param _details exchange details.

   */



    function createExchange(string _id,string _details) public onlyOwner

          

    returns (bool)

   

    {

         BlueprintInfo memory info;

         info.details=sha256(_details);

         info.creator=msg.sender;

         info.createTime=block.timestamp;

         _bluePrint[_id] = info;

         return true;

         

    }

    

    /**

  * @dev Gets the BluePrint details of the specified id.

  */

  function getBluePrint(string _id) public view returns (bytes32,address,uint256) {

    return (_bluePrint[_id].details,_bluePrint[_id].creator,_bluePrint[_id].createTime);

  }

    

}