/**

 *Submitted for verification at Etherscan.io on 2018-08-15

*/



pragma solidity ^0.4.21;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}





contract TestVesting is Ownable {

  using SafeMath for uint256;



  address public teamWallet;

 

  

  uint256 public teamTimeLock = 60 minutes;

 

  

  //amount of allocation

  uint256 public teamAllocation = 3 * (10 ** 1) * (10 ** 5);

  

  uint256 public totalAllocation = 3 * (10 ** 1) * (10 ** 5);

  

  uint256 public teamStageSetting = 6;

  

  ERC20Basic public token;

  //token start time

  uint256 public start;

  //lock start time

  uint256 public lockStartTime; 

   /** Reserve allocations */

    mapping(address => uint256) public allocations;

    

    mapping(address => uint256) public stageSettings;

    

    mapping(address => uint256) public timeLockDurations;



    /** How many tokens each reserve wallet has claimed */

    mapping(address => uint256) public releasedAmounts;

    

    modifier onlyReserveWallets {

        require(allocations[msg.sender] > 0);

        _;

    }

    function TestVesting(ERC20Basic _token,

                          address _teamWallet,

                          uint256 _start,

                          uint256 _lockTime)public{

        require(_start > 0);

        require(_lockTime > 0);

        require(_start.add(_lockTime) > 0);

        require(_teamWallet != address(0));

        

        token = _token;

        teamWallet = _teamWallet;

      

        start = _start;

        lockStartTime = start.add(_lockTime);

    }

    

    function allocateToken() onlyOwner public{

        require(block.timestamp > lockStartTime);

        //only claim  once

        require(allocations[teamWallet] == 0);

        require(token.balanceOf(address(this)) >= totalAllocation);

        

        allocations[teamWallet] = teamAllocation;

        

        stageSettings[teamWallet] = teamStageSetting;

       

        timeLockDurations[teamWallet] = teamTimeLock;

       

    }

    function releaseToken() onlyReserveWallets public{

        uint256 totalUnlocked = unlockAmount();

        require(totalUnlocked <= allocations[msg.sender]);

        require(releasedAmounts[msg.sender] < totalUnlocked);

        uint256 payment = totalUnlocked.sub(releasedAmounts[msg.sender]);

        

        releasedAmounts[msg.sender] = totalUnlocked;

        require(token.transfer(msg.sender, payment));

    }

    function unlockAmount() public view onlyReserveWallets returns(uint256){

        uint256 stage = vestStage();

        uint256 totalUnlocked = stage.mul(allocations[msg.sender]).div(stageSettings[msg.sender]);

        return totalUnlocked;

    }

    

    function vestStage() public view onlyReserveWallets returns(uint256){

        uint256 vestingMonths = timeLockDurations[msg.sender].div(stageSettings[msg.sender]);

        uint256 stage = (block.timestamp.sub(lockStartTime)).div(vestingMonths);

        

        if(stage > stageSettings[msg.sender]){

            stage = stageSettings[msg.sender];

        }

        return stage;

    }

}