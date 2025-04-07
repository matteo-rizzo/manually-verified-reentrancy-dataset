pragma solidity ^0.4.18;

/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="49283b282a2127202d0927263d2d263d67272c3d">[email&#160;protected]</a>>
 *
 * @dev Functionality in this library is largely implemented using an
 *      abstraction called a &#39;slice&#39;. A slice represents a part of a string -
 *      anything from the entire string to a single character, or even no
 *      characters at all (a 0-length slice). Since a slice only has to specify
 *      an offset and a length, copying and manipulating slices is a lot less
 *      expensive than copying and manipulating the strings they reference.
 *
 *      To further reduce gas costs, most functions on slice that need to return
 *      a slice modify the original one instead of allocating a new one; for
 *      instance, `s.split(".")` will return the text up to the first &#39;.&#39;,
 *      modifying s to only contain the remainder of the string after the &#39;.&#39;.
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
 *      `s.splitNew(&#39;.&#39;)` leaves s unmodified, and returns two values
 *      corresponding to the left and right parts of the string.
 */
 




/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5135342534113029383e3c2b343f7f323e">[email&#160;protected]</a>> (https://github.com/dete)
contract ERC721 {
  // Required methods
  function approve(address _to, uint256 _tokenId) public;
  function balanceOf(address _owner) public view returns (uint256 balance);
  function implementsERC721() public pure returns (bool);
  function ownerOf(uint256 _tokenId) public view returns (address addr);
  function takeOwnership(uint256 _tokenId) public;
  function totalSupply() public view returns (uint256 total);
  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function transfer(address _to, uint256 _tokenId) public;

  event Transfer(address indexed from, address indexed to, uint256 tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 tokenId);

  // Optional
  // function name() public view returns (string name);
  // function symbol() public view returns (string symbol);
  // function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 tokenId);
  // function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl);
}

contract ERC20 {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);

  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20 {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender&#39;s allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract MutableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount, uint256 balance, uint256 totalSupply);
  event Burn(address indexed burner, uint256 value, uint256 balance, uint256 totalSupply);

  address master;

  function setContractMaster(address _newMaster) onlyOwner public {
    require(_newMaster != address(0));
    require(EmojiToken(_newMaster).isEmoji());
    master = _newMaster;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) public returns (bool) {
    require(master == msg.sender);
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount, balances[_to], totalSupply_);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value, address _owner) public {
    require(master == msg.sender);
    require(_value <= balances[_owner]);
    // no need to require value <= totalSupply, since that would imply the
    // sender&#39;s balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = _owner;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(burner, _value, balances[burner], totalSupply_);
  }

}

/* Base contract for ERC-20 Craft Token Collectibles. 
 * @title Crypto Emoji - #Emojinomics
 * @author Fazri Zubair & Farhan Khwaja (Lucid Sight, Inc.)
 */
contract CraftToken is MutableToken {
  string public name;
  string public symbol;
  uint8 public decimals;

  function CraftToken(string emoji, string symb) public {
    require(EmojiToken(msg.sender).isEmoji());
    master = msg.sender;
    name = emoji;
    symbol = symb;
    decimals = 8;
  }
}


/* Base contract for ERC-721 Emoji Token Collectibles. 
 * @title Crypto Emoji - #Emojinomics
 * @author Fazri Zubair & Farhan Khwaja (Lucid Sight, Inc.)
 */
