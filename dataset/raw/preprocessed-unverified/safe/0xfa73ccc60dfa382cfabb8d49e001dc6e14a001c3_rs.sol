/**
 *Submitted for verification at Etherscan.io on 2020-07-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
contract testingUSDT {
    
    ERC20 token;
    
    constructor (address _token) public {
        token = ERC20(_token);
    }
    
    
    function deposit (uint _amount, uint _recipient) external {
        require(token.transferFrom(msg.sender , address(this), _amount));
    } 
    
    function withdraw (uint _amount) external {
        require(token.transfer(msg.sender , _amount));
    } 
    
}