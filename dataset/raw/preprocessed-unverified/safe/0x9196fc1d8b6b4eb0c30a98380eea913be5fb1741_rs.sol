/**
 *Submitted for verification at Etherscan.io on 2020-10-04
*/

/*


  _  ___                      __   _   _            _    _ _ _ _ 
 | |/ (_)                    / _| | | | |          | |  | (_) | |
 | ' / _ _ __   __ _    ___ | |_  | |_| |__   ___  | |__| |_| | |
 |  < | | '_ \ / _` |  / _ \|  _| | __| '_ \ / _ \ |  __  | | | |
 | . \| | | | | (_| | | (_) | |   | |_| | | |  __/ | |  | | | | |
 |_|\_\_|_| |_|\__, |  \___/|_|    \__|_| |_|\___| |_|  |_|_|_|_|
                __/ |                                            
               |___/                                             

Play game at https://lailune.github.io/KingOfTheHill
Original repo: https://github.com/lailune/KingOfTheHill
by @lailune

Don't forget MetaMask!
***************************
HeyHo! 

Who Wants to Become King of the Hill? Everybody wants!

What to get the king of the hill? All the riches!

Become the king of the mountain and claim all the riches saved on this contract! Trust me, it's worth it!

Who will be in charge and take everything, and who will lose? It's up to you to decide. Take action!

*/

pragma solidity ^0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


contract KingOfTheHill{
    using SafeMath for uint256;

    //It's me
    address payable private _owner;

    //Last income block
    uint256 public lastKingBlock;

    //Current King of Hill
    address payable public currentKing;

    //Current balance
    uint256 public currentBalance = 0;

    //Min participant bid (25 cent)
    uint256 public  minBid = 725000 gwei;

    //Min Bid incrase for every bid
    uint public constant BID_INCRASE = 29000 gwei;

    //Revenue for me :)
    uint public constant OWNER_REVENUE_PERCENT = 5;

    //Wait for 6000 block to claim all money on game start
    uint public constant START_BLOCK_DISTANCE = 6000;


    //Wait for 5 blocks in game barely finished
    uint public constant MIN_BLOCK_DISTANCE = 5;

    //Current block distance
    uint public blockDistance = START_BLOCK_DISTANCE;



    //We have a new king! All glory to new king!
    event NewKing(address indexed user, uint256 amount);

    //We have a winner
    event Winner(address indexed user, uint256 amount);

    /**
     * Were we go
     */
    constructor () public payable {
        _owner = msg.sender;
        lastKingBlock = block.number;
    }

    /**
     * Place a bid for game
     */
    function placeABid() public payable{
      uint256  income = msg.value;


      require(income >= minBid, "Bid should be greater than min bid");

      //Calculate owner revenue
      uint256 ownerRevenue = income.mul(OWNER_REVENUE_PERCENT).div(100);

      //Calculate real income value
      uint256 realIncome = income.sub(ownerRevenue);

      //Check is ok
      require(ownerRevenue != 0 && realIncome !=0,"Income too small");


      //Change current contract balance
      currentBalance = currentBalance.add(realIncome);

      //Save all changes
      currentKing = msg.sender;
      lastKingBlock = block.number;

      //Change block distance
      blockDistance = blockDistance - 1;
      if(blockDistance < MIN_BLOCK_DISTANCE){
          blockDistance = MIN_BLOCK_DISTANCE;
      }

      //Change minimal bid
      minBid = minBid.add(BID_INCRASE);


      //Send owner revenue
      _owner.transfer(ownerRevenue);

      //We have a new King!
      emit NewKing(msg.sender, realIncome);
    }

    receive() external payable {
        placeABid();
    }

    /**
     * Claim the revenue
     */
    function claim() public payable {

        //Check King is a king
        require(currentKing == msg.sender, "You are not king");

        //Check balance
        require(currentBalance > 0, "The treasury is empty");

        //Check wait
        require(block.number - lastKingBlock >= blockDistance, "You can pick up the reward only after waiting for the minimum time");


        //Transfer money to winner
        currentKing.transfer(currentBalance);

        //Emit winner event
        emit Winner(msg.sender, currentBalance);


        //Reset game
        currentBalance = 0;
        currentKing = address(0x0);
        lastKingBlock = block.number;
        blockDistance = START_BLOCK_DISTANCE;
        minBid = 725000 gwei;
    }

    /**
     * How many blocks remain for claim
     */
    function blocksRemain() public view returns (uint){

        if(block.number - lastKingBlock > blockDistance){
            return 0;
        }

        return blockDistance - (block.number - lastKingBlock);
    }

}