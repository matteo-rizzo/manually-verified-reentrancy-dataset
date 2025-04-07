/**
 *Submitted for verification at Etherscan.io on 2021-02-12
*/

pragma solidity 0.8.0;
pragma abicoder v2;






abstract contract IInvariantValidator is MassetStructs {
    // Mint
    function computeMint(
        BassetData[] calldata _bAssets,
        uint8 _i,
        uint256 _rawInput,
        InvariantConfig memory _config
    ) external view virtual returns (uint256);

    function computeMintMulti(
        BassetData[] calldata _bAssets,
        uint8[] calldata _indices,
        uint256[] calldata _rawInputs,
        InvariantConfig memory _config
    ) external view virtual returns (uint256);

    // Swap
    function computeSwap(
        BassetData[] calldata _bAssets,
        uint8 _i,
        uint8 _o,
        uint256 _rawInput,
        uint256 _feeRate,
        InvariantConfig memory _config
    ) external view virtual returns (uint256, uint256);

    // Redeem
    function computeRedeem(
        BassetData[] calldata _bAssets,
        uint8 _i,
        uint256 _mAssetQuantity,
        InvariantConfig memory _config
    ) external view virtual returns (uint256);

    function computeRedeemExact(
        BassetData[] calldata _bAssets,
        uint8[] calldata _indices,
        uint256[] calldata _rawOutputs,
        InvariantConfig memory _config
    ) external view virtual returns (uint256);
}







/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

/**
 * @dev Collection of functions related to the address type
 */








// SPDX-License-Identifier: AGPL-3.0-or-later
// External
// Internal
// Libs
/**
 * @title   Manager
 * @author  mStable
 * @notice  Simply contains logic to perform Basket Manager duties for an mAsset.
 *          Allowing logic can be abstracted here to avoid bytecode inflation.
 * @dev     VERSION: 1.0
 *          DATE:    2021-01-22
 */
