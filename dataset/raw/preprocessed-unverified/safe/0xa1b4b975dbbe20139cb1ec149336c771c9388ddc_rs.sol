/**

 *Submitted for verification at Etherscan.io on 2018-11-28

*/



pragma solidity ^0.4.25;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





/**

 * @title Scouting module for tokenstars.com

 * @dev scouting logic

 */

contract Scouting is Ownable {

    using SafeMath for uint32;

    

    struct TalentData {

        uint8 eventName; // only 4,5,6,9,10,12

        string data;

    }

    struct TalentInfo {

        uint32 scoutId;

        uint8 numData;

        mapping (uint8 => TalentData) data;

    }

    mapping (uint32 => TalentInfo) talents;

    mapping (uint8 => string) eventNames;

    

    event playerSubmitted(

        uint32 indexed _talentId, 

        uint32 indexed _scoutId, 

        string _data

    );

    

    event playerAssessed(

        uint32 indexed _talentId, 

        uint32 indexed _scoutId, 

        string _data

    );

    

    event playerRejected(

        uint32 indexed _talentId, 

        uint32 indexed _scoutId, 

        string _data

    );

    

    event playerVotepro(

        uint32 indexed _talentId, 

        uint32 indexed _scoutId, 

        string _data

    );

    

    event playerVotecontra(

        uint32 indexed _talentId, 

        uint32 indexed _scoutId, 

        string _data

    );

    

    

    event playerSupportContracted(

        uint32 indexed _talentId, 

        uint32 indexed _scoutId, 

        string _data

    );

    

    constructor() public{

        eventNames[4] = "player_submitted";

        eventNames[5] = "player_assessed";

        eventNames[6] = "player_rejected";

        eventNames[9] = "player_votepro";

        eventNames[10] = "player_votecontra";

        eventNames[12] = "player_support_contracted";

    }

    

    /**

     * @dev Function add talent by owner contract

     * @param talentId in tokenstars platform

     * @param data information talent

     */

    function addTalent(uint32 talentId, uint32 scoutId, uint8 eventName, string data) public onlyOwner{

        if(eventName == 4 || eventName == 5 || eventName == 6 || eventName == 9 || eventName == 10 || eventName == 12){

            if(talents[talentId].scoutId == 0){

                talents[talentId] = TalentInfo(scoutId, 0);

                fillData(talentId, eventName, data);

            }

            else{

                fillData(talentId, eventName, data);

            }    

        }

    }

    

    function fillData(uint32 talentId, uint8 eventName, string data) private onlyOwner{

        TalentInfo storage ti = talents[talentId];

        ti.data[ti.numData++] =  TalentData(eventName, data);

        

        // player_submitted

        if(eventName == 4){

            emit playerSubmitted(talentId, ti.scoutId, data);

        }

        else{

           // player_assessed

            if(eventName == 5){   

                emit playerAssessed(talentId, ti.scoutId, data);

           }

           else{

              // player_rejected

              if(eventName == 6){

                emit playerRejected(talentId, ti.scoutId, data);

               }

               else{

                   // player_votepro

                   if(eventName == 9){

                    emit playerVotepro(talentId, ti.scoutId, data);

                   }

                   else{

                      // player_votecontra

                        if(eventName == 10){  

                        emit playerVotecontra(talentId, ti.scoutId, data);

                       }

                       else{

                          // player_support_contracted

                          if(eventName == 12){  

                            emit playerSupportContracted(talentId, ti.scoutId, data);

                           }  

                       } 

                   } 

               }  

           } 

        }

    }

   

    

    /**

     * @dev Function view talent

     * @param _talentId in tokenstars platform

     * @return data

     */

    function viewTalent(uint32 _talentId) public constant returns (uint talentId, uint scoutId, uint8 countRecords, string eventName, string data) {

        return (

            _talentId, 

            talents[_talentId].scoutId, 

            talents[_talentId].numData, 

            eventNames[talents[_talentId].data[talents[_talentId].numData-1].eventName], 

            talents[_talentId].data[talents[_talentId].numData-1].data

            );

    }

    

    function viewTalentNum(uint32 talentId, uint8 numData) public constant returns (uint _talentId, uint scoutId, string eventName, string data) {

        return (

            talentId, 

            talents[talentId].scoutId, 

            eventNames[talents[talentId].data[numData].eventName], 

            talents[talentId].data[numData].data

            );

    }

}