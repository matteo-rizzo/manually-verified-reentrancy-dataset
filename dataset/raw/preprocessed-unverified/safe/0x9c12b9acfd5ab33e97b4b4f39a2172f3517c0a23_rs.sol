/**
 *Submitted for verification at Etherscan.io on 2020-08-06
*/

/**
 *Submitted for verification at Etherscan.io on 2020-07-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.10;



abstract contract IERC20 {
    function balanceOf(address account) public view virtual returns (uint256);
    function transfer(address to, uint256 value) public virtual returns (bool);
}

/**
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens after a given release time. 
 
 * This contract was modified to support a daily vesting schedule that will release 1500 everday to Big PP (total locked 50k, more can be locked in the future if desired by community).
 */
contract TokenTimelock {
    using SafeMath for uint256;

    // ERC20 basic token contract being held
    IERC20 private _token;

    // Beneficiary of tokens after they are released
    address private _beneficiary;

    // Timestamp when the timelock started
    uint256 private _startTime;
    
    // Timestamp of the last time vested tokens were claimed
    uint256 private _lastRelease;
    
    // Total days tokens will be locked for
    uint private _totalDays;
    
    // Total tokens the contract holds
    uint private _totalTokens;
    
    // True when the first month of tokens were claimed
    bool private _vestingStarted;

    constructor (IERC20 token) public {
        _token = token;
        _beneficiary = msg.sender;
        _startTime = block.timestamp;
        _lastRelease = block.timestamp;
        _totalDays = 33;   // tokens will be locked for 33 days
        _vestingStarted = false;
    }

    /**
     * @return the token being held.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the time when the timelock started.
     */
    function startTime() public view returns (uint256) {
        return _startTime;
    }
    
    function lastRelease() public view returns (uint256) {
        return _lastRelease;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.This will release 1500 tokens a day to beneficiary.
     */
    function release() public {
        
        require(msg.sender == _beneficiary);
        
        if(!_vestingStarted) {
            _totalTokens = _token.balanceOf(address(this));
            _vestingStarted = true;
        }
        
        require(_totalTokens > 0, "TokenTimelock: no tokens to release");
         
        
        uint daysSinceLast = block.timestamp.sub(_lastRelease) / 86400;
        
        require(daysSinceLast >= 1);
        
        _lastRelease = block.timestamp;
        
        uint amount = 1500;

        _token.transfer(_beneficiary, amount);
    }
    
    // Only used in case the above does not work (after 33 days)
    function releaseTheRest() external {
        
        require(msg.sender == _beneficiary);
        
        uint daysSinceStart = block.timestamp.sub(_startTime) / 86400;
        require(daysSinceStart >= 33);
        uint amount = _token.balanceOf(address(this));
        _token.transfer(_beneficiary, amount);
        
    }
    
    function updateBeneficiary(address newBeneficiary) external {
        require(msg.sender == _beneficiary);
        _beneficiary = newBeneficiary;
    }
    
    // Used if more tokens are transferred to be locked
    function syncBalance() external {
        require(msg.sender == _beneficiary);
        _totalTokens = _token.balanceOf(address(this));
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
}