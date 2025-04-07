/**

 *Submitted for verification at Etherscan.io on 2018-09-27

*/



pragma solidity 0.4.24;



// File: openzeppelin-solidity/contracts/AddressUtils.sol



/**

 * Utility library of inline functions on addresses

 */





// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: openzeppelin-solidity/contracts/introspection/ERC165.sol



/**

 * @title ERC165

 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md

 */





// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol



/**

 * @title ERC721 Non-Fungible Token Standard basic interface

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721Basic is ERC165 {



  bytes4 internal constant InterfaceId_ERC721 = 0x80ac58cd;

  /*

   * 0x80ac58cd ===

   *   bytes4(keccak256('balanceOf(address)')) ^

   *   bytes4(keccak256('ownerOf(uint256)')) ^

   *   bytes4(keccak256('approve(address,uint256)')) ^

   *   bytes4(keccak256('getApproved(uint256)')) ^

   *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^

   *   bytes4(keccak256('isApprovedForAll(address,address)')) ^

   *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^

   *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^

   *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))

   */



  bytes4 internal constant InterfaceId_ERC721Exists = 0x4f558e79;

  /*

   * 0x4f558e79 ===

   *   bytes4(keccak256('exists(uint256)'))

   */



  bytes4 internal constant InterfaceId_ERC721Enumerable = 0x780e9d63;

  /**

   * 0x780e9d63 ===

   *   bytes4(keccak256('totalSupply()')) ^

   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^

   *   bytes4(keccak256('tokenByIndex(uint256)'))

   */



  bytes4 internal constant InterfaceId_ERC721Metadata = 0x5b5e139f;

  /**

   * 0x5b5e139f ===

   *   bytes4(keccak256('name()')) ^

   *   bytes4(keccak256('symbol()')) ^

   *   bytes4(keccak256('tokenURI(uint256)'))

   */



  event Transfer(

    address indexed _from,

    address indexed _to,

    uint256 indexed _tokenId

  );

  event Approval(

    address indexed _owner,

    address indexed _approved,

    uint256 indexed _tokenId

  );

  event ApprovalForAll(

    address indexed _owner,

    address indexed _operator,

    bool _approved

  );



  function balanceOf(address _owner) public view returns (uint256 _balance);

  function ownerOf(uint256 _tokenId) public view returns (address _owner);

  function exists(uint256 _tokenId) public view returns (bool _exists);



  function approve(address _to, uint256 _tokenId) public;

  function getApproved(uint256 _tokenId)

    public view returns (address _operator);



  function setApprovalForAll(address _operator, bool _approved) public;

  function isApprovedForAll(address _owner, address _operator)

    public view returns (bool);



  function transferFrom(address _from, address _to, uint256 _tokenId) public;

  function safeTransferFrom(address _from, address _to, uint256 _tokenId)

    public;



  function safeTransferFrom(

    address _from,

    address _to,

    uint256 _tokenId,

    bytes _data

  )

    public;

}



// File: contracts/IMarketplace.sol



contract IMarketplace {

    function createAuction(

        uint256 _tokenId,

        uint128 startPrice,

        uint128 endPrice,

        uint128 duration

    )

        external;

}



// File: contracts/AnimalMarketplace.sol



