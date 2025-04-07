/**
 *Submitted for verification at Etherscan.io on 2020-07-14
*/

pragma solidity 0.6.10;





abstract contract Staking {
    struct update {             // Price updateState
        uint timestamp;         // Last update timestamp, unix time
        uint numerator;         // Numerator of percent change (1% increase = 1/100)
        uint denominator;       // Denominator of percent change
        uint price;         // In USD. 0001 is $0.001, 1000 is $1.000, 1001 is $1.001, etc
        uint volume;        // In whole USD (100 = $100)
    }
    update public _lastUpdate; 
    function streak() public virtual view returns (uint);
}

contract Calculator {
    using SafeMath for uint256;
    
    struct update {             // Price updateState
        uint timestamp;         // Last update timestamp, unix time
        uint numerator;         // Numerator of percent change (1% increase = 1/100)
        uint denominator;       // Denominator of percent change
        uint price;         // In USD. 0001 is $0.001, 1000 is $1.000, 1001 is $1.001, etc
        uint volume;        // In whole USD (100 = $100)
    }
    
    uint public _percent;
    
    uint public _inflationAdjustmentFactor;
    
    Staking public _stakingContract;
    
    uint public _maxStreak;
    
    address payable public _owner;
    
    constructor(address stakingContract) public {
        _stakingContract = Staking(stakingContract);
        _owner = msg.sender;
        _percent = 8;
        _inflationAdjustmentFactor = 350;
        _maxStreak = 7;
    }
    
    
    
    function mulDiv (uint x, uint y, uint z) public pure returns (uint) {
          (uint l, uint h) = fullMul (x, y);
          assert (h < z);
          uint mm = mulmod (x, y, z);
          if (mm > l) h -= 1;
          l -= mm;
          uint pow2 = z & -z;
          z /= pow2;
          l /= pow2;
          l += h * ((-pow2) / pow2 + 1);
          uint r = 1;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          r *= 2 - z * r;
          return l * r;
    }
    
    function fullMul (uint x, uint y) private pure returns (uint l, uint h) {
          uint mm = mulmod (x, y, uint (-1));
          l = x * y;
          h = mm - l;
          if (mm < l) h -= 1;
    }
    
    function calculateNumTokens(uint256 balance, uint256 daysStaked, address stakerAddress, uint256 totalSupply) external view returns (uint256) {
        require(msg.sender == address(_stakingContract));
        uint256 inflationAdjustmentFactor = _inflationAdjustmentFactor;
        uint _streak = _stakingContract.streak();
        (uint _, uint numerator, uint denominator, uint price, uint volume) = _stakingContract._lastUpdate();
        
        if(_streak > _maxStreak) {
            _streak = _maxStreak;
        }
        
        if (_streak > 1) {
            inflationAdjustmentFactor /= _streak;       // If there is a streak, we decrease the inflationAdjustmentFactor
        }
        
        if (daysStaked > 60) {      // If you stake for more than 60 days, you have hit the upper limit of the multiplier
            daysStaked = 60;
        } else if (daysStaked == 0) {   // If the minimum days staked is zero, we change the number to 1 so we don't return zero below
            daysStaked = 1;
        }
        
        uint ratio = mulDiv(totalSupply, price, 1000E18).div(volume);     // Ratio of market cap to volume
        
        if (ratio > 50) {  // Too little volume. Decrease rewards. To be honest, this number was arbitrarily chosen.
            inflationAdjustmentFactor = inflationAdjustmentFactor.mul(10);
        } else if (ratio > 25) { // Still not enough. Streak doesn't count.
            inflationAdjustmentFactor = _inflationAdjustmentFactor;
        }
        
        uint numTokens = mulDiv(balance, numerator * daysStaked, denominator * inflationAdjustmentFactor);      // Function that calculates how many tokens are due. See muldiv below.
        uint tenPercent = mulDiv(balance, 1, 10);
        
        if (numTokens > tenPercent) {       // We don't allow a daily rewards of greater than ten percent of a holder's balance.
            numTokens = tenPercent;
        }
        
        return numTokens;
    }
    
    function randomness() public view returns (uint256) {
        return _percent;
    }
    
    function updatePercent(uint percent) external {
        require(msg.sender == _owner);
        _percent = percent;
    }
    
    function updateMaxStreak(uint maxStreak) external {
        require(msg.sender == _owner);
        _maxStreak = maxStreak;
    }
    
    function updateInflationAdjustmentFactor(uint inflationAdjustmentFactor) external {
        require(msg.sender == _owner);
        _inflationAdjustmentFactor = inflationAdjustmentFactor;
    }
    
    function selfDestruct() external {
        require(msg.sender == _owner);
        selfdestruct(_owner);
    }
}