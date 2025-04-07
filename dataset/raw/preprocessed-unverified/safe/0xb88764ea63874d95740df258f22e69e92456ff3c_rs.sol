pragma solidity ^0.4.18;

contract NFT {
  function totalSupply() constant returns (uint);
  function balanceOf(address) constant returns (uint);

  function tokenOfOwnerByIndex(address owner, uint index) constant returns (uint);
  function ownerOf(uint tokenId) constant returns (address);

  function transfer(address to, uint tokenId);
  function takeOwnership(uint tokenId);
  function transferFrom(address from, address to, uint tokenId);
  function approve(address beneficiary, uint tokenId);

  function metadata(uint tokenId) constant returns (string);
}

contract NFTEvents {
  event Created(uint tokenId, address owner, string metadata);
  event Destroyed(uint tokenId, address owner);

  event Transferred(uint tokenId, address from, address to);
  event Approval(address owner, address beneficiary, uint tokenId);

  event MetadataUpdated(uint tokenId, address owner, string data);
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */







contract BasicNFT is NFT, NFTEvents {

  uint public totalTokens;

  // Array of owned tokens for a user
  mapping(address => uint[]) public ownedTokens;
  mapping(address => uint) _virtualLength;
  mapping(uint => uint) _tokenIndexInOwnerArray;

  // Mapping from token ID to owner
  mapping(uint => address) public tokenOwner;

  // Allowed transfers for a token (only one at a time)
  mapping(uint => address) public allowedTransfer;

  // Metadata associated with each token
  mapping(uint => string) public _tokenMetadata;

  function totalSupply() public constant returns (uint) {
    return totalTokens;
  }

  function balanceOf(address owner) public constant returns (uint) {
    return _virtualLength[owner];
  }

  function tokenOfOwnerByIndex(address owner, uint index) public constant returns (uint) {
    require(index >= 0 && index < balanceOf(owner));
    return ownedTokens[owner][index];
  }

  function getAllTokens(address owner) public constant returns (uint[]) {
    uint size = _virtualLength[owner];
    uint[] memory result = new uint[](size);
    for (uint i = 0; i < size; i++) {
      result[i] = ownedTokens[owner][i];
    }
    return result;
  }

  function ownerOf(uint tokenId) public constant returns (address) {
    return tokenOwner[tokenId];
  }

  function transfer(address to, uint tokenId) public {
    require(tokenOwner[tokenId] == msg.sender || allowedTransfer[tokenId] == msg.sender);
    return _transfer(tokenOwner[tokenId], to, tokenId);
  }

  function takeOwnership(uint tokenId) public {
    require(allowedTransfer[tokenId] == msg.sender);
    return _transfer(tokenOwner[tokenId], msg.sender, tokenId);
  }

  function transferFrom(address from, address to, uint tokenId) public {
    require(allowedTransfer[tokenId] == msg.sender);
    return _transfer(tokenOwner[tokenId], to, tokenId);
  }

  function approve(address beneficiary, uint tokenId) public {
    require(msg.sender == tokenOwner[tokenId]);

    if (allowedTransfer[tokenId] != 0) {
      allowedTransfer[tokenId] = 0;
    }
    allowedTransfer[tokenId] = beneficiary;
    Approval(tokenOwner[tokenId], beneficiary, tokenId);
  }

  function tokenMetadata(uint tokenId) constant public returns (string) {
    return _tokenMetadata[tokenId];
  }

  function metadata(uint tokenId) constant public returns (string) {
    return _tokenMetadata[tokenId];
  }

  function updateTokenMetadata(uint tokenId, string _metadata) public {
    require(msg.sender == tokenOwner[tokenId]);
    _tokenMetadata[tokenId] = _metadata;
    MetadataUpdated(tokenId, msg.sender, _metadata);
  }

  function _transfer(address from, address to, uint tokenId) internal {
    _clearApproval(tokenId);
    _removeTokenFrom(from, tokenId);
    _addTokenTo(to, tokenId);
    Transferred(tokenId, from, to);
  }

  function _clearApproval(uint tokenId) internal {
    allowedTransfer[tokenId] = 0;
    Approval(tokenOwner[tokenId], 0, tokenId);
  }

  function _removeTokenFrom(address from, uint tokenId) internal {
    require(_virtualLength[from] > 0);

    uint length = _virtualLength[from];
    uint index = _tokenIndexInOwnerArray[tokenId];
    uint swapToken = ownedTokens[from][length - 1];

    ownedTokens[from][index] = swapToken;
    _tokenIndexInOwnerArray[swapToken] = index;
    _virtualLength[from]--;
  }

  function _addTokenTo(address owner, uint tokenId) internal {
    if (ownedTokens[owner].length == _virtualLength[owner]) {
      ownedTokens[owner].push(tokenId);
    } else {
      ownedTokens[owner][_virtualLength[owner]] = tokenId;
    }
    tokenOwner[tokenId] = owner;
    _tokenIndexInOwnerArray[tokenId] = _virtualLength[owner];
    _virtualLength[owner]++;
  }
}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract GAZUAToken is Ownable, BasicNFT {
    string public name = "Gazua";
    string public symbol = "GAZ";
    uint public limitation = 300;

    mapping (uint => string) public _message; //Personal Message;

    event MessageUpdated(uint tokenId, address owner, string data);

    using SafeMath for uint;

    function generateToken(address beneficiary, uint tokenId, string _metadata, string _personalMessage) public onlyOwner {
        require(tokenOwner[tokenId] == 0);
        require(totalSupply() <= limitation);
        _generateToken(beneficiary, tokenId, _metadata, _personalMessage);
    }

    function _generateToken(address beneficiary, uint tokenId, string _metadata, string _personalMessage) internal {
        _addTokenTo(beneficiary, tokenId);
        totalTokens++;
        _tokenMetadata[tokenId] = _metadata;
        _message[tokenId] = _personalMessage;
        Created(tokenId, beneficiary, _metadata);
    }

    // no one can update metadata
    function updateTokenMetadata(uint tokenId, string _metadata) public {
         throw; 
    }

    function addLimitation(uint _quantity) public onlyOwner returns (bool) {
        limitation = limitation.add(_quantity);
        return true;
    }

    function updateMessage(uint _tokenId, string _personalMessage) {
        require(tokenOwner[_tokenId] == msg.sender);
        _message[_tokenId] = _personalMessage;
        MessageUpdated(_tokenId, msg.sender, _personalMessage);
    }

    function getMessage(uint _tokenId) public constant returns (string) {
        return _message[_tokenId];
    }

}