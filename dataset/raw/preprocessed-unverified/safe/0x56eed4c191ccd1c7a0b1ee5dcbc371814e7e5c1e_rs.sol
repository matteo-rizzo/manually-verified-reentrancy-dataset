/**

 *Submitted for verification at Etherscan.io on 2019-03-04

*/



pragma solidity 0.5.4;











contract DailyLucky is Ownable {

    using SafeMath for uint;

    

    // round => winner

    mapping(uint => address) public winners;

    

    // round => gain

    mapping(uint => uint) public balances;

    

    uint bet = 0.001 ether;

    

    uint startTime = 1551700800; // 03.04.2019 15:00:00

    uint roundTime = 3600; // 1 hour in sec

    

    address payable public wallet;

    address payable public jackpot;

    

    constructor (address payable _wallet, address payable _jackpot) public {

        require(_wallet != address(0));

        require(_jackpot != address(0));

        

    	wallet = _wallet;

    	jackpot = _jackpot;  

    }

    

    function () external payable {

        setBet(msg.sender);

    }

    

    function setBet(address _player) public payable {

        require(msg.value >= bet);

        

        uint currentRound = now.sub(startTime).div(roundTime);



        uint amount = msg.value;

        uint toWallet = amount.mul(20).div(100);

        uint toNextRound = amount.mul(15).div(100);

        uint toSuperJackpot = amount.mul(15).div(100);



        winners[currentRound] = _player;

        

        balances[currentRound] = balances[currentRound].add(amount).sub(toWallet).sub(toNextRound).sub(toSuperJackpot);

        balances[currentRound.add(1)] = balances[currentRound.add(1)].add(toNextRound);

        

        jackpot.transfer(toSuperJackpot);

        wallet.transfer(toWallet);

    }

    

    function getWinner(uint _round) public view returns (address) {

        if (winners[_round] != address(0)) return winners[_round];

        else return owner;

    }

    

    function getGain(uint _round) public {

	    require(_round < now.sub(startTime).div(roundTime));

        require(msg.sender == getWinner(_round));

        

    	uint gain = balances[_round];

    	balances[_round] = 0;



        address(msg.sender).transfer(gain);

    }

    

    function changeRoundTime(uint _time) onlyOwner public {

        roundTime = _time;

    }

    

    function changeStartTime(uint _time) onlyOwner public {

        startTime = _time;    

    }

    

    function changeWallet(address payable _wallet) onlyOwner public {

        wallet = _wallet;

    }



    function changeJackpot(address payable _jackpot) onlyOwner public {

        jackpot = _jackpot;

    }

    

    function getCurrentRound() public view returns (uint) {

        return now.sub(startTime).div(roundTime);

    }

    

    function getRoundBalance(uint _round) public view returns (uint) {

        return balances[_round];

    }

    

    function getRoundByTime(uint _time) public view returns (uint) {

        return _time.sub(startTime).div(roundTime);

    }

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

