/**
 *Submitted for verification at Etherscan.io on 2021-08-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 









interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) external view returns (uint256);
}

interface IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;
    string private _name;
    string private _symbol;
    mapping (uint256 => address) private _owners;
    mapping (address => uint256) private _balances;
    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}

abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    uint256[] private _allTokens;
    mapping(uint256 => uint256) private _allTokensIndex;

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
      
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract Elementa is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;

    address proxyRegistryAddress;
    mapping (uint256 => string) private _tokenURIs;
    string private BASE_URI = "ipfs://";
    uint256 public MAX_TOKENS = 10000;
    uint256 public TOKEN_PRICE = 50000000000000000;
    uint256 public REROLL_PRICE = 25000000000000000;
    uint256 public PRESALE_TOKEN_PRICE = 30000000000000000;
    uint public MAX_TOKENS_PER_ORDER = 10;
    uint public MAX_TOKENS_PER_WALLET = 50;
    uint256 public MAX_GAS_PRICE = 100000000000;
    bool public ON_SALE = false;                        
    bool public REROLL = false;  
    bool public ON_PRESALE = false;
    uint256 public MAX_TOKENS_IN_PRESALE = 1;
    bool public ON_PUBLIC_PRESALE = false;
    mapping(address => bool) public presaleWhitelist;    
    
    event Reroll(address indexed roller, uint256 indexed tokenId);                  

    constructor(address _proxyRegistryAddress) ERC721("Elementa", "ELEM") {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function changeTokenURI(uint256 tokenId, string memory _tokenURI) external onlyOwner {
        _setTokenURI(tokenId, _tokenURI);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
            require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
            _tokenURIs[tokenId] = _tokenURI;
    }

    function withdrawBalance() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function reserveTokens(uint256 quantity) external onlyOwner {
        for(uint i = 0; i < quantity; i++) {
            uint mintIndex = totalSupply();
            if (mintIndex < MAX_TOKENS) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }

    function airdropTokens(uint256 quantity, address userAddress) external onlyOwner {
        for(uint i = 0; i < quantity; i++) {
            uint mintIndex = totalSupply();
            if (mintIndex < MAX_TOKENS) {
                _safeMint(userAddress, mintIndex);
            }
        }
    }

    function mintToken(uint numberOfTokens) external payable  {
        require(totalSupply().add(numberOfTokens) <= MAX_TOKENS, "Sorry, we don't have enough tokens to fulfil your order.");
        require(ON_SALE, "These tokens are not on sale yet, nice try.");
        require(numberOfTokens <= MAX_TOKENS_PER_ORDER, "Tried to buy too many in one go.");
        require(numberOfTokens > 0, "You cannot mint 0 items.");
        require(balanceOf(msg.sender).add(numberOfTokens) <= MAX_TOKENS_PER_WALLET, "Tried to mint more than allowed per wallet");
        require(tx.gasprice <= MAX_GAS_PRICE, "Whoops, you tried to cause a gas war, no thanks!");
        require(TOKEN_PRICE.mul(numberOfTokens) <= msg.value, 'Not enough Ethereum sent to buy that many');
        for(uint i = 0; i < numberOfTokens; i++) {
            uint mintIndex = totalSupply();
            if (totalSupply() < MAX_TOKENS) {
                _safeMint(msg.sender, mintIndex);
            }
        }
    }

    function mintPresaleTokenPrivate(uint numberOfTokens) external payable  {
        require(ON_PRESALE, "These tokens are not on presale yet, nice try.");
        require(presaleWhitelist[msg.sender], "Not in whitelist");
        require(numberOfTokens <= MAX_TOKENS_IN_PRESALE, "Tried to buy too many in one go.");
        require(balanceOf(msg.sender).add(numberOfTokens) <= MAX_TOKENS_IN_PRESALE, "No more allowed in presale");
        require(PRESALE_TOKEN_PRICE <= msg.value, 'Not enough Ethereum sent to buy that many');
        uint mintIndex = totalSupply();
        _safeMint(msg.sender, mintIndex);
    }

    function mintPresaleTokenPublic(uint numberOfTokens) external payable  {
        require(ON_PUBLIC_PRESALE, "These tokens are not on presale yet, nice try.");
        require(numberOfTokens <= MAX_TOKENS_IN_PRESALE, "Tried to buy too many in one go.");
        require(balanceOf(msg.sender).add(numberOfTokens) <= MAX_TOKENS_IN_PRESALE, "No more allowed in presale");
        require(PRESALE_TOKEN_PRICE <= msg.value, 'Not enough Ethereum sent to buy that many');
        uint mintIndex = totalSupply();
        _safeMint(msg.sender, mintIndex);
    }

    function rerollToken(uint256 tokenId) external payable  {
        require(REROLL, "Rerolling is not available");
        require(ownerOf(tokenId) == msg.sender, "You do not own this token");
        require(msg.value >= REROLL_PRICE, 'Not enough Ethereum to reroll');
        //_burn(tokenId);
        //uint mintIndex = totalSupply();
        //_safeMint(msg.sender, mintIndex);
        emit Reroll(msg.sender, tokenId);
    }

    function createWhitelist(address[] calldata whitelist) external onlyOwner {
        for(uint i = 0; i < whitelist.length; i++) {
            presaleWhitelist[whitelist[i]] = true;
        }
    }
    function removeFromWhitelist(address walletAddress) external onlyOwner {
        delete presaleWhitelist[walletAddress];
    }

    function startPublicPreSale() external onlyOwner {
        ON_PUBLIC_PRESALE = true;
    }
    function stopPublicPreSale() external onlyOwner {
        ON_PUBLIC_PRESALE = false;
    }
    function startPreSale() external onlyOwner {
        ON_PRESALE = true;
    }
    function stopPreSale() external onlyOwner {
        ON_PRESALE = false;
    }
    function startSale() external onlyOwner {
        ON_SALE = true;
    }
    function stopSale() external onlyOwner {
        ON_SALE = false;
    }
    function enableReroll() external onlyOwner {
        REROLL = true;
    }
    function disableReroll() external onlyOwner {
        REROLL = false;
    }
    function setPresaleLimit(uint256 quantity) external onlyOwner {
        MAX_TOKENS_IN_PRESALE = quantity;
    }
    function setMaxTokensPerOrder(uint256 quantity) external onlyOwner {
        MAX_TOKENS_PER_ORDER = quantity;
    }
    function setMaxTokensPerWallet(uint256 quantity) external onlyOwner {
        MAX_TOKENS_PER_WALLET = quantity;
    }
    function setPresaleTokenPrice(uint256 price) external onlyOwner {
        PRESALE_TOKEN_PRICE = price;
    }
    function setTokenPrice(uint256 price) external onlyOwner {
        TOKEN_PRICE = price;
    }
    function setRerollPrice(uint256 price) external onlyOwner {
        REROLL_PRICE = price;
    }
    function setMaxTokens(uint256 quantity) external onlyOwner {
        MAX_TOKENS = quantity;
    }
    function setMaxGasPrice(uint256 price) external onlyOwner {
        MAX_GAS_PRICE = price;
    }
    
    function setBaseURI(string memory baseURI) external onlyOwner() {
        BASE_URI = baseURI;
    }
    
    function _baseURI() internal view override returns (string memory) {
        return BASE_URI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
            require(_exists(tokenId), "Token does not exist");

            string memory _tokenURI = _tokenURIs[tokenId];
            string memory base = _baseURI();
            
            if (bytes(base).length == 0) {
                return _tokenURI;
            }
            if (bytes(_tokenURI).length > 0) {
                return string(abi.encodePacked(base, _tokenURI));
            }
            return string(abi.encodePacked(base, tokenId.toString()));
    }
    
    function isApprovedForAll(address owner, address operator)
        override
        public
        view
        returns (bool)
    {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }
}