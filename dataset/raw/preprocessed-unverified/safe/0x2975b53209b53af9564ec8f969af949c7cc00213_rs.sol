/**
 *Submitted for verification at Etherscan.io on 2021-05-06
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.7.0;






// File: contracts/Utils/EnumerableSet.sol



// File: contracts/Utils/Strings.sol

/**
 * @dev String operations.
 */


// File: contracts/Utils/Address.sol




// File: contracts/HashGuise.sol
contract HashGuise {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    mapping(bytes4 => bool) private _supportedInterfaces;

    uint256 public constant SALE_START_TIMESTAMP = 1611846000;

    uint256 public constant MAX_NFT_SUPPLY = 100;
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from holder address to their (enumerable) set of owned tokens
    mapping (address => EnumerableSet.UintSet) private _holderTokens;
    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;
    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;
    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    // Keeps track of how much each index was minted for
    mapping (uint8 => uint256) public mintedPrice;

    // Token symbol
    string private _symbol;
    string private _name;

    uint256 public mintedCounter;
    uint256 public colorCounter;

    uint8 [] public availableNFTs;
    address public _owner;

    bool public readyForSale;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    constructor () {
        _name = "HashGuise";
        _symbol = "HSGS";
        _owner = msg.sender;

        bytes4 _INTERFACE_ID_ERC165 = 0x01ffc9a7;
        bytes4 _INTERFACE_ID_ERC721 = 0x80ac58cd;
        bytes4 _INTERFACE_ID_ERC721_METADATA = 0x93254542;
        bytes4 _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

        _supportedInterfaces[_INTERFACE_ID_ERC165] = true;
        _supportedInterfaces[_INTERFACE_ID_ERC721] = true;
        _supportedInterfaces[_INTERFACE_ID_ERC721_METADATA] = true;
        _supportedInterfaces[_INTERFACE_ID_ERC721_ENUMERABLE] = true;

        // 0 ... 99 tokenIDs available to purchase
        // 100 ... 199 tokenIDs for color that mirror their bw 0 ... 99 IDs
        for(uint8 _index; _index < 100; _index++)
          availableNFTs.push(_index);
    }

    function supportsInterface(bytes4 interfaceId) public view  returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function balanceOf(address owner) public view  returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view  returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view  returns (string memory) {
        return _name;
    }

    function symbol() public view  returns (string memory) {
        return _symbol;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view  returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view  returns (uint256) {
        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view  returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function distributionCurve(bool _forColor) public view returns (uint256) {
        uint256 _counter = _forColor == true ? colorCounter : mintedCounter;
        uint256 weiAmount = 0;

        if(_forColor == true){
          weiAmount = 50e16;
        } else if(_counter < 2){
          weiAmount = 10e16;
        } else if(_counter < 5){
          weiAmount = 23e16;
        } else if(_counter < 10){
          weiAmount = 45e16;
        } else if(_counter < 15){
          weiAmount = 68e16;
        } else if(_counter < 20){
          weiAmount = 90e16;
        } else if(_counter < 25){
          weiAmount = 113e16;
        } else if(_counter < 30){
          weiAmount = 135e16;
        } else if(_counter < 35){
          weiAmount = 158e16;
        } else if(_counter < 40){
          weiAmount = 180e16;
        } else if(_counter < 45){
          weiAmount = 203e16;
        } else if(_counter < 50){
          weiAmount = 225e16;
        } else if(_counter < 55){
          weiAmount = 248e16;
        } else if(_counter < 60){
          weiAmount = 270e16;
        } else if(_counter < 65){
          weiAmount = 293e16;
        } else if(_counter < 70){
          weiAmount = 317e16;
        } else if(_counter < 75){
          weiAmount = 342e16;
        } else if(_counter < 80){
          weiAmount = 373e16;
        } else if(_counter < 85){
          weiAmount = 416e16;
        } else if(_counter < 90){
          weiAmount = 497e16;
        } else if(_counter < 95){
          weiAmount = 675e16;
        } else if(_counter < 100){
          weiAmount = 1118e16;
        }

        return weiAmount;
    }

    function changeToColor(uint256[] calldata index) external payable {
        require(readyForSale == true, "HashGuise::changeToColor: not ready for sale");
        require(index.length > 0);
        uint256 returnAmount = msg.value;

        for(uint _index = 0; _index < index.length; _index++){
          uint256 requiredWei = distributionCurve(true);
          if(returnAmount < requiredWei)
            break;

          require(returnAmount >= requiredWei, "HashGuise::changeToColor: not enough ETH");
          require(index[_index] < 100, "HashGuise::changeToColor: already color");
          require(ownerOf(index[_index]) == msg.sender, "HashGuise::changeToColor: not the owner");

          uint256 colorIndex = index[_index].add(100);

          returnAmount = returnAmount.sub(requiredWei);

          _burn(index[_index]);
          _safeMint(msg.sender, colorIndex);

          colorCounter++;
        }

        // refund any excess eth
        if(returnAmount > 0){
          (bool success, ) = address(msg.sender).call{ value: returnAmount }("");
          require(success, "Address: unable to send value, recipient may have reverted");
        }
    }

    function mintNFT() public payable {
        uint256 mintPrice = distributionCurve(false);

        require(readyForSale == true, "HashGuise::changeToColor: not ready for sale");
        require(mintPrice != 0, "HashGuise::mintNFT: Sale has already ended");
        require(mintPrice <= msg.value, "HashGuise::mintNFT: Ether value sent is not correct");

        uint256 returnAmount = msg.value;
        while (returnAmount >= mintPrice && mintPrice != 0){
            returnAmount = returnAmount.sub(mintPrice);
            uint256 randomMintIndex = uint(blockhash(block.number - 1)) % (availableNFTs.length);

            if(availableNFTs.length == 1)
              randomMintIndex = 0;

            mintedPrice[uint8(randomMintIndex)] = mintPrice;

            _safeMint(msg.sender, availableNFTs[randomMintIndex]);

            // reorder array, creates more randomness
            if(randomMintIndex != availableNFTs.length.sub(1)){
              availableNFTs[randomMintIndex] = availableNFTs[availableNFTs.length.sub(1)];
            }

            delete availableNFTs[availableNFTs.length.sub(1)];
            availableNFTs.pop();

            mintedCounter++;

            mintPrice = distributionCurve(false);
        }

        // refund any excess eth
        if(returnAmount > 0){
          (bool success, ) = address(msg.sender).call{ value: returnAmount }("");
          require(success, "Address: unable to send value, recipient may have reverted");
        }
    }

    function withdraw() public {
        require(msg.sender == _owner, "Not the owner");
        uint balance = address(this).balance;
        msg.sender.transfer(balance);
    }

    function setReadyForSale(bool _readyForSale) public {
        require(msg.sender == _owner, "Not the owner");
        readyForSale = _readyForSale;
    }

    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public   {
        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view  returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public   {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public   {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public   {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal  {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal  {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, ""), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal  {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal  {
        address owner = ownerOf(tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal  {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            msg.sender,
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }
}



