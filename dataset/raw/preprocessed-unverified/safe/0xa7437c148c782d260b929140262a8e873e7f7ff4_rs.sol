/**

 *Submitted for verification at Etherscan.io on 2019-07-11

*/



pragma solidity 0.5.9;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */



contract Bussiness is Ownable {

    uint public periodToPlay = 60; // 86400; // seconds



    mapping(address => uint) public timeTrackUser;

    event _random(address _from, uint _ticket);

    constructor() public {}

    function getAward() public {

        require(isValidToPlay());

        timeTrackUser[msg.sender] = block.timestamp;

        emit _random(msg.sender, block.timestamp);

    }



    function isValidToPlay() public view returns (bool){

        return periodToPlay <= now - timeTrackUser[msg.sender];

    }

    function changePeriodToPlay(uint _period) onlyOwner public{

        periodToPlay = _period;

    }



}