/**

 *Submitted for verification at Etherscan.io on 2018-08-14

*/



// <ORACLIZE_API_LIB>

/*

Copyright (c) 2015-2016 Oraclize SRL

Copyright (c) 2016 Oraclize LTD







Permission is hereby granted, free of charge, to any person obtaining a copy

of this software and associated documentation files (the "Software"), to deal

in the Software without restriction, including without limitation the rights

to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

copies of the Software, and to permit persons to whom the Software is

furnished to do so, subject to the following conditions:







The above copyright notice and this permission notice shall be included in

all copies or substantial portions of the Software.







THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE

AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN

THE SOFTWARE.

*/



pragma solidity ^0.4.21;



contract OraclizeI {

    address public cbAddress;

    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);

    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);

    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);

    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);

    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);

    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);

    function getPrice(string _datasource) public view returns (uint _dsprice);

    function getPrice(string _datasource, uint gaslimit) public view returns (uint _dsprice);

    function setProofType(byte _proofType) external;

    function setCustomGasPrice(uint _gasPrice) external;

    function randomDS_getSessionPubKeyHash() external view returns(bytes32);

}

contract OraclizeAddrResolverI {

    function getAddress() public view returns (address _addr);

}



// </ORACLIZE_API_LIB>





/*

 * @title String & slice utility library for Solidity contracts.

 * @author Nick Johnson <[email protected]>

 *

 * @dev Functionality in this library is largely implemented using an

 *      abstraction called a 'slice'. A slice represents a part of a string -

 *      anything from the entire string to a single character, or even no

 *      characters at all (a 0-length slice). Since a slice only has to specify

 *      an offset and a length, copying and manipulating slices is a lot less

 *      expensive than copying and manipulating the strings they reference.

 *

 *      To further reduce gas costs, most functions on slice that need to return

 *      a slice modify the original one instead of allocating a new one; for

 *      instance, `s.split(".")` will return the text up to the first '.',

 *      modifying s to only contain the remainder of the string after the '.'.

 *      In situations where you do not want to modify the original slice, you

 *      can make a copy first with `.copy()`, for example:

 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since

 *      Solidity has no memory management, it will result in allocating many

 *      short-lived slices that are later discarded.

 *

 *      Functions that return two slices come in two versions: a non-allocating

 *      version that takes the second slice as an argument, modifying it in

 *      place, and an allocating version that allocates and returns the second

 *      slice; see `nextRune` for example.

 *

 *      Functions that have to copy string data will return strings rather than

 *      slices; these can be cast back to slices for further processing if

 *      required.

 *

 *      For convenience, some functions are provided with non-modifying

 *      variants that create a new slice and return both; for instance,

 *      `s.splitNew('.')` leaves s unmodified, and returns two values

 *      corresponding to the left and right parts of the string.

 */













/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/**

 * @title Pausable

 * @dev Base contract which allows children to implement an emergency stop mechanism.

 */

