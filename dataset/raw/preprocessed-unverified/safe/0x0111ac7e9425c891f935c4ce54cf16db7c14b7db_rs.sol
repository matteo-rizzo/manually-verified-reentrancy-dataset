/**

 *Submitted for verification at Etherscan.io on 2018-12-06

*/



pragma solidity ^0.4.24;



contract BasicAccessControl {

    address public owner;

    address[] moderatorsArray;

    uint16 public totalModerators = 0;

    mapping (address => bool) moderators;

    bool public isMaintaining = true;



    constructor() public {

        owner = msg.sender;

        AddModerator(msg.sender);

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    modifier onlyModerators() {

        require(moderators[msg.sender] == true);

        _;

    }



    modifier isActive {

        require(!isMaintaining);

        _;

    }



    function findInArray(address _address) internal view returns(uint8) {

        uint8 i = 0;

        while (moderatorsArray[i] != _address) {

            i++;

        }

        return i;

    }



    function ChangeOwner(address _newOwner) onlyOwner public {

        if (_newOwner != address(0)) {

            owner = _newOwner;

        }

    }



    function AddModerator(address _newModerator) onlyOwner public {

        if (moderators[_newModerator] == false) {

            moderators[_newModerator] = true;

            moderatorsArray.push(_newModerator);

            totalModerators += 1;

        }

    }



    function getModerators() public view returns(address[] memory) {

        return moderatorsArray;

    }



    function RemoveModerator(address _oldModerator) onlyOwner public {

        if (moderators[_oldModerator] == true) {

            moderators[_oldModerator] = false;

            uint8 i = findInArray(_oldModerator);

            while (i<moderatorsArray.length-1) {

                moderatorsArray[i] = moderatorsArray[i+1];

                i++;

            }

            moderatorsArray.length--;

            totalModerators -= 1;

        }

    }



    function UpdateMaintaining(bool _isMaintaining) onlyOwner public {

        isMaintaining = _isMaintaining;

    }



    function isModerator(address _address) public view returns(bool, address) {

        return (moderators[_address], _address);

    }

}



contract randomRange {

    function getRandom(uint256 minRan, uint256 maxRan, uint8 index, address priAddress) view internal returns(uint) {

        uint256 genNum = uint256(blockhash(block.number-1)) + uint256(priAddress) + uint256(keccak256(abi.encodePacked(block.timestamp, index)));

        for (uint8 i = 0; i < index && i < 6; i ++) {

            genNum /= 256;

        }

        return uint(genNum % (maxRan + 1 - minRan) + minRan);

    }

}



/*

 * @title String & slice utility library for Solidity contracts.

 * @author Nick Johnson <[emailÂ protected]>

 *

 * @dev Functionality in this library is largely implemented using an

 *      abstraction called a 'slice'. A slice represents a part of a string -

 *      anything from the entire string to a single character, or even no

 *      characters at all (a 0-length slice). Since a slice only has to specify

 *      an offset and a length, copying and manipulating slices is a lot less

 *      expensive than copying and manipulating the strings they reference.

 *

 *      To further reduce gas costs, most functions on slice that need to return

 *      a slice modify the original one instead of allocating a new one; for

 *      instance, `s.split(".")` will return the text up to the first '.',

 *      modifying s to only contain the remainder of the string after the '.'.

 *      In situations where you do not want to modify the original slice, you

 *      can make a copy first with `.copy()`, for example:

 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since

 *      Solidity has no memory management, it will result in allocating many

 *      short-lived slices that are later discarded.

 *

 *      Functions that return two slices come in two versions: a non-allocating

 *      version that takes the second slice as an argument, modifying it in

 *      place, and an allocating version that allocates and returns the second

 *      slice; see `nextRune` for example.

 *

 *      Functions that have to copy string data will return strings rather than

 *      slices; these can be cast back to slices for further processing if

 *      required.

 *

 *      For convenience, some functions are provided with non-modifying

 *      variants that create a new slice and return both; for instance,

 *      `s.splitNew('.')` leaves s unmodified, and returns two values

 *      corresponding to the left and right parts of the string.

 */











/**

 * @title ERC165

 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md

 */





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

  function name() external view returns (string _name);

  function symbol() external view returns (string _symbol);

  function tokenURI(uint256 _tokenId) public view returns (string);

}





/**

 * @title ERC-721 Non-Fungible Token Standard, full implementation interface

 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {

}



/**

 * @title ERC721 token receiver interface

 * @dev Interface for any contract that wants to support safeTransfers

 * from ERC721 asset contracts.

 */

