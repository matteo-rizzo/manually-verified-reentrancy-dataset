/**
 *Submitted for verification at Etherscan.io on 2021-04-09
*/

// Sources flattened with hardhat v2.0.2 https://hardhat.org

// File @openzeppelin/contracts/introspection/[email protected]

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */



// File @openzeppelin/contracts/math/[email protected]





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



// File contracts/Math.sol




/**
 * @title Math
 *
 * Library for non-standard Math functions
 * NOTE: This file is a clone of the dydx protocol's Decimal.sol contract.
 * It was forked from https://github.com/dydxprotocol/solo at commit
 * 2d8454e02702fe5bc455b848556660629c3cad36. It has not been modified other than to use a
 
 */



// File contracts/Decimal.sol

/*
    Copyright 2019 dYdX Trading Inc.
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/




/**
 * NOTE: This file is a clone of the dydx protocol's Decimal.sol contract. It was forked from https://github.com/dydxprotocol/solo
 * at commit 2d8454e02702fe5bc455b848556660629c3cad36
 *
 
 */


/**
 * @title Decimal
 *
 * Library that defines a fixed-point number with 18 decimal places.
 */



// File contracts/interfaces/IMarket.sol






/**
 * @title Interface for Zora Protocol's Market
 */



// File contracts/interfaces/IMedia.sol






/**
 * @title Interface for Zora Protocol's Media
 */



// File contracts/NFTFactoryV3.sol









contract NFTFactoryV3 {
    // ============ Constants ============

    // To check that the given media address represents an ERC721 contract.
    bytes4 internal constant NFT_INTERFACE_ID = 0x80ac58cd;

    // ============ Immutable Storage ============

    // An NFT contract address that represents the media that will eventually be traded.
    address public immutable mediaAddress;

    // ============ Constructor ============

    constructor(address mediaAddress_) public {
        // NFT compatibility check.
        require(
            IERC165(mediaAddress_).supportsInterface(NFT_INTERFACE_ID),
            "Media address must be ERC721"
        );

        // Initialize immutable storage.
        mediaAddress = mediaAddress_;
    }

    function mintNFT(
        IMedia.MediaData calldata mediaData,
        IMarket.BidShares calldata bidShares,
        address payable creator,
        IMedia.EIP712Signature calldata creatorSignature
    ) external {
        IMedia(mediaAddress).mintWithSig(
            creator,
            mediaData,
            bidShares,
            creatorSignature
        );
    }

    function createAuction(
        uint256 tokenId,
        uint256 duration,
        uint256 reservePrice,
        uint8 curatorFeePercent,
        address curator,
        address payable fundsRecipient,
        address auction,
        IMedia.EIP712Signature calldata creatorSignature
    ) external {
        // Allow the auction contract to pull the NFT.
        IMedia(mediaAddress).permit(auction, tokenId, creatorSignature);
        // Create an auction for the NFT, which pulls the NFT.
        IReserveAuctionV3Modified(auction).createAuction(
            tokenId,
            duration,
            reservePrice,
            curatorFeePercent,
            curator,
            fundsRecipient
        );
    }
}