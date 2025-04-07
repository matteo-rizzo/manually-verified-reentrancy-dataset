/**
 *Submitted for verification at Etherscan.io on 2020-12-24
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------


contract VanillaRewardsWallet is Owned{
    
    mapping(address => bool) public allowedPools;
    
    IERC20 public vanilla;
    
    constructor(address payable _owner, address _vanillaToken) public{
        owner = _owner;
        vanilla = IERC20(_vanillaToken);
    }
    
    function addPool(address _poolAddress) external onlyOwner{
        allowedPools[_poolAddress] = true;
    }
    
    function removePool(address _poolAddress) external onlyOwner{
        allowedPools[_poolAddress] = false;
    }
    
    function sendRewards(address to, uint256 tokens) public{
        require(allowedPools[msg.sender], "UnAuthorized");
        
        // transfer rewards tokens
        require(vanilla.transfer(to, tokens));
    }
}