contract ERC721Receiver {

  /**

   * @dev Magic value to be returned upon successful reception of an NFT

   *  Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`,

   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`

   */

  bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;



  /**

   * @notice Handle the receipt of an NFT

   * @dev The ERC721 smart contract calls this function on the recipient

   * after a `safetransfer`. This function MAY throw to revert and reject the

   * transfer. Return of other than the magic value MUST result in the

   * transaction being reverted.

   * Note: the contract address is always the message sender.

   * @param _operator The address which called `safeTransferFrom` function

   * @param _from The address which previously owned the token

   * @param _tokenId The NFT identifier which is being transferred

   * @param _data Additional data with no specified format

   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

   */

  function onERC721Received(

    address _operator,

    address _from,

    uint256 _tokenId,

    bytes _data

  )

    public

    returns(bytes4);

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * Utility library of inline functions on addresses

 */





/**

 * @title SupportsInterfaceWithLookup

 * @author Matt Condon (@shrugs)

 * @dev Implements ERC165 using a lookup table.

 */

contract SupportsInterfaceWithLookup is ERC165 {



  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;

  /**

   * 0x01ffc9a7 ===

   *   bytes4(keccak256('supportsInterface(bytes4)'))

   */



  /**

   * @dev a mapping of interface id to whether or not it's supported

   */

  mapping(bytes4 => bool) internal supportedInterfaces;



  /**

   * @dev A contract implementing SupportsInterfaceWithLookup

   * implement ERC165 itself

   */

  constructor()

    public

  {

    _registerInterface(InterfaceId_ERC165);

  }



  /**

   * @dev implement supportsInterface(bytes4) using a lookup table

   */

  function supportsInterface(bytes4 _interfaceId)

    external

    view

    returns (bool)

  {

    return supportedInterfaces[_interfaceId];

  }



  /**

   * @dev private method for registering an interface

   */

  function _registerInterface(bytes4 _interfaceId)

    internal

  {

    require(_interfaceId != 0xffffffff);

    supportedInterfaces[_interfaceId] = true;

  }

}



/**

 * @title ERC721 Non-Fungible Token Standard basic implementation

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721BasicToken is SupportsInterfaceWithLookup, ERC721Basic {



  using SafeMath for uint256;

  using AddressUtils for address;



  // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`

  bytes4 private constant ERC721_RECEIVED = 0x150b7a02;



  // Mapping from token ID to owner

  mapping (uint256 => address) internal tokenOwner;



  // Mapping from token ID to approved address

  mapping (uint256 => address) internal tokenApprovals;



  // Mapping from owner to number of owned token

  mapping (address => uint256) internal ownedTokensCount;



  // Mapping from owner to operator approvals

  mapping (address => mapping (address => bool)) internal operatorApprovals;



  constructor()

    public

  {

    // register the supported interfaces to conform to ERC721 via ERC165

    _registerInterface(InterfaceId_ERC721);

    _registerInterface(InterfaceId_ERC721Exists);

  }



  /**

   * @dev Gets the balance of the specified address

   * @param _owner address to query the balance of

   * @return uint256 representing the amount owned by the passed address

   */

  function balanceOf(address _owner) public view returns (uint256) {

    require(_owner != address(0));

    return ownedTokensCount[_owner];

  }



  /**

   * @dev Gets the owner of the specified token ID

   * @param _tokenId uint256 ID of the token to query the owner of

   * @return owner address currently marked as the owner of the given token ID

   */

  function ownerOf(uint256 _tokenId) public view returns (address) {

    address owner = tokenOwner[_tokenId];

    require(owner != address(0));

    return owner;

  }



  /**

   * @dev Returns whether the specified token exists

   * @param _tokenId uint256 ID of the token to query the existence of

   * @return whether the token exists

   */

  function exists(uint256 _tokenId) public view returns (bool) {

    address owner = tokenOwner[_tokenId];

    return owner != address(0);

  }



  /**

   * @dev Approves another address to transfer the given token ID

   * The zero address indicates there is no approved address.

   * There can only be one approved address per token at a given time.

   * Can only be called by the token owner or an approved operator.

   * @param _to address to be approved for the given token ID

   * @param _tokenId uint256 ID of the token to be approved

   */

  function approve(address _to, uint256 _tokenId) public {

    address owner = ownerOf(_tokenId);

    require(_to != owner);

    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));



    tokenApprovals[_tokenId] = _to;

    emit Approval(owner, _to, _tokenId);

  }



  /**

   * @dev Gets the approved address for a token ID, or zero if no address set

   * @param _tokenId uint256 ID of the token to query the approval of

   * @return address currently approved for the given token ID

   */

  function getApproved(uint256 _tokenId) public view returns (address) {

    return tokenApprovals[_tokenId];

  }



  /**

   * @dev Sets or unsets the approval of a given operator

   * An operator is allowed to transfer all tokens of the sender on their behalf

   * @param _to operator address to set the approval

   * @param _approved representing the status of the approval to be set

   */

  function setApprovalForAll(address _to, bool _approved) public {

    require(_to != msg.sender);

    operatorApprovals[msg.sender][_to] = _approved;

    emit ApprovalForAll(msg.sender, _to, _approved);

  }



  /**

   * @dev Tells whether an operator is approved by a given owner

   * @param _owner owner address which you want to query the approval of

   * @param _operator operator address which you want to query the approval of

   * @return bool whether the given operator is approved by the given owner

   */

  function isApprovedForAll(

    address _owner,

    address _operator

  )

    public

    view

    returns (bool)

  {

    return operatorApprovals[_owner][_operator];

  }



  /**

   * @dev Transfers the ownership of a given token ID to another address

   * Usage of this method is discouraged, use `safeTransferFrom` whenever possible

   * Requires the msg sender to be the owner, approved, or operator

   * @param _from current owner of the token

   * @param _to address to receive the ownership of the given token ID

   * @param _tokenId uint256 ID of the token to be transferred

  */

  function transferFrom(

    address _from,

    address _to,

    uint256 _tokenId

  )

    public

  {

    require(isApprovedOrOwner(msg.sender, _tokenId));

    require(_from != address(0));

    require(_to != address(0));



    clearApproval(_from, _tokenId);

    removeTokenFrom(_from, _tokenId);

    addTokenTo(_to, _tokenId);



    emit Transfer(_from, _to, _tokenId);

  }



  /**

   * @dev Safely transfers the ownership of a given token ID to another address

   * If the target address is a contract, it must implement `onERC721Received`,

   * which is called upon a safe transfer, and return the magic value

   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,

   * the transfer is reverted.

   *

   * Requires the msg sender to be the owner, approved, or operator

   * @param _from current owner of the token

   * @param _to address to receive the ownership of the given token ID

   * @param _tokenId uint256 ID of the token to be transferred

  */

  function safeTransferFrom(

    address _from,

    address _to,

    uint256 _tokenId

  )

    public

  {

    // solium-disable-next-line arg-overflow

    safeTransferFrom(_from, _to, _tokenId, "");

  }



  /**

   * @dev Safely transfers the ownership of a given token ID to another address

   * If the target address is a contract, it must implement `onERC721Received`,

   * which is called upon a safe transfer, and return the magic value

   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,

   * the transfer is reverted.

   * Requires the msg sender to be the owner, approved, or operator

   * @param _from current owner of the token

   * @param _to address to receive the ownership of the given token ID

   * @param _tokenId uint256 ID of the token to be transferred

   * @param _data bytes data to send along with a safe transfer check

   */

  function safeTransferFrom(

    address _from,

    address _to,

    uint256 _tokenId,

    bytes _data

  )

    public

  {

    transferFrom(_from, _to, _tokenId);

    // solium-disable-next-line arg-overflow

    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));

  }



  /**

   * @dev Returns whether the given spender can transfer a given token ID

   * @param _spender address of the spender to query

   * @param _tokenId uint256 ID of the token to be transferred

   * @return bool whether the msg.sender is approved for the given token ID,

   *  is an operator of the owner, or is the owner of the token

   */

  function isApprovedOrOwner(

    address _spender,

    uint256 _tokenId

  )

    internal

    view

    returns (bool)

  {

    address owner = ownerOf(_tokenId);

    // Disable solium check because of

    // https://github.com/duaraghav8/Solium/issues/175

    // solium-disable-next-line operator-whitespace

    return (

      _spender == owner ||

      getApproved(_tokenId) == _spender ||

      isApprovedForAll(owner, _spender)

    );

  }



  /**

   * @dev Internal function to mint a new token

   * Reverts if the given token ID already exists

   * @param _to The address that will own the minted token

   * @param _tokenId uint256 ID of the token to be minted by the msg.sender

   */

  function _mint(address _to, uint256 _tokenId) internal {

    require(_to != address(0));

    addTokenTo(_to, _tokenId);

    emit Transfer(address(0), _to, _tokenId);

  }



  /**

   * @dev Internal function to burn a specific token

   * Reverts if the token does not exist

   * @param _tokenId uint256 ID of the token being burned by the msg.sender

   */

  function _burn(address _owner, uint256 _tokenId) internal {

    clearApproval(_owner, _tokenId);

    removeTokenFrom(_owner, _tokenId);

    emit Transfer(_owner, address(0), _tokenId);

  }



  /**

   * @dev Internal function to clear current approval of a given token ID

   * Reverts if the given address is not indeed the owner of the token

   * @param _owner owner of the token

   * @param _tokenId uint256 ID of the token to be transferred

   */

  function clearApproval(address _owner, uint256 _tokenId) internal {

    require(ownerOf(_tokenId) == _owner);

    if (tokenApprovals[_tokenId] != address(0)) {

      tokenApprovals[_tokenId] = address(0);

    }

  }



  /**

   * @dev Internal function to add a token ID to the list of a given address

   * @param _to address representing the new owner of the given token ID

   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address

   */

  function addTokenTo(address _to, uint256 _tokenId) internal {

    require(tokenOwner[_tokenId] == address(0));

    tokenOwner[_tokenId] = _to;

    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);

  }



  /**

   * @dev Internal function to remove a token ID from the list of a given address

   * @param _from address representing the previous owner of the given token ID

   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address

   */

  function removeTokenFrom(address _from, uint256 _tokenId) internal {

    require(ownerOf(_tokenId) == _from);

    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);

    tokenOwner[_tokenId] = address(0);

  }



  /**

   * @dev Internal function to invoke `onERC721Received` on a target address

   * The call is not executed if the target address is not a contract

   * @param _from address representing the previous owner of the given token ID

   * @param _to target address that will receive the tokens

   * @param _tokenId uint256 ID of the token to be transferred

   * @param _data bytes optional data to send along with the call

   * @return whether the call correctly returned the expected magic value

   */

  function checkAndCallSafeTransfer(

    address _from,

    address _to,

    uint256 _tokenId,

    bytes _data

  )

    internal

    returns (bool)

  {

    if (!_to.isContract()) {

      return true;

    }

    bytes4 retval = ERC721Receiver(_to).onERC721Received(

      msg.sender, _from, _tokenId, _data);

    return (retval == ERC721_RECEIVED);

  }

}



