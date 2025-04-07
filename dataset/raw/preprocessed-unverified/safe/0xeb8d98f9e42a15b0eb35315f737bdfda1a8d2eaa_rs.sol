/**
 *Submitted for verification at Etherscan.io on 2021-08-25
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;



// Part: ATokenV1



// Part: ATokenV2



// Part: CToken



// Part: LendingPool



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/Math

/**
 * @dev Standard math utilities missing in the Solidity language.
 */


// Part: Registry



// Part: Vault



// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: YVEmpire.sol

contract YVEmpire {
    Registry constant registry = Registry(0x50c1a2eA0a861A967D9d0FFE2AE4012c2E053804);
    LendingPool constant lendingPool =
        LendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

    enum Service {
        Compound,
        Aavev1,
        Aavev2
    }
    struct Swap {
        Service service;
        address coin;
    }

    function migrate(Swap[] calldata swaps) public {
        for (uint256 i = 0; i < swaps.length; i++) {
            if (swaps[i].service == Service.Compound) {
                swapCompound(swaps[i].coin);
            } else if (swaps[i].service == Service.Aavev1) {
                swapAaveV1(swaps[i].coin);
            } else if (swaps[i].service == Service.Aavev2) {
                swapAaveV2(swaps[i].coin);
            }
        }
    }

    function transferToSelf(address coin) internal returns (uint256) {
        IERC20 token = IERC20(coin);
        uint256 amount = Math.min(
            token.balanceOf(msg.sender),
            token.allowance(msg.sender, address(this))
        );
        require(amount > 0, "!amount");
        SafeERC20.safeTransferFrom(token, msg.sender, address(this), amount);
        return amount;
    }

    function approve(
        IERC20 token,
        address spender,
        uint256 amount
    ) internal {
        if (token.allowance(address(this), spender) < amount) {
            SafeERC20.safeApprove(token, spender, type(uint256).max);
        }
    }

    function depositIntoVault(IERC20 token) internal {
        uint256 balance = token.balanceOf(address(this));
        Vault vault = Vault(registry.latestVault(address(token)));
        approve(token, address(vault), balance);
        uint256 vaultBalance = vault.deposit(balance);
        vault.transfer(msg.sender, vaultBalance);
    }

    function swapCompound(address coin) internal {
        uint256 amount = transferToSelf(coin);
        CToken cToken = CToken(coin);
        IERC20 underlying = IERC20(cToken.underlying());
        require(cToken.redeem(amount) == 0, "!redeem");

        depositIntoVault(underlying);
    }

    function swapAaveV1(address coin) internal {
        transferToSelf(coin);
        ATokenV1 aToken = ATokenV1(coin);
        IERC20 underlying = IERC20(aToken.underlyingAssetAddress());
        aToken.redeem(type(uint256).max);

        depositIntoVault(underlying);
    }

    function swapAaveV2(address coin) internal {
        transferToSelf(coin);
        IERC20 underlying = IERC20(ATokenV2(coin).UNDERLYING_ASSET_ADDRESS());
        lendingPool.withdraw(
            address(underlying),
            type(uint256).max,
            address(this)
        );
        depositIntoVault(underlying);
    }
}