/**
 *Submitted for verification at Etherscan.io on 2021-09-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
    _setOwner(_msgSender());
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view virtual returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public virtual onlyOwner {
    _setOwner(address(0));
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _setOwner(newOwner);
  }

  function _setOwner(address newOwner) private {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */




/**
 * Meta Kings - 4
 * Metavatars - 9
 * Archaeons - 19
 * Aeons - 69
 * Eos - 900
 *
 * Total number of NFTs: 1001
 */

contract NFTInitialSeller is Ownable {
  using Counters for Counters.Counter;
  using SafeMath for uint256;

  enum SaleStep {
    None,
    EarlyBirdSale,
    Airdrop,
    SecondSale,
    SoldOut
  }

  uint16 public constant MAX_NFT_SUPPLY = 1001;

  // Early bird sale prices
  uint256 public constant METAKING_PRICE = 0.5 ether;
  uint256 public constant METAVATARS_PRICE = 0.5 ether;
  uint256 public constant ARCHAEONS_PRICE = 0.3 ether;
  uint256 public constant AEONS_PRICE = 0.3 ether;
  uint256 public constant EOS_PRICE = 0.19 ether;

  // Second sale price
  uint256 public constant SECOND_SALE_PRICE = 0.3 ether;

  uint256 public startTime;

  uint16 public pendingCount = MAX_NFT_SUPPLY;

  bool[1002] public minted;

  IFacelessNFT public facelessNFT;

  uint16[10000] private _pendingIds;

  // First sale is Early Bird Sale
  SaleStep private _currentSale = SaleStep.None;

  modifier airdropPeriod() {
    require(
      _currentSale == SaleStep.Airdrop,
      "NFTInitialSeller: Airdrop ended"
    );
    _;
  }

  modifier earlyBirdSalePeriod() {
    require(
      _currentSale == SaleStep.EarlyBirdSale,
      "NFTInitialSeller: Early Bird Sale ended"
    );
    _;
  }

  modifier secondSalePeriod() {
    require(
      _currentSale == SaleStep.SecondSale,
      "NFTInitialSeller: Second Sale ended"
    );
    _;
  }

  modifier periodStarted() {
    require(
      block.timestamp >= startTime,
      "NFTInitialSeller: Period not started"
    );
    _;
  }

  constructor(address nftAddress) {
    facelessNFT = IFacelessNFT(nftAddress);
  }

  function setCurrentSale(SaleStep _sale) external onlyOwner {
    require(_currentSale != _sale, "NFTInitialSeller: step already set");
    _currentSale = _sale;
  }

  function setStartTime(uint256 _startTime) external onlyOwner {
    require(_startTime > 0, "NFTInitialSeller: invalid _startTime");
    require(_startTime > block.timestamp, "NFTInitialSeller: old start time");
    startTime = _startTime;
  }

  function airdropTransfer(address to, uint16 tokenId)
    external
    airdropPeriod
    onlyOwner
  {
    uint16 nftIndex = _getPendingIndexById(tokenId, 647, 200);
    require(nftIndex >= 647, "NFTInitialSeller: too low index");
    require(nftIndex <= 846, "NFTInitialSeller: too high index");
    require(!minted[tokenId], "NFTInitialSeller: already minted");
    _popPendingAtIndex(nftIndex);
    minted[tokenId] = true;
    facelessNFT.mint(to, tokenId);
  }

  function standardPurchase(uint16 tokenId)
    external
    payable
    earlyBirdSalePeriod
    periodStarted
  {
    uint16 nftIndex = _getPendingIndexById(tokenId, 847, 155);
    require(nftIndex >= 847, "NFTInitialSeller: too low index");
    require(nftIndex <= 1001, "NFTInitialSeller: too high index");
    require(!minted[tokenId], "NFTInitialSeller: already minted");
    require(
      msg.value == _getMintPrice(tokenId),
      "NFTInitialSeller: invalid ether value"
    );
    _popPendingAtIndex(nftIndex);
    minted[tokenId] = true;
    facelessNFT.mint(msg.sender, tokenId);
  }

  /**
   * @dev Mint 'numberOfNfts' new tokens
   */
  function randomPurchase(uint256 numberOfNfts)
    external
    payable
    secondSalePeriod
    periodStarted
  {
    require(pendingCount > 0, "NFTInitialSeller: All minted");
    require(numberOfNfts > 0, "NFTInitialSelle: numberOfNfts cannot be 0");
    require(
      numberOfNfts <= 20,
      "NFTInitialSeller: You may not buy more than 20 NFTs at once"
    );
    require(
      facelessNFT.totalSupply().add(numberOfNfts) <= MAX_NFT_SUPPLY,
      "NFTInitialSeller: sale already ended"
    );
    require(
      SECOND_SALE_PRICE.mul(numberOfNfts) == msg.value,
      "NFTInitialSeller: invalid ether value"
    );

    for (uint i = 0; i < numberOfNfts; i++) {
      _randomMint(msg.sender);
    }
  }

  /**
   * @dev Withdraw total eth balance on the contract to owner
   */
  function withdraw() external onlyOwner {
    (bool sent, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(sent, "NFTInitialSeller: Failed to withdraw");
  }

  function getPendingAtIndex(uint16 _index) public view returns (uint16) {
    return _pendingIds[_index] + _index;
  }

  function _getPendingIndexById(
    uint16 tokenId,
    uint16 startIndex,
    uint16 totalCount
  ) internal view returns (uint16) {
    for (uint16 i = 0; i < totalCount; i++) {
      uint16 pendingTokenId = getPendingAtIndex(i + startIndex);
      if (pendingTokenId == tokenId) {
        return i + startIndex;
      }
    }
    revert("NFTInitialSeller: invalid token id(pending index)");
  }

  function _getMintPrice(uint16 tokenId) internal pure returns (uint256) {
    require(tokenId >= 847, "NFTInitialSeller: low token id");
    if (tokenId <= 848) return METAKING_PRICE;
    if (tokenId <= 851) return METAVATARS_PRICE;
    if (tokenId <= 862) return ARCHAEONS_PRICE;
    if (tokenId <= 901) return AEONS_PRICE;
    if (tokenId <= 1001) return EOS_PRICE;
    revert("NFTInitialSeller: invalid token id(mint price)");
  }

  function _popPendingAtIndex(uint16 _index) internal returns (uint16) {
    uint16 tokenId = getPendingAtIndex(_index);
    if (_index != pendingCount) {
      uint16 lastPendingId = getPendingAtIndex(pendingCount);
      _pendingIds[_index] = lastPendingId - _index;
    }
    pendingCount--;
    return tokenId;
  }

  function _randomMint(address _to) internal {
    uint16 index = uint16((_getRandom() % pendingCount) + 1);
    uint256 tokenId = _popPendingAtIndex(index);
    minted[tokenId] = true;
    facelessNFT.mint(_to, index);
  }

  function _getRandom() internal view returns (uint256) {
    return
      uint256(
        keccak256(
          abi.encodePacked(block.difficulty, block.timestamp, pendingCount)
        )
      );
  }
}