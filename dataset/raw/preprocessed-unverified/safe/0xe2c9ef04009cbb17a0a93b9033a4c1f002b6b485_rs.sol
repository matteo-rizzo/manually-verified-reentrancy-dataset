/**
 *Submitted for verification at Etherscan.io on 2019-09-21
*/

pragma solidity 0.5.6;




/**
 * @dev ERC-721 non-fungible token standard. 
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
 */


/**
 * @dev ERC-721 interface for accepting safe transfers. 
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
 */


/**
 * @dev Math operations with safety checks that throw on error. This contract is based on the 
 * source code at: 
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol.
 */



/**
 * @dev A standard for detecting smart contract interfaces. 
 * See: https://eips.ethereum.org/EIPS/eip-165.
 */


/**
 * @dev Implementation of standard for detect smart contract interfaces.
 */
contract SupportsInterface is
  ERC165
{

  /**
   * @dev Mapping of supported intefraces.
   * @notice You must not set element 0xffffffff to true.
   */
  mapping(bytes4 => bool) internal supportedInterfaces;

  /**
   * @dev Contract constructor.
   */
  constructor()
    public 
  {
    supportedInterfaces[0x01ffc9a7] = true; // ERC165
  }

  /**
   * @dev Function to check which interfaces are suported by this contract.
   * @param _interfaceID Id of the interface.
   * @return True if _interfaceID is supported, false otherwise.
   */
  function supportsInterface(
    bytes4 _interfaceID
  )
    external
    view
    returns (bool)
  {
    return supportedInterfaces[_interfaceID];
  }

}

/**
 * @dev Utility library of inline functions on addresses.
 */


/**
 * @dev Implementation of ERC-721 non-fungible token standard.
 */
