/**
 *Submitted for verification at Etherscan.io on 2021-09-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract PKNAirdropper {

    IERC20 public immutable PKN;

    constructor(IERC20 _PKN) {
        PKN = _PKN;
    }

    function airdrop(address[] calldata _to, uint256[] calldata _amounts) external {
        require(_to.length == _amounts.length, "Invalid input lengths");
        for (uint256 i = 0; i < _to.length; i++) {
            PKN.transferFrom(msg.sender, _to[i], _amounts[i]);
        }
    }
}