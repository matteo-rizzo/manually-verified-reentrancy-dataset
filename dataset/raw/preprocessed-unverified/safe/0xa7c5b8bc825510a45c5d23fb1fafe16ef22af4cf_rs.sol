/**
 *Submitted for verification at Etherscan.io on 2020-11-21
*/

pragma solidity 0.7.3;

//SPDX-LICENSE-IDENTIFIER: UNLICENSED
/*
    ERC20 Standard Token interface
*/




/**
  * @notice Vesting contract designed to release funds on a monthly basis over a 12 month period
  * @notice all funds deposited into the vesting contract are evenly distributed across the 12 months
  * @notice The contract was designed to accomodate the needs of Leverage Token and as such may not be applicable in other circumstances
  * @notice for example there is no usage of safe math, as the values being vested by Leverage Token can't overflow so no need for extra gas cost
*/
contract Vesting {

    uint256 public startTime;
    uint256 public endTime;
    uint256 public currentCycle;
    uint256 public releaseAmount;
    address public receiver;
    address public owner;

    ERC20Interface private levI; 
    DateTimeInterface private dateI;

    struct Release {
        uint256 timestamp;
        uint256 released;
    }

    mapping (uint256 => Release) public releases;

    event TokensReleased();

    /**
      * @param _levTokenAddress the address of the deployed LEV token contract
      * @param _dateTimeContract the address of the deployed date time contract
    */
    constructor(address _levTokenAddress, address _dateTimeContract, address _owner) {
        levI = ERC20Interface(_levTokenAddress);
        dateI = DateTimeInterface(_dateTimeContract);
        owner = _owner;
    }

    /**
      * @notice prepares the contract for vesting, depositing tokens and 
      * @notice marking the address that will be allowed to receive vested funds
      * @param _amountToVest is the amount of tokens to be vested
      * @param _receiver is the address that will be allowed to receive the withdrawn funds
    */
    function prepare(uint256 _amountToVest, address _receiver) public {
        // make sure only contract owner can call this
        require(msg.sender == owner);
        // make sure prepared is false
        require(isPrepared() == false);
        require(levI.transferFrom(msg.sender, address(this), _amountToVest));
        // the current time when vesting starts
        uint256 _startTime = dateI._now();
        // the time when vesting ends, and the final token release is allowed
        uint256 _endTime = dateI.addMonths(_startTime, 12);
        // set the last token release
        releases[12].timestamp = _endTime;
        // now set the other 11 token release times
        for (uint i = 1; i <= 11; i++) {
            releases[i].timestamp = dateI.addMonths(_startTime, i);
        }
        // each month release 1/12 of _amountToVest
        releaseAmount = _amountToVest / 12;
        // copy memory variables to storage
        startTime = _startTime;
        endTime = _endTime;
        receiver = _receiver;
        // set current release cycle
        currentCycle = 1;
    }

    /**
        * @notice release funds for the current vesting cycle
        * @notice while it is callable by anyone, funds are sent to a fixed address
        * @notice regardless of who calls this function, so owner check is avoided to save gas
    */
    function release() public {
        // make sure prepare function has been called and successfully executed
        require(isPrepared() == true);
        // ensure the current cycle hasn't been released
        require(releases[currentCycle].released == 0, "already released");
        // mark current cycle as released
        releases[currentCycle].released = 1;
        // get current timestamp
        uint256 timestamp = dateI._now();
        // ensure the current timestamp (date) is on or after the release date
        require(timestamp >= releases[currentCycle].timestamp, "release timestamp not yet passed");
        // transfer tokens to designated receiver wallet
        require(levI.transfer(receiver, releaseAmount));
        // move onto the next cycle (if we arent cycle 12 which is last)
        if (currentCycle < 12) {
            currentCycle += 1;
        }
        // emit event indicating tokens are released
        emit TokensReleased();
        
    }

    /**
      * @notice returns whether or not the given cycle has released the tokens
    */
    function isReleased(uint256 _cycle) public view returns (bool) {
        bool released = false;
        if (releases[_cycle].released == 1) {
            released = true;
        }
        return released;
    }

    /**
      * @notice returns whether or note the vesting contract has been prepared
    */
    function isPrepared() public view returns (bool) {
        bool prepared = false;
        if (receiver != address(0) && releaseAmount > 0 && currentCycle > 0) {
            prepared = true;
        }
        return prepared;
    }
}