contract NFToken is
  ERC721,
  SupportsInterface
{
  using SafeMath for uint256;
  using AddressUtils for address;

  /**
   * @dev Magic value of a smart contract that can recieve NFT.
   * Equal to: bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")).
   */
  bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

  /**
   * @dev A mapping from NFT ID to the address that owns it.
   */
  mapping (uint256 => address) internal idToOwner;

  /**
   * @dev Mapping from NFT ID to approved address.
   */
  mapping (uint256 => address) internal idToApproval;

   /**
   * @dev Mapping from owner address to count of his tokens.
   */
  mapping (address => uint256) private ownerToNFTokenCount;

  /**
   * @dev Mapping from owner address to mapping of operator addresses.
   */
  mapping (address => mapping (address => bool)) internal ownerToOperators;

  /**
   * @dev Emits when ownership of any NFT changes by any mechanism. This event emits when NFTs are
   * created (`from` == 0) and destroyed (`to` == 0). Exception: during contract creation, any
   * number of NFTs may be created and assigned without emitting Transfer. At the time of any
   * transfer, the approved address for that NFT (if any) is reset to none.
   * @param _from Sender of NFT (if address is zero address it indicates token creation).
   * @param _to Receiver of NFT (if address is zero address it indicates token destruction).
   * @param _tokenId The NFT that got transfered.
   */
  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );

  /**
   * @dev This emits when the approved address for an NFT is changed or reaffirmed. The zero
   * address indicates there is no approved address. When a Transfer event emits, this also
   * indicates that the approved address for that NFT (if any) is reset to none.
   * @param _owner Owner of NFT.
   * @param _approved Address that we are approving.
   * @param _tokenId NFT which we are approving.
   */
  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );

  /**
   * @dev This emits when an operator is enabled or disabled for an owner. The operator can manage
   * all NFTs of the owner.
   * @param _owner Owner of NFT.
   * @param _operator Address to which we are setting operator rights.
   * @param _approved Status of operator rights(true if operator rights are given and false if
   * revoked).
   */
  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  /**
   * @dev Guarantees that the msg.sender is an owner or operator of the given NFT.
   * @param _tokenId ID of the NFT to validate.
   */
  modifier canOperate(
    uint256 _tokenId
  ) 
  {
    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender]);
    _;
  }

  /**
   * @dev Guarantees that the msg.sender is allowed to transfer NFT.
   * @param _tokenId ID of the NFT to transfer.
   */
  modifier canTransfer(
    uint256 _tokenId
  ) 
  {
    address tokenOwner = idToOwner[_tokenId];
    require(
      tokenOwner == msg.sender
      || idToApproval[_tokenId] == msg.sender
      || ownerToOperators[tokenOwner][msg.sender]
    );
    _;
  }

  /**
   * @dev Guarantees that _tokenId is a valid Token.
   * @param _tokenId ID of the NFT to validate.
   */
  modifier validNFToken(
    uint256 _tokenId
  )
  {
    require(idToOwner[_tokenId] != address(0));
    _;
  }

  /**
   * @dev Contract constructor.
   */
  constructor()
    public
  {
    supportedInterfaces[0x80ac58cd] = true; // ERC721
  }

  /**
   * @dev Transfers the ownership of an NFT from one address to another address. This function can
   * be changed to payable.
   * @notice Throws unless `msg.sender` is the current owner, an authorized operator, or the
   * approved address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is
   * the zero address. Throws if `_tokenId` is not a valid NFT. When transfer is complete, this
   * function checks if `_to` is a smart contract (code size > 0). If so, it calls 
   * `onERC721Received` on `_to` and throws if the return value is not 
   * `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`.
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   * @param _data Additional data with no specified format, sent in call to `_to`.
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
  {
    _safeTransferFrom(_from, _to, _tokenId, _data);
  }

  /**
   * @dev Transfers the ownership of an NFT from one address to another address. This function can
   * be changed to payable.
   * @notice This works identically to the other function with an extra data parameter, except this
   * function just sets data to ""
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
  {
    _safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
   * @dev Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
   * address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is the zero
   * address. Throws if `_tokenId` is not a valid NFT. This function can be changed to payable.
   * @notice The caller is responsible to confirm that `_to` is capable of receiving NFTs or else
   * they maybe be permanently lost.
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    canTransfer(_tokenId)
    validNFToken(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == _from);
    require(_to != address(0));

    _transfer(_to, _tokenId);
  }

  /**
   * @dev Set or reaffirm the approved address for an NFT. This function can be changed to payable.
   * @notice The zero address indicates there is no approved address. Throws unless `msg.sender` is
   * the current NFT owner, or an authorized operator of the current owner.
   * @param _approved Address to be approved for the given NFT ID.
   * @param _tokenId ID of the token to be approved.
   */
  function approve(
    address _approved,
    uint256 _tokenId
  )
    external
    canOperate(_tokenId)
    validNFToken(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    require(_approved != tokenOwner);

    idToApproval[_tokenId] = _approved;
    emit Approval(tokenOwner, _approved, _tokenId);
  }

  /**
   * @dev Enables or disables approval for a third party ("operator") to manage all of
   * `msg.sender`'s assets. It also emits the ApprovalForAll event.
   * @notice This works even if sender doesn't own any tokens at the time.
   * @param _operator Address to add to the set of authorized operators.
   * @param _approved True if the operators is approved, false to revoke approval.
   */
  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external
  {
    ownerToOperators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  /**
   * @dev Returns the number of NFTs owned by `_owner`. NFTs assigned to the zero address are
   * considered invalid, and this function throws for queries about the zero address.
   * @param _owner Address for whom to query the balance.
   * @return Balance of _owner.
   */
  function balanceOf(
    address _owner
  )
    external
    view
    returns (uint256)
  {
    require(_owner != address(0));
    return _getOwnerNFTCount(_owner);
  }

  /**
   * @dev Returns the address of the owner of the NFT. NFTs assigned to zero address are considered
   * invalid, and queries about them do throw.
   * @param _tokenId The identifier for an NFT.
   * @return Address of _tokenId owner.
   */
  function ownerOf(uint256 _tokenId)
  public
  view
  returns (address) {
    address _owner = idToOwner[_tokenId];
    require(_owner != address(0));
    return _owner;
  }

  function isOwner(uint256 _tokenId, address _addr)
  public
  view
  returns (bool) {
    return idToOwner[_tokenId] == _addr && _addr != address(0);
  }

  /**
   * @dev Get the approved address for a single NFT.
   * @notice Throws if `_tokenId` is not a valid NFT.
   * @param _tokenId ID of the NFT to query the approval of.
   * @return Address that _tokenId is approved for.
   */
  function getApproved(uint256 _tokenId)
  public
  view
  validNFToken(_tokenId)
  returns (address)
  {
    return idToApproval[_tokenId];
  }

  /**
   * @dev Checks if `_operator` is an approved operator for `_owner`.
   * @param _owner The address that owns the NFTs.
   * @param _operator The address that acts on behalf of the owner.
   * @return True if approved for all, false otherwise.
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    public
    view
    returns (bool)
  {
    return ownerToOperators[_owner][_operator];
  }

  /**
   * @dev Actually preforms the transfer.
   * @notice Does NO checks.
   * @param _to Address of a new owner.
   * @param _tokenId The NFT that is being transferred.
   */
  function _transfer(
    address _to,
    uint256 _tokenId
  )
    internal
  {
    address from = idToOwner[_tokenId];
    _clearApproval(_tokenId);

    _removeNFToken(from, _tokenId);
    _addNFToken(_to, _tokenId);

    emit Transfer(from, _to, _tokenId);
  }
   
  /**
   * @dev Mints a new NFT.
   * @notice This is an internal function which should be called from user-implemented external
   * mint function. Its purpose is to show and properly initialize data structures when using this
   * implementation.
   * @param _to The address that will own the minted NFT.
   * @param _tokenId of the NFT to be minted by the msg.sender.
   */
  function _mint(
    address _to,
    uint256 _tokenId
  )
    internal
  {
    require(_to != address(0));
    require(idToOwner[_tokenId] == address(0));

    _addNFToken(_to, _tokenId);

    emit Transfer(address(0), _to, _tokenId);
  }

  /**
   * @dev Burns a NFT.
   * @notice This is an internal function which should be called from user-implemented external burn
   * function. Its purpose is to show and properly initialize data structures when using this
   * implementation. Also, note that this burn implementation allows the minter to re-mint a burned
   * NFT.
   * @param _tokenId ID of the NFT to be burned.
   */
  function _burn(
    uint256 _tokenId
  )
    internal
    validNFToken(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    _clearApproval(_tokenId);
    _removeNFToken(tokenOwner, _tokenId);
    emit Transfer(tokenOwner, address(0), _tokenId);
  }

  /**
   * @dev Removes a NFT from owner.
   * @notice Use and override this function with caution. Wrong usage can have serious consequences.
   * @param _from Address from wich we want to remove the NFT.
   * @param _tokenId Which NFT we want to remove.
   */
  function _removeNFToken(
    address _from,
    uint256 _tokenId
  )
    internal
  {
    require(idToOwner[_tokenId] == _from);
    ownerToNFTokenCount[_from] = ownerToNFTokenCount[_from] - 1;
    delete idToOwner[_tokenId];
  }

  /**
   * @dev Assignes a new NFT to owner.
   * @notice Use and override this function with caution. Wrong usage can have serious consequences.
   * @param _to Address to wich we want to add the NFT.
   * @param _tokenId Which NFT we want to add.
   */
  function _addNFToken(
    address _to,
    uint256 _tokenId
  )
    internal
  {
    require(idToOwner[_tokenId] == address(0));

    idToOwner[_tokenId] = _to;
    ownerToNFTokenCount[_to] = ownerToNFTokenCount[_to].add(1);
  }

  /**
   *Â @dev Helper function that gets NFT count of owner. This is needed for overriding in enumerable
   * extension to remove double storage (gas optimization) of owner nft count.
   * @param _owner Address for whom to query the count.
   * @return Number of _owner NFTs.
   */
  function _getOwnerNFTCount(
    address _owner
  )
    internal
    view
    returns (uint256)
  {
    return ownerToNFTokenCount[_owner];
  }

  /**
   * @dev Actually perform the safeTransferFrom.
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   * @param _data Additional data with no specified format, sent in call to `_to`.
   */
  function _safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
    private
    canTransfer(_tokenId)
    validNFToken(_tokenId)
  {
    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == _from);
    require(_to != address(0));

    _transfer(_to, _tokenId);

    if (_to.isContract()) 
    {
      bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
      require(retval == MAGIC_ON_ERC721_RECEIVED);
    }
  }

  /** 
   * @dev Clears the current approval of a given NFT ID.
   * @param _tokenId ID of the NFT to be transferred.
   */
  function _clearApproval(
    uint256 _tokenId
  )
    private
  {
    if (idToApproval[_tokenId] != address(0))
    {
      delete idToApproval[_tokenId];
    }
  }

}

