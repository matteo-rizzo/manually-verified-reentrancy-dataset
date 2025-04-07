pragma solidity ^0.4.24;









/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}





/**

 * @title ERC721 Non-Fungible Token Standard basic interface

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721Basic {

  event Transfer(

    address indexed _from,

    address indexed _to,

    uint256 _tokenId

  );

  event Approval(

    address indexed _owner,

    address indexed _approved,

    uint256 _tokenId

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



/**

 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721Enumerable is ERC721Basic {

  function totalSupply() public view returns (uint256);

  function tokenOfOwnerByIndex(

    address _owner,

    uint256 _index

  )

    public

    view

    returns (uint256 _tokenId);



  function tokenByIndex(uint256 _index) public view returns (uint256);

}





/**

 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721Metadata is ERC721Basic {

  function name() public view returns (string _name);

  function symbol() public view returns (string _symbol);

  function tokenURI(uint256 _tokenId) public view returns (string);

}





/**

 * @title ERC-721 Non-Fungible Token Standard, full implementation interface

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {

}















contract ListingsERC721 is Ownable {

    using SafeMath for uint256;



    struct Listing {

        address seller;

        address tokenContractAddress;

        uint256 price;

        uint256 allowance;

        uint256 dateStarts;

        uint256 dateEnds;

    }

    

    event ListingCreated(bytes32 indexed listingId, address tokenContractAddress, uint256 price, uint256 allowance, uint256 dateStarts, uint256 dateEnds, address indexed seller);

    event ListingCancelled(bytes32 indexed listingId, uint256 dateCancelled);

    event ListingBought(bytes32 indexed listingId, address tokenContractAddress, uint256 price, uint256 amount, uint256 dateBought, address buyer);



    string constant public VERSION = "1.0.1";

    uint16 constant public GAS_LIMIT = 4999;

    uint256 public ownerPercentage;

    mapping (bytes32 => Listing) public listings;



    constructor (uint256 percentage) public {

        ownerPercentage = percentage;

    }



    function updateOwnerPercentage(uint256 percentage) external onlyOwner {

        ownerPercentage = percentage;

    }



    function withdrawBalance() onlyOwner external {

        assert(owner.send(address(this).balance));

    }

    function approveToken(address token, uint256 amount) onlyOwner external {

        assert(ERC20(token).approve(owner, amount));

    }



    function() external payable { }



    function getHash(address tokenContractAddress, uint256 price, uint256 allowance, uint256 dateEnds, uint256 salt) external view returns (bytes32) {

        return getHashInternal(tokenContractAddress, price, allowance, dateEnds, salt);

    }



    function getHashInternal(address tokenContractAddress, uint256 price, uint256 allowance, uint256 dateEnds, uint256 salt) internal view returns (bytes32) {

        return keccak256(abi.encodePacked(msg.sender, tokenContractAddress, price, allowance, dateEnds, salt));

    }



    function createListing(address tokenContractAddress, uint256 price, uint256 allowance, uint256 dateEnds, uint256 salt) external {

        require(price > 0, "price less than zero");

        require(allowance > 0, "allowance less than zero");

        require(dateEnds > 0, "dateEnds less than zero");

        require(ERC721(tokenContractAddress).ownerOf(allowance) == msg.sender, "user doesn't own this token");

        bytes32 listingId = getHashInternal(tokenContractAddress, price, allowance, dateEnds, salt);

        Listing memory listing = Listing(msg.sender, tokenContractAddress, price, allowance, now, dateEnds);

        listings[listingId] = listing;

        emit ListingCreated(listingId, tokenContractAddress, price, allowance, now, dateEnds, msg.sender);



    }

    function cancelListing(bytes32 listingId) external {

        Listing storage listing = listings[listingId];

        require(msg.sender == listing.seller);

        delete listings[listingId];

        emit ListingCancelled(listingId, now);

    }



    function buyListing(bytes32 listingId, uint256 amount) external payable {

        Listing storage listing = listings[listingId];

        address seller = listing.seller;

        address contractAddress = listing.tokenContractAddress;

        uint256 price = listing.price;

        uint256 tokenId = listing.allowance;

        ERC721 tokenContract = ERC721(contractAddress);

        //make sure listing is still available

        require(now <= listing.dateEnds);

        //make sure that the seller still has that amount to sell

        require(tokenContract.ownerOf(tokenId) == seller, "user doesn't own this token");

        //make sure that the seller still will allow that amount to be sold

        require(tokenContract.getApproved(tokenId) == address(this));

        require(msg.value == price);

        tokenContract.transferFrom(seller, msg.sender, tokenId);

        if (ownerPercentage > 0) {

            seller.transfer(price - (listing.price.mul(ownerPercentage).div(10000)));

        } else {

            seller.transfer(price);

        }

        emit ListingBought(listingId, contractAddress, price, amount, now, msg.sender);

    }





}