/**

 * @title Full ERC721 Token

 * This implementation includes all the required and some optional functionality of the ERC721 standard

 * Moreover, it includes approve all functionality using operator terminology

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721Token is SupportsInterfaceWithLookup, ERC721BasicToken, ERC721 {



  // Token name

  string internal name_;



  // Token symbol

  string internal symbol_;



  // Mapping from owner to list of owned token IDs

  mapping(address => uint256[]) internal ownedTokens;



  // Mapping from token ID to index of the owner tokens list

  mapping(uint256 => uint256) internal ownedTokensIndex;



  // Array with all token ids, used for enumeration

  uint256[] internal allTokens;



  // Mapping from token id to position in the allTokens array

  mapping(uint256 => uint256) internal allTokensIndex;



  // Optional mapping for token URIs

  mapping(uint256 => string) internal tokenURIs;



  /**

   * @dev Constructor function

   */

  constructor(string _name, string _symbol) public {

    name_ = _name;

    symbol_ = _symbol;



    // register the supported interfaces to conform to ERC721 via ERC165

    _registerInterface(InterfaceId_ERC721Enumerable);

    _registerInterface(InterfaceId_ERC721Metadata);

  }



  /**

   * @dev Gets the token name

   * @return string representing the token name

   */

  function name() external view returns (string) {

    return name_;

  }



  /**

   * @dev Gets the token symbol

   * @return string representing the token symbol

   */

  function symbol() external view returns (string) {

    return symbol_;

  }



  /**

   * @dev Returns an URI for a given token ID

   * Throws if the token ID does not exist. May return an empty string.

   * @param _tokenId uint256 ID of the token to query

   */

  function tokenURI(uint256 _tokenId) public view returns (string) {

    require(exists(_tokenId));

    return tokenURIs[_tokenId];

  }



  /**

   * @dev Gets the token ID at a given index of the tokens list of the requested owner

   * @param _owner address owning the tokens list to be accessed

   * @param _index uint256 representing the index to be accessed of the requested tokens list

   * @return uint256 token ID at the given index of the tokens list owned by the requested address

   */

  function tokenOfOwnerByIndex(

    address _owner,

    uint256 _index

  )

    public

    view

    returns (uint256)

  {

    require(_index < balanceOf(_owner));

    return ownedTokens[_owner][_index];

  }



  /**

   * @dev Gets the total amount of tokens stored by the contract

   * @return uint256 representing the total amount of tokens

   */

  function totalSupply() public view returns (uint256) {

    return allTokens.length;

  }



  /**

   * @dev Gets the token ID at a given index of all the tokens in this contract

   * Reverts if the index is greater or equal to the total number of tokens

   * @param _index uint256 representing the index to be accessed of the tokens list

   * @return uint256 token ID at the given index of the tokens list

   */

  function tokenByIndex(uint256 _index) public view returns (uint256) {

    require(_index < totalSupply());

    return allTokens[_index];

  }



  /**

   * @dev Internal function to set the token URI for a given token

   * Reverts if the token ID does not exist

   * @param _tokenId uint256 ID of the token to set its URI

   * @param _uri string URI to assign

   */

  function _setTokenURI(uint256 _tokenId, string _uri) internal {

    require(exists(_tokenId));

    tokenURIs[_tokenId] = _uri;

  }



  /**

   * @dev Internal function to add a token ID to the list of a given address

   * @param _to address representing the new owner of the given token ID

   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address

   */

  function addTokenTo(address _to, uint256 _tokenId) internal {

    super.addTokenTo(_to, _tokenId);

    uint256 length = ownedTokens[_to].length;

    ownedTokens[_to].push(_tokenId);

    ownedTokensIndex[_tokenId] = length;

  }



  /**

   * @dev Internal function to remove a token ID from the list of a given address

   * @param _from address representing the previous owner of the given token ID

   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address

   */

  function removeTokenFrom(address _from, uint256 _tokenId) internal {

    super.removeTokenFrom(_from, _tokenId);



    // To prevent a gap in the array, we store the last token in the index of the token to delete, and

    // then delete the last slot.

    uint256 tokenIndex = ownedTokensIndex[_tokenId];

    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);

    uint256 lastToken = ownedTokens[_from][lastTokenIndex];



    ownedTokens[_from][tokenIndex] = lastToken;

    // This also deletes the contents at the last position of the array

    ownedTokens[_from].length--;



    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to

    // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping

    // the lastToken to the first position, and then dropping the element placed in the last position of the list



    ownedTokensIndex[_tokenId] = 0;

    ownedTokensIndex[lastToken] = tokenIndex;

  }



  /**

   * @dev Internal function to mint a new token

   * Reverts if the given token ID already exists

   * @param _to address the beneficiary that will own the minted token

   * @param _tokenId uint256 ID of the token to be minted by the msg.sender

   */

  function _mint(address _to, uint256 _tokenId) internal {

    super._mint(_to, _tokenId);



    allTokensIndex[_tokenId] = allTokens.length;

    allTokens.push(_tokenId);

  }



  /**

   * @dev Internal function to burn a specific token

   * Reverts if the token does not exist

   * @param _owner owner of the token to burn

   * @param _tokenId uint256 ID of the token being burned by the msg.sender

   */

  function _burn(address _owner, uint256 _tokenId) internal {

    super._burn(_owner, _tokenId);



    // Clear metadata (if any)

    if (bytes(tokenURIs[_tokenId]).length != 0) {

      delete tokenURIs[_tokenId];

    }



    // Reorg all tokens array

    uint256 tokenIndex = allTokensIndex[_tokenId];

    uint256 lastTokenIndex = allTokens.length.sub(1);

    uint256 lastToken = allTokens[lastTokenIndex];



    allTokens[tokenIndex] = lastToken;

    allTokens[lastTokenIndex] = 0;



    allTokens.length--;

    allTokensIndex[_tokenId] = 0;

    allTokensIndex[lastToken] = tokenIndex;

  }



}



