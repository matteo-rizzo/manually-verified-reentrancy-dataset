/**
 *Submitted for verification at Etherscan.io on 2021-06-30
*/

pragma solidity 0.8.0;
//SPDX-License-Identifier: BSD-3-Clause
/**
 * Vaults Reward Fund Locked till 20th Oct 2020 
 * Farming vault token will transfer on Vaults smart contrcat after unlock which will be without withdrawal permission
 *
 */
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract DAO1_LP_Locker is Ownable {
    address public constant beneficiary = 0x920ae8A9c224d554d9642292670a684a1466ED16; // DAO1 Token Owner address
    // unlocks on Dec 07 2022
    uint public constant unlockTime = 1670351400;
    function isUnlocked() public view returns (bool) {
        return block.timestamp > unlockTime;
    }
    function claim(address _tokenAddr, uint _amount) public onlyCaller {
        require(isUnlocked(), "Cannot transfer tokens while locked.");
        token(_tokenAddr).transfer(beneficiary, _amount);
    }
}