/**
 * @dev Optional metadata extension for ERC-721 non-fungible token standard.
 * See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md.
 */


/**
 * @dev Optional metadata implementation for ERC-721 non-fungible token standard.
 */
contract NFTokenMetadata is
  NFToken,
  ERC721Metadata
{

  /**
   * @dev A descriptive name for a collection of NFTs.
   */
  string internal nftName;

  /**
   * @dev The IPFS gateway which will serve the metadata
   */
  string internal gateway;

  /**
   * @dev An abbreviated name for NFTokens.
   */
  string internal nftSymbol;

  /**
   * @dev Mapping from NFT ID to metadata uri.
   */
  mapping (uint256 => string) internal _idToUri;

  /**
   * @dev Contract constructor.
   * @notice When implementing this contract don't forget to set nftName and nftSymbol.
   */
  constructor()
    public
  {
    supportedInterfaces[0x5b5e139f] = true; // ERC721Metadata
  }

  function idToUri(uint256 _tokenID)
  public
  view
  returns (string memory){
    return _idToUri[_tokenID];
  }

  /**
   * @dev Returns a descriptive name for a collection of NFTokens.
   * @return Representing name.
   */
  function name()
    external
    view
    returns (string memory _name)
  {
    _name = nftName;
  }

  /**
   * @dev Returns an abbreviated name for NFTokens.
   * @return Representing symbol.
   */
  function symbol()
    external
    view
    returns (string memory _symbol)
  {
    _symbol = nftSymbol;
  }

  /**
   * @dev Set a distinct URI (RFC 3986) for a given NFT ID.
   * @notice This is an internal function which should be called from user-implemented external
   * function. Its purpose is to show and properly initialize data structures when using this
   * implementation.
   * @param _tokenId Id for which we want uri.
   * @param _uri String representing RFC 3986 URI.
   */
  function _setTokenUri(
    uint256 _tokenId,
    string memory _uri
  )
    internal
    validNFToken(_tokenId)
  {
    _idToUri[_tokenId] = _uri;
  }

    /**
  * @dev A distinct URI (RFC 3986) for a given NFT.
  * @param _tokenId Id for which we want uri.
  * @return URI of _tokenId.
  */
  function tokenURI(
    uint256 _tokenId
  )
    external
    view
    validNFToken(_tokenId)
    returns (string memory)
  {
    return strConcat(ipfsGateway(), _idToUri[_tokenId]);
  }

  /**
  * @dev returns the current baseURI. Can either be IPFS gateway or Galaxia gateway
  */
  function ipfsGateway() public view returns (string memory) {
    return gateway;
  }

  /**
  * @dev returns the current baseURI. Can either be IPFS gateway or Galaxia gateway
  */
  function _setBaseURI(string memory _newBase)
  internal {
    gateway = _newBase;
  }

  function strConcat(string memory _a, string memory _b)
  internal
  pure
  returns (string memory) {
    bytes memory aa = bytes(_a);
    bytes memory bb = bytes(_b);
    string memory ab = new string(aa.length + bb.length);
    bytes memory bytes_ab = bytes(ab);
    uint k = 0;
    for (uint i = 0; i < aa.length; i++) bytes_ab[k++] = aa[i];
    for (uint i = 0; i < bb.length; i++) bytes_ab[k++] = bb[i];
    return string(bytes_ab);
  }
}

