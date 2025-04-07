/**

 *Submitted for verification at Etherscan.io on 2018-09-24

*/



pragma solidity ^0.4.24;































contract BullsAndCows {



    using Player for Player.Map;

    //using PlayerReply for PlayerReply.Data;

    //using PlayerReply for PlayerReply.List;

    using RoomInfo for RoomInfo.Data;

    using RoomInfo for RoomInfo.List;

    using CommUtils for string;

    





    uint256 public constant DIGIT_MIN = 4;    

    uint256 public constant SELL_PRICE_RATE = 200;

    uint256 public constant SELL_MIN_RATE = 50;



   // RoomInfo.Data[] private roomInfos ;

    RoomInfo.List roomInfos;

    Player.Map private players;

    

    //constructor() public   {    }

    

    // function createRoomQuick() public payable {

    //     createRoom(4,10,"AAA",35,10,20,0.05 ether,20,20,60*60,60*60);

    // }

        

    // function getBalance() public view returns (uint){

    //     return address(this).balance;

    // }    

    

    // function testNow() public  view returns(uint256[]) {

    //     RoomInfo.Data storage r = roomInfos[0]    ; 

    //     return r.answer;

    // }

    

    // function TestreplayAnser(uint256 roomIdx) public payable   {

    //     RoomInfo.Data storage r = roomInfos.map[roomIdx];

    //     for(uint256 i=0;i<4;i++){

    //         uint256[] memory aa = CommUtils.genRandomArray(r.answer.length,r.charsLength,i);

    //         r.replayAnser(players,0.5 ether,aa);

    //     }

    // }    

    

    

    function getInitInfo() public view returns(

        uint256,//roomSize

        bytes32 //refert

        ){

        return (

            roomInfos.size,

            players.getReferrerName(msg.sender)

        );

    }

    

    function getRoomIdxByNameElseLargest(string _roomName) public view returns(uint256 ){

        return roomInfos.getIdxByNameElseLargest(_roomName.nameFilter());

    }    

    

    function getRoomInfo(uint256 roomIdx) public view returns(

        address, //ownerId

        bytes32, //roomName,

        uint256, // replay visible idx type

        uint256, // prize

        uint256, // replyFee

        uint256, // reply combo count

        uint256, // lastReplyAt

        uint256, // get over time

        uint256,  // round

        bool // winner

        ){

        RoomInfo.Data storage r = roomInfos.get(roomIdx)    ;

        (uint256 time,uint256 count) = r.getRoomExReplyInfo();

        (PlayerReply.Data storage pr) = r.getWinReply();

        return (

            r.ownerId,

            r.name,

            r.replys.size,

            r.prize,

            r.getReplyFee(),

            count,

            time,

            r.getOverTimeLeft(),

            r.round,

            PlayerReply.isOwner(pr)

        );

    }

    

    function getRoom(uint256 roomIdx) public view returns(

        uint256, //digits,

        uint256, //templateLen,

        uint256, //toAnswerRate,

        uint256, //toOwner,

        uint256, //nextRoundRate,

        uint256, //minReplyFee,

        uint256, //maxReplyFeeRate           

        uint256  //IdxIncreaseRate

        ){

        RoomInfo.Data storage r = roomInfos.map[roomIdx]    ;

        return(

        r.answer.length,

        r.charsLength,

        r.toAnswerRate ,  //r.toAnswerRate 

        r.toOwner , //r.toOwner,

        r.nextRoundRate ,  //r.nextRoundRate,

        r.minReplyFee, 

        r.maxReplyFeeRate,     //r.maxReplyFeeRate  

        r.increaseRate_1000     //IdxIncreaseRate

        );

        

    }

    

    function getGameItem(uint256 idx) public view returns(

        bytes32 ,// name

        uint256, //totalPrize

        uint256, //bestACount 

        uint256 , //bestBCount

        uint256 , //answer count

        uint256, //replyFee

        uint256 //OverTimeLeft

        ){

        return roomInfos.map[idx].getGameItem();

    }

    

    function getReplyFee(uint256 roomIdx) public view returns(uint256){

        return roomInfos.map[roomIdx].getReplyFee();

    }

    

    function getReplay(uint256 roomIdx,uint256 replayIdx) public view returns(

        uint256 ,//aCount;

        uint256,// bCount;

        uint256[],// answer;

        uint,// replyAt;

        uint256, // VisibleType

        uint256 ,//sellPrice

        uint256 //ansHash

        ) {

        RoomInfo.Data storage r = roomInfos.map[roomIdx];

        return r.getReplay(replayIdx);

    }

    

    function replayAnserWithReferrer(uint256 roomIdx,uint256[] tryA,string referrer)public payable {

        players.applyReferrer(referrer);

        replayAnser(roomIdx,tryA);

    }



    function replayAnser(uint256 roomIdx,uint256[] tryA) public payable   {

        RoomInfo.Data storage r = roomInfos.map[roomIdx];

        (uint256 a, uint256 b)= r.replayAnser(players,players.withdrawalFee(r.getReplyFee()),tryA);

        emit ReplayAnserResult (a,b,roomIdx);

    }

    

    

    function sellReply(uint256 roomIdx,uint256 ansHash,uint256 price) public payable {

        RoomInfo.Data storage r = roomInfos.map[roomIdx];

        require(price >= r.prize * SELL_MIN_RATE / 100,"price too low");

        r.sellReply(players,ansHash,price,players.withdrawalFee(price * SELL_PRICE_RATE /100));

    }

    

    function buyReply(uint256 roomIdx,uint256 replyIdx) public payable{

        roomInfos.map[roomIdx].buyReply(players,replyIdx,msg.value);

    }

    

    



    function isEmptyName(string _n) public view returns(bool){

        return players.isEmptyName(_n.nameFilter());

    }

    

    function award(uint256 roomIdx) public  {

        RoomInfo.Data storage r = roomInfos.map[roomIdx];

        (

            address[] memory winners,

            uint256[] memory rewords,

            uint256 nextRound

        )=r.award(players);

        emit Wined(winners , rewords,roomIdx);

        //(nextRound >= CREATE_INIT_PRIZE && SafeMath.mulRate(nextRound,maxReplyFeeRate) > r.minReplyFee  ) || roomInfos.length == 1

        if(r.isAbleNextRound(nextRound)){

            r.clearAndNextRound(nextRound);   

        }else if(roomInfos.size>1){

            for(uint256 i = roomIdx; i<roomInfos.size-1; i++){

                roomInfos.map[i] = roomInfos.map[i+1];

            }

            delete roomInfos.map[roomInfos.size-1];

            roomInfos.size--;

            roomInfos.getByPrizeLeast().prize += nextRound;

        }else{

            delete roomInfos.map[roomIdx];

            players.depositAuthor(nextRound);

            roomInfos.size = 0;

        }

    }

    



    function createRoom(

        uint256 digits,

        uint256 templateLen,

        string roomName,

        uint256 toAnswerRate,

        uint256 toOwner,

        uint256 nextRoundRate,

        uint256 minReplyFee,

        uint256 maxReplyFeeRate,

        uint256 increaseRate,

        uint256 initAwardTime,

        uint256 plusAwardTime

        )  public payable{



        bytes32 name = roomName.nameFilter();

        require(roomInfos.getByName(name).ownerId == address(0));

        RoomInfo.Data storage r = roomInfos.getEmpty();

        r.init(

            digits,

            templateLen,

            name,

            toAnswerRate,

            toOwner,

            nextRoundRate,

            minReplyFee,

            maxReplyFeeRate,

            increaseRate,

            initAwardTime,

            plusAwardTime

        );

    }

    

    function getPlayerWallet() public view returns(  uint256   ){

        return players.getAmmount(msg.sender);

    }

    

    function withdrawal() public payable {

        uint256 sum=players.withdrawalAll(msg.sender);

        msg.sender.transfer(sum);

    }

    

    function registerName(string  name) public payable {

        require(msg.value >= 0.1 ether);

        require(players.getName()=="");

        players.registerName(name.nameFilter());

    }

    

    function getPlayerName() public view returns(bytes32){

        return players.getName();

    }

    

    event ReplayAnserResult(

        uint256 aCount,

        uint256 bCount,

        uint256 roomIdx

    );

    

    event Wined(

        address[]  winners,

        uint256[]  rewords,

        uint256 roomIdx

    );    

    

}