contract AnimalMarketplace is Ownable, IMarketplace {

    using AddressUtils for address;

    using SafeMath for uint256;

    uint8 internal percentFee = 5;



    ERC721Basic private erc721Contract;



    struct Auction {

        address tokenOwner;

        uint256 startTime;

        uint128 startPrice;

        uint128 endPrice;

        uint128 duration;

    }



    struct AuctionEntry {

        uint256 keyIndex;

        Auction value;

    }



    struct TokenIdAuctionMap {

        mapping(uint256 => AuctionEntry) data;

        uint256[] keys;

    }



    TokenIdAuctionMap private auctions;



    event AuctionBoughtEvent(

        uint256 tokenId,

        address previousOwner,

        address newOwner,

        uint256 pricePaid

    );



    event AuctionCreatedEvent(

        uint256 tokenId,

        uint128 startPrice,

        uint128 endPrice,

        uint128 duration

    );



    event AuctionCanceledEvent(uint256 tokenId);



    modifier isNotFromContract() {

        require(!msg.sender.isContract());

        _;

    }



    constructor(ERC721Basic _erc721Contract) public {

        erc721Contract = _erc721Contract;

    }



    // "approve" in game contract will revert if sender is not token owner

    function createAuction(

        uint256 _tokenId,

        uint128 _startPrice,

        uint128 _endPrice,

        uint128 _duration

    )

        external

    {

        // this can be only called from game contract

        require(msg.sender == address(erc721Contract));



        AuctionEntry storage entry = auctions.data[_tokenId];

        require(entry.keyIndex == 0);



        address tokenOwner = erc721Contract.ownerOf(_tokenId);

        erc721Contract.transferFrom(tokenOwner, address(this), _tokenId);



        entry.value = Auction({

            tokenOwner: tokenOwner,

            startTime: block.timestamp,

            startPrice: _startPrice,

            endPrice: _endPrice,

            duration: _duration

        });



        entry.keyIndex = ++auctions.keys.length;

        auctions.keys[entry.keyIndex - 1] = _tokenId;



        emit AuctionCreatedEvent(_tokenId, _startPrice, _endPrice, _duration);

    }



    function cancelAuction(uint256 _tokenId) external {

        AuctionEntry storage entry = auctions.data[_tokenId];

        Auction storage auction = entry.value;

        address sender = msg.sender;

        require(sender == auction.tokenOwner);

        erc721Contract.transferFrom(address(this), sender, _tokenId);

        deleteAuction(_tokenId, entry);

        emit AuctionCanceledEvent(_tokenId);

    }



    function buyAuction(uint256 _tokenId)

        external

        payable

        isNotFromContract

    {

        AuctionEntry storage entry = auctions.data[_tokenId];

        require(entry.keyIndex > 0);

        Auction storage auction = entry.value;

        address sender = msg.sender;

        address tokenOwner = auction.tokenOwner;

        uint256 auctionPrice = calculateCurrentPrice(auction);

        uint256 pricePaid = msg.value;



        require(pricePaid >= auctionPrice);

        deleteAuction(_tokenId, entry);



        refundSender(sender, pricePaid, auctionPrice);

        payTokenOwner(tokenOwner, auctionPrice);

        erc721Contract.transferFrom(address(this), sender, _tokenId);

        emit AuctionBoughtEvent(_tokenId, tokenOwner, sender, auctionPrice);

    }



    function getAuctionByTokenId(uint256 _tokenId)

        external

        view

        returns (

            uint256 tokenId,

            address tokenOwner,

            uint128 startPrice,

            uint128 endPrice,

            uint256 startTime,

            uint128 duration,

            uint256 currentPrice,

            bool exists

        )

    {

        AuctionEntry storage entry = auctions.data[_tokenId];

        Auction storage auction = entry.value;

        uint256 calculatedCurrentPrice = calculateCurrentPrice(auction);

        return (

            entry.keyIndex > 0 ? _tokenId : 0,

            auction.tokenOwner,

            auction.startPrice,

            auction.endPrice,

            auction.startTime,

            auction.duration,

            calculatedCurrentPrice,

            entry.keyIndex > 0

        );

    }



    function getAuctionByIndex(uint256 _auctionIndex)

        external

        view

        returns (

            uint256 tokenId,

            address tokenOwner,

            uint128 startPrice,

            uint128 endPrice,

            uint256 startTime,

            uint128 duration,

            uint256 currentPrice,

            bool exists

        )

    {

        // for consistency with getAuctionByTokenId when returning invalid auction - otherwise it would throw error

        if (_auctionIndex >= auctions.keys.length) {

            return (0, address(0), 0, 0, 0, 0, 0, false);

        }



        uint256 currentTokenId = auctions.keys[_auctionIndex];

        Auction storage auction = auctions.data[currentTokenId].value;

        uint256 calculatedCurrentPrice = calculateCurrentPrice(auction);

        return (

            currentTokenId,

            auction.tokenOwner,

            auction.startPrice,

            auction.endPrice,

            auction.startTime,

            auction.duration,

            calculatedCurrentPrice,

            true

        );

    }



    function getAuctionsCount() external view returns (uint256 auctionsCount) {

        return auctions.keys.length;

    }



    function isOnAuction(uint256 _tokenId) public view returns (bool onAuction) {

        return auctions.data[_tokenId].keyIndex > 0;

    }



    function withdrawContract() public onlyOwner {

        msg.sender.transfer(address(this).balance);

    }



    function refundSender(address _sender, uint256 _pricePaid, uint256 _auctionPrice) private {

        uint256 etherToRefund = _pricePaid.sub(_auctionPrice);

        if (etherToRefund > 0) {

            _sender.transfer(etherToRefund);

        }

    }



    function payTokenOwner(address _tokenOwner, uint256 _auctionPrice) private {

        uint256 etherToPay = _auctionPrice.sub(_auctionPrice * percentFee / 100);

        if (etherToPay > 0) {

            _tokenOwner.transfer(etherToPay);

        }

    }



    function deleteAuction(uint256 _tokenId, AuctionEntry storage _entry) private {

        uint256 keysLength = auctions.keys.length;

        if (_entry.keyIndex <= keysLength) {

            // Move an existing element into the vacated key slot.

            auctions.data[auctions.keys[keysLength - 1]].keyIndex = _entry.keyIndex;

            auctions.keys[_entry.keyIndex - 1] = auctions.keys[keysLength - 1];

            auctions.keys.length = keysLength - 1;

            delete auctions.data[_tokenId];

        }

    }



    function calculateCurrentPrice(Auction storage _auction) private view returns (uint256) {

        uint256 secondsInProgress = block.timestamp - _auction.startTime;



        if (secondsInProgress >= _auction.duration) {

            return _auction.endPrice;

        }



        int256 totalPriceChange = int256(_auction.endPrice) - int256(_auction.startPrice);

        int256 currentPriceChange =

            totalPriceChange * int256(secondsInProgress) / int256(_auction.duration);



        int256 calculatedPrice = int256(_auction.startPrice) + int256(currentPriceChange);



        return uint256(calculatedPrice);

    }



}