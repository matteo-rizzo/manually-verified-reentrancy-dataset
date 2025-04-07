/**
 *Submitted for verification at Etherscan.io on 2021-10-05
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: BSD-3-Clause

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


// Modern ERC20 Token interface


// Modern ERC721 Token interface


contract NFT_Market is Ownable {
    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.UintSet;

    // =========== Start Smart Contract Setup ==============

    // MUST BE CONSTANT - THE FEE TOKEN ADDRESS AND NFT ADDRESS
    // the below addresses are trusted and constant so no issue of re-entrancy happens
    address public constant trustedNftAddress = 0x501c6522e3888e7C1fa6b6c01404F02e4AD08784;

    // minting fee in token, 10 tokens (10e18 because token has 18 decimals)

    uint public mintFee = 50e15;
    uint public maxFree = 0;
    uint public maxToMint = 5000;
    uint public maxPerTransaction = 25;

    // ============ End Smart Contract Setup ================

    function setMintNativeFee(uint _mintFee) public onlyOwner {
        mintFee = _mintFee;
    }
    
    function setMaxPerTransaction(uint _max) public onlyOwner {
        maxPerTransaction = _max;
    }

    function totalSupply() public view returns (uint256){
      return IERC721(trustedNftAddress).totalSupply();
    }

    function canMintFree(uint256 count) public view returns (bool) {
      uint256 totalMinted = IERC721(trustedNftAddress).totalSupply();
      return totalMinted.add(count) < maxFree;
    }

    function mint(uint256 count) payable public {
        // owner can mint without fee
        // other users need to pay a fixed fee in token
        uint256 totalMinted = IERC721(trustedNftAddress).totalSupply();
        require (count < maxPerTransaction, "Max to mint reached");
        require (totalMinted.add(count) <= maxToMint, "Max supply reached");

        address payable _owner = address(uint160(owner));
        if (totalMinted.add(count) > maxFree) {
            require(msg.value >= mintFee.mul(count), "Insufficient fees");
            _owner.transfer(msg.value);
        }
        for(uint i = 0; i < count; i++){
          IERC721(trustedNftAddress).mint(msg.sender);
        }

    }



    event ERC721Received(address operator, address from, uint256 tokenId, bytes data);

    // ERC721 Interface Support Function
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns(bytes4) {
        require(msg.sender == trustedNftAddress);
        emit ERC721Received(operator, from, tokenId, data);
        return this.onERC721Received.selector;
    }

}