/**
 * @dev The contract has an owner address, and provides basic authorization control whitch
 * simplifies the implementation of user permissions. This contract is based on the source code at:
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */


contract OwnableDelegateProxy { }

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @dev This is an example contract implementation of NFToken with enumerable extension.
 */
contract Galaxia is
  NFTokenMetadata,
  Ownable
{
  address public proxyRegistryAddress;
  mapping (bytes32 => bool) public validUpgrade;
  uint256 public totalSupply;

  /**
  * @dev Contract constructor.
  * @param _name A descriptive name for a collection of NFTs.
  * @param _symbol An abbreviated name for NFTokens.
  */
  constructor(string memory _name, string memory _symbol, address _proxyRegistryAddress)
  public {
    proxyRegistryAddress = _proxyRegistryAddress;
    nftName = _name;
    nftSymbol = _symbol;
    gateway = "https://cloudflare-ipfs.com/ipfs/";
  }

  /**
   * @dev Mints a new NFT.
   * @param _to The address that will own the minted NFT.
   * @param _uri The IPFS hash of this asset metadata
   */
  function mint(address _to, string calldata _uri)
  external
  onlyOwner {
    super._mint(_to, totalSupply);
    super._setTokenUri(totalSupply, _uri);
    totalSupply++;
  }

    /**
   * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
   */
  function isApprovedForAll(address _owner, address _operator)
    public
    view
    returns (bool) {
    // Whitelist OpenSea proxy contract for easy trading.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (address(proxyRegistry.proxies(_owner)) == _operator) {
        return true;
    }

    return super.isApprovedForAll(_owner, _operator);
  }

    /**
  * @dev Galaxia owner can add an optional upgrade path for token holder of _tokenId
  * @dev Owner of contract can give alternative metadata versions for users to upgrade to
  * @param _tokenId ID of this token
  * @param _newURI metadata hash for this token
  */
  function addUpgradePath(uint256 _tokenId, string calldata _newURI, uint8 _version) external onlyOwner {
    require(_tokenId < totalSupply);
    bytes32 upgradeHash = keccak256(abi.encodePacked(_tokenId, _newURI));
    validUpgrade[upgradeHash] = true;
    emit UpgradePathAdded(_tokenId, _newURI, _version);
  }

    /**
  * @dev Token holder can upgrade to one of the upgrade paths supplied by the Galaxia owner
  * @param _tokenId The ID of this token
  * @param _newURI The new metadata hash for this token
  */
  function upgradeMetadata(uint256 _tokenId, string calldata _newURI) external  {
    require(super.isOwner(_tokenId, msg.sender));
    bytes32 upgradeHash = keccak256(abi.encodePacked(_tokenId, _newURI));
    require(validUpgrade[upgradeHash]);
    string memory oldURI = idToUri(_tokenId);
    super._setTokenUri(_tokenId, _newURI);
    emit MetadataUpgraded(oldURI, _newURI);
  }

  /**
  * @dev Changes the ipfs gateway
  * @param _gatewayURL is the http url for this ipfs gateway
  */
  function changeGateway(string calldata _gatewayURL) external onlyOwner {
    require(bytes(_gatewayURL).length > 0);
    emit GatewayChanged(gateway, _gatewayURL);
    gateway = _gatewayURL;
  }


  event MetadataUpgraded(string indexed _oldURI, string _newURI);
  event UpgradePathAdded(uint256 indexed _tokenID, string _newURI, uint8 _version);
  event GatewayChanged(string indexed _old, string _new);

}