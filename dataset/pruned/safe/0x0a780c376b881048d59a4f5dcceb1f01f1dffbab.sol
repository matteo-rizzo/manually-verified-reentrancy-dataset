/**

 *Submitted for verification at Etherscan.io on 2018-11-07

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





// File: openzeppelin-solidity/contracts/access/Roles.sol



/**

 * @title Roles

 * @dev Library for managing addresses assigned to a Role.

 */





// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol



contract MinterRole {

  using Roles for Roles.Role;



  event MinterAdded(address indexed account);

  event MinterRemoved(address indexed account);



  Roles.Role private minters;



  constructor() internal {

    _addMinter(msg.sender);

  }



  modifier onlyMinter() {

    require(isMinter(msg.sender));

    _;

  }



  function isMinter(address account) public view returns (bool) {

    return minters.has(account);

  }



  function addMinter(address account) public onlyMinter {

    _addMinter(account);

  }



  function renounceMinter() public {

    _removeMinter(msg.sender);

  }



  function _addMinter(address account) internal {

    minters.add(account);

    emit MinterAdded(account);

  }



  function _removeMinter(address account) internal {

    minters.remove(account);

    emit MinterRemoved(account);

  }

}



// File: openzeppelin-solidity/contracts/introspection/IERC165.sol



/**

 * @title IERC165

 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md

 */





// File: openzeppelin-solidity/contracts/token/ERC721/IERC721.sol



/**

 * @title ERC721 Non-Fungible Token Standard basic interface

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract IERC721 is IERC165 {



  event Transfer(

    address indexed from,

    address indexed to,

    uint256 indexed tokenId

  );

  event Approval(

    address indexed owner,

    address indexed approved,

    uint256 indexed tokenId

  );

  event ApprovalForAll(

    address indexed owner,

    address indexed operator,

    bool approved

  );



  function balanceOf(address owner) public view returns (uint256 balance);

  function ownerOf(uint256 tokenId) public view returns (address owner);



  function approve(address to, uint256 tokenId) public;

  function getApproved(uint256 tokenId)

    public view returns (address operator);



  function setApprovalForAll(address operator, bool _approved) public;

  function isApprovedForAll(address owner, address operator)

    public view returns (bool);



  function transferFrom(address from, address to, uint256 tokenId) public;

  function safeTransferFrom(address from, address to, uint256 tokenId)

    public;



  function safeTransferFrom(

    address from,

    address to,

    uint256 tokenId,

    bytes data

  )

    public;

}



// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol



/**

 * @title ERC721 token receiver interface

 * @dev Interface for any contract that wants to support safeTransfers

 * from ERC721 asset contracts.

 */

contract IERC721Receiver {

  /**

   * @notice Handle the receipt of an NFT

   * @dev The ERC721 smart contract calls this function on the recipient

   * after a `safeTransfer`. This function MUST return the function selector,

   * otherwise the caller will revert the transaction. The selector to be

   * returned can be obtained as `this.onERC721Received.selector`. This

   * function MAY throw to revert and reject the transfer.

   * Note: the ERC721 contract address is always the message sender.

   * @param operator The address which called `safeTransferFrom` function

   * @param from The address which previously owned the token

   * @param tokenId The NFT identifier which is being transferred

   * @param data Additional data with no specified format

   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

   */

  function onERC721Received(

    address operator,

    address from,

    uint256 tokenId,

    bytes data

  )

    public

    returns(bytes4);

}



// File: openzeppelin-solidity/contracts/utils/Address.sol



/**

 * Utility library of inline functions on addresses

 */





// File: openzeppelin-solidity/contracts/introspection/ERC165.sol



/**

 * @title ERC165

 * @author Matt Condon (@shrugs)

 * @dev Implements ERC165 using a lookup table.

 */

