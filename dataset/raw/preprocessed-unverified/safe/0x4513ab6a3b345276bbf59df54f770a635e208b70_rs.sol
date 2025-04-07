/**

 *Submitted for verification at Etherscan.io on 2018-12-26

*/



pragma solidity ^0.4.23;







contract FiftyFifty{

    using SafeMath for uint; // using SafeMath

    //rate to 0.125 ETH.  0.125:1, 0.250:2, 0.500:4, 1.00:8, 2.00:16, 4.00:32, 8.00: 64, 16.00:128, 32.00:256, 64.00:512

    uint[11] betValues = [0.125 ether, 0.250 ether, 0.500 ether, 1.00 ether, 2.00 ether, 4.00 ether, 8.00 ether, 16.00 ether, 32.00 ether, 64.00 ether];

    // return value is 95 % of two people.

    uint[11] returnValues = [0.2375 ether, 0.475 ether, 0.950 ether, 1.90 ether, 3.80 ether, 7.60 ether, 15.20 ether, 30.40 ether, 60.80 ether, 121.60 ether];

    // jackpot value is 4 % of total value

    uint[11] jackpotValues = [0.05 ether, 0.010 ether, 0.020 ether, 0.04 ether, 0.08 ether, 0.16 ether, 0.32 ether, 0.64 ether, 1.28 ether, 2.56 ether];

    // fee 1 %

    uint[11] fees = [0.0025 ether, 0.005 ether, 0.010 ether, 0.020 ether, 0.040 ether, 0.080 ether, 0.16 ether, 0.32 ether, 0.64 ether, 1.28 ether];

    uint roundNumber; // number of round that jackpot is paid

    mapping(uint => uint) jackpot;

    //round -> betValue -> user address

    mapping(uint => mapping(uint => address[])) roundToBetValueToUsers;

    //round -> betValue -> totalBet

    mapping(uint => mapping(uint => uint)) roundToBetValueToTotalBet;

    //round -> totalBet

    mapping(uint => uint) public roundToTotalBet;

    // current user who bet for the value

    mapping(uint => address) currentUser;

    address owner;

    uint ownerDeposit;



    // Event

    event Jackpot(address indexed _user, uint _value, uint indexed _round, uint _now);

    event Bet(address indexed _winner,address indexed _user,uint _bet, uint _payBack, uint _now);





    constructor() public {

        owner = msg.sender;

        roundNumber = 1;

    }



    modifier onlyOwner () {

        require(msg.sender == owner);

        _;

    }



    function changeOwner(address _owner) external onlyOwner{

        owner = _owner;

    }



    // fallback function that



    function() public payable {

        // check if msg.value is equal to specified amount of value.

        uint valueNumber = checkValue(msg.value);

        /**

            jackpot starts when block hash % 10000 < 0

        */

        uint randJackpot = (uint(blockhash(block.number - 1)) + roundNumber) % 10000;

        if(jackpot[roundNumber] != 0 && randJackpot <= 1){

            // Random number that is under contract total bet amount

            uint randJackpotBetValue = uint(blockhash(block.number - 1)) % roundToTotalBet[roundNumber];

            //betNum

            uint betNum=0;

            uint addBetValue = 0;

            // Loop until addBetValue exceeds randJackpotBetValue

            while(randJackpotBetValue > addBetValue){

                // Select bet number which is equal to

                addBetValue += roundToBetValueToTotalBet[roundNumber][betNum];

                betNum++;

            }

            //  betNum.sub(1)¤Îindex¤Ëº¬¤Þ¤ì¤Æ¤¤¤ëuser¤ÎÊýÎ´œº¤Î¥é¥ó¥À¥à·¬ºÅ¤òÉú³É¤¹¤ë

            uint randJackpotUser = uint(blockhash(block.number - 1)) % roundToBetValueToUsers[roundNumber][betNum.sub(1)].length;

            address user = roundToBetValueToUsers[roundNumber][valueNumber][randJackpotUser];

            uint jp = jackpot[roundNumber];

            user.transfer(jp);

            emit Jackpot(user, jp, roundNumber, now);

            roundNumber = roundNumber.add(1);

        }

        if(currentUser[valueNumber] == address(0)){

            //when current user does not exists

            currentUser[valueNumber] = msg.sender;

            emit Bet(address(0), msg.sender, betValues[valueNumber], 0, now);

        }else{

            // when current user exists

            uint rand = uint(blockhash(block.number-1)) % 2;

            ownerDeposit = ownerDeposit.add(fees[valueNumber]);

            if(rand == 0){

                // When the first user win

                currentUser[valueNumber].transfer(returnValues[valueNumber]);

                emit Bet(currentUser[valueNumber], msg.sender, betValues[valueNumber], returnValues[valueNumber], now);

            }else{

                // When the last user win

                msg.sender.transfer(returnValues[valueNumber]);

                emit Bet(msg.sender, msg.sender, betValues[valueNumber], returnValues[valueNumber], now);

            }

            // delete current user

            delete currentUser[valueNumber];

        }

        // common in each contracts

        jackpot[roundNumber] = jackpot[roundNumber].add(jackpotValues[valueNumber]);

        roundToBetValueToUsers[roundNumber][valueNumber].push(currentUser[valueNumber]);

        roundToTotalBet[roundNumber] = roundToTotalBet[roundNumber].add(betValues[valueNumber]);

        roundToBetValueToTotalBet[roundNumber][valueNumber] = roundToBetValueToTotalBet[roundNumber][valueNumber].add(betValues[valueNumber]);

    }



    /**

        @param sendValue is ETH that is sent to this contract.

        @return num is index that represent value that is sent.

    */

    function checkValue(uint sendValue) internal view returns(uint) {

        /**

            Check sendValue is match prepared values. Revert if sendValue doesn't match any values.

        */

        uint num = 0;

        while (sendValue != betValues[num]){

            if(num == 11){

                revert();

            }

            num++;

        }

        return num;

    }



    function roundToBetValueToUsersLength(uint _roundNum, uint _betNum) public view returns(uint){

        return roundToBetValueToUsers[_roundNum][_betNum].length;

    }



    function withdrawDeposit() public onlyOwner{

        owner.transfer(ownerDeposit);

        ownerDeposit = 0;

    }



    function currentJackpot() public view  returns(uint){

        return jackpot[roundNumber];

    }



}