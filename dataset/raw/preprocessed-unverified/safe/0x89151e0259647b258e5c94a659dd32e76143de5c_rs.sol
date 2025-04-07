/**

 *Submitted for verification at Etherscan.io on 2019-02-02

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/introspection/IERC165.sol



/**

 * @title IERC165

 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md

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



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





// File: openzeppelin-solidity/contracts/utils/Address.sol



/**

 * Utility library of inline functions on addresses

 */





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



// File: contracts/library/token/ERC721Manager.sol



/**

 * @title ERC721Manager

 *

 * @dev This library implements OpenZepellin's ERC721 implementation (as of 7/31/2018) as

 * an external library, in order to keep contract sizes smaller.

 *

 * Released under the MIT License.

 *

 *

 * The MIT License (MIT)

 *

 * Copyright (c) 2016 Smart Contract Solutions, Inc.

 *

 * Permission is hereby granted, free of charge, to any person obtaining

 * a copy of this software and associated documentation files (the

 * "Software"), to deal in the Software without restriction, including

 * without limitation the rights to use, copy, modify, merge, publish,

 * distribute, sublicense, and/or sell copies of the Software, and to

 * permit persons to whom the Software is furnished to do so, subject to

 * the following conditions:

 *

 * The above copyright notice and this permission notice shall be included

 * in all copies or substantial portions of the Software.

 *

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS

 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF

 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY

 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,

 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE

 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 *

 */





// File: contracts/library/token/ERC721Token.sol



/**

 * @title ERC721Token

 *

 * @dev This token interfaces with the OpenZepellin's ERC721 implementation (as of 7/31/2018) as

 * an external library, in order to keep contract sizes smaller.  Intended for use with the

 * ERC721Manager.sol, also provided.

 *

 * Both files are released under the MIT License.

 *

 *

 * The MIT License (MIT)

 *

 * Copyright (c) 2016 Smart Contract Solutions, Inc.

 *

 * Permission is hereby granted, free of charge, to any person obtaining

 * a copy of this software and associated documentation files (the

 * "Software"), to deal in the Software without restriction, including

 * without limitation the rights to use, copy, modify, merge, publish,

 * distribute, sublicense, and/or sell copies of the Software, and to

 * permit persons to whom the Software is furnished to do so, subject to

 * the following conditions:

 *

 * The above copyright notice and this permission notice shall be included

 * in all copies or substantial portions of the Software.

 *

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS

 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF

 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY

 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,

 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE

 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 *

 */

contract ERC721Token is ERC165, ERC721 {



    ERC721Manager.ERC721Data internal erc721Data;



    // We define the events on both the library and the client, so that the events emitted here are detected

    // as if they had been emitted by the client

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





    constructor(string _name, string _symbol) public {

        ERC721Manager.initialize(erc721Data, _name, _symbol);

    }



    function supportsInterface(bytes4 _interfaceId) external view returns (bool) {

        return ERC721Manager.supportsInterface(erc721Data, _interfaceId);

    }



    function balanceOf(address _owner) public view returns (uint256 _balance) {

        return ERC721Manager.balanceOf(erc721Data, _owner);

    }



    function ownerOf(uint256 _tokenId) public view returns (address _owner) {

        return ERC721Manager.ownerOf(erc721Data, _tokenId);

    }



    function exists(uint256 _tokenId) public view returns (bool _exists) {

        return ERC721Manager.exists(erc721Data, _tokenId);

    }



    function approve(address _to, uint256 _tokenId) public {

        ERC721Manager.approve(erc721Data, _to, _tokenId);

    }



    function getApproved(uint256 _tokenId) public view returns (address _operator) {

        return ERC721Manager.getApproved(erc721Data, _tokenId);

    }



    function setApprovalForAll(address _to, bool _approved) public {

        ERC721Manager.setApprovalForAll(erc721Data, _to, _approved);

    }



    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {

        return ERC721Manager.isApprovedForAll(erc721Data, _owner, _operator);

    }



    function transferFrom(address _from, address _to, uint256 _tokenId) public {

        ERC721Manager.transferFrom(erc721Data, _from, _to, _tokenId);

    }



    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {

        ERC721Manager.safeTransferFrom(erc721Data, _from, _to, _tokenId);

    }



    function safeTransferFrom(

        address _from,

        address _to,

        uint256 _tokenId,

        bytes _data

    ) public {

        ERC721Manager.safeTransferFrom(erc721Data, _from, _to, _tokenId, _data);

    }





    function totalSupply() public view returns (uint256) {

        return ERC721Manager.totalSupply(erc721Data);

    }



    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId) {

        return ERC721Manager.tokenOfOwnerByIndex(erc721Data, _owner, _index);

    }



    function tokenByIndex(uint256 _index) public view returns (uint256) {

        return ERC721Manager.tokenByIndex(erc721Data, _index);

    }



    function name() external view returns (string _name) {

        return erc721Data.name_;

    }



    function symbol() external view returns (string _symbol) {

        return erc721Data.symbol_;

    }



    function tokenURI(uint256 _tokenId) public view returns (string) {

        return ERC721Manager.tokenURI(erc721Data, _tokenId);

    }





    function _mint(address _to, uint256 _tokenId) internal {

        ERC721Manager.mint(erc721Data, _to, _tokenId);

    }



    function _burn(address _owner, uint256 _tokenId) internal {

        ERC721Manager.burn(erc721Data, _owner, _tokenId);

    }



    function _setTokenURI(uint256 _tokenId, string _uri) internal {

        ERC721Manager.setTokenURI(erc721Data, _tokenId, _uri);

    }



    function isApprovedOrOwner(

        address _spender,

        uint256 _tokenId

    ) public view returns (bool) {

        return ERC721Manager.isApprovedOrOwner(erc721Data, _spender, _tokenId);

    }

}