contract ERC165 is IERC165 {



  bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;

  /**

   * 0x01ffc9a7 ===

   *   bytes4(keccak256('supportsInterface(bytes4)'))

   */



  /**

   * @dev a mapping of interface id to whether or not it's supported

   */

  mapping(bytes4 => bool) private _supportedInterfaces;



  /**

   * @dev A contract implementing SupportsInterfaceWithLookup

   * implement ERC165 itself

   */

  constructor()

    internal

  {

    _registerInterface(_InterfaceId_ERC165);

  }



  /**

   * @dev implement supportsInterface(bytes4) using a lookup table

   */

  function supportsInterface(bytes4 interfaceId)

    external

    view

    returns (bool)

  {

    return _supportedInterfaces[interfaceId];

  }



  /**

   * @dev internal method for registering an interface

   */

  function _registerInterface(bytes4 interfaceId)

    internal

  {

    require(interfaceId != 0xffffffff);

    _supportedInterfaces[interfaceId] = true;

  }

}



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721.sol



/**

 * @title ERC721 Non-Fungible Token Standard basic implementation

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721 is ERC165, IERC721 {



  using SafeMath for uint256;

  using Address for address;



  // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

  // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`

  bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;



  // Mapping from token ID to owner

  mapping (uint256 => address) private _tokenOwner;



  // Mapping from token ID to approved address

  mapping (uint256 => address) private _tokenApprovals;



  // Mapping from owner to number of owned token

  mapping (address => uint256) private _ownedTokensCount;



  // Mapping from owner to operator approvals

  mapping (address => mapping (address => bool)) private _operatorApprovals;



  bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;

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



  constructor()

    public

  {

    // register the supported interfaces to conform to ERC721 via ERC165

    _registerInterface(_InterfaceId_ERC721);

  }



  /**

   * @dev Gets the balance of the specified address

   * @param owner address to query the balance of

   * @return uint256 representing the amount owned by the passed address

   */

  function balanceOf(address owner) public view returns (uint256) {

    require(owner != address(0));

    return _ownedTokensCount[owner];

  }



  /**

   * @dev Gets the owner of the specified token ID

   * @param tokenId uint256 ID of the token to query the owner of

   * @return owner address currently marked as the owner of the given token ID

   */

  function ownerOf(uint256 tokenId) public view returns (address) {

    address owner = _tokenOwner[tokenId];

    require(owner != address(0));

    return owner;

  }



  /**

   * @dev Approves another address to transfer the given token ID

   * The zero address indicates there is no approved address.

   * There can only be one approved address per token at a given time.

   * Can only be called by the token owner or an approved operator.

   * @param to address to be approved for the given token ID

   * @param tokenId uint256 ID of the token to be approved

   */

  function approve(address to, uint256 tokenId) public {

    address owner = ownerOf(tokenId);

    require(to != owner);

    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));



    _tokenApprovals[tokenId] = to;

    emit Approval(owner, to, tokenId);

  }



  /**

   * @dev Gets the approved address for a token ID, or zero if no address set

   * Reverts if the token ID does not exist.

   * @param tokenId uint256 ID of the token to query the approval of

   * @return address currently approved for the given token ID

   */

  function getApproved(uint256 tokenId) public view returns (address) {

    require(_exists(tokenId));

    return _tokenApprovals[tokenId];

  }



  /**

   * @dev Sets or unsets the approval of a given operator

   * An operator is allowed to transfer all tokens of the sender on their behalf

   * @param to operator address to set the approval

   * @param approved representing the status of the approval to be set

   */

  function setApprovalForAll(address to, bool approved) public {

    require(to != msg.sender);

    _operatorApprovals[msg.sender][to] = approved;

    emit ApprovalForAll(msg.sender, to, approved);

  }



  /**

   * @dev Tells whether an operator is approved by a given owner

   * @param owner owner address which you want to query the approval of

   * @param operator operator address which you want to query the approval of

   * @return bool whether the given operator is approved by the given owner

   */

  function isApprovedForAll(

    address owner,

    address operator

  )

    public

    view

    returns (bool)

  {

    return _operatorApprovals[owner][operator];

  }



  /**

   * @dev Transfers the ownership of a given token ID to another address

   * Usage of this method is discouraged, use `safeTransferFrom` whenever possible

   * Requires the msg sender to be the owner, approved, or operator

   * @param from current owner of the token

   * @param to address to receive the ownership of the given token ID

   * @param tokenId uint256 ID of the token to be transferred

  */

  function transferFrom(

    address from,

    address to,

    uint256 tokenId

  )

    public

  {

    require(_isApprovedOrOwner(msg.sender, tokenId));

    require(to != address(0));



    _clearApproval(from, tokenId);

    _removeTokenFrom(from, tokenId);

    _addTokenTo(to, tokenId);



    emit Transfer(from, to, tokenId);

  }



  /**

   * @dev Safely transfers the ownership of a given token ID to another address

   * If the target address is a contract, it must implement `onERC721Received`,

   * which is called upon a safe transfer, and return the magic value

   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,

   * the transfer is reverted.

   *

   * Requires the msg sender to be the owner, approved, or operator

   * @param from current owner of the token

   * @param to address to receive the ownership of the given token ID

   * @param tokenId uint256 ID of the token to be transferred

  */

  function safeTransferFrom(

    address from,

    address to,

    uint256 tokenId

  )

    public

  {

    // solium-disable-next-line arg-overflow

    safeTransferFrom(from, to, tokenId, "");

  }



  /**

   * @dev Safely transfers the ownership of a given token ID to another address

   * If the target address is a contract, it must implement `onERC721Received`,

   * which is called upon a safe transfer, and return the magic value

   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,

   * the transfer is reverted.

   * Requires the msg sender to be the owner, approved, or operator

   * @param from current owner of the token

   * @param to address to receive the ownership of the given token ID

   * @param tokenId uint256 ID of the token to be transferred

   * @param _data bytes data to send along with a safe transfer check

   */

  function safeTransferFrom(

    address from,

    address to,

    uint256 tokenId,

    bytes _data

  )

    public

  {

    transferFrom(from, to, tokenId);

    // solium-disable-next-line arg-overflow

    require(_checkOnERC721Received(from, to, tokenId, _data));

  }



  /**

   * @dev Returns whether the specified token exists

   * @param tokenId uint256 ID of the token to query the existence of

   * @return whether the token exists

   */

  function _exists(uint256 tokenId) internal view returns (bool) {

    address owner = _tokenOwner[tokenId];

    return owner != address(0);

  }



  /**

   * @dev Returns whether the given spender can transfer a given token ID

   * @param spender address of the spender to query

   * @param tokenId uint256 ID of the token to be transferred

   * @return bool whether the msg.sender is approved for the given token ID,

   *  is an operator of the owner, or is the owner of the token

   */

  function _isApprovedOrOwner(

    address spender,

    uint256 tokenId

  )

    internal

    view

    returns (bool)

  {

    address owner = ownerOf(tokenId);

    // Disable solium check because of

    // https://github.com/duaraghav8/Solium/issues/175

    // solium-disable-next-line operator-whitespace

    return (

      spender == owner ||

      getApproved(tokenId) == spender ||

      isApprovedForAll(owner, spender)

    );

  }



  /**

   * @dev Internal function to mint a new token

   * Reverts if the given token ID already exists

   * @param to The address that will own the minted token

   * @param tokenId uint256 ID of the token to be minted by the msg.sender

   */

  function _mint(address to, uint256 tokenId) internal {

    require(to != address(0));

    _addTokenTo(to, tokenId);

    emit Transfer(address(0), to, tokenId);

  }



  /**

   * @dev Internal function to burn a specific token

   * Reverts if the token does not exist

   * @param tokenId uint256 ID of the token being burned by the msg.sender

   */

  function _burn(address owner, uint256 tokenId) internal {

    _clearApproval(owner, tokenId);

    _removeTokenFrom(owner, tokenId);

    emit Transfer(owner, address(0), tokenId);

  }



  /**

   * @dev Internal function to add a token ID to the list of a given address

   * Note that this function is left internal to make ERC721Enumerable possible, but is not

   * intended to be called by custom derived contracts: in particular, it emits no Transfer event.

   * @param to address representing the new owner of the given token ID

   * @param tokenId uint256 ID of the token to be added to the tokens list of the given address

   */

  function _addTokenTo(address to, uint256 tokenId) internal {

    require(_tokenOwner[tokenId] == address(0));

    _tokenOwner[tokenId] = to;

    _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

  }



  /**

   * @dev Internal function to remove a token ID from the list of a given address

   * Note that this function is left internal to make ERC721Enumerable possible, but is not

   * intended to be called by custom derived contracts: in particular, it emits no Transfer event,

   * and doesn't clear approvals.

   * @param from address representing the previous owner of the given token ID

   * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address

   */

  function _removeTokenFrom(address from, uint256 tokenId) internal {

    require(ownerOf(tokenId) == from);

    _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);

    _tokenOwner[tokenId] = address(0);

  }



  /**

   * @dev Internal function to invoke `onERC721Received` on a target address

   * The call is not executed if the target address is not a contract

   * @param from address representing the previous owner of the given token ID

   * @param to target address that will receive the tokens

   * @param tokenId uint256 ID of the token to be transferred

   * @param _data bytes optional data to send along with the call

   * @return whether the call correctly returned the expected magic value

   */

  function _checkOnERC721Received(

    address from,

    address to,

    uint256 tokenId,

    bytes _data

  )

    internal

    returns (bool)

  {

    if (!to.isContract()) {

      return true;

    }

    bytes4 retval = IERC721Receiver(to).onERC721Received(

      msg.sender, from, tokenId, _data);

    return (retval == _ERC721_RECEIVED);

  }



  /**

   * @dev Private function to clear current approval of a given token ID

   * Reverts if the given address is not indeed the owner of the token

   * @param owner owner of the token

   * @param tokenId uint256 ID of the token to be transferred

   */

  function _clearApproval(address owner, uint256 tokenId) private {

    require(ownerOf(tokenId) == owner);

    if (_tokenApprovals[tokenId] != address(0)) {

      _tokenApprovals[tokenId] = address(0);

    }

  }

}



// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Enumerable.sol



/**

 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract IERC721Enumerable is IERC721 {

  function totalSupply() public view returns (uint256);

  function tokenOfOwnerByIndex(

    address owner,

    uint256 index

  )

    public

    view

    returns (uint256 tokenId);



  function tokenByIndex(uint256 index) public view returns (uint256);

}



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Enumerable.sol



contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

  // Mapping from owner to list of owned token IDs

  mapping(address => uint256[]) private _ownedTokens;



  // Mapping from token ID to index of the owner tokens list

  mapping(uint256 => uint256) private _ownedTokensIndex;



  // Array with all token ids, used for enumeration

  uint256[] private _allTokens;



  // Mapping from token id to position in the allTokens array

  mapping(uint256 => uint256) private _allTokensIndex;



  bytes4 private constant _InterfaceId_ERC721Enumerable = 0x780e9d63;

  /**

   * 0x780e9d63 ===

   *   bytes4(keccak256('totalSupply()')) ^

   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^

   *   bytes4(keccak256('tokenByIndex(uint256)'))

   */



  /**

   * @dev Constructor function

   */

  constructor() public {

    // register the supported interface to conform to ERC721 via ERC165

    _registerInterface(_InterfaceId_ERC721Enumerable);

  }



  /**

   * @dev Gets the token ID at a given index of the tokens list of the requested owner

   * @param owner address owning the tokens list to be accessed

   * @param index uint256 representing the index to be accessed of the requested tokens list

   * @return uint256 token ID at the given index of the tokens list owned by the requested address

   */

  function tokenOfOwnerByIndex(

    address owner,

    uint256 index

  )

    public

    view

    returns (uint256)

  {

    require(index < balanceOf(owner));

    return _ownedTokens[owner][index];

  }



  /**

   * @dev Gets the total amount of tokens stored by the contract

   * @return uint256 representing the total amount of tokens

   */

  function totalSupply() public view returns (uint256) {

    return _allTokens.length;

  }



  /**

   * @dev Gets the token ID at a given index of all the tokens in this contract

   * Reverts if the index is greater or equal to the total number of tokens

   * @param index uint256 representing the index to be accessed of the tokens list

   * @return uint256 token ID at the given index of the tokens list

   */

  function tokenByIndex(uint256 index) public view returns (uint256) {

    require(index < totalSupply());

    return _allTokens[index];

  }



  /**

   * @dev Internal function to add a token ID to the list of a given address

   * This function is internal due to language limitations, see the note in ERC721.sol.

   * It is not intended to be called by custom derived contracts: in particular, it emits no Transfer event.

   * @param to address representing the new owner of the given token ID

   * @param tokenId uint256 ID of the token to be added to the tokens list of the given address

   */

  function _addTokenTo(address to, uint256 tokenId) internal {

    super._addTokenTo(to, tokenId);

    uint256 length = _ownedTokens[to].length;

    _ownedTokens[to].push(tokenId);

    _ownedTokensIndex[tokenId] = length;

  }



  /**

   * @dev Internal function to remove a token ID from the list of a given address

   * This function is internal due to language limitations, see the note in ERC721.sol.

   * It is not intended to be called by custom derived contracts: in particular, it emits no Transfer event,

   * and doesn't clear approvals.

   * @param from address representing the previous owner of the given token ID

   * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address

   */

  function _removeTokenFrom(address from, uint256 tokenId) internal {

    super._removeTokenFrom(from, tokenId);



    // To prevent a gap in the array, we store the last token in the index of the token to delete, and

    // then delete the last slot.

    uint256 tokenIndex = _ownedTokensIndex[tokenId];

    uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);

    uint256 lastToken = _ownedTokens[from][lastTokenIndex];



    _ownedTokens[from][tokenIndex] = lastToken;

    // This also deletes the contents at the last position of the array

    _ownedTokens[from].length--;



    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to

    // be zero. Then we can make sure that we will remove tokenId from the ownedTokens list since we are first swapping

    // the lastToken to the first position, and then dropping the element placed in the last position of the list



    _ownedTokensIndex[tokenId] = 0;

    _ownedTokensIndex[lastToken] = tokenIndex;

  }



  /**

   * @dev Internal function to mint a new token

   * Reverts if the given token ID already exists

   * @param to address the beneficiary that will own the minted token

   * @param tokenId uint256 ID of the token to be minted by the msg.sender

   */

  function _mint(address to, uint256 tokenId) internal {

    super._mint(to, tokenId);



    _allTokensIndex[tokenId] = _allTokens.length;

    _allTokens.push(tokenId);

  }



  /**

   * @dev Internal function to burn a specific token

   * Reverts if the token does not exist

   * @param owner owner of the token to burn

   * @param tokenId uint256 ID of the token being burned by the msg.sender

   */

  function _burn(address owner, uint256 tokenId) internal {

    super._burn(owner, tokenId);



    // Reorg all tokens array

    uint256 tokenIndex = _allTokensIndex[tokenId];

    uint256 lastTokenIndex = _allTokens.length.sub(1);

    uint256 lastToken = _allTokens[lastTokenIndex];



    _allTokens[tokenIndex] = lastToken;

    _allTokens[lastTokenIndex] = 0;



    _allTokens.length--;

    _allTokensIndex[tokenId] = 0;

    _allTokensIndex[lastToken] = tokenIndex;

  }

}



// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Metadata.sol



/**

 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract IERC721Metadata is IERC721 {

  function name() external view returns (string);

  function symbol() external view returns (string);

  function tokenURI(uint256 tokenId) external view returns (string);

}



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Metadata.sol



contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {

  // Token name

  string private _name;



  // Token symbol

  string private _symbol;



  // Optional mapping for token URIs

  mapping(uint256 => string) private _tokenURIs;



  bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;

  /**

   * 0x5b5e139f ===

   *   bytes4(keccak256('name()')) ^

   *   bytes4(keccak256('symbol()')) ^

   *   bytes4(keccak256('tokenURI(uint256)'))

   */



  /**

   * @dev Constructor function

   */

  constructor(string name, string symbol) public {

    _name = name;

    _symbol = symbol;



    // register the supported interfaces to conform to ERC721 via ERC165

    _registerInterface(InterfaceId_ERC721Metadata);

  }



  /**

   * @dev Gets the token name

   * @return string representing the token name

   */

  function name() external view returns (string) {

    return _name;

  }



  /**

   * @dev Gets the token symbol

   * @return string representing the token symbol

   */

  function symbol() external view returns (string) {

    return _symbol;

  }



  /**

   * @dev Returns an URI for a given token ID

   * Throws if the token ID does not exist. May return an empty string.

   * @param tokenId uint256 ID of the token to query

   */

  function tokenURI(uint256 tokenId) external view returns (string) {

    require(_exists(tokenId));

    return _tokenURIs[tokenId];

  }



  /**

   * @dev Internal function to set the token URI for a given token

   * Reverts if the token ID does not exist

   * @param tokenId uint256 ID of the token to set its URI

   * @param uri string URI to assign

   */

  function _setTokenURI(uint256 tokenId, string uri) internal {

    require(_exists(tokenId));

    _tokenURIs[tokenId] = uri;

  }



  /**

   * @dev Internal function to burn a specific token

   * Reverts if the token does not exist

   * @param owner owner of the token to burn

   * @param tokenId uint256 ID of the token being burned by the msg.sender

   */

  function _burn(address owner, uint256 tokenId) internal {

    super._burn(owner, tokenId);



    // Clear metadata (if any)

    if (bytes(_tokenURIs[tokenId]).length != 0) {

      delete _tokenURIs[tokenId];

    }

  }

}



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol



