/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}



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

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}



contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    mapping(bytes4 => bool) private _supportedInterfaces;
    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}











contract DeFiLABS is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    mapping (address => EnumerableSet.UintSet) private _holderTokens;
    EnumerableMap.UintToAddressMap private _tokenOwners;
    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    string private _name;
    string private _symbol;
    mapping (uint256 => string) private _tokenURIs;
    string private _baseURI;
    struct nft_properties {
        string name;
        string thumbnail;
        string model_url;
        uint256 coef_1;
        uint256 coef_2;
        uint256 coef_3;
        int256 latitude;
        int256 longitude;
    }
    mapping (uint256 => nft_properties) public arAsset;
    address public deployer;

    uint256 public spawnlimit;
    mapping (uint256 => uint256) public spawnCount;
    uint256 public mintTicket;
    address public geoplacer;
    nft_properties spawnerData;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        deployer = msg.sender;
        geoplacer = deployer;
        spawnlimit = 0;
        mintTicket = 0;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function arAsset_name(uint256 tokenId) external view returns(string memory) {
        return arAsset[tokenId].name;
    }
    
    function arAsset_thumbnail(uint256 tokenId) external view returns(string memory) {
        return arAsset[tokenId].thumbnail;
    }

    function arAsset_contents(uint256 tokenId) external view returns(string memory) {
        return arAsset[tokenId].model_url;
    }

    function arAsset_coef1(uint256 tokenId) external view returns(uint256) {
        return arAsset[tokenId].coef_1;
    }

    function arAsset_coef2(uint256 tokenId) external view returns(uint256) {
        return arAsset[tokenId].coef_2;
    }

    function arAsset_coef3(uint256 tokenId) external view returns(uint256) {
        return arAsset[tokenId].coef_3;
    }

    function arAsset_latitude(uint256 tokenId) external view returns(int256) {
        return arAsset[tokenId].latitude;
    }

    function arAsset_longitude(uint256 tokenId) external view returns(int256) {
        return arAsset[tokenId].longitude;
    }

    function arAsset_coords(uint256 tokenId) external view returns(int256[2] memory coords) {
        return [arAsset[tokenId].latitude, arAsset[tokenId].longitude];
    }
    

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function setSpawnLimit(uint256 limit) external returns(bool) {
        require(msg.sender == deployer);
        spawnlimit = limit;
        return true;
    }

    function setSpawnerData(string calldata nft_name, string calldata image, string calldata url, uint256 coef1, uint256 coef2, uint256 coef3, int256 lat, int256 long) external returns(bool) {
        require (msg.sender == deployer);
        spawnerData = nft_properties(nft_name, image, url, coef1, coef2, coef3, lat, long);
        return true;
    }
    

    function setGeoPlacer(address _geoplacer) external returns(bool) {
        require(msg.sender == deployer);
        geoplacer = _geoplacer;
        return true;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory _tokenURI = _tokenURIs[tokenId];
        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    function baseURI() public view returns (string memory) {
        return string(abi.encodePacked(_baseURI, "defilabs_nfts.json"));
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view override returns (uint256) {
        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {
        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );
        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
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

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        if (_exists(tokenId) == true) {
                mintTicket++;
            } else {
                _beforeTokenTransfer(address(0), to, tokenId);
                _holderTokens[to].add(tokenId);
                _tokenOwners.set(tokenId, to);
                emit Transfer(address(0), to, tokenId);
            }
    }

    function mint(address to, string calldata nft_name, string calldata image, string calldata url, uint256 coef1, uint256 coef2, uint256 coef3, int256 lat, int256 long) external returns(bool) {
        require (to != address(0));
        require (msg.sender == deployer);
        require ((lat < 90000000 && lat > -90000000) && (long < 180000000 && long > -180000000));
        _mint(to, mintTicket);
        nft_properties memory nft;
        nft = nft_properties(nft_name, image, url, coef1, coef2, coef3, lat, long);
        arAsset[mintTicket] = nft;
        mintTicket++;
        return true;
    }

    function bulkmint(address[] calldata to, uint256[] calldata coef1, int256[] calldata lat, int256[] calldata long) external returns(bool) {
        require (msg.sender == deployer);
        uint listsize = to.length;
        nft_properties memory nft;
        for (uint i = 0; i < listsize; i++) {
            _mint(to[i], mintTicket);
            nft = nft_properties(spawnerData.name, spawnerData.thumbnail, spawnerData.model_url, coef1[i], spawnerData.coef_2, spawnerData.coef_3, lat[i], long[i]);
            arAsset[mintTicket] = nft;
            mintTicket++;
        }
        return true;
    }
    
    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        _approve(address(0), tokenId);
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
        _holderTokens[owner].remove(tokenId);
        _tokenOwners.remove(tokenId);
        emit Transfer(owner, address(0), tokenId);
    }

    function burn(uint256 tokenId) external returns(bool) {
        require (msg.sender == deployer);
        _burn(tokenId);
        nft_properties memory nft;
        nft = nft_properties("", "", "", 0, 0, 0, 0, 0);
        arAsset[tokenId] = nft;
        return true;
    }

    function spawn(uint256 _SpawnerTokenId, int256 _latitude, int256 _longitude) external returns(bool) {
        require(msg.sender == ownerOf(_SpawnerTokenId));
        require(spawnCount[_SpawnerTokenId] < spawnlimit);
        require ((_latitude < 90000000 && _latitude > -90000000) && (_longitude < 180000000 && _longitude > -180000000));
        _mint(geoplacer, mintTicket);
        spawnCount[mintTicket] = spawnlimit;
        spawnCount[_SpawnerTokenId]++;
        nft_properties memory nft;
        nft = nft_properties(spawnerData.name, spawnerData.thumbnail, spawnerData.model_url, spawnerData.coef_1, spawnerData.coef_2, spawnerData.coef_3, _latitude, _longitude);
        arAsset[mintTicket] = nft;
        mintTicket++;
        return true;
    }    
    
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);
        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);
        _tokenOwners.set(tokenId, to);
        emit Transfer(from, to, tokenId);
    }

    function setTokenURI(uint256 tokenId, string calldata _tokenURI) external {
        require (msg.sender == deployer);
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function setBaseURI(string calldata baseURI_) external {
        require (msg.sender == deployer);
        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
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
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}