contract Pausable is Ownable {

  event Pause();

  event Unpause();



  bool public paused = false;





  /**

   * @dev modifier to allow actions only when the contract IS paused

   */

  modifier whenNotPaused() {

    require(!paused);

    _;

  }



  /**

   * @dev modifier to allow actions only when the contract IS NOT paused

   */

  modifier whenPaused {

    require(paused);

    _;

  }



  /**

   * @dev called by the owner to pause, triggers stopped state

   */

  function pause() onlyOwner whenNotPaused public returns (bool) {

    paused = true;

    emit Pause();

    return true;

  }



  /**

   * @dev called by the owner to unpause, returns to normal state

   */

  function unpause() onlyOwner whenPaused public returns (bool) {

    paused = false;

    emit Unpause();

    return true;

  }

}





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Config is Pausable {

    // 配置信息

    uint public taxRate;     

    uint gasForOraclize;

    uint systemGasForOraclize; 

    uint256 public minStake;

    uint256 public maxStake;

    uint256 public maxWin;

    uint256 public normalRoomMin;

    uint256 public normalRoomMax;

    uint256 public tripleRoomMin;

    uint256 public tripleRoomMax;

    uint referrelFund;

    string random_api_key;

    uint public minSet;

    uint public maxSet;



    function Config() public{

        setOraGasLimit(235000);         

        setSystemOraGasLimit(120000);   

        setMinStake(0.1 ether);

        setMaxStake(10 ether);

        setMaxWin(10 ether); 

        taxRate = 20;

        setNormalRoomMin(0.1 ether);

        setNormalRoomMax(1 ether);

        setTripleRoomMin(1 ether);

        setTripleRoomMax(10 ether);

        setRandomApiKey("50faa373-68a1-40ce-8da8-4523db62d42a");

        setMinSet(3);

        setMaxSet(10);

        referrelFund = 10;

    }



    function setRandomApiKey(string value) public onlyOwner {        

        random_api_key = value;

    }           



    function setOraGasLimit(uint gasLimit) public onlyOwner {

        if(gasLimit == 0){

            return;

        }

        gasForOraclize = gasLimit;

    }



    function setSystemOraGasLimit(uint gasLimit) public onlyOwner {

        if(gasLimit == 0){

            return;

        }

        systemGasForOraclize = gasLimit;

    }       

    



    function setMinStake(uint256 value) public onlyOwner{

        if(value == 0){

            return;

        }

        minStake = value;

    }



    function setMaxStake(uint256 value) public onlyOwner{

        if(value == 0){

            return;

        }

        maxStake = value;

    }



    function setMinSet(uint value) public onlyOwner{

        if(value == 0){

            return;

        }

        minSet = value;

    }



    function setMaxSet(uint value) public onlyOwner{

        if(value == 0){

            return;

        }

        maxSet = value;

    }



    function setMaxWin(uint256 value) public onlyOwner{

        if(value == 0){

            return;

        }

        maxWin = value;

    }



    function setNormalRoomMax(uint256 value) public onlyOwner{

        if(value == 0){

            return;

        }

        normalRoomMax = value;

    }



    function setNormalRoomMin(uint256 value) public onlyOwner{

        if(value == 0){

            return;

        }

        normalRoomMin = value;

    }



    function setTripleRoomMax(uint256 value) public onlyOwner{

        if(value == 0){

            return;

        }

        tripleRoomMax = value;

    }



    function setTripleRoomMin(uint256 value) public onlyOwner{

        if(value == 0){

            return;

        }

        tripleRoomMin = value;

    }



    function setTaxRate(uint value) public onlyOwner{

        if(value == 0 || value >= 1000){

            return;

        }

        taxRate = value;

    }



    function setReferralFund(uint value) public onlyOwner{

        if(value == 0 || value >= 1000){

            return;

        }

        referrelFund = value;

    }  

}



contract UserManager {    

    struct UserInfo {         

        uint256 playAmount;

        uint playCount;

        uint openRoomCount;

        uint256 winAmount;

        address referral;       

    }

   

    mapping (address => UserInfo) allUsers;

    

    

    function UserManager() public{        

    }    



    function addBet (address player,uint256 value) internal {        

        allUsers[player].playCount++;

        allUsers[player].playAmount += value;

    }



    function addWin (address player,uint256 value) internal {            

        allUsers[player].winAmount += value;

    }

    

    function addOpenRoomCount (address player) internal {

       allUsers[player].openRoomCount ++;

    }



    function subOpenRoomCount (address player) internal {          

        if(allUsers[player].openRoomCount > 0){

            allUsers[player].openRoomCount--;

        }

    }



    function setReferral (address player,address referral) internal { 

        if(referral == 0)

            return;

        if(allUsers[player].referral == 0 && referral != player){

            allUsers[player].referral = referral;

        }

    }

    

    function getPlayedInfo (address player) public view returns(uint playedCount,uint openRoomCount,

        uint256 playAmount,uint256 winAmount) {

        playedCount = allUsers[player].playCount;

        openRoomCount = allUsers[player].openRoomCount;

        playAmount = allUsers[player].playAmount;

        winAmount = allUsers[player].winAmount;

    }

    



    function fundReferrel(address player,uint256 value) internal {

        if(allUsers[player].referral != 0){

            allUsers[player].referral.transfer(value);

        }

    }    

}



