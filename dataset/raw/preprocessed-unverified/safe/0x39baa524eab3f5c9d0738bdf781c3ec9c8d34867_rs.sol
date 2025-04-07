/**
 *Submitted for verification at Etherscan.io on 2021-03-23
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract RewardPool {

    event TransferredOwnership(address _previous, address _next, uint256 _time);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Owner only");
        _;
    }

    IERC20 public OHMToken;

    address public owner;

    constructor( address _OHMToken ) {
        OHMToken = IERC20( _OHMToken );
        owner = msg.sender;
    }

    function transferOwnership(address _owner) public onlyOwner() {
        address previousOwner = owner;
        owner = _owner;
        emit TransferredOwnership(previousOwner, owner, block.timestamp);
    }

    function allowTransferToStaking(address _stakingAddress, uint256 _amount) public onlyOwner() {
        OHMToken.approve(_stakingAddress, _amount);
    }

}