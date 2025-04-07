/**
 *Submitted for verification at Etherscan.io on 2021-06-08
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
    address public constant trustedFeeTokenAddress = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17;
    address public constant trustedNftAddress = 0x582c905df6caD7a1c490eDc215F0Baa0Dc0960Dd;
    
    // minting fee in token, 10 tokens (10e18 because token has 18 decimals)
    uint public mintFee = 10e18;
    
    // selling fee rate
    uint public sellingFeeRateX100 = 30;
    
    // ============ End Smart Contract Setup ================
    
    // ---------------- owner modifier functions ------------------------
    function setMintFee(uint _mintFee) public onlyOwner {
        mintFee = _mintFee;
    }
    function setSellingFeeRateX100(uint _sellingFeeRateX100) public onlyOwner {
        sellingFeeRateX100 = _sellingFeeRateX100;
    }
    
    // --------------- end owner modifier functions ---------------------
    
    enum PriceType {
        ETHER,
        TOKEN
    }
    
    event List(uint tokenId, uint price, PriceType priceType);
    event Unlist(uint tokenId);
    event Buy(uint tokenId);
    
     
    EnumerableSet.UintSet private nftsForSaleIds;
    
    // nft id => nft price
    mapping (uint => uint) private nftsForSalePrices;
    // nft id => nft owner
    mapping (uint => address) private nftOwners;
    // nft id => ETHER | TOKEN
    mapping (uint => PriceType) private priceTypes;
    
    // nft owner => nft id set
    mapping (address => EnumerableSet.UintSet) private nftsForSaleByAddress;
    
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return nftsForSaleByAddress[owner].length();
    }
    function totalListed() public view returns (uint256) {
        return nftsForSaleIds.length();
    }

    function getToken(uint tokenId) public view returns (uint _tokenId, uint _price, address _owner, PriceType _priceType) {
        _tokenId = tokenId;
        _price = nftsForSalePrices[tokenId];
        _owner = nftOwners[tokenId];
        _priceType = priceTypes[tokenId];
    }
    
    function getTokens(uint startIndex, uint endIndex) public view returns 
        (uint[] memory _tokens, uint[] memory _prices, address[] memory _owners, PriceType[] memory _priceTypes) {
        require(startIndex < endIndex, "Invalid indexes supplied!");
        uint len = endIndex.sub(startIndex);
        require(len <= totalListed(), "Invalid length!");
        
        _tokens = new uint[](len);
        _prices = new uint[](len);
        _owners = new address[](len);
        _priceTypes = new PriceType[](len);
        
        for (uint i = startIndex; i < endIndex; i = i.add(1)) {
            uint listIndex = i.sub(startIndex);
            
            uint tokenId = nftsForSaleIds.at(i);
            uint price = nftsForSalePrices[tokenId];
            address nftOwner = nftOwners[tokenId];
            PriceType priceType = priceTypes[tokenId];
            
            _tokens[listIndex] = tokenId;
            _prices[listIndex] = price;
            _owners[listIndex] = nftOwner;
            _priceTypes[listIndex] = priceType;
        }
    }
    
    // overloaded getTokens to allow for getting seller tokens
    // _owners array not needed but returned for interface consistency
    // view function so no gas is used
    function getTokens(address seller, uint startIndex, uint endIndex) public view returns
        (uint[] memory _tokens, uint[] memory _prices, address[] memory _owners, PriceType[] memory _priceTypes) {
        require(startIndex < endIndex, "Invalid indexes supplied!");
        uint len = endIndex.sub(startIndex);
        require(len <= balanceOf(seller), "Invalid length!");
        
        _tokens = new uint[](len);
        _prices = new uint[](len);
        _owners = new address[](len);
        _priceTypes = new PriceType[](len);
        
        for (uint i = startIndex; i < endIndex; i = i.add(1)) {
            uint listIndex = i.sub(startIndex);
            
            uint tokenId = nftsForSaleByAddress[seller].at(i);
            uint price = nftsForSalePrices[tokenId];
            address nftOwner = nftOwners[tokenId];
            PriceType priceType = priceTypes[tokenId];
            
            _tokens[listIndex] = tokenId;
            _prices[listIndex] = price;
            _owners[listIndex] = nftOwner;
            _priceTypes[listIndex] = priceType;
        }
    }
    
    function mint() public {
        // owner can mint without fee
        // other users need to pay a fixed fee in token
        if (msg.sender != owner) {
            require(IERC20(trustedFeeTokenAddress).transferFrom(msg.sender, owner, mintFee), "Could not transfer mint fee!");
        }
        
        IERC721(trustedNftAddress).mint(msg.sender);
    }
    
    function list(uint tokenId, uint price, PriceType priceType) public {
        IERC721(trustedNftAddress).transferFrom(msg.sender, address(this), tokenId);
        
        nftsForSaleIds.add(tokenId);
        nftsForSaleByAddress[msg.sender].add(tokenId);
        nftOwners[tokenId] = msg.sender;
        nftsForSalePrices[tokenId] = price;
        priceTypes[tokenId] = priceType;
        
        emit List(tokenId, price, priceType);
    }
    
    function unlist(uint tokenId) public {
        require(nftsForSaleIds.contains(tokenId), "Trying to unlist an NFT which is not listed yet!");
        address nftOwner = nftOwners[tokenId];
        require(nftOwner == msg.sender, "Cannot unlist other's NFT!");
        
        nftsForSaleIds.remove(tokenId);
        nftsForSaleByAddress[msg.sender].remove(tokenId);
        delete nftOwners[tokenId];
        delete nftsForSalePrices[tokenId];
        delete priceTypes[tokenId];
        
        IERC721(trustedNftAddress).transferFrom(address(this), msg.sender, tokenId);
        emit Unlist(tokenId);
    }

    function buy(uint tokenId) public payable {
        require(nftsForSaleIds.contains(tokenId), "Trying to unlist an NFT which is not listed yet!");
        address payable nftOwner = address(uint160(nftOwners[tokenId]));
        address payable _owner = address(uint160(owner));
        
        uint price = nftsForSalePrices[tokenId];
        uint fee = price.mul(sellingFeeRateX100).div(1e4);
        uint amountAfterFee = price.sub(fee);
        PriceType _priceType = priceTypes[tokenId];
    
        nftsForSaleIds.remove(tokenId);
        nftsForSaleByAddress[nftOwners[tokenId]].remove(tokenId);
        delete nftOwners[tokenId];
        delete nftsForSalePrices[tokenId];
        delete priceTypes[tokenId];
        
        if (_priceType == PriceType.ETHER) {
            require(msg.value >= price, "Insufficient ETH is transferred to purchase!");
            _owner.transfer(fee);
            nftOwner.transfer(amountAfterFee);
            // in case extra ETH is transferred, forward the extra to owner
            if (msg.value > price) {
                _owner.transfer(msg.value.sub(price));                
            }
        } else if (_priceType == PriceType.TOKEN) {
            require(IERC20(trustedFeeTokenAddress).transferFrom(msg.sender, address(this), price), "Could not transfer fee to Marketplace!");
            require(IERC20(trustedFeeTokenAddress).transfer(_owner, fee), "Could not transfer purchase fee to admin!");
            require(IERC20(trustedFeeTokenAddress).transfer(nftOwner, amountAfterFee), "Could not transfer sale revenue to NFT seller!");
        } else {
            revert("Invalid Price Type!");
        }
        IERC721(trustedNftAddress).transferFrom(address(this), msg.sender, tokenId);
        emit Buy(tokenId);
    }
    
    event ERC721Received(address operator, address from, uint256 tokenId, bytes data);
    
    // ERC721 Interface Support Function
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns(bytes4) {
        require(msg.sender == trustedNftAddress);
        emit ERC721Received(operator, from, tokenId, data);
        return this.onERC721Received.selector;
    }
    
}