// File: contracts/library/data/PRNG.sol



/**

 * Implementation of the xorshift128+ PRNG

 */





// File: contracts/library/data/EnumerableSetAddress.sol



/**

 * @title EnumerableSetAddress

 * @dev Library containing logic for an enumerable set of address values -- supports checking for presence, adding,

 * removing elements, and enumerating elements (without preserving order between mutable operations).

 */





// File: contracts/library/data/EnumerableSet256.sol



/**

 * @title EnumerableSet256

 * @dev Library containing logic for an enumerable set of uint256 values -- supports checking for presence, adding,

 * removing elements, and enumerating elements (without preserving order between mutable operations).

 */





// File: contracts/library/data/URIDistribution.sol



/**

 * @title URIDistribution

 * @dev Library responsible for maintaining a weighted distribution of URIs

 */





// File: contracts/library/game/GameDataLib.sol



/**

 * @title GameDataLib

 *

 * Library containing data structures and logic for game entities.

 */





// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





// File: contracts\game\Main.sol



/**

 * @title Main

 *

 * Main contract for LittleButterflies.  Implements the ERC721 EIP for Non-Fungible Tokens.

 */

contract Main is ERC721Token, Ownable {



    GameDataLib.Data internal data;



    // Set our token name and symbol

    constructor() ERC721Token("LittleButterfly", "BFLY") public {

        // initialize PRNG values

        data.seed.s0 = uint64(now);

        data.seed.s1 = uint64(msg.sender);

    }





    /** Token viewer methods **/





    /**

     * @dev Gets game information associated with a specific butterfly.

     * Requires ID to be a valid butterfly.

     *

     * @param butterflyId uint256 ID of butterfly being queried

     *

     * @return gene uint64

     * @return createdTimestamp uint64

     * @return lastTimestamp uint64

     * @return numOwners uint160

     */

    function getButterflyInfo(uint256 butterflyId) public view returns (

        uint64 gene,

        uint64 createdTimestamp,

        uint64 lastTimestamp,

        uint160 numOwners

    ) {

       (gene, createdTimestamp, lastTimestamp, numOwners) = GameDataLib.getButterflyInfo(data, butterflyId);

    }



    /**

     * @dev Returns the N-th owner associated with a butterfly.

     * Requires ID to be a valid butterfly, and owner index to be smaller than the number of owners.

     *

     * @param butterflyId uint256 ID of butterfly being queried

     * @param index uint160 Index of owner being queried

     *

     * @return address

     */

    function getButterflyOwnerByIndex(

        uint256 butterflyId,

        uint160 index

    ) external view returns (address) {

        return GameDataLib.getButterflyOwnerByIndex(data, butterflyId, index);

    }





    /**

     * @dev Gets game information associated with a specific heart.

     * Requires ID to be a valid heart.

     *

     * @param heartId uint256 ID of heart being queried

     *

     * @return butterflyId uint256

     * @return gene uint64

     * @return snapshotTimestamp uint64

     * @return numOwners uint160

     */

    function getHeartInfo(uint256 heartId) public view returns (

        uint256 butterflyId,

        uint64 gene,

        uint64 snapshotTimestamp,

        uint160 numOwners

    ) {

        (butterflyId, gene, snapshotTimestamp, numOwners) = GameDataLib.getHeartInfo(data, heartId);

    }



    /**

     * @dev Returns the N-th owner associated with a heart's snapshot.

     * Requires ID to be a valid butterfly, and owner index to be smaller than the number of owners.

     *

     * @param heartId uint256 ID of heart being queried

     * @param index uint160 Index of owner being queried

     *

     * @return address

     */

    function getHeartOwnerByIndex(

        uint256 heartId,

        uint160 index

    ) external view returns (address) {

        return GameDataLib.getHeartOwnerByIndex(data, heartId, index);

    }





    /**

     * @dev Gets game information associated with a specific flower.

     *

     * @param flowerAddress address Address of the flower being queried

     *

     * @return isClaimed bool

     * @return gene uint64

     * @return gardenTimezone uint64

     * @return createdTimestamp uint64

     * @return flowerIndex uint160

     */

    function getFlowerInfo(

        address flowerAddress

    ) external view returns (

        bool isClaimed,

        uint64 gene,

        uint64 gardenTimezone,

        uint64 createdTimestamp,

        uint160 flowerIndex

    ) {

        (isClaimed, gene, gardenTimezone, createdTimestamp, flowerIndex) = GameDataLib.getFlowerInfo(data, flowerAddress);

    }





    /**

     * @dev Determines whether the game logic allows a transfer of a butterfly to another address.

     * Conditions:

     * - The receiver address must have already claimed a butterfly

     * - The butterfly's last timestamp is within the last 24 hours

     * - The receiver address must have never claimed *this* butterfly

     *

     * @param butterflyId uint256 ID of butterfly being queried

     * @param receiver address Address of potential receiver

     */

    function canReceiveButterfly(

        uint256 butterflyId,

        address receiver

    ) external view returns (bool) {

        return GameDataLib.canReceiveButterfly(data, butterflyId, receiver, uint64(now));

    }





    /** Override token methods **/



    /**

     * @dev Override the default ERC721 transferFrom implementation in order to check game conditions and

     * generate side effects

     */

    function transferFrom(address _from, address _to, uint256 _tokenId) public {

        _setupTransferFrom(_from, _to, _tokenId, uint64(now));

        ERC721Manager.transferFrom(erc721Data, _from, _to, _tokenId);

    }



    /**

     * @dev Override the default ERC721 safeTransferFrom implementation in order to check game conditions and

     * generate side effects

     */

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {

        _setupTransferFrom(_from, _to, _tokenId, uint64(now));

        ERC721Manager.safeTransferFrom(erc721Data, _from, _to, _tokenId);

    }



    /**

     * @dev Override the default ERC721 safeTransferFrom implementation in order to check game conditions and

     * generate side effects

     */

    function safeTransferFrom(

        address _from,

        address _to,

        uint256 _tokenId,

        bytes _data

    ) public {

        _setupTransferFrom(_from, _to, _tokenId, uint64(now));

        ERC721Manager.safeTransferFrom(erc721Data, _from, _to, _tokenId, _data);

    }





    /**

    * @dev Execute before transfer, preventing token transfer in some circumstances.

    * Requirements:

    *  - Caller is owner, approved, or operator for the token

    *  - To has claimed a token before

    *  - Token is a Heart, or Token's last activity was in the last 24 hours

    *

    * @param from current owner of the token

    * @param to address to receive the ownership of the given token ID

    * @param tokenId uint256 ID of the token to be transferred

    * @param currentTimestamp uint64

    */

    function _setupTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        uint64 currentTimestamp

    ) private {

        if (data.tokenToType[tokenId] == GameDataLib.TokenType.Butterfly) {

            // try to do transfer and mint a heart

            uint256 heartId = GameDataLib.transferButterfly(data, tokenId, from, to, currentTimestamp);

            ERC721Manager.mint(erc721Data, from, heartId);

        } else {

            GameDataLib.transferHeart(data, tokenId, from, to);

        }

    }



    /**

     * @dev Overrides the default tokenURI method to lookup from the stored table of URIs -- rather than

     * storing a copy of the URI for each instance

     *

     * @param _tokenId uint256

     * @return string

     */

    function tokenURI(uint256 _tokenId) public view returns (string) {

        if (data.tokenToType[_tokenId] == GameDataLib.TokenType.Heart) {

            return GameDataLib.getHeartURI(data, _tokenId);

        }

        return GameDataLib.getButterflyURI(data, erc721Data, _tokenId, uint64(now));

    }



    /**

     * @dev Returns the URI mapped to a particular account / flower

     *

     * @param accountAddress address

     * @return string

     */

    function accountURI(address accountAddress) public view returns (string) {

        return GameDataLib.getFlowerURI(data, accountAddress);

    }



    /**

     * @dev Returns the URI mapped to account 0

     *

     * @return string

     */

    function accountZeroURI() public view returns (string) {

        return GameDataLib.getWhiteFlowerURI(data);

    }



    /**

     * @dev Returns the URI for a particular butterfly gene -- useful for seeing the butterfly "as it was"

     * when it dropped a heart

     *

     * @param gene uint64

     * @param isAlive bool

     * @return string

     */

    function getButterflyURIFromGene(uint64 gene, bool isAlive) public view returns (string) {

        return GameDataLib.getButterflyURIFromGene(data, gene, isAlive);

    }





    /** Extra token methods **/



    /**

     * @dev Claims a flower and an initial butterfly for a given address.

     * Requires address to have not claimed previously

     *

     * @param gardenTimezone uint64

     */

    function claim(uint64 gardenTimezone) external {

        address claimer = msg.sender;



        // claim a butterfly

        uint256 butterflyId = GameDataLib.claim(data, claimer, gardenTimezone, uint64(now));



        // mint its token

        ERC721Manager.mint(erc721Data, claimer, butterflyId);

    }



    /**

     * @dev Burns a token.  Caller must be owner or approved.

     *

     * @param _tokenId uint256 ID of token to burn

     */

    function burn(uint256 _tokenId) public {

        require(ERC721Manager.isApprovedOrOwner(erc721Data, msg.sender, _tokenId));



        address _owner = ERC721Manager.ownerOf(erc721Data, _tokenId);



        _setupTransferFrom(_owner, address(0x0), _tokenId, uint64(now));

        ERC721Manager.burn(erc721Data, _owner, _tokenId);

    }







    /**

     * @dev Returns the total number of tokens for a given type, owned by a specific address

     *

     * @param tokenType uint8

     * @param _owner address

     *

     * @return uint256

     */

    function typedBalanceOf(uint8 tokenType, address _owner) public view returns (uint256) {

        return GameDataLib.typedBalanceOf(data, tokenType, _owner);

    }



    /**

     * @dev Returns the total number of tokens for a given type

     *

     * @param tokenType uint8

     *

     * @return uint256

     */

    function typedTotalSupply(uint8 tokenType) public view returns (uint256) {

        return GameDataLib.typedTotalSupply(data, tokenType);

    }





    /**

     * @dev Returns the I-th token of a specific type owned by an index

     *

     * @param tokenType uint8

     * @param _owner address

     * @param _index uint256

     *

     * @return uint256

     */

    function typedTokenOfOwnerByIndex(

        uint8 tokenType,

        address _owner,

        uint256 _index

    ) external view returns (uint256) {

        return GameDataLib.typedTokenOfOwnerByIndex(data, tokenType, _owner, _index);

    }



    /**

     * @dev Returns the I-th token of a specific type

     *

     * @param tokenType uint8

     * @param _index uint256

     *

     * @return uint256

     */

    function typedTokenByIndex(

        uint8 tokenType,

        uint256 _index

    ) external view returns (uint256) {

        return GameDataLib.typedTokenByIndex(data, tokenType, _index);

    }



    /**

     * @dev Gets the total number of claimed flowers

     *

     * @return uint160

     */

    function totalFlowers() external view returns (uint160) {

        return GameDataLib.totalFlowers(data);

    }



    /**

     * @dev Gets the address of the N-th flower

     *

     * @return address

     */

    function getFlowerByIndex(uint160 index) external view returns (address) {

        return GameDataLib.getFlowerByIndex(data, index);

    }





    /** Admin setup methods */



    /*

    * Methods intended for initial contract setup, to be called at deployment.

    * Call renounceOwnership() to make the contract have no owner after setup is complete.

    */



    /**

     * @dev Registers a new flower URI with the corresponding weight

     *

     * @param weight uint16 Relative weight for the occurrence of this URI

     * @param uri string

     */

    function addFlowerURI(uint16 weight, string uri) external onlyOwner {

        GameDataLib.addFlowerURI(data, weight, uri);

    }



    /**

     * @dev Registers the flower URI for address 0

     *

     * @param uri string

     */

    function setWhiteFlowerURI(string uri) external onlyOwner {

        GameDataLib.setWhiteFlowerURI(data, uri);

    }



    /**

     * @dev Registers a new butterfly URI with the corresponding weight

     *

     * @param weight uint16 Relative weight for the occurrence of this URI

     * @param liveUri string

     * @param deadUri string

     * @param heartUri string

     */

    function addButterflyURI(uint16 weight, string liveUri, string deadUri, string heartUri) external onlyOwner {

        GameDataLib.addButterflyURI(data, weight, liveUri, deadUri, heartUri);

    }



}