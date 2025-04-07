/**

 *Submitted for verification at Etherscan.io on 2019-01-14

*/



pragma solidity ^0.5.0;











/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor

 * - added sqrt

 * - added sq

 * - added pwr 

 * - changed asserts to requires with error log outputs

 * - removed div, its useless

 */

 







/**

 * @title Player Contract

 * @dev http://www.puzzlebid.com/

 * @author PuzzleBID Game Team 

 * @dev Simon<[emailÂ protected]>

 */

contract Player {



    using SafeMath for *;



    TeamInterface private team; 

    WorksInterface private works; 

    

    constructor(address _teamAddress, address _worksAddress) public {

        require(_teamAddress != address(0) && _worksAddress != address(0));

        team = TeamInterface(_teamAddress);

        works = WorksInterface(_worksAddress);

    }



    function() external payable {

        revert();

    }



    event OnUpgrade(address indexed _teamAddress, address indexed _worksAddress);

    event OnRegister(

        address indexed _address, 

        bytes32 _unionID, 

        bytes32 _referrer, 

        uint256 time

    );

    event OnUpdateLastAddress(bytes32 _unionID, address indexed _sender);

    event OnUpdateLastTime(bytes32 _unionID, bytes32 _worksID, uint256 _time);

    event OnUpdateFirstBuyNum(bytes32 _unionID, bytes32 _worksID, uint256 _firstBuyNum);

    event OnUpdateSecondAmount(bytes32 _unionID, bytes32 _worksID, uint256 _amount);

    event OnUpdateFirstAmount(bytes32 _unionID, bytes32 _worksID, uint256 _amount);

    event OnUpdateReinvest(bytes32 _unionID, bytes32 _worksID, uint256 _amount);

    event OnUpdateRewardAmount(bytes32 _unionID, bytes32 _worksID, uint256 _amount);

    event OnUpdateMyWorks(

        bytes32 _unionID, 

        address indexed _address, 

        bytes32 _worksID, 

        uint256 _totalInput, 

        uint256 _totalOutput,

        uint256 _time

    );



    mapping(bytes32 => Datasets.Player) private playersByUnionId; 

    mapping(address => bytes32) private playersByAddress; 

    address[] private playerAddressSets; 

    bytes32[] private playersUnionIdSets; 



    mapping(bytes32 => mapping(bytes32 => Datasets.PlayerCount)) playerCount;



   mapping(bytes32 => mapping(bytes32 => Datasets.MyWorks)) myworks; 

    

    modifier onlyAdmin() {

        require(team.isAdmin(msg.sender));

        _;

    }

    

    modifier onlyDev() {

        require(team.isDev(msg.sender));

        _;

    }



    function upgrade(address _teamAddress, address _worksAddress) external onlyAdmin() {

        require(_teamAddress != address(0) && _worksAddress != address(0));

        team = TeamInterface(_teamAddress);

        works = WorksInterface(_worksAddress);

        emit OnUpgrade(_teamAddress, _worksAddress);

    }





    function hasAddress(address _address) external view returns (bool) {

        bool has = false;

        for(uint256 i=0; i<playerAddressSets.length; i++) {

            if(playerAddressSets[i] == _address) {

                has = true;

                break;

            }

        }

        return has;

    }



    function hasUnionId(bytes32 _unionID) external view returns (bool) {

        bool has = false;

        for(uint256 i=0; i<playersUnionIdSets.length; i++) {

            if(playersUnionIdSets[i] == _unionID) {

                has = true;

                break;

            }

        }

        return has;

    }



    function getInfoByUnionId(bytes32 _unionID) external view returns (address payable, bytes32, uint256) {

        return (

            playersByUnionId[_unionID].lastAddress,

            playersByUnionId[_unionID].referrer, 

            playersByUnionId[_unionID].time

        );

    }



    function getUnionIdByAddress(address _address) external view returns (bytes32) {

        return playersByAddress[_address];

    }



    function isFreeze(bytes32 _unionID, bytes32 _worksID) external view returns (bool) {

        uint256 freezeGap = works.getFreezeGap(_worksID);

        return playerCount[_unionID][_worksID].lastTime.add(freezeGap) < now ? false : true;

    }



    function getFirstBuyNum(bytes32 _unionID, bytes32 _worksID) external view returns (uint256) {

        return playerCount[_unionID][_worksID].firstBuyNum;

    }



    function getSecondAmount(bytes32 _unionID, bytes32 _worksID) external view returns (uint256) {

        return playerCount[_unionID][_worksID].secondAmount;

    }



    function getFirstAmount(bytes32 _unionID, bytes32 _worksID) external view returns (uint256) {

        return playerCount[_unionID][_worksID].firstAmount;

    }



    function getLastAddress(bytes32 _unionID) external view returns (address payable) {

        return playersByUnionId[_unionID].lastAddress;

    }



    function getRewardAmount(bytes32 _unionID, bytes32 _worksID) external view returns (uint256) {

        return playerCount[_unionID][_worksID].rewardAmount;

    }



    function getFreezeHourglass(bytes32 _unionID, bytes32 _worksID) external view returns(uint256) {

        uint256 freezeGap = works.getFreezeGap(_worksID);

        if(playerCount[_unionID][_worksID].lastTime.add(freezeGap) > now) {

            return playerCount[_unionID][_worksID].lastTime.add(freezeGap).sub(now);

        }

        return 0;

    }



    function getMyReport(bytes32 _unionID, bytes32 _worksID) external view returns (uint256, uint256, uint256) {

        uint256 currInput = 0; 

        uint256 currOutput = 0;      

        uint256 currFinishReward = 0; 

        uint8 lastAllot = works.getAllot(_worksID, 2, 0); 



        currInput = this.getFirstAmount(_unionID, _worksID).add(this.getSecondAmount(_unionID, _worksID));

        currOutput = this.getRewardAmount(_unionID, _worksID);         

        currFinishReward = this.getRewardAmount(_unionID, _worksID).add(works.getPools(_worksID).mul(lastAllot) / 100);

        return (currInput, currOutput, currFinishReward);

    }



    function getMyStatus(bytes32 _unionID, bytes32 _worksID) external view returns (uint256, uint256, uint256, uint256, uint256) {

        return (

            playerCount[_unionID][_worksID].lastTime, 

            works.getFreezeGap(_worksID), 

            now, 

            playerCount[_unionID][_worksID].firstBuyNum,

            works.getFirstBuyLimit(_worksID)

        );

    }



    function getMyWorks(bytes32 _unionID, bytes32 _worksID) external view returns (address, bytes32, uint256, uint256, uint256) {

        return (

            myworks[_unionID][_worksID].ethAddress,

            myworks[_unionID][_worksID].worksID,

            myworks[_unionID][_worksID].totalInput,

            myworks[_unionID][_worksID].totalOutput,

            myworks[_unionID][_worksID].time

        );

    }



    function isLegalPlayer(bytes32 _unionID, address _address) external view returns (bool) {

        return (this.hasUnionId(_unionID) || this.hasAddress(_address)) && playersByAddress[_address] == _unionID;

    }



    function register(bytes32 _unionID, address payable _address, bytes32 _worksID, bytes32 _referrer) external onlyDev() returns (bool) {

        require(_unionID != bytes32(0) && _address != address(0) && _worksID != bytes32(0));



        if(this.hasAddress(_address)) {

            if(playersByAddress[_address] != _unionID) {

                revert();

            } else {

                return true;

            }

        }

         

        playersByUnionId[_unionID].ethAddress.push(_address);

        if(_referrer != bytes32(0)) {

            playersByUnionId[_unionID].referrer = _referrer;

        }

        playersByUnionId[_unionID].lastAddress = _address;

        playersByUnionId[_unionID].time = now;



        playersByAddress[_address] = _unionID;



        playerAddressSets.push(_address);

        if(this.hasUnionId(_unionID) == false) {

            playersUnionIdSets.push(_unionID);

            playerCount[_unionID][_worksID] = Datasets.PlayerCount(0, 0, 0, 0, 0);

        }



        emit OnRegister(_address, _unionID, _referrer, now);



        return true;

    }



    function updateLastAddress(bytes32 _unionID, address payable _sender) external onlyDev() {

        if(playersByUnionId[_unionID].lastAddress != _sender) {

            playersByUnionId[_unionID].lastAddress = _sender;

            emit OnUpdateLastAddress(_unionID, _sender);

        }

    }



    function updateLastTime(bytes32 _unionID, bytes32 _worksID) external onlyDev() {

        playerCount[_unionID][_worksID].lastTime = now;

        emit OnUpdateLastTime(_unionID, _worksID, now);

    }



    function updateFirstBuyNum(bytes32 _unionID, bytes32 _worksID) external onlyDev() {

        playerCount[_unionID][_worksID].firstBuyNum = playerCount[_unionID][_worksID].firstBuyNum.add(1);

        emit OnUpdateFirstBuyNum(_unionID, _worksID, playerCount[_unionID][_worksID].firstBuyNum);

    }



    function updateSecondAmount(bytes32 _unionID, bytes32 _worksID, uint256 _amount) external onlyDev() {

        playerCount[_unionID][_worksID].secondAmount = playerCount[_unionID][_worksID].secondAmount.add(_amount);

        emit OnUpdateSecondAmount(_unionID, _worksID, _amount);

    }



    function updateFirstAmount(bytes32 _unionID, bytes32 _worksID, uint256 _amount) external onlyDev() {

        playerCount[_unionID][_worksID].firstAmount = playerCount[_unionID][_worksID].firstAmount.add(_amount);

        emit OnUpdateFirstAmount(_unionID, _worksID, _amount);

    }



    function updateRewardAmount(bytes32 _unionID, bytes32 _worksID, uint256 _amount) external onlyDev() {

        playerCount[_unionID][_worksID].rewardAmount = playerCount[_unionID][_worksID].rewardAmount.add(_amount);

        emit OnUpdateRewardAmount(_unionID, _worksID, _amount);

    }    



    function updateMyWorks(

        bytes32 _unionID, 

        address _address, 

        bytes32 _worksID, 

        uint256 _totalInput, 

        uint256 _totalOutput

    ) external onlyDev() {

        myworks[_unionID][_worksID] = Datasets.MyWorks(_address, _worksID, _totalInput, _totalOutput, now);

        emit OnUpdateMyWorks(_unionID, _address, _worksID, _totalInput, _totalOutput, now);

    }



}