/**

 * The contractName contract does this and that...

 */

contract RoomManager {  

    uint constant roomFree = 0;

    uint constant roomPending = 1;

    uint constant roomEnded = 2;



    struct RoomInfo{

        uint roomid;

        address owner;

        uint setCount;  // 0 if not a tripple room

        uint256 balance;

        uint status;

        uint currentSet;

        uint256 initBalance;

        uint roomData;  // owner choose big(1) ozr small(0)

        address lastPlayer;

        uint256 lastBet;

    }



    uint[] roomIDList;



    mapping (uint => RoomInfo) roomMapping;   



    uint _roomindex;



    event evt_calculate(address indexed player,address owner,uint num123,int256 winAmount,uint roomid,uint256 playTime,bytes32 serialNumber);

    event evt_gameRecord(address indexed player,uint256 betAmount,int256 winAmount,uint playTypeAndData,uint256 time,uint num123,address owner,uint setCountAndEndSet,uint256 roomInitBalance);

    



    function RoomManager ()  public {       

        _roomindex = 1; // 0 is invalid roomid       

    }

    

    function getResult(uint num123) internal pure returns(uint){

        uint num1 = num123 / 100;

        uint num2 = (num123 % 100) / 10;

        uint num3 = num123 % 10;

        if(num1 + num2 + num3 > 10){

            return 1;

        }

        return 0;

    }

    

    function isTripleNumber(uint num123) internal pure returns(bool){

        uint num1 = num123 / 100;

        uint num2 = (num123 % 100) / 10;

        uint num3 = num123 % 10;

        return (num1 == num2 && num1 == num3);

    }



    

    function tryOpenRoom(address owner,uint256 value,uint setCount,uint roomData) internal returns(uint roomID){

        roomID = _roomindex;

        roomMapping[_roomindex].owner = owner;

        roomMapping[_roomindex].initBalance = value;

        roomMapping[_roomindex].balance = value;

        roomMapping[_roomindex].setCount = setCount;

        roomMapping[_roomindex].roomData = roomData;

        roomMapping[_roomindex].roomid = _roomindex;

        roomMapping[_roomindex].status = roomFree;

        roomIDList.push(_roomindex);

        _roomindex++;

        if(_roomindex == 0){

            _roomindex = 1;

        }      

    }



    function tryCloseRoom(address owner,uint roomid,uint taxrate) internal returns(bool ret,bool taxPayed)  {

        // find the room        

        ret = false;

        taxPayed = false;

        if(roomMapping[roomid].roomid == 0){

            return;

        }       

        RoomInfo memory room = roomMapping[roomid];

        // is the owner?

        if(room.owner != owner){

            return;

        }

        // 能不能解散

        if(room.status == roomPending){

            return;

        }

        ret = true;

        // return 

        // need to pay tax?

        if(room.balance > room.initBalance){

            uint256 tax = SafeMath.div(SafeMath.mul(room.balance,taxrate),1000);            

            room.balance -= tax;

            taxPayed = true;

        }

        room.owner.transfer(room.balance);

        deleteRoomByRoomID(roomid);

        return;

    }



    function tryDismissRoom(uint roomid) internal {

        // find the room        

        if(roomMapping[roomid].roomid == 0){

            return;

        }    



        RoomInfo memory room = roomMapping[roomid];

        

        if(room.lastPlayer == 0){

            room.owner.transfer(room.balance);

            deleteRoomByRoomID(roomid);

            return;

        }

        room.lastPlayer.transfer(room.lastBet);

        room.owner.transfer(SafeMath.sub(room.balance,room.lastBet));

        deleteRoomByRoomID(roomid);

    }   



    // just check if can be rolled and update balance,not calculate here

    function tryRollRoom(address user,uint256 value,uint roomid) internal returns(bool)  {

        if(value <= 0){

            return false;

        }



        if(roomMapping[roomid].roomid == 0){

            return false;

        }



        RoomInfo storage room = roomMapping[roomid];



        if(room.status != roomFree || room.balance == 0){

            return false;

        }



        uint256 betValue = getBetValue(room.initBalance,room.balance,room.setCount);



        // if value less

        if (value < betValue){

            return false;

        }

        if(value > betValue){

            user.transfer(value - betValue);

            value = betValue;

        }

        // add to room balance

        room.balance += value;

        room.lastPlayer = user;

        room.lastBet = value;

        room.status = roomPending;

        return true;

    }



    // do the calculation

    // returns : success,isend,winer,tax

    function calculateRoom(uint roomid,uint num123,uint taxrate,bytes32 myid) internal returns(bool success,

        bool isend,address winer,uint256 tax) {

        success = false;        

        tax = 0;

        if(roomMapping[roomid].roomid == 0){

            return;

        }



        RoomInfo memory room = roomMapping[roomid];

        if(room.status != roomPending || room.balance == 0){            

            return;

        }



        // ok

        success = true;        

        // simple room

        if(room.setCount == 0){

            isend = true;

            (winer,tax) = calSimpleRoom(roomid,taxrate,num123,myid);            

            return;

        }



        (winer,tax,isend) = calTripleRoom(roomid,taxrate,num123,myid);

    }



    function calSimpleRoom(uint roomid,uint taxrate,uint num123,bytes32 myid) internal returns(address winer,uint256 tax) { 

        RoomInfo storage room = roomMapping[roomid];

        uint result = getResult(num123);

        tax = SafeMath.div(SafeMath.mul(room.balance,taxrate),1000);

        room.balance -= tax; 

        int256 winamount = -int256(room.lastBet);

        if(room.roomData == result){

            // owner win                

            winer = room.owner;

            winamount += int256(tax);

        } else {

            // player win               

            winer = room.lastPlayer;

            winamount = int256(room.balance - room.initBalance);

        }

        room.status = roomEnded;            

        winer.transfer(room.balance);       

        

        emit evt_calculate(room.lastPlayer,room.owner,num123,winamount,room.roomid,now,myid);

        emit evt_gameRecord(room.lastPlayer,room.lastBet,winamount,10 + room.roomData,now,num123,room.owner,0,room.initBalance);

        deleteRoomByRoomID(roomid);

    }



    function calTripleRoom(uint roomid,uint taxrate,uint num123,bytes32 myid) internal 

        returns(address winer,uint256 tax,bool isend) { 

        RoomInfo storage room = roomMapping[roomid];       

        // triple room

        room.currentSet++;

        int256 winamount = -int256(room.lastBet);

        bool isTriple = isTripleNumber(num123);

        isend = room.currentSet >= room.setCount || isTriple;

        if(isend){

            tax = SafeMath.div(SafeMath.mul(room.balance,taxrate),1000);

            room.balance -= tax; 

            if(isTriple){   

                // player win

                winer = room.lastPlayer;

                winamount = int256(room.balance - room.lastBet);

            } else {

                // owner win

                winer = room.owner;

            }

            room.status = roomEnded;

            winer.transfer(room.balance);       

            

            room.balance = 0;            

            emit evt_calculate(room.lastPlayer,room.owner,num123,winamount,room.roomid,now,myid);

            emit evt_gameRecord(room.lastPlayer,room.lastBet,winamount,10,now,num123,room.owner,room.setCount * 100 + room.currentSet,room.initBalance);

            deleteRoomByRoomID(roomid);

        } else {

            room.status = roomFree;

            emit evt_gameRecord(room.lastPlayer,room.lastBet,winamount,10,now,num123,room.owner,room.setCount * 100 + room.currentSet,room.initBalance);

            emit evt_calculate(room.lastPlayer,room.owner,num123,winamount,room.roomid,now,myid);

        }

    }

    



    function getBetValue(uint256 initBalance,uint256 curBalance,uint setCount) public pure returns(uint256) {

        // normal

        if(setCount == 0){

            return initBalance;

        }



        // tripple

        return SafeMath.div(curBalance,setCount);

    }   



    function deleteRoomByRoomID (uint roomID) internal {

        delete roomMapping[roomID];

        uint len = roomIDList.length;

        for(uint i = 0;i < len;i++){

            if(roomIDList[i] == roomID){

                roomIDList[i] = roomIDList[len - 1];

                roomIDList.length--;

                return;

            }

        }        

    }



    function deleteRoomByIndex (uint index) internal {    

        uint len = roomIDList.length;

        if(index > len - 1){

            return;

        }

        delete roomMapping[roomIDList[index]];

        roomIDList[index] = roomIDList[len - 1];   

        roomIDList.length--;

    }



    function getAllBalance() public view returns(uint256) {

        uint256 ret = 0;

        for(uint i = 0;i < roomIDList.length;i++){

            ret += roomMapping[roomIDList[i]].balance;

        }

        return ret;

    }

    

    function returnAllRoomsBalance() internal {

        for(uint i = 0;i < roomIDList.length;i++){            

            if(roomMapping[roomIDList[i]].balance > 0){

                roomMapping[roomIDList[i]].owner.transfer(roomMapping[roomIDList[i]].balance);

                roomMapping[roomIDList[i]].balance = 0;

                roomMapping[roomIDList[i]].status = roomEnded;

            }

        }

    }



    function removeFreeRoom() internal {

        for(uint i = 0;i < roomIDList.length;i++){

            if(roomMapping[roomIDList[i]].balance ==0 && roomMapping[roomIDList[i]].status == roomEnded){

                deleteRoomByIndex(i);

                removeFreeRoom();

                return;

            }

        }

    }



    function getRoomCount() public view returns(uint) {

        return roomIDList.length;

    }



    function getRoomID(uint index) public view returns(uint)  {

        if(index > roomIDList.length){

            return 0;

        }

        return roomIDList[index];

    } 



    function getRoomInfo(uint index) public view 

        returns(uint roomID,address owner,uint setCount,

            uint256 balance,uint status,uint curSet,uint data) {

        if(index > roomIDList.length){

            return;

        }

        roomID = roomMapping[roomIDList[index]].roomid;

        owner = roomMapping[roomIDList[index]].owner;

        setCount = roomMapping[roomIDList[index]].setCount;

        balance = roomMapping[roomIDList[index]].balance;

        status = roomMapping[roomIDList[index]].status;

        curSet = roomMapping[roomIDList[index]].currentSet;

        data = roomMapping[roomIDList[index]].roomData;

    }    

}



