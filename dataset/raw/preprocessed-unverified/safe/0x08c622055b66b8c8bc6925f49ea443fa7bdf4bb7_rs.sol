pragma solidity ^0.4.18;

    /// @title Ownable





contract SafeTimeLock is Ownable {
    
    token public epm;
    
    uint256 public constant DURATION = 2 years;
    uint256 public startTime = 0;
    uint256 public endTime = 0;
    uint256 public remaining = 0;
    
    /**
     * Constructor function
     *
     */

    function SafeTimeLock() {
        epm = token(0xc5594d84B996A68326d89FB35E4B89b3323ef37d);
        startTime = now;
        endTime = startTime + DURATION;
    }
    
    function getRemainTime() public constant returns (uint256 remaining) {
        remaining = endTime - now;
    }
    
    modifier onlyOutTimeLock() {
        if (now < startTime || now <= endTime) {
            throw;
        }
        _;
    }
    
    function Withdrawal(uint amount) onlyOutTimeLock {
        epm.transfer(msg.sender, amount*10**18);
    }
}