// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract MultiSend {
    
    address private owner;
    constructor (address _owner) public {
        owner = _owner;
    }
    
    function sendMany(IERC20 token, address[] calldata addresses, uint256[] calldata amounts) external {
        require(msg.sender == owner);
        require(addresses.length == amounts.length);
        for (uint i = 0; i < addresses.length; i++) {
            token.transfer(addresses[i], amounts[i]);
        }
        
    }
    
    
}