/// @title Contract for Chainbreakers Items (ERC721Token)

/// @author Tobias Thiele - Qwellcode GmbH - www.qwellcode.de



/*  HOSTFILE

*   0 = 3D Model (*.glb)

*   1 = Icon

*   2 = Thumbnail

*   3 = Transparent

*/



/*  RARITY

*   0 = Common

*   1 = Uncommon

*   2 = Rare

*   3 = Epic

*   4 = Legendary

*/



/*  WEAPONS

*   0 = Axe

*   1 = Mace

*   2 = Sword

*/



/*  STATS

*   0 = MQ - Motivational Quotient - Charisma

*   1 = PQ - Physical Quotient - Vitality

*   2 = IQ - Intelligence Quotient - Intellect

*   3 = EQ - Experience Quotient - Wisdom

*   4 = LQ - Learning Agility Quotient - Dexterity

*   5 = TQ - Technical Quotient - Tactics

*/















/** @dev used to manage payment in MANA */

contract MANAInterface {

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);

    function balanceOf(address _owner) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

}



contract OwnableDelegateProxy { }



contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;

}



contract ChainbreakersItemsERC721 is ERC721Token("Chainbreakers Items", "CBI"), BasicAccessControl, randomRange {



    address proxyRegistryAddress;



    using SafeMath for uint256;

    using strings for *;



    uint256 public totalItems;

    uint256 public totalItemClass;

    uint256 public totalTokens;

    uint8 public currentGen;



    string _baseURI = "http://api.chainbreakers.io/api/v1/items/metadata?tokenId=";





    uint public presaleStart = 1541073600;



    // use as seed for random

    address private lastMinter;



    ItemClass[] private globalClasses;



    mapping(uint256 => ItemData) public tokenToData;

    mapping(uint256 => ItemClass) public classIdToClass;



    struct ItemClass {

        uint256 classId;

        string name;

        uint16 amount;

        string hostfile;

        uint16 minLevel;

        uint16 rarity;

        uint16 weapon;

        uint[] category;

        uint[] statsMin;

        uint[] statsMax;

        string desc;

        uint256 total;

        uint price;

        bool active;

    }



    struct ItemData {

        uint256 tokenId;

        uint256 classId;

        uint[] stats;

        uint8 gen;

    }



    event ItemMinted(uint classId, uint price, uint256 total, uint tokenId);

    event GenerationIncreased(uint8 currentGen);

    event OwnerPayed(uint amount);

    event OwnerPayedETH(uint amount);



    // declare interface for communication between smart contracts

    MANAInterface MANAContract;



    /* HELPER FUNCTIONS - START */

    /** @dev Concatenate two strings

      * @param _a The first string

      * @param _b The second string

      */

    function addToString(string _a, string _b) internal pure returns(string) {

        return _a.toSlice().concat(_b.toSlice());

    }



    /** @dev Converts an uint to a string

      * @notice used with addToString() to generate the tokenURI

      * @param i The uint you want to convert into a string

      */

    function uint2str(uint i) internal pure returns(string) {

        if (i == 0) return "0";

        uint j = i;

        uint length;

        while (j != 0){

            length++;

            j /= 10;

        }

        bytes memory bstr = new bytes(length);

        uint k = length - 1;

        while (i != 0){

            bstr[k--] = byte(48 + i % 10);

            i /= 10;

        }

        return string(bstr);

    }

    /* HELPER FUNCTIONS - END */



    constructor(address _proxyRegistryAddress) public {

        proxyRegistryAddress = _proxyRegistryAddress;

    }



    /** @dev changes the date of the start of the presale

      * @param _start Timestamp the presale starts

      */

    function changePresaleData(uint _start) public onlyModerators {

        presaleStart = _start;

    }



    /** @dev Used to init the communication between our contracts

      * @param _manaContractAddress The contract address for the currency you want to accept e.g. MANA

      */

    function setDatabase(address _manaContractAddress) public onlyModerators {

        MANAContract = MANAInterface(_manaContractAddress); // change to official MANA contract address alter (0x0f5d2fb29fb7d3cfee444a200298f468908cc942)

    }



    /** @dev changes the tokenURI of all minted items + the _baseURI value

      * @param _newBaseURI base url to the api which reads the meta data from the contract e.g. "http://api.chainbreakers.io/api/v1/items/metadata?tokenId="

      */

    function changeBaseURIAll(string _newBaseURI) public onlyModerators {

        _baseURI = _newBaseURI;



        for(uint a = 0; a < totalTokens; a++) {

            uint tokenId = tokenByIndex(a);

            _setTokenURI(tokenId, addToString(_newBaseURI, uint2str(tokenId)));

        }

    }



    /** @dev changes the _baseURI value

      * @param _newBaseURI base url to the api which reads the meta data from the contract e.g. "http://api.chainbreakers.io/api/v1/items/metadata?tokenId="

      */

    function changeBaseURI(string _newBaseURI) public onlyModerators {

        _baseURI = _newBaseURI;

    }



    /** @dev changes the active state of an item class by its class id

      * @param _classId calss id of the item class

      * @param _active active state of the item class

      */

    function editActiveFromClassId(uint256 _classId, bool _active) public onlyModerators {

        ItemClass storage _itemClass = classIdToClass[_classId];

        _itemClass.active = _active;

    }



    /** @dev Adds an item to the contract which can be minted by the user paying the selected currency (MANA)

      * @notice You will find a list of the meanings of the individual indexes on top of the document

      * @param _name The name of the item

      * @param _rarity Defines the rarity on an item

      * @param _weapon Defines which weapon this item is

      * @param _statsMin An array of integers of the lowest stats an item can have

      * @param _statsMax An array of integers of the highest stats an item can have

      * @param _amount Defines how many items can be minted in general

      * @param _hostfile A string contains links to the 3D object, the icon and the thumbnail

      * @notice All links inside the _hostfile string has to be seperated by commas. Use `.split(",")` to get an array in frontend

      * @param _minLevel The lowest level a unit has to be to equip this item

      * @param _desc An optional item description used for legendary items mostly

      * @param _price The price of the item

      */

    function addItemWithClassAndData(string _name, uint16 _rarity, uint16 _weapon, uint[] _statsMin, uint[] _statsMax, uint16 _amount, string _hostfile, uint16 _minLevel, string _desc, uint _price) public onlyModerators {

        ItemClass storage _itemClass = classIdToClass[totalItemClass];

        _itemClass.classId = totalItemClass;

        _itemClass.name = _name;

        _itemClass.amount = _amount;

        _itemClass.rarity = _rarity;

        _itemClass.weapon = _weapon;

        _itemClass.statsMin = _statsMin;

        _itemClass.statsMax = _statsMax;

        _itemClass.hostfile = _hostfile;

        _itemClass.minLevel = _minLevel;

        _itemClass.desc = _desc;

        _itemClass.total = 0;

        _itemClass.price = _price;

        _itemClass.active = true;



        totalItemClass = globalClasses.push(_itemClass);



        totalItems++;

    }



    /** @dev The function the user calls to buy the selected item for a given price

      * @notice The price of the items increases after each bought item by a given amount

      * @param _classId The class id of the item which the user wants to buy

      */

    function buyItem(uint256 _classId) public {

        require(now > presaleStart, "The presale is not started yet");



        ItemClass storage class = classIdToClass[_classId];

        require(class.active == true, "This item is not for sale");

        require(class.amount > 0);



        require(class.total < class.amount, "Sold out");

        require(class.statsMin.length == class.statsMax.length);



        if (class.price > 0) {

            require(MANAContract != address(0), "Invalid contract address for MANA. Please use the setDatabase() function first.");

            require(MANAContract.transferFrom(msg.sender, address(this), class.price) == true, "Failed transfering MANA");

        }



        _mintItem(_classId, msg.sender);

    }



    /** @dev This function mints the item on the blockchain and generates an ERC721 token

      * @notice All stats of the item are randomly generated by using the getRandom() function using min and max values

      * @param _classId The class id of the item which one will be minted

      * @param _address The address of the owner of the new item

      */

    function _mintItem(uint256 _classId, address _address) internal {

        ItemClass storage class = classIdToClass[_classId];

        uint[] memory stats = new uint[](6);

        for(uint j = 0; j < class.statsMin.length; j++) {

            if (class.statsMax[j] > 0) {

                if (stats.length == class.statsMin.length) {

                    stats[j] = getRandom(class.statsMin[j], class.statsMax[j], uint8(j + _classId + class.total), lastMinter);

                }

            } else {

                if (stats.length == class.statsMin.length) {

                    stats[j] = 0;

                }

            }

        }



        ItemData storage _itemData = tokenToData[totalTokens + 1];

        _itemData.tokenId = totalTokens + 1;

        _itemData.classId = _classId;

        _itemData.stats = stats;

        _itemData.gen = currentGen;



        class.total += 1;

        totalTokens += 1;

        _mint(_address, totalTokens);

        _setTokenURI(totalTokens, addToString(_baseURI, uint2str(totalTokens)));



        lastMinter = _address;



        emit ItemMinted(class.classId, class.price, class.total, totalTokens);

    }



    /** @dev Gets the min and the max range of stats a given class id can have

      * @param _classId The class id of the item you want to return the stats of

      * @return statsMin An array of the lowest stats the given item can have

      * @return statsMax An array of the highest stats the given item can have

      */

    function getStatsRange(uint256 _classId) public view returns(uint[] statsMin, uint[] statsMax) {

        return (classIdToClass[_classId].statsMin, classIdToClass[_classId].statsMax);

    }



    /** @dev Gets information about the item stands behind the given token

      * @param _tokenId The id of the token you want to get the item data from

      * @return tokenId The id of the token

      * @return classId The class id of the item behind the token

      * @return stats The randomly generated stats of the item behind the token

      * @return gen The generation of the item

      */

    function getItemDataByToken(uint256 _tokenId) public view returns(uint256 tokenId, uint256 classId, uint[] stats, uint8 gen) {

        return (tokenToData[_tokenId].tokenId, tokenToData[_tokenId].classId, tokenToData[_tokenId].stats, tokenToData[_tokenId].gen);

    }



    /** @dev Returns information about the item category of the given class id

      * @param _classId The class id of the item you want to return the stats of

      * @return classId The class id of the item

      * @return category An array contains information about the category of the item

      */

    function getItemCategory(uint256 _classId) public view returns(uint256 classId, uint[] category) {

        return (classIdToClass[_classId].classId, classIdToClass[_classId].category);

    }



    /** @dev Edits the item class

      * @param _classId The class id of the item you want to edit

      * @param _name The name of the item

      * @param _rarity Defines the rarity on an item

      * @param _weapon Defines which weapon this item is

      * @param _statsMin An array of integers of the lowest stats an item can have

      * @param _statsMax An array of integers of the highest stats an item can have

      * @param _amount Defines how many items can be minted in general

      * @param _hostfile A string contains links to the 3D object, the icon and the thumbnail

      * @notice All links inside the _hostfile string has to be seperated by commas. Use `.split(",")` to get an array in frontend

      * @param _minLevel The lowest level a unit has to be to equip this item

      * @param _desc An optional item description used for legendary items mostly

      * @param _price The price of the item

      */

    function editClass(uint256 _classId, string _name, uint16 _rarity, uint16 _weapon, uint[] _statsMin, uint[] _statsMax, uint16 _amount, string _hostfile, uint16 _minLevel, string _desc, uint _price) public onlyModerators {

        ItemClass storage _itemClass = classIdToClass[_classId];

        _itemClass.name = _name;

        _itemClass.rarity = _rarity;

        _itemClass.weapon = _weapon;

        _itemClass.statsMin = _statsMin;

        _itemClass.statsMax = _statsMax;

        _itemClass.amount = _amount;

        _itemClass.hostfile = _hostfile;

        _itemClass.minLevel = _minLevel;

        _itemClass.desc = _desc;

        _itemClass.price = _price;

    }



    /** @dev Returns a count of created item classes

      * @return totalClasses Integer of how many items are able to be minted

      */

    function countItemsByClass() public view returns(uint totalClasses) {

        return (globalClasses.length);

    }



    /** @dev This function mints an item as a quest reward. The quest contract needs to be added as a moderator

      * @param _classId The id of the item should be minted

      * @param _address The address of the future owner of the minted item

      */

    function mintItemFromQuest(uint256 _classId, address _address) public onlyModerators {

        _mintItem(_classId, _address);

    }



    /** @dev Changes the tokenURI from a minted item by its tokenId

      * @param _tokenId The id of the token

      * @param _uri The new URI of the token for metadata e.g. http://api.chainbreakers.io/api/v1/items/metadata?tokenId=TOKEN_ID

      */

    function changeURIFromTokenByTokenId(uint256 _tokenId, string _uri) public onlyModerators {

        _setTokenURI(_tokenId, _uri);

    }



    function increaseGen() public onlyModerators {

        currentGen += 1;



        emit GenerationIncreased(currentGen);

    }



    /** @dev Function to get a given amount of MANA from this contract.

      * @param _amount The amount of coins you want to get from this contract.

      */

    function payOwner(uint _amount) public onlyOwner {

        MANAContract.transfer(msg.sender, _amount);

        emit OwnerPayed(_amount);

    }



    /** @dev Returns all MANA from this contract to the owner of the contract. */

    function payOwnerAll() public onlyOwner {

        uint tokens = MANAContract.balanceOf(address(this));

        MANAContract.transfer(msg.sender, tokens);

        emit OwnerPayed(tokens);

    }



    /** @dev Function to get a given amount of ETH from this contract.

      * @param _amount The amount of coins you want to get from this contract.

      */

    function payOwnerETH(uint _amount) public onlyOwner {

        msg.sender.transfer(_amount);

        emit OwnerPayedETH(_amount);

    }



    /** @dev Returns all ETH from this contract to the owner of the contract. */

    function payOwnerAllETH() public onlyOwner {

        uint balance = address(this).balance;

        msg.sender.transfer(balance);

        emit OwnerPayedETH(balance);

    }



    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        // Whitelist OpenSea proxy contract for easy trading.

        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);

        if (proxyRegistry.proxies(owner) == operator) {

            return true;

        }



        return super.isApprovedForAll(owner, operator);

    }

}