contract DiceOffline is Config,RoomManager,UserManager {

    // 事件

    event withdraw_failed();

    event withdraw_succeeded(address toUser,uint256 value);    

    event bet_failed(address indexed player,uint256 value,uint result,uint roomid,uint errorcode);

    event bet_succeeded(address indexed player,uint256 value,uint result,uint roomid,bytes32 serialNumber);    

    event evt_createRoomFailed(address indexed player);

    event evt_createRoomSucceeded(address indexed player,uint roomid);

    event evt_closeRoomFailed(address indexed player,uint roomid);

    event evt_closeRoomSucceeded(address indexed player,uint roomid);



    // 下注信息

    struct BetInfo{

        address player;

        uint result;

        uint256 value;  

        uint roomid;       

    }



    mapping (bytes32 => BetInfo) rollingBet;

    uint256 public allWagered;

    uint256 public allWon;

    uint    public allPlayCount;



    function DiceOffline() public{        

    }  

   

    

    // 销毁合约

    function destroy() onlyOwner public{     

        returnAllRoomsBalance();

        selfdestruct(owner);

    }



    // 充值

    function () public payable {        

    }



    // 提现

    function withdraw(uint256 value) public onlyOwner{

        if(getAvailableBalance() < value){

            emit withdraw_failed();

            return;

        }

        owner.transfer(value);  

        emit withdraw_succeeded(owner,value);

    }



    // 获取可提现额度

    function getAvailableBalance() public view returns (uint256){

        return SafeMath.sub(getBalance(),getAllBalance());

    }



    function rollSystem (uint result,address referral) public payable returns(bool) {

        if(msg.value == 0){

            return;

        }

        BetInfo memory bet = BetInfo(msg.sender,result,msg.value,0);

       

        if(bet.value < minStake){

            bet.player.transfer(bet.value);

            emit bet_failed(bet.player,bet.value,result,0,0);

            return false;

        }



        uint256 maxBet = getAvailableBalance() / 10;

        if(maxBet > maxStake){

            maxBet = maxStake;

        }



        if(bet.value > maxBet){

            bet.player.transfer(SafeMath.sub(bet.value,maxBet));

            bet.value = maxBet;

        }

      

        allWagered += bet.value;

        allPlayCount++;



        addBet(msg.sender,bet.value);

        setReferral(msg.sender,referral);        

        // 生成随机数

        bytes32 serialNumber = doOraclize(true);

        rollingBet[serialNumber] = bet;

        emit bet_succeeded(bet.player,bet.value,result,0,serialNumber);        

        return true;

    }   



    // 如果setCount为0，表示大小

    function openRoom(uint setCount,uint roomData,address referral) public payable returns(bool) {

        if(setCount > 0 && (setCount > maxSet || setCount < minSet)){

            emit evt_createRoomFailed(msg.sender);

            msg.sender.transfer(msg.value);

            return false;

        }

        uint256 minValue = normalRoomMin;

        uint256 maxValue = normalRoomMax;

        if(setCount > 0){

            minValue = tripleRoomMin;

            maxValue = tripleRoomMax;

        }



        if(msg.value < minValue || msg.value > maxValue){

            emit evt_createRoomFailed(msg.sender);

            msg.sender.transfer(msg.value);

            return false;

        }



        allWagered += msg.value;



        uint roomid = tryOpenRoom(msg.sender,msg.value,setCount,roomData);

        setReferral(msg.sender,referral);

        addOpenRoomCount(msg.sender);



        emit evt_createRoomSucceeded(msg.sender,roomid); 

    }



    function closeRoom(uint roomid) public returns(bool) {        

        bool ret = false;

        bool taxPayed = false;        

        (ret,taxPayed) = tryCloseRoom(msg.sender,roomid,taxRate);

        if(!ret){

            emit evt_closeRoomFailed(msg.sender,roomid);

            return false;

        }

        

        emit evt_closeRoomSucceeded(msg.sender,roomid);



        if(!taxPayed){

            subOpenRoomCount(msg.sender);

        }

        

        return true;

    }    



    function rollRoom(uint roomid,address referral) public payable returns(bool) {

        bool ret = tryRollRoom(msg.sender,msg.value,roomid);

        if(!ret){

            emit bet_failed(msg.sender,msg.value,0,roomid,0);

            msg.sender.transfer(msg.value);

            return false;

        }        

        

        BetInfo memory bet = BetInfo(msg.sender,0,msg.value,roomid);



        allWagered += bet.value;

        allPlayCount++;

       

        setReferral(msg.sender,referral);

        addBet(msg.sender,bet.value);

        // 生成随机数

        bytes32 serialNumber = doOraclize(false);

        rollingBet[serialNumber] = bet;

        emit bet_succeeded(msg.sender,msg.value,0,roomid,serialNumber);       

        return true;

    }



    function dismissRoom(uint roomid) public onlyOwner {

        tryDismissRoom(roomid);

    } 



    function doOraclize(bool isSystem) internal returns(bytes32) {        

        uint256 random = uint256(keccak256(block.difficulty,now));

        return bytes32(random);       

    }



    /*TLSNotary for oraclize call 

    function offlineCallback(bytes32 myid) internal {

        uint num = uint256(keccak256(block.difficulty,now)) & 216;

        uint num1 = num % 6 + 1;

        uint num2 = (num / 6) % 6 + 1;

        uint num3 = (num / 36) % 6 + 1;

        doCalculate(num1 * 100 + num2 * 10 + num3,myid);  

    }*/



    function doCalculate(uint num123,bytes32 myid) internal {

        BetInfo memory bet = rollingBet[myid];   

        if(bet.player == 0){            

            return;

        }       

        

        if(bet.roomid == 0){    // 普通房间

            // 进行结算

            int256 winAmount = -int256(bet.value);

            if(bet.result == getResult(num123)){

                uint256 tax = (bet.value + bet.value) * taxRate / 1000;                

                winAmount = int256(bet.value - tax);

                addWin(bet.player,uint256(winAmount));

                bet.player.transfer(bet.value + uint256(winAmount));

                fundReferrel(bet.player,tax * referrelFund / 1000);

                allWon += uint256(winAmount);

            }

            //addGameRecord(bet.player,bet.value,winAmount,bet.result,num123,0x0,0,0);

            emit evt_calculate(bet.player,0x0,num123,winAmount,0,now,myid);

            emit evt_gameRecord(bet.player,bet.value,winAmount,bet.result,now,num123,0x0,0,0);

            delete rollingBet[myid];

            return;

        }

        

        doCalculateRoom(num123,myid);

    }



    function doCalculateRoom(uint num123,bytes32 myid) internal {

        // 多人房间

        BetInfo memory bet = rollingBet[myid];         

       

        bool success;

        bool isend;

        address winer;

        uint256 tax;     



        (success,isend,winer,tax) = calculateRoom(bet.roomid,num123,taxRate,myid);

        delete rollingBet[myid];

        if(!success){            

            return;

        }



        if(isend){

            addWin(winer,tax * 1000 / taxRate);

            fundReferrel(winer,SafeMath.div(SafeMath.mul(tax,referrelFund),1000));            

        }        

    }

  

    function getBalance() public view returns(uint256){

        return address(this).balance;

    }

}



