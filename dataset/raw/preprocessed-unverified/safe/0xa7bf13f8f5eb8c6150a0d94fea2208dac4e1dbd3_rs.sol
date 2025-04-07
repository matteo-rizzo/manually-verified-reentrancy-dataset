/**
 *Submitted for verification at Etherscan.io on 2021-05-13
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.5.15;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




contract SetJoiner {
    address constant SET_TOKEN = 0x7b18913D945242A9c313573E6c99064cd940c6aF;

    IBasicIssuanceModule constant ISSUANCE_MODULE =
        IBasicIssuanceModule(0xd8EF3cACe8b4907117a45B0b125c68560532F94D);

    IERC20 constant TOKEN = IERC20(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);

    address constant TREASURY_MULTISIG =
        0xe94B5EEC1fA96CEecbD33EF5Baa8d00E4493F4f3;

    function execute() public {
        require(
            msg.sender == 0x189bC085565697509cFA34131521Dc7981BACDA0 ||
            msg.sender == 0x285b7EEa81a5B66B62e7276a24c1e0F83F7409c1 ||
            msg.sender == TREASURY_MULTISIG
        );

        uint256 balance = TOKEN.balanceOf(address(this));

        TOKEN.approve(address(ISSUANCE_MODULE), balance);

        ISSUANCE_MODULE.issue(SET_TOKEN, balance, TREASURY_MULTISIG);
    }

    function abort() public {
        require(msg.sender == 0x285b7EEa81a5B66B62e7276a24c1e0F83F7409c1);
        TOKEN.transfer(TREASURY_MULTISIG, TOKEN.balanceOf(address(this)));
    }
}