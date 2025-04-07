/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: UNLICENSED

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */


contract Airdropper {
    address public owner;
    constructor()public{
        owner = msg.sender;
    }
    
    function AirTransfer(address[] memory _recipients, uint _values, address _tokenAddress) onlyOwner public returns (bool) {
        require(_recipients.length > 0);
        InterfaceERC20 token = InterfaceERC20(_tokenAddress);
        for(uint j = 0; j < _recipients.length; j++){
            token.transfer(_recipients[j], _values);
        }
        return true;
    }
    
    function withdrawalToken(address _tokenAddress) onlyOwner public { 
        InterfaceERC20 token = InterfaceERC20(_tokenAddress);
        token.transfer(owner, token.balanceOf(address(this)));
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}