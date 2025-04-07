pragma solidity ^0.4.19;




contract CryptoMyWord {
  using SafeMath for uint256;
  using strings for *;

  event Bought (uint256 indexed _itemId, address indexed _owner, uint256 _price);
  event Sold (uint256 indexed _itemId, address indexed _owner, uint256 _price);
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event NewWord(uint wordId, string name, uint price);

  address private owner;
  uint256 nameTokenId;
  uint256 tokenId;
  mapping (address => bool) private admins;
  //IItemRegistry private itemRegistry;
  bool private erc721Enabled = false;

  uint256 private increaseLimit1 = 0.8 ether;
  uint256 private increaseLimit2 = 1.5 ether;
  uint256 private increaseLimit3 = 2.0 ether;
  uint256 private increaseLimit4 = 5.0 ether;

  uint256[] private listedItems;
  mapping (uint256 => address) public ownerOfItem;
  mapping (address => string) public nameOfOwner;
  mapping (address => string) public snsOfOwner;
  mapping (uint256 => uint256) private startingPriceOfItem;
  mapping (uint256 => uint256) private priceOfItem;
  mapping (uint256 => string) private nameOfItem;
  mapping (uint256 => string) private urlOfItem;
  mapping (uint256 => address[]) private borrowerOfItem;
  mapping (string => uint256[]) private nameToItems;
  mapping (uint256 => address) private approvedOfItem;
  mapping (string => uint256) private nameToParents;
  mapping (string => uint256) private nameToNameToken;
  mapping (string => string) private firstIdOfName;
  mapping (string => string) private secondIdOfName;

  function CryptoMyWord () public {
    owner = msg.sender;
    admins[owner] = true;
  }

  struct Token {
    address firstMintedBy;
    uint64 mintedAt;
    uint256 startingPrice;
    uint256 priceOfItem;
    string name;
    string url;
    string firstIdOfName;
    string secondIdOfName;
    address owner;
  }
  Token[] public tokens;
  struct Name {
    string name;
    uint256 parent;
  }
  Name[] public names;
  /* Modifiers */
  modifier onlyOwner() {
    require(owner == msg.sender);
    _;
  }

  modifier onlyAdmins() {
    require(admins[msg.sender]);
    _;
  }

  modifier onlyERC721() {
    require(erc721Enabled);
    _;
  }

  /* Owner */
  function setOwner (address _owner) onlyOwner() public {
    owner = _owner;
  }

  function getOwner () view public returns(address) {
    return owner;
  }

  function addAdmin (address _admin) onlyOwner() public {
    admins[_admin] = true;
  }

  function removeAdmin (address _admin) onlyOwner() public {
    delete admins[_admin];
  }

  // Unlocks ERC721 behaviour, allowing for trading on third party platforms.
  function enableERC721 () onlyOwner() public {
    erc721Enabled = true;
  }

  // locks ERC721 behaviour, allowing for trading on third party platforms.
  function disableERC721 () onlyOwner() public {
    erc721Enabled = false;
  }

  /* Withdraw */
  /*
    NOTICE: These functions withdraw the developer's cut which is left
    in the contract by `buy`. User funds are immediately sent to the old
    owner in `buy`, no user funds are left in the contract.
  */
  function withdrawAll () onlyOwner() public {
    owner.transfer(this.balance);
  }

  function withdrawAmount (uint256 _amount) onlyOwner() public {
    owner.transfer(_amount);
  }


  function listItem (uint256 _price, address _owner, string _name) onlyAdmins() public {
    require(nameToItems[_name].length == 0);
    Token memory token = Token({
      firstMintedBy: _owner,
      mintedAt: uint64(now),
      startingPrice: _price,
      priceOfItem: _price,
      name: _name,
      url: "",
      firstIdOfName: "",
      secondIdOfName: "",
      owner: _owner
    });
    tokenId = tokens.push(token) - 1;
    Name memory namesval = Name({
      name: _name,
      parent: tokenId
    });
    ownerOfItem[tokenId] = _owner;
    priceOfItem[tokenId] = _price;
    startingPriceOfItem[tokenId] = _price;
    nameOfItem[tokenId] = _name;
    nameToItems[_name].push(tokenId);
    listedItems.push(tokenId);
    nameToParents[_name] = tokenId;
    nameTokenId = names.push(namesval) - 1;
    nameToNameToken[_name] = nameTokenId;
  }

  function _mint (uint256 _price, address _owner, string _name, string _url) internal {
    address firstOwner = _owner;
    if(nameToItems[_name].length != 0){
      firstOwner = ownerOf(nameToParents[_name]);
      if(admins[firstOwner]){
        firstOwner = _owner;
      }
    }
    Token memory token = Token({
      firstMintedBy: firstOwner,
      mintedAt: uint64(now),
      startingPrice: _price,
      priceOfItem: _price,
      name: _name,
      url: "",
      firstIdOfName: "",
      secondIdOfName: "",
      owner: _owner
    });
    tokenId = tokens.push(token) - 1;
    Name memory namesval = Name({
      name: _name,
      parent: tokenId
    });
    if(nameToItems[_name].length != 0){
      names[nameToNameToken[_name]] = namesval;
    }
    ownerOfItem[tokenId] = _owner;
    priceOfItem[tokenId] = _price;
    startingPriceOfItem[tokenId] = _price;
    nameOfItem[tokenId] = _name;
    urlOfItem[tokenId] = _url;
    nameToItems[_name].push(tokenId);
    listedItems.push(tokenId);
    nameToParents[_name] = tokenId;
  }

  function composite (uint256 _firstId, uint256 _secondId, uint8 _space) public {
    int counter1 = 0;
    for (uint i = 0; i < borrowerOfItem[_firstId].length; i++) {
      if (borrowerOfItem[_firstId][i] == msg.sender) {
        counter1++;
      }
    }
    int counter2 = 0;
    for (uint i2 = 0; i2 < borrowerOfItem[_secondId].length; i2++) {
      if (borrowerOfItem[_secondId][i2] == msg.sender) {
        counter2++;
      }
    }
    require(ownerOfItem[_firstId] == msg.sender || counter1 > 0);
    require(ownerOfItem[_secondId] == msg.sender || counter2 > 0);
    string memory compositedName1 = nameOfItem[_firstId];
    string memory space = " ";
    if(_space > 0){
      compositedName1 = nameOfItem[_firstId].toSlice().concat(space.toSlice());
    }
    string memory compositedName = compositedName1.toSlice().concat(nameOfItem[_secondId].toSlice());
    require(nameToItems[compositedName].length == 0);
    firstIdOfName[compositedName] = nameOfItem[_firstId];
    secondIdOfName[compositedName] = nameOfItem[_secondId];
    _mint(0.01 ether, msg.sender, compositedName, "");
  }

  function setUrl (uint256 _tokenId, string _url) public {
    require(ownerOf(_tokenId) == msg.sender);
    tokens[_tokenId].url = _url;
  }

  /* Buying */
  function calculateNextPrice (uint256 _price) public view returns (uint256 _nextPrice) {
    if (_price < increaseLimit1) {
      return _price.mul(200).div(95); // 1.95
    } else if (_price < increaseLimit2) {
      return _price.mul(135).div(95); //1.3
    } else if (_price < increaseLimit3) {
      return _price.mul(125).div(95); //1.2
    } else if (_price < increaseLimit4) {
      return _price.mul(120).div(95); //1.12
    } else {
      return _price.mul(115).div(95); //1.1
    }
  }

  function calculateDevCut (uint256 _price) public pure returns (uint256 _devCut) {
    return _price.mul(4).div(100);
  }
  function calculateFirstCut (uint256 _price) public pure returns (uint256 _firstCut) {
    return _price.mul(1).div(100);
  }
  function ceil(uint a) public pure returns (uint ) {
    return uint(int(a * 100) / 100);
  }
  /*
     Buy a country directly from the contract for the calculated price
     which ensures that the owner gets a profit.  All countries that
     have been listed can be bought by this method. User funds are sent
     directly to the previous owner and are never stored in the contract.
  */
  function buy (uint256 _itemId) payable public {
    require(priceOf(_itemId) > 0);
    require(ownerOf(_itemId) != address(0));
    require(msg.value >= priceOf(_itemId));
    require(ownerOf(_itemId) != msg.sender);
    require(!isContract(msg.sender));
    require(msg.sender != address(0));
    address firstOwner = tokens[_itemId].firstMintedBy;
    address oldOwner = ownerOf(_itemId);
    address newOwner = msg.sender;
    uint256 price = ceil(priceOf(_itemId));
    uint256 excess = msg.value.sub(price);
    string memory name = nameOf(_itemId);
    uint256 nextPrice = ceil(nextPriceOf(_itemId));
    //_transfer(oldOwner, newOwner, _itemId);
    _mint(nextPrice, newOwner, name, "");
    priceOfItem[_itemId] = nextPrice;

    Bought(_itemId, newOwner, price);
    Sold(_itemId, oldOwner, price);

    // Devevloper's cut which is left in contract and accesed by
    // `withdrawAll` and `withdrawAmountTo` methods.
    uint256 devCut = ceil(calculateDevCut(price));
    uint256 firstCut = ceil(calculateFirstCut(price));
    // Transfer payment to old owner minus the developer's cut.
    oldOwner.transfer(price.sub(devCut));
    firstOwner.transfer(price.sub(firstCut));
    if (excess > 0) {
      newOwner.transfer(excess);
    }
  }

  /* ERC721 */
  function implementsERC721() public view returns (bool _implements) {
    return erc721Enabled;
  }

  function name() public pure returns (string _name) {
    return "CryptoMyWord";
  }

  function symbol() public pure returns (string _symbol) {
    return "CMW";
  }

  function totalSupply() public view returns (uint256 _totalSupply) {
    return listedItems.length;
  }

  function balanceOf (address _owner) public view returns (uint256 _balance) {
    uint256 counter = 0;

    for (uint256 i = 0; i < listedItems.length; i++) {
      if (ownerOf(listedItems[i]) == _owner) {
        counter++;
      }
    }

    return counter;
  }

  function ownerOf (uint256 _itemId) public view returns (address _owner) {
    return ownerOfItem[_itemId];
  }

  function tokensOf (address _owner) external view returns (uint256[] _tokenIds) {
    uint256[] memory result = new uint256[](balanceOf(_owner));

    uint256 itemCounter = 0;
    for (uint256 i = 0; i < tokens.length; i++) {
      if (ownerOfItem[i] == _owner) {
        result[itemCounter] = i;
        itemCounter++;
      }
    }

    return result;
  }

  function getNames () external view returns (uint256[] _tokenIds){
    uint256[] memory result = new uint256[](names.length);
    uint256 itemCounter = 0;
    for (uint i = 0; i < names.length; i++) {
      result[itemCounter] = nameToNameToken[names[itemCounter].name];
      itemCounter++;
    }
    return result;
  }

  function tokenExists (uint256 _itemId) public view returns (bool _exists) {
    return priceOf(_itemId) > 0;
  }

  function approvedFor(uint256 _itemId) public view returns (address _approved) {
    return approvedOfItem[_itemId];
  }

  function approve(address _to, uint256 _itemId) onlyERC721() public {
    require(msg.sender != _to);
    require(tokenExists(_itemId));
    require(ownerOf(_itemId) == msg.sender);

    if (_to == 0) {
      if (approvedOfItem[_itemId] != 0) {
        delete approvedOfItem[_itemId];
        Approval(msg.sender, 0, _itemId);
      }
    } else {
      approvedOfItem[_itemId] = _to;
      Approval(msg.sender, _to, _itemId);
    }
  }

  /* Transferring a country to another owner will entitle the new owner the profits from `buy` */
  function transfer(address _to, uint256 _itemId) onlyERC721() public {
    require(msg.sender == ownerOf(_itemId));
    _transfer(msg.sender, _to, _itemId);
  }

  function transferFrom(address _from, address _to, uint256 _itemId) onlyERC721() public {
    require(approvedFor(_itemId) == msg.sender);
    _transfer(_from, _to, _itemId);
  }

  function _transfer(address _from, address _to, uint256 _itemId) internal {
    require(tokenExists(_itemId));
    require(ownerOf(_itemId) == _from);
    require(_to != address(0));
    require(_to != address(this));

    ownerOfItem[_itemId] = _to;
    approvedOfItem[_itemId] = 0;

    Transfer(_from, _to, _itemId);
  }

  /* Read */
  function isAdmin (address _admin) public view returns (bool _isAdmin) {
    return admins[_admin];
  }

  function startingPriceOf (uint256 _itemId) public view returns (uint256 _startingPrice) {
    return startingPriceOfItem[_itemId];
  }

  function priceOf (uint256 _itemId) public view returns (uint256 _price) {
    return priceOfItem[_itemId];
  }

  function nextPriceOf (uint256 _itemId) public view returns (uint256 _nextPrice) {
    return calculateNextPrice(priceOf(_itemId));
  }

  function nameOf (uint256 _itemId) public view returns (string _name) {
    return nameOfItem[_itemId];
  }

  function itemsByName (string _name) public view returns (uint256[] _items){
    return nameToItems[_name];
  }

  function allOf (uint256 _itemId) external view returns (address _owner, uint256 _startingPrice, uint256 _price, uint256 _nextPrice) {
    return (ownerOf(_itemId), startingPriceOf(_itemId), priceOf(_itemId), nextPriceOf(_itemId));
  }

  function allForPopulate (uint256 _itemId) onlyOwner() external view returns (address _owner, uint256 _startingPrice, uint256 _price, uint256 _nextPrice) {
    return (ownerOf(_itemId), startingPriceOf(_itemId), priceOf(_itemId), nextPriceOf(_itemId));
  }

  function selfDestruct () onlyOwner() public{
    selfdestruct(owner);
  }

  function itemsForSaleLimit (uint256 _from, uint256 _take) public view returns (uint256[] _items) {
    uint256[] memory items = new uint256[](_take);

    for (uint256 i = 0; i < _take; i++) {
      items[i] = listedItems[_from + i];
    }

    return items;
  }

  /* Util */
  function isContract(address addr) internal view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) } // solium-disable-line
    return size > 0;
  }
}