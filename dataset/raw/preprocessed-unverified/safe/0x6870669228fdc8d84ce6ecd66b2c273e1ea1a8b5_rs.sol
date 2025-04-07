/**
 *Submitted for verification at Etherscan.io on 2021-06-14
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

  function mintMany(uint256[] calldata tokenIds) external {
    require(msg.sender == owner);
    _mintMany(tokenIds);
  }

  //  --------------------
  //  INTERNAL
  //  -------------------

  function _mintMany(uint256[] memory tokenIds) private {
    uint256 tokensCount = tokenIds.length;

    for (uint256 i = 0; i < tokensCount; i++) {
      if (_isAvailable(tokenIds[i])) {
        _mintNft(msg.sender, tokenIds[i]);
      }
    }
  }

  function _mintNft(address receiver, uint256 tokenId) private {
    millionPieces.mintTo(receiver, tokenId);
  }

  function _isAvailable(uint256 tokenId) private view returns (bool) {
    return !millionPieces.exists(tokenId);
  }
}