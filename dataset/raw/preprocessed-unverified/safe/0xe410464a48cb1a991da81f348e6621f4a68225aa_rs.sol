/**
 *Submitted for verification at Etherscan.io on 2020-12-06
*/

// SPDX-License-Identifier: AGPLv3
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;





contract VaultPermitDeposit {
    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function approveNewVaultToken(address token, address vault)
        external
    {
        ITokenPermit(token).approve(address(vault), type(uint256).max);
    }

    function deposit(address token, address vault, uint256 amount, Permit calldata permit)
        external
        returns (uint256)
    {
        ITokenPermit(token).permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            permit.v,
            permit.r,
            permit.s
        );
        
        ITokenPermit(token).transferFrom(permit.owner, address(this), amount);
        return Vault(vault).deposit(amount, permit.owner);
    }
}