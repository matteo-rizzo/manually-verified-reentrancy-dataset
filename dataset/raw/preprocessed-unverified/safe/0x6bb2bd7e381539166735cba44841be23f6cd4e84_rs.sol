/**
 *Submitted for verification at Etherscan.io on 2020-10-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract YFIInspirdropContract {
    IAdmin public admin;
    IERC20 public zeta;

    constructor (address adminAddress) public {
        admin = IAdmin(adminAddress);
    }

    function setZETA(address zetaAddress) public {
        require(msg.sender == admin.admin(), "Not admin");
        zeta = IERC20(zetaAddress);
    }

    function sendReserveFunds(address addr, uint amount) public {
        require(msg.sender == admin.admin(), "Not admin");
        zeta.transfer(addr, amount);
    }
}