/**

 * @title Full ERC721 Token

 * This implementation includes all the required and some optional functionality of the ERC721 standard

 * Moreover, it includes approve all functionality using operator terminology

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {

  constructor(string name, string symbol) ERC721Metadata(name, symbol)

    public

  {

  }

}



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: eth-token-recover/contracts/TokenRecover.sol



/**

 * @title TokenRecover

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev Allow to recover any ERC20 sent into the contract for error

 */

contract TokenRecover is Ownable {



  /**

   * @dev Remember that only owner can call so be careful when use on contracts generated from other contracts.

   * @param tokenAddress The token contract address

   * @param tokenAmount Number of tokens to be sent

   */

  function recoverERC20(

    address tokenAddress,

    uint256 tokenAmount

  )

    public

    onlyOwner

  {

    IERC20(tokenAddress).transfer(owner(), tokenAmount);

  }

}



// File: solidity-linked-list/contracts/StructuredLinkedList.sol



contract StructureInterface {

  function getValue (uint256 _id) public view returns (uint256);

}





/**

 * @title StructuredLinkedList

 * @author Vittorio Minacori (https://github.com/vittominacori)

 * @dev This utility library is inspired by https://github.com/Modular-Network/ethereum-libraries/tree/master/LinkedListLib

 *  It has been updated to add additional functionality and be compatible with solidity 0.4.24 coding patterns.

 */





