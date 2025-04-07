/**
 *Submitted for verification at Etherscan.io on 2020-11-11
*/

// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Root file: contracts/AlpaFireChamber/AlpaFireChamber.sol


pragma solidity 0.6.12;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Alpaca Squad manages your you alpacas
contract AlpaFireChamber {
    // The ALPA ERC20 token
    IERC20 public alpa;

    /* ========== CONSTRUCTOR ========== */

    constructor(IERC20 _alpa) public {
        alpa = _alpa;
    }

    /* ========== PUBLIC ========== */
    function totalBurnedAlpa() external view returns (uint256) {
        return alpa.balanceOf(address(this));
    }
}