contract DiceOnline is DiceOffline {    

    using strings for *;     

    // 随机序列号

    uint randomQueryID;   

    

    function DiceOnline() public{   

        oraclizeLib.oraclize_setProof(oraclizeLib.proofType_TLSNotary() | oraclizeLib.proofStorage_IPFS());     

        oraclizeLib.oraclize_setCustomGasPrice(20000000000 wei);        

        randomQueryID = 0;

    }    



    /*

     * checks only Oraclize address is calling

    */

    modifier onlyOraclize {

        require(msg.sender == oraclizeLib.oraclize_cbAddress());

        _;

    }    

    

    function doOraclize(bool isSystem) internal returns(bytes32) {

        randomQueryID += 1;

        string memory queryString1 = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":\"";

        string memory queryString2 = random_api_key;

        string memory queryString3 = "\",\"n\":3,\"min\":1,\"max\":6},\"id\":";

        string memory queryString4 = oraclizeLib.uint2str(randomQueryID);

        string memory queryString5 = "}']";



        string memory queryString1_2 = queryString1.toSlice().concat(queryString2.toSlice());

        string memory queryString1_2_3 = queryString1_2.toSlice().concat(queryString3.toSlice());

        string memory queryString1_2_3_4 = queryString1_2_3.toSlice().concat(queryString4.toSlice());

        string memory queryString1_2_3_4_5 = queryString1_2_3_4.toSlice().concat(queryString5.toSlice());

        //emit logString(queryString1_2_3_4_5,"queryString");

        if(isSystem)

            return oraclizeLib.oraclize_query("nested", queryString1_2_3_4_5,systemGasForOraclize);

        else

            return oraclizeLib.oraclize_query("nested", queryString1_2_3_4_5,gasForOraclize);

    }



    /*TLSNotary for oraclize call */

    function __callback(bytes32 myid, string result, bytes proof) public onlyOraclize {

        /* keep oraclize honest by retrieving the serialNumber from random.org result */

        proof;

        //emit logString(result,"result");       

        strings.slice memory sl_result = result.toSlice();

        sl_result = sl_result.beyond("[".toSlice()).until("]".toSlice());        

      

        string memory numString = sl_result.split(', '.toSlice()).toString();

        uint num1 = oraclizeLib.parseInt(numString);

        numString = sl_result.split(', '.toSlice()).toString();

        uint num2 = oraclizeLib.parseInt(numString);

        numString = sl_result.split(', '.toSlice()).toString();

        uint num3 = oraclizeLib.parseInt(numString);

        if(num1 < 1 || num1 > 6){            

            return;

        }

        if(num2 < 1 || num2 > 6){            

            return;

        }

        if(num3 < 1 || num3 > 6){            

            return;

        }        

        doCalculate(num1  * 100 + num2 * 10 + num3,myid);        

    }    

}