// File: contracts/WallOfChainToken.sol



contract WallOfChainToken is ERC721Full, TokenRecover, MinterRole {

  using StructuredLinkedList for StructuredLinkedList.List;



  StructuredLinkedList.List list;



  struct WallStructure {

    uint256 value;

    string firstName;

    string lastName;

    uint256 pattern;

    uint256 icon;

  }



  bool public mintingFinished = false;



  uint256 public progressiveId = 0;



  // Mapping from token ID to the structures

  mapping(uint256 => WallStructure) structureIndex;



  modifier canGenerate() {

    require(

      !mintingFinished,

      "Minting is finished"

    );

    _;

  }



  constructor(string _name, string _symbol) public

  ERC721Full(_name, _symbol)

  {}



  /**

   * @dev Function to stop minting new tokens.

   */

  function finishMinting() public onlyOwner canGenerate {

    mintingFinished = true;

  }



  function newToken(

    address _beneficiary,

    uint256 _value,

    string _firstName,

    string _lastName,

    uint256 _pattern,

    uint256 _icon

  )

    public

    canGenerate

    onlyMinter

    returns (uint256)

  {

    uint256 tokenId = progressiveId.add(1);

    _mint(_beneficiary, tokenId);

    structureIndex[tokenId] = WallStructure(

      _value,

      _firstName,

      _lastName,

      _value == 0 ? 0 : _pattern,

      _value == 0 ? 0 : _icon

    );

    progressiveId = tokenId;



    uint256 position = list.getSortedSpot(StructureInterface(this), _value);

    list.insertBefore(position, tokenId);



    return tokenId;

  }



  function editToken (

    uint256 _tokenId,

    uint256 _value,

    string _firstName,

    string _lastName,

    uint256 _pattern,

    uint256 _icon

  )

    public

    onlyMinter

    returns (uint256)

  {

    require(

      _exists(_tokenId),

      "Token must exists"

    );



    uint256 value = getValue(_tokenId);



    if (_value > 0) {

      value = value.add(_value); // add the new value sent



      // reorder the list

      list.remove(_tokenId);

      uint256 position = list.getSortedSpot(StructureInterface(this), value);

      list.insertBefore(position, _tokenId);

    }



    structureIndex[_tokenId] = WallStructure(

      value,

      _firstName,

      _lastName,

      value == 0 ? 0 : _pattern,

      value == 0 ? 0 : _icon

    );



    return _tokenId;

  }



  function getWall (

    uint256 _tokenId

  )

    public

    view

    returns (

      address tokenOwner,

      uint256 value,

      string firstName,

      string lastName,

      uint256 pattern,

      uint256 icon

    )

  {

    require(

      _exists(_tokenId),

      "Token must exists"

    );



    WallStructure storage wall = structureIndex[_tokenId];



    tokenOwner = ownerOf(_tokenId);



    value = wall.value;

    firstName = wall.firstName;

    lastName = wall.lastName;

    pattern = wall.pattern;

    icon = wall.icon;

  }



  function getValue (uint256 _tokenId) public view returns (uint256) {

    require(

      _exists(_tokenId),

      "Token must exists"

    );

    WallStructure storage wall = structureIndex[_tokenId];

    return wall.value;

  }



  function getNextNode(uint256 _tokenId) public view returns (bool, uint256) {

    return list.getNextNode(_tokenId);

  }



  function getPreviousNode(

    uint256 _tokenId

  )

    public

    view

    returns (bool, uint256)

  {

    return list.getPreviousNode(_tokenId);

  }



  /**

   * @dev Only contract owner or token owner can burn

   */

  function burn(uint256 _tokenId) public {

    address tokenOwner = isOwner() ? ownerOf(_tokenId) : msg.sender;

    super._burn(tokenOwner, _tokenId);

    list.remove(_tokenId);

    delete structureIndex[_tokenId];

  }

}