contract EmojiToken is ERC721 {
  using strings for *;

  /*** EVENTS ***/
  event Birth(uint256 tokenId, string name, address owner);

  event TokenSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string name);

  event Transfer(address from, address to, uint256 tokenId);

  event EmojiMessageUpdated(address from, uint256 tokenId, string message);

  event TokenBurnt(uint256 tokenId, address master);

  /*** CONSTANTS ***/

  /// @notice Name and symbol of the non fungible token, as defined in ERC721.
  string public constant NAME = "CryptoEmoji";
  string public constant SYMBOL = "CE";

  uint256 private constant PROMO_CREATION_LIMIT = 1000;

  uint256 private startingPrice = 0.001 ether;
  uint256 private firstStepLimit =  0.063 ether;
  uint256 private secondStepLimit = 0.52 ether;

  //5% to contract
  uint256 ownerCut = 5;

  bool ownerCutIsLocked;

  //One Craft token 1 has 8 decimals
  uint256 oneCraftToken = 100000000;

  /*** STORAGE ***/

  /// @dev A mapping from EMOJI IDs to the address that owns them. All emojis must have
  ///  some valid owner address.
  mapping (uint256 => address) public emojiIndexToOwner;

  // @dev A mapping from owner address to count of tokens that address owns.
  //  Used internally inside balanceOf() to resolve ownership count.
  mapping (address => uint256) private ownershipTokenCount;

  /// @dev A mapping from Emojis to an address that has been approved to call
  ///  transferFrom(). Each Emoji can only have one approved address for transfer
  ///  at any time. A zero value means no approval is outstanding.
  mapping (uint256 => address) public emojiIndexToApproved;

  // @dev A mapping from emojis to the price of the token.
  mapping (uint256 => uint256) private emojiIndexToPrice;

  // @dev A mapping from emojis in existence 
  mapping (string => bool) private emojiCreated;

  mapping (uint256 => address) private emojiCraftTokenAddress;

  // The addresses of the accounts (or contracts) that can execute actions within each roles.
  address public ceoAddress;
  address public cooAddress;

  uint256 public promoCreatedCount;

  /*** DATATYPES ***/
  struct Emoji {
    string name;
    string msg;
  }

  struct MemoryHolder {
    mapping(uint256 => uint256) bal;
    mapping(uint256 => uint256) used;
  }


  Emoji[] private emojis;

  /*** ACCESS MODIFIERS ***/
  /// @dev Access modifier for CEO-only functionality
  modifier onlyCEO() {
    require(msg.sender == ceoAddress);
    _;
  }

  /// @dev Access modifier for COO-only functionality
  modifier onlyCOO() {
    require(msg.sender == cooAddress);
    _;
  }
  
  /// Access modifier for contract owner only functionality
  modifier onlyCLevel() {
    require(
      msg.sender == ceoAddress ||
      msg.sender == cooAddress
    );
    _;
  }
  
  /*** CONSTRUCTOR ***/
  function EmojiToken() public {
    ceoAddress = msg.sender;
    cooAddress = msg.sender;
  }

  function isEmoji() public returns (bool) {
    return true;
  }

  /// @notice Here for bug related migration
  function migrateCraftTokenMaster(uint tokenId, address newMasterContract) public onlyCLevel {
    CraftToken(emojiCraftTokenAddress[tokenId]).setContractMaster(newMasterContract);
  }

  /*** PUBLIC FUNCTIONS ***/
  /// @notice Grant another address the right to transfer token via takeOwnership() and transferFrom().
  /// @param _to The address to be granted transfer approval. Pass address(0) to
  ///  clear all approvals.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function approve(
    address _to,
    uint256 _tokenId
  ) public {
    // Caller must own token.
    require(_owns(msg.sender, _tokenId));

    emojiIndexToApproved[_tokenId] = _to;

    Approval(msg.sender, _to, _tokenId);
  }

  /// For querying balance of a particular account
  /// @param _owner The address for balance query
  /// @dev Required for ERC-721 compliance.
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return ownershipTokenCount[_owner];
  }

  
  /// @dev Creates a new promo Emoji with the given name, with given _price and assignes it to an address.
  function createPromoEmoji(address _owner, string _name, string _symb, uint256 _price) public onlyCLevel {
    require(promoCreatedCount < PROMO_CREATION_LIMIT);

    address emojiOwner = _owner;
    if (emojiOwner == address(0)) {
      emojiOwner = cooAddress;
    }

    if (_price <= 0) {
      _price = startingPrice;
    }

    promoCreatedCount++;

    uint256 indx = _createEmoji(_name, emojiOwner, _price);
    //Creates token contract
    emojiCraftTokenAddress[indx] = new CraftToken(_name, _symb);
  }

  /// @dev Creates a new Emoji with the given name.
  function createBaseEmoji(string _name, string _symb) public onlyCLevel {
    uint256 indx = _createEmoji(_name, address(this), startingPrice);
    //Creates token contract
    emojiCraftTokenAddress[indx] = new CraftToken(_name, _symb);
  }

  function createEmojiStory(uint[] _parts) public {
    MemoryHolder storage memD;

    string memory mashUp = "";
    uint price;

    for(uint i = 0; i < _parts.length; i++) {

      if(memD.bal[_parts[i]] == 0) {
        memD.bal[_parts[i]] = CraftToken(emojiCraftTokenAddress[_parts[i]]).balanceOf(msg.sender);
      }
      memD.used[_parts[i]]++;

      require(CraftToken(emojiCraftTokenAddress[_parts[i]]).balanceOf(msg.sender) >= memD.used[_parts[i]]);

      price += emojiIndexToPrice[_parts[i]];
      mashUp = mashUp.toSlice().concat(emojis[_parts[i]].name.toSlice()); 
    }
      
    //Creates Mash Up
    _createEmoji(mashUp,msg.sender,price);

    //BURN
    for(uint iii = 0; iii < _parts.length; iii++) {
      CraftToken(emojiCraftTokenAddress[_parts[iii]]).burn(oneCraftToken, msg.sender);
      TokenBurnt(_parts[iii], emojiCraftTokenAddress[_parts[iii]]);
    }
    
  }

   /// @notice Returns all the relevant information about a specific emoji.
  /// @param _tokenId The tokenId of the emoji of interest.
  function getCraftTokenAddress(uint256 _tokenId) public view returns (
    address masterErc20
  ) {
    masterErc20 = emojiCraftTokenAddress[_tokenId];
  }

  /// @notice Returns all the relevant information about a specific emoji.
  /// @param _tokenId The tokenId of the emoji of interest.
  function getEmoji(uint256 _tokenId) public view returns (
    string emojiName,
    string emojiMsg,
    uint256 sellingPrice,
    address owner
  ) {
    Emoji storage emojiObj = emojis[_tokenId];
    emojiName = emojiObj.name;
    emojiMsg = emojiObj.msg;
    sellingPrice = emojiIndexToPrice[_tokenId];
    owner = emojiIndexToOwner[_tokenId];
  }

  function implementsERC721() public pure returns (bool) {
    return true;
  }

  /// @dev Required for ERC-721 compliance.
  function name() public pure returns (string) {
    return NAME;
  }

  /// For querying owner of token
  /// @param _tokenId The tokenID for owner inquiry
  /// @dev Required for ERC-721 compliance.
  function ownerOf(uint256 _tokenId)
    public
    view
    returns (address owner)
  {
    owner = emojiIndexToOwner[_tokenId];
    require(owner != address(0));
  }

  function payout(address _to) public onlyCLevel {
    _payout(_to);
  }

  // Allows someone to send ether and obtain the token
  function purchase(uint256 _tokenId) public payable {
    address oldOwner = emojiIndexToOwner[_tokenId];
    uint sellingPrice = emojiIndexToPrice[_tokenId];
    address newOwner = msg.sender;

    // Making sure token owner is not sending to self
    require(oldOwner != newOwner);

    // Safety check to prevent against an unexpected 0x0 default.
    require(_addressNotNull(newOwner));

    // Making sure sent amount is greater than or equal to the sellingPrice
    require(msg.value >= sellingPrice);

    uint256 percentage = SafeMath.sub(100, ownerCut);
    uint256 payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, percentage), 100));
    uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);

    // Update prices
    if (sellingPrice < firstStepLimit) {
      // first stage
      emojiIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 200), percentage);
    } else if (sellingPrice < secondStepLimit) {
      // second stage
      emojiIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 130), percentage);
    } else {
      // third stage
      emojiIndexToPrice[_tokenId] = SafeMath.div(SafeMath.mul(sellingPrice, 115), percentage);
    }

    _transfer(oldOwner, newOwner, _tokenId);

    // Pay previous tokenOwner if owner is not contract
    if (oldOwner != address(this)) {
      oldOwner.transfer(payment); //(1-0.06)
    }

    TokenSold(_tokenId, sellingPrice, emojiIndexToPrice[_tokenId], oldOwner, newOwner, emojis[_tokenId].name);

    msg.sender.transfer(purchaseExcess);

    //if Non-Story
    if(emojiCraftTokenAddress[_tokenId] != address(0)) {
      CraftToken(emojiCraftTokenAddress[_tokenId]).mint(oldOwner,oneCraftToken);
      CraftToken(emojiCraftTokenAddress[_tokenId]).mint(msg.sender,oneCraftToken);
    }
    
  }

  function transferTokenToCEO(uint256 _tokenId, uint qty) public onlyCLevel {
    CraftToken(emojiCraftTokenAddress[_tokenId]).transfer(ceoAddress,qty);
  }

  function priceOf(uint256 _tokenId) public view returns (uint256 price) {
    return emojiIndexToPrice[_tokenId];
  }

  /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
  /// @param _newCEO The address of the new CEO
  function setCEO(address _newCEO) public onlyCEO {
    require(_newCEO != address(0));

    ceoAddress = _newCEO;
  }

  /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
  /// @param _newCOO The address of the new COO
  function setCOO(address _newCOO) public onlyCOO {
    require(_newCOO != address(0));

    cooAddress = _newCOO;
  }

  /// @dev Required for ERC-721 compliance.
  function symbol() public pure returns (string) {
    return SYMBOL;
  }

  /// @notice Allow pre-approved user to take ownership of a token
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function takeOwnership(uint256 _tokenId) public {
    address newOwner = msg.sender;
    address oldOwner = emojiIndexToOwner[_tokenId];

    // Safety check to prevent against an unexpected 0x0 default.
    require(_addressNotNull(newOwner));

    // Making sure transfer is approved
    require(_approved(newOwner, _tokenId));

    _transfer(oldOwner, newOwner, _tokenId);
  }

  function setEmojiMsg(uint256 _tokenId, string message) public {
    require(_owns(msg.sender, _tokenId));
    Emoji storage item = emojis[_tokenId];
    item.msg = bytes32ToString(stringToBytes32(message));

    EmojiMessageUpdated(msg.sender, _tokenId, item.msg);
  }

  function stringToBytes32(string memory source) internal returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(source, 32))
        }
    }

  function bytes32ToString(bytes32 x) constant internal returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

  /// @param _owner The owner whose emoji tokens we are interested in.
  /// @dev This method MUST NEVER be called by smart contract code. First, it&#39;s fairly
  ///  expensive (it walks the entire Emojis array looking for emojis belonging to owner),
  ///  but it also returns a dynamic array, which is only supported for web3 calls, and
  ///  not contract-to-contract calls.
  function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {
    uint256 tokenCount = balanceOf(_owner);
    if (tokenCount == 0) {
        // Return an empty array
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](tokenCount);
      uint256 totalEmojis = totalSupply();
      uint256 resultIndex = 0;

      uint256 emojiId;
      for (emojiId = 0; emojiId <= totalEmojis; emojiId++) {
        if (emojiIndexToOwner[emojiId] == _owner) {
          result[resultIndex] = emojiId;
          resultIndex++;
        }
      }
      return result;
    }
  }

  /// For querying totalSupply of token
  /// @dev Required for ERC-721 compliance.
  function totalSupply() public view returns (uint256 total) {
    return emojis.length;
  }

  /// Owner initates the transfer of the token to another account
  /// @param _to The address for the token to be transferred to.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function transfer(
    address _to,
    uint256 _tokenId
  ) public {
    require(_owns(msg.sender, _tokenId));
    require(_addressNotNull(_to));

    _transfer(msg.sender, _to, _tokenId);
  }

  /// Third-party initiates transfer of token from address _from to address _to
  /// @param _from The address for the token to be transferred from.
  /// @param _to The address for the token to be transferred to.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) public {
    require(_owns(_from, _tokenId));
    require(_approved(_to, _tokenId));
    require(_addressNotNull(_to));

    _transfer(_from, _to, _tokenId);
  }

  /*** PRIVATE FUNCTIONS ***/
  /// Safety check on _to address to prevent against an unexpected 0x0 default.
  function _addressNotNull(address _to) private pure returns (bool) {
    return _to != address(0);
  }

  /// For checking approval of transfer for address _to
  function _approved(address _to, uint256 _tokenId) private view returns (bool) {
    return emojiIndexToApproved[_tokenId] == _to;
  }

  /// For creating Emoji
  function _createEmoji(string _name, address _owner, uint256 _price) private returns(uint256) {
    require(emojiCreated[_name] == false);
    Emoji memory _emoji = Emoji({
      name: _name,
      msg: "&#128165;New&#128165;"
    });
    uint256 newEmojiId = emojis.push(_emoji) - 1;

    // It&#39;s probably never going to happen, 4 billion tokens are A LOT, but
    // let&#39;s just be 100% sure we never let this happen.
    require(newEmojiId == uint256(uint32(newEmojiId)));

    Birth(newEmojiId, _name, _owner);

    emojiIndexToPrice[newEmojiId] = _price;

    // This will assign ownership, and also emit the Transfer event as
    // per ERC721 draft
    _transfer(address(0), _owner, newEmojiId);
    emojiCreated[_name] = true;

    return newEmojiId;
  }

  /// Check for token ownership
  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {
    return claimant == emojiIndexToOwner[_tokenId];
  }

  /// For paying out balance on contract
  function _payout(address _to) private {
    if (_to == address(0)) {
      ceoAddress.transfer(this.balance);
    }
  }

  /// @dev Assigns ownership of a specific Emoji to an address.
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    // Since the number of emojis is capped to 2^32 we can&#39;t overflow this
    ownershipTokenCount[_to]++;
    //transfer ownership
    emojiIndexToOwner[_tokenId] = _to;

    // When creating new emojis _from is 0x0, but we can&#39;t account that address.
    if (_from != address(0)) {
      ownershipTokenCount[_from]--;
      // clear any previously approved ownership exchange
      delete emojiIndexToApproved[_tokenId];
    }

    // Emit the transfer event.
    Transfer(_from, _to, _tokenId);
  }

  /// @dev Updates ownerCut
  function updateOwnerCut(uint256 _newCut) external onlyCLevel{
    require(ownerCut <= 9);
    require(ownerCutIsLocked == false);
    ownerCut = _newCut;
  }

  /// @dev Lock ownerCut
  function lockOwnerCut(uint confirmCode) external onlyCLevel{
    /// Not a secert just to make sure we don&#39;t accidentally submit this function
    if(confirmCode == 197428124) {
    ownerCutIsLocked = true;
    }
  }
}