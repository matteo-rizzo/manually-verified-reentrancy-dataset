/**
 *Submitted for verification at Etherscan.io on 2021-09-13
*/

// SPDX-License-Identifier: GPL-3.0-or-later
// built by @nanexcool for his OCD friend
pragma solidity ^0.8.6;



contract Eth2MultiDeposit {
    IDepositContract constant dc =
        IDepositContract(0x00000000219ab540356cBB839Cbe05303d7705Fa);

    function deposit(
        bytes[] calldata pubkey,
        bytes[] calldata withdrawal_credentials,
        bytes[] calldata signature,
        bytes32[] calldata deposit_data_root
    ) external payable {
        unchecked {
            for (uint256 i = 0; i < pubkey.length; i++) {
                dc.deposit{value: 32 ether}(
                    pubkey[i],
                    withdrawal_credentials[i],
                    signature[i],
                    deposit_data_root[i]
                );
            }
        }
    }
}