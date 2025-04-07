/**
 *Submitted for verification at Etherscan.io on 2021-06-15
*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.6.12;



/**
 * @title MultiMinter
 */
contract MultiMinter {
  address public owner;
  IMillionPieces constant public millionPieces = IMillionPieces(0x32A984F84E056b6E553cD0C3729fDDd2d897769c);

  constructor() public {
    owner = msg.sender;
  }

  //  --------------------
  //  PUBLIC
  //  --------------------

  function mintMany(uint256[] calldata tokenIds, address receiver) external {
    require(msg.sender == owner);
    _mintMany(tokenIds, receiver);
  }

  //  --------------------
  //  INTERNAL
  //  -------------------

  function _mintMany(uint256[] memory tokenIds, address receiver) private {
    uint256 tokensCount = tokenIds.length;

    for (uint256 i = 0; i < tokensCount; i++) {
      uint256 tokenId = tokenIds[i];
      if (_isAvailable(tokenId)) {

        if (_isSpecialSegment(tokenId)) {
            _mintSpecialNft(receiver, tokenId);
        } else 
            _mintNft(receiver, tokenId);
        }

      }
  }

  function _mintNft(address receiver, uint256 tokenId) private {
    millionPieces.mintTo(receiver, tokenId);
  }

  function _mintSpecialNft(address receiver, uint256 tokenId) private {
    millionPieces.mintToSpecial(receiver, tokenId);
  }

  function _isAvailable(uint256 tokenId) private view returns (bool) {
    return !millionPieces.exists(tokenId);
  }

  function _isSpecialSegment(uint256 tokenId) private view returns (bool) {
    return millionPieces.isSpecialSegment(tokenId);
  }
}