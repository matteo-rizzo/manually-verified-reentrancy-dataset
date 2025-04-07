/**
 *Submitted for verification at Etherscan.io on 2020-10-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.4;
/**
Sc dev
t.me/bolpol
*/

/**
    @title ERC20 interface (short version)
*/


/**
    @title Owned - ownership
*/


/**
    @title Airdropper - using for package token transfer
*/
contract Airdropper is Owned {
    ERC20 public token;
    
    event Airdropped(bool indexed ok);
    event Destroyed(uint indexed time);

    /**
     * @dev Constructor.
     * @param tokenAddress Address of the token contract.
     */
    constructor(address tokenAddress) {
        token = ERC20(tokenAddress);
    }

    /**
     * @dev Airdrop.
     * @ !important Before using, send needed token amount to this contract
     */
    function airdrop(address[] memory dests, uint[] memory values) public onlyOwner {
        // This simple validation will catch most mistakes without consuming
        // too much gas.
        require(dests.length == values.length);

        for (uint256 i = 0; i < dests.length; i++) {
            token.transfer(dests[i], values[i]);
        }
        
        emit Airdropped(true);
    }

    /**
     * @dev Return all tokens back to owner, in case any were accidentally
     *   transferred to this contract.
     */
    function returnTokens() public onlyOwner returns(bool) {
        return token.transfer(owner, token.balanceOf(address(this)));
    }

    /**
     * @dev Destroy this contract and recover any ether to the owner.
     */
    function destroy() public onlyOwner {
        if(returnTokens()) {
            emit Destroyed(block.timestamp);
            selfdestruct(msg.sender);
        }
    }
}