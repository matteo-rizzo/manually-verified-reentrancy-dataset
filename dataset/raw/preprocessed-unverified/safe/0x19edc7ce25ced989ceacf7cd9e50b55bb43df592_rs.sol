/**

 *Submitted for verification at Etherscan.io on 2019-02-08

*/



pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;







/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





contract Bombastic {

  using SafeMath for uint256;

  

  IERC20 public BOMB = IERC20(0x1F4F33C3A163b9Ad84613C1c61337CbFD7C8839f);

  uint256 public START_PRICE = 21;

  uint256 public FEE = 2;

  uint256 public INTERVAL = 12 hours;

  uint256 public ids;



  struct Round {

    address starter;

    uint256 countdown;

    address [] tickets;

    address winner;

    uint256 winnings;

    uint256 started;

    uint256 ended;

  }



  mapping(uint256 => Round) rounds;



  modifier isHuman() {

    address _addr = msg.sender;

    require(_addr == tx.origin);

    uint256 _codeLength;



    assembly {_codeLength := extcodesize(_addr)}

    require(_codeLength == 0);

    _;

  }



  function start() external isHuman() {

    Round storage round = rounds[ids];



    // round must not have started

    require(round.countdown == 0);



    // start round

    round.countdown = now.add(INTERVAL);



    // add to pot

    require(BOMB.transferFrom(msg.sender, address(this), START_PRICE));



    // set round starter

    round.starter = msg.sender;



    // set start time

    round.started = now;



    // add a ticket

    round.tickets.push(msg.sender);

  }



  function buy() external isHuman() {

    Round storage round = rounds[ids];



    // round must have started

    require(round.countdown != 0);



    // round must not have finished

    require(now <= round.countdown);



    // add to countdown

    round.countdown = now.add(INTERVAL);



    // add to pot

    require(BOMB.transferFrom(msg.sender, address(this), FEE));



    // pay starter

    require(BOMB.transferFrom(msg.sender, round.starter, FEE));



    // add a ticket

    round.tickets.push(msg.sender);

  }



  function draw() external isHuman() {

    Round storage round = rounds[ids];



    // round must have started

    require(round.countdown != 0);



    // round must have finished

    require(now > round.countdown);



    // start next round

    ids = ids.add(1);



    // set end time

    round.ended = now;



    // get winner

    round.winner = round.tickets[_winner(round.tickets.length)];



    // update winnings

    round.winnings = BOMB.balanceOf(address(this));



    // transfer to winner

    require(BOMB.transfer(round.winner, round.winnings));

  }



  function _winner(uint256 length) internal view returns (uint256) {

    uint256 seed = uint256(keccak256(abi.encodePacked(

      (block.timestamp).add

      (block.difficulty).add

      ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add

      (block.gaslimit).add

      ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add

      (block.number)

    )));

    return seed % length;

  }



  function getCurrentRound() view external returns (Round memory, uint256, uint256) {

    return (rounds[ids], BOMB.balanceOf(address(this)), ids);

  }



  function getRound(uint256 _roundNum) view external returns (Round memory) {

    return rounds[_roundNum];

  }

}