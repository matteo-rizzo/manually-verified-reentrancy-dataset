/**
 *Submitted for verification at Etherscan.io on 2021-10-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

/**
 * @dev String operations.
 */



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




contract VestingValidator {
    using Strings for uint256;

    IERC20 public constant TOKEN = IERC20(0x111111111117dC0aa78b770fA6A738034120C302);

    function check(
        IStepVesting[] memory contracts,
        address[] memory receivers,
        uint256[] memory amounts
    ) external {
        uint256 len = contracts.length;
        require(len == receivers.length, "Invalid receivers length");
        require(len == amounts.length, "Invalid amounts length");

        for (uint i = 0; i < len; i++) {
            IStepVesting vesting = contracts[i];
            require(
                vesting.token() == TOKEN,
                string(abi.encodePacked("Invalid token #", (i + 1).toString()))
            );
            require(
                vesting.receiver() == receivers[i],
                string(abi.encodePacked("Invalid receiver #", (i + 1).toString()))
            );
            require(
                vesting.started() == 1606824000, // 01 Dec 2020 12:00 UTC
                string(abi.encodePacked("Invalid start date #", (i + 1).toString()))
            );
            require(
                vesting.cliffDuration() == 31536000, // 365 days
                string(abi.encodePacked("Invalid cliff duration #", (i + 1).toString()))
            );
            require(
                vesting.stepDuration() == 15768000, // 182.5 days
                string(abi.encodePacked("Invalid step duration #", (i + 1).toString()))
            );
            require(
                vesting.cliffAmount() + vesting.stepAmount() * vesting.numOfSteps() == amounts[i],
                string(abi.encodePacked("Invalid amount #", (i + 1).toString()))
            );
            require(
                TOKEN.balanceOf(address(vesting)) == amounts[i],
                string(abi.encodePacked("Invalid balance #", (i + 1).toString()))
            );
        }
    }
}