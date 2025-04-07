/**
 *Submitted for verification at Etherscan.io on 2020-10-30
*/

/**
 * SPDX-License-Identifier: UNLICENSED
 */
pragma solidity 0.6.10;

pragma experimental ABIEncoderV2;




/**
 * @dev ZeroX Exchange contract interface.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */



/**
 * @dev Collection of functions related to the address type
 */





/**
 * @author Opyn Team
 * @title Trade0x
 * @notice callee contract to trade on 0x.
 */
contract Trade0x is CalleeInterface {
    using SafeERC20 for ERC20Interface;
    IZeroXExchange public exchange;    
    address public assetProxy;

    constructor(address _exchange, address _assetProxy) public {
        exchange = IZeroXExchange(_exchange);
        assetProxy = _assetProxy;
        // ERC20Interface(_weth).safeApprove(_assetProxy, uint256(-1));
    }

    event Trade0xBatch(address indexed to, uint256 amount);
    event UnwrappedETH(address to, uint256 amount);

    function callFunction(
        address payable _sender,
        address, /* _vaultOwner */
        uint256, /* _vaultId, */
        bytes memory _data
    ) external override payable {

        // todo1: can only be called by controller.

        // todo2: can only be used to trade oTokens

        (IZeroXExchange.Order memory order, uint256 takerAssetFillAmount, bytes memory signature) = abi.decode(
            _data,
            (IZeroXExchange.Order, uint256, bytes)
        );

        address makerAsset = decodeERC20Asset(order.makerAssetData);
        address takerAsset = decodeERC20Asset(order.takerAssetData);

        ERC20Interface(takerAsset).safeTransferFrom(_sender, address(this), takerAssetFillAmount);

        // approve the proxy if not done before
        uint256 allowance = ERC20Interface(takerAsset).allowance(address(this), assetProxy);
        if (allowance < takerAssetFillAmount) {
            ERC20Interface(takerAsset).approve(assetProxy, takerAssetFillAmount);
        }

        exchange.fillOrder{value: msg.value}(order, takerAssetFillAmount, signature);

        // transfer token to sender
        uint256 balance = ERC20Interface(makerAsset).balanceOf(address(this));
        ERC20Interface(makerAsset).safeTransfer(_sender, balance);

        // transfer any excess fee back to user
        _sender.transfer(address(this).balance);
    }

    function decodeERC20Asset(bytes memory b) internal pure returns (address result) {
        require(b.length == 36, "LENGTH_65_REQUIRED");

        uint256 index = 16;

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 20-byte mask to obtain address
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }
}