// File: contracts/WallOfChainMarket.sol



contract WallOfChainMarket is TokenRecover {

  using SafeMath for uint256;



  // The token being sold

  WallOfChainToken public token;



  // Address where funds are collected

  address public wallet;



  // Amount of wei raised

  uint256 public weiRaised;



  /**

   * Event for token purchase logging

   * @param purchaser who paid for the tokens

   * @param beneficiary who got the tokens

   * @param value weis paid for purchase

   * @param tokenId the token id purchased

   */

  event TokenPurchase(

    address indexed purchaser,

    address indexed beneficiary,

    uint256 value,

    uint256 tokenId

  );



  /**

   * Event for token edit logging

   * @param beneficiary who has the tokens

   * @param value weis added in edit

   * @param tokenId the token id edited

   */

  event TokenEdit(

    address indexed beneficiary,

    uint256 value,

    uint256 tokenId

  );



  /**

   * @param _wallet Address where collected funds will be forwarded to

   * @param _token Address of the token being sold

   */

  constructor(address _wallet, WallOfChainToken _token) public {

    require(

      _wallet != address(0),

      "Wallet can't be the zero address"

    );

    require(

      _token != address(0),

      "Token can't be the zero address"

    );



    wallet = _wallet;

    token = _token;

  }



  /**

   * @dev low level token purchase ***DO NOT OVERRIDE***

   */

  function buyToken(

    address _beneficiary,

    string _firstName,

    string _lastName,

    uint256 _pattern,

    uint256 _icon

  )

    public

    payable

  {

    uint256 weiAmount = msg.value;



    _preValidatePurchase(_beneficiary);



    // update state

    weiRaised = weiRaised.add(weiAmount);



    uint256 lastTokenId = _processPurchase(

      _beneficiary,

      weiAmount,

      _firstName,

      _lastName,

      _pattern,

      _icon

    );



    emit TokenPurchase(

      msg.sender,

      _beneficiary,

      weiAmount,

      lastTokenId

    );



    _forwardFunds();

  }



  /**

   * @dev low level token edit

   */

  function editToken(

    uint256 _tokenId,

    string _firstName,

    string _lastName,

    uint256 _pattern,

    uint256 _icon

  )

    public

    payable

  {

    address tokenOwner = token.ownerOf(_tokenId);

    require(msg.sender == tokenOwner, "Sender must be token owner");



    // update state

    uint256 weiAmount = msg.value;

    weiRaised = weiRaised.add(weiAmount);



    uint256 currentTokenId = _processEdit(

      _tokenId,

      weiAmount,

      _firstName,

      _lastName,

      _pattern,

      _icon

    );



    emit TokenEdit(

      tokenOwner,

      weiAmount,

      currentTokenId

    );



    _forwardFunds();

  }



  /**

   * @dev change the destination wallet

   */

  function changeWallet(address _newWallet) public onlyOwner {

    require(

      _newWallet != address(0),

      "Wallet can't be the zero address"

    );



    wallet = _newWallet;

  }



  // -----------------------------------------

  // Internal interface (extensible)

  // -----------------------------------------



  /**

   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.

   * @param _beneficiary Address performing the token purchase

   */

  function _preValidatePurchase(

    address _beneficiary

  )

    internal

    pure

  {

    require(

      _beneficiary != address(0),

      "Beneficiary can't be the zero address"

    );

  }



  /**

   * @dev Executed when a purchase has been validated and is ready to be executed.

   */

  function _processPurchase(

    address _beneficiary,

    uint256 _weiAmount,

    string _firstName,

    string _lastName,

    uint256 _pattern,

    uint256 _icon

  )

    internal

    returns (uint256)

  {

    return token.newToken(

      _beneficiary,

      _weiAmount,

      _firstName,

      _lastName,

      _pattern,

      _icon

    );

  }



  /**

   * @dev Executed when a edit has been validated and is ready to be executed.

   */

  function _processEdit(

    uint256 _tokenId,

    uint256 _weiAmount,

    string _firstName,

    string _lastName,

    uint256 _pattern,

    uint256 _icon

  )

    internal

    returns (uint256)

  {

    return token.editToken(

      _tokenId,

      _weiAmount,

      _firstName,

      _lastName,

      _pattern,

      _icon

    );

  }



  /**

   * @dev Determines how ETH is stored/forwarded on purchases.

   */

  function _forwardFunds() internal {

    if (msg.value > 0) {

      wallet.transfer(msg.value);

    }

  }

}