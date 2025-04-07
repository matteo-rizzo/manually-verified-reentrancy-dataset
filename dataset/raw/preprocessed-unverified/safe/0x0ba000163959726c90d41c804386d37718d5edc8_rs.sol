/**

 *Submitted for verification at Etherscan.io on 2018-10-24

*/



pragma solidity ^0.4.24;







/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */









/**

 * Strings Library

 * 

 * In summary this is a simple library of string functions which make simple 

 * string operations less tedious in solidity.

 * 

 * Please be aware these functions can be quite gas heavy so use them only when

 * necessary not to clog the blockchain with expensive transactions.

 * 

 * @author James Lockhart <[email protected]>

 */







/**

 * Integers Library

 * 

 * In summary this is a simple library of integer functions which allow a simple

 * conversion to and from strings

 * 

 * @author James Lockhart <[email protected]>

 */





contract HEROES {



  using SafeMath for uint256;

  using AddressUtils for address;

  using Strings for string;

  using Integers for uint;





  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  event Lock(uint256 lockedTo, uint16 lockId);

  event LevelUp(uint32 level);





  struct Character {

    uint256 genes;



    uint256 mintedAt;

    uint256 godfather;

    uint256 mentor;



    uint32 wins;

    uint32 losses;

    uint32 level;



    uint256 lockedTo;

    uint16 lockId;

  }





  string internal constant name_ = "⚔ CRYPTOHEROES GAME ⚔";

  string internal constant symbol_ = "CRYPTOHEROES";

  string internal baseURI_;



  address internal admin;

  mapping(address => bool) internal agents;



  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;



  mapping(uint256 => address) internal tokenOwner;

  mapping(address => uint256[]) internal ownedTokens;

  mapping(uint256 => uint256) internal ownedTokensIndex;

  mapping(address => uint256) internal ownedTokensCount;



  mapping(uint256 => address) internal tokenApprovals;

  mapping(address => mapping(address => bool)) internal operatorApprovals;



  uint256[] internal allTokens;

  mapping(uint256 => uint256) internal allTokensIndex;



  Character[] characters;

  mapping(uint256 => uint256) tokenCharacters; // tokenId => characterId





  modifier onlyOwnerOf(uint256 _tokenId) {

    require(ownerOf(_tokenId) == msg.sender ||

            (ownerOf(_tokenId) == tx.origin && isAgent(msg.sender)) ||

            msg.sender == admin);

    _;

  }



  modifier canTransfer(uint256 _tokenId) {

    require(isLocked(_tokenId) &&

            (isApprovedOrOwned(msg.sender, _tokenId) ||

             (isApprovedOrOwned(tx.origin, _tokenId) && isAgent(msg.sender)) ||

             msg.sender == admin));

    _;

  }



  modifier onlyAdmin() {

    require(msg.sender == admin);

    _;

  }



  modifier onlyAgent() {

    require(isAgent(msg.sender));

    _;

  }



  /* CONTRACT METHODS */



  constructor(string _baseURI) public {

    baseURI_ = _baseURI;

    admin = msg.sender;

    addAgent(msg.sender);

  }



  function name() external pure returns (string) {

    return name_;

  }



  function symbol() external pure returns (string) {

    return symbol_;

  }



  /* METADATA METHODS */



  function setBaseURI(string _baseURI) external onlyAdmin {

    baseURI_ = _baseURI;

  }



  function tokenURI(uint256 _tokenId) public view returns (string) {

    require(exists(_tokenId));

    return baseURI_.concat(_tokenId.toString());

  }



  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {

    require(_index < balanceOf(_owner));

    return ownedTokens[_owner][_index];

  }



  function totalSupply() public view returns (uint256) {

    return allTokens.length;

  }



  /* TOKEN METHODS */



  function tokenByIndex(uint256 _index) public view returns (uint256) {

    require(_index < totalSupply());

    return allTokens[_index];

  }



  function exists(uint256 _tokenId) public view returns (bool) {

    address owner = tokenOwner[_tokenId];

    return owner != address(0);

  }



  function balanceOf(address _owner) public view returns (uint256) {

    require(_owner != address(0));

    return ownedTokensCount[_owner];

  }



  function ownerOf(uint256 _tokenId) public view returns (address) {

    address owner = tokenOwner[_tokenId];

    require(owner != address(0));

    return owner;

  }



  function approve(address _to, uint256 _tokenId) public {

    address owner = ownerOf(_tokenId);

    require(_to != owner);

    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));



    if (getApproved(_tokenId) != address(0) || _to != address(0)) {

      tokenApprovals[_tokenId] = _to;

      emit Approval(owner, _to, _tokenId);

    }

  }



  function getApproved(uint256 _tokenId) public view returns (address) {

    return tokenApprovals[_tokenId];

  }



  function setApprovalForAll(address _to, bool _approved) public {

    require(_to != msg.sender);

    operatorApprovals[msg.sender][_to] = _approved;

    emit ApprovalForAll(msg.sender, _to, _approved);

  }



  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {

    return operatorApprovals[_owner][_operator];

  }



  function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {

    require(_from != address(0));

    require(_to != address(0));



    clearApproval(_from, _tokenId);

    removeTokenFrom(_from, _tokenId);

    addTokenTo(_to, _tokenId);



    emit Transfer(_from, _to, _tokenId);

  }



  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {

    safeTransferFrom(_from, _to, _tokenId, "");

  }



  function safeTransferFrom(address _from,

                            address _to,

                            uint256 _tokenId,

                            bytes _data)

    public

    canTransfer(_tokenId)

  {

    transferFrom(_from, _to, _tokenId);

    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));

  }



  function isApprovedOrOwned(address _spender, uint256 _tokenId) internal view returns (bool) {



    address owner = ownerOf(_tokenId);



    return (_spender == owner ||

            getApproved(_tokenId) == _spender ||

            isApprovedForAll(owner, _spender));

  }



  function clearApproval(address _owner, uint256 _tokenId) internal {

    require(ownerOf(_tokenId) == _owner);

    if (tokenApprovals[_tokenId] != address(0)) {

      tokenApprovals[_tokenId] = address(0);

      emit Approval(_owner, address(0), _tokenId);

    }

  }



  function _mint(address _to, uint256 _tokenId) internal {

    require(_to != address(0));

    addTokenTo(_to, _tokenId);

    emit Transfer(address(0), _to, _tokenId);



    allTokensIndex[_tokenId] = allTokens.length;

    allTokens.push(_tokenId);

  }



  function addTokenTo(address _to, uint256 _tokenId) internal {

    require(tokenOwner[_tokenId] == address(0));

    tokenOwner[_tokenId] = _to;

    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);



    uint256 length = ownedTokens[_to].length;

    ownedTokens[_to].push(_tokenId);

    ownedTokensIndex[_tokenId] = length;

  }



  function removeTokenFrom(address _from, uint256 _tokenId) internal {

    require(ownerOf(_tokenId) == _from);

    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);

    tokenOwner[_tokenId] = address(0);



    uint256 tokenIndex = ownedTokensIndex[_tokenId];

    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);

    uint256 lastToken = ownedTokens[_from][lastTokenIndex];



    ownedTokens[_from][tokenIndex] = lastToken;

    ownedTokens[_from][lastTokenIndex] = 0;



    ownedTokens[_from].length--;

    ownedTokensIndex[_tokenId] = 0;

    ownedTokensIndex[lastToken] = tokenIndex;

  }



  function checkAndCallSafeTransfer(address _from,

                                    address _to,

                                    uint256 _tokenId,

                                    bytes _data)

    internal

    returns(bool)

  {

    return true;

  }



  /* AGENT ROLE */



  function addAgent(address _agent) public onlyAdmin {

    agents[_agent] = true;

  }



  function removeAgent(address _agent) external onlyAdmin {

    agents[_agent] = false;

  }



  function isAgent(address _agent) public view returns (bool) {

    return agents[_agent];

  }



  /* CHARACTER LOGIC */



  function getCharacter(uint256 _tokenId)

    external view returns

    (uint256 genes,

     uint256 mintedAt,

     uint256 godfather,

     uint256 mentor,

     uint32 wins,

     uint32 losses,

     uint32 level,

     uint256 lockedTo,

     uint16 lockId) {



    require(exists(_tokenId));



    Character memory c = characters[tokenCharacters[_tokenId]];



    genes = c.genes;

    mintedAt = c.mintedAt;

    godfather = c.godfather;

    mentor = c.mentor;

    wins = c.wins;

    losses = c.losses;

    level = c.level;

    lockedTo = c.lockedTo;

    lockId = c.lockId;

  }



  function addWin(uint256 _tokenId) external onlyAgent {



    require(exists(_tokenId));



    Character storage character = characters[tokenCharacters[_tokenId]];

    character.wins++;

    character.level++;



    emit LevelUp(character.level);

  }



  function addLoss(uint256 _tokenId) external onlyAgent {



    require(exists(_tokenId));



    Character storage character = characters[tokenCharacters[_tokenId]];

    character.losses++;

    if (character.level > 1) {

      character.level--;



      emit LevelUp(character.level);

    }

  }



  /* MINTING */



  function mintTo(address _to,

                  uint256 _genes,

                  uint256 _godfather,

                  uint256 _mentor,

                  uint32 _level)

    external

    onlyAgent

    returns (uint256)

  {

    uint256 newTokenId = totalSupply().add(1);

    _mint(_to, newTokenId);

    _mintCharacter(newTokenId, _genes, _godfather, _mentor, _level);



    return newTokenId;

  }



  function _mintCharacter(uint256 _tokenId,

                          uint256 _genes,

                          uint256 _godfather,

                          uint256 _mentor,

                          uint32 _level)

    internal

  {



    require(exists(_tokenId));



    Character memory character = Character({

      genes: _genes,



          mintedAt: now,

          mentor: _mentor,

          godfather: _godfather,



          wins: 0,

          losses: 0,

          level: _level,



          lockedTo: 0,

          lockId: 0

          });



    uint256 characterId = characters.push(character) - 1;

    tokenCharacters[_tokenId] = characterId;

  }



  /* LOCKS */



  function lock(uint256 _tokenId, uint256 _lockedTo, uint16 _lockId)

    external onlyAgent returns (bool) {



    require(exists(_tokenId));



    Character storage character = characters[tokenCharacters[_tokenId]];



    if (character.lockId == 0) {

      character.lockedTo = _lockedTo;

      character.lockId = _lockId;



      emit Lock(character.lockedTo, character.lockId);



      return true;

    }



    return false;

  }



  function unlock(uint256 _tokenId, uint16 _lockId)

    external onlyAgent returns (bool) {



    require(exists(_tokenId));



    Character storage character = characters[tokenCharacters[_tokenId]];



    if (character.lockId == _lockId) {

      character.lockedTo = 0;

      character.lockId = 0;



      emit Lock(character.lockedTo, character.lockId);



      return true;

    }



    return false;

  }



  function getLock(uint256 _tokenId)

    external view returns (uint256 lockedTo, uint16 lockId) {



    require(exists(_tokenId));



    lockedTo = characters[tokenCharacters[_tokenId]].lockedTo;

    lockId = characters[tokenCharacters[_tokenId]].lockId;

  }



  function isLocked(uint _tokenId) public view returns (bool) {

    require(exists(_tokenId));

    //isLocked workaround: lockedTo должен быть =1 для блокировки трансфер

    return ((characters[tokenCharacters[_tokenId]].lockedTo == 0 &&

             characters[tokenCharacters[_tokenId]].lockId != 0) ||

            now <= characters[tokenCharacters[_tokenId]].lockedTo);

  }



  function test(uint256 _x) returns (bool) {

    return now <= _x;

  }

}