/**
 *Submitted for verification at Etherscan.io on 2021-06-10
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




contract OwnerHelper {
    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }
}

contract TokenLock is OwnerHelper {
    using SafeMath for uint256;
    
    address public neopinContract;
    
    uint256 initTime = 1623250800; // 2021/06/10 00:00
    uint256 firstFreezeTime = 1654786800; // 2022/06/10 00:00
    uint256 secondFreezeTime = 1686322800; // 2023/06/10 00:00
    
    mapping (address => mapping ( uint256 => uint256 )) public freezeBalances;
    mapping (address => mapping ( uint256 => uint256 )) public freezeTimes;
    uint256 public totalLockBalance;
    
  	constructor(address _contract)
	{
		neopinContract = _contract;
		totalLockBalance = 0;
  	}
  	
  	function getBlockTime() view public returns (uint) {
  	    return block.timestamp;
  	}
    
    function freezeTokens(address _target, uint256 _amount) public onlyOwner {
        require(_amount > 0, 'Not Enough Ammount');
        require(_target != address(0x0), 'Invalid Address');
        
        uint256 balance = IERC20(neopinContract).balanceOf(address(this)) / 1e18;
        require(_amount + totalLockBalance <= balance, 'Not Enough Balance');
        
        totalLockBalance = totalLockBalance.add(_amount);
        
        freezeBalances[_target][0] = _amount * 5 / 10;
        freezeBalances[_target][1] = _amount * 3 / 10;
        freezeBalances[_target][2] = _amount * 2 / 10;
        
        freezeTimes[_target][0] = initTime;
        freezeTimes[_target][1] = firstFreezeTime;
        freezeTimes[_target][2] = secondFreezeTime;
    }
    
    function getTotalFreezeBalance() view public returns (uint256) {
        return freezeBalances[msg.sender][0] + freezeBalances[msg.sender][1] + freezeBalances[msg.sender][2];
    }
    
    function getFreezeBalance(uint256 _time) view public returns (uint256) {
        return freezeBalances[msg.sender][_time];
    }
    
    function withdrawToken(uint256 _time) public
    {
        require(freezeBalances[msg.sender][_time] > 0 && block.timestamp > freezeTimes[msg.sender][_time]);
        
        uint256 value = freezeBalances[msg.sender][_time] * (10 ** 18);
        freezeBalances[msg.sender][_time] = 0;
        
        IERC20(neopinContract).transfer(msg.sender, value);
    }
}