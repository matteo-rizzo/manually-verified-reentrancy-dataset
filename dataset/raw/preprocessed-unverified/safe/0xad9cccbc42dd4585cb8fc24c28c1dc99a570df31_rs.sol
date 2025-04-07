/**
 *Submitted for verification at Etherscan.io on 2021-09-14
*/

pragma solidity ^0.8.0;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}








contract KeyNouns is Ownable{

    using LibString for string;

    string[] private RESERVEDWORDS;
    string[] private RESERVEDKEYS;
    string[] private ILLEGALKEYS;

    uint public nounsLen;

    mapping(string => bool) private KEYWORDSTATE;
    mapping(string => bool) private KEYSTATE;
    mapping(string => bool) private ILLEGALSTATE;

    constructor() Ownable() {
        nounsLen = 32;
        ILLEGALSTATE[" "] = true;
        ILLEGALKEYS.push(" ");
    }

    function addKeyWord(string memory word) external onlyOwner{
        string memory _lower = word.toLowercase();
        require(!KEYWORDSTATE[_lower], "keyword duplicated");
        RESERVEDWORDS.push(_lower);
        KEYWORDSTATE[_lower] = true;
    }

    function addIllegalKey(string memory illegal) external onlyOwner{
        string memory _lower = illegal.toLowercase();
        require(illegal.lenOfChars() == 1, "illegal key too long");
        require(!ILLEGALSTATE[_lower], "illegal key duplicated");
        ILLEGALKEYS.push(_lower);
        ILLEGALSTATE[_lower] = true;
    }

    function addKey(string memory key) external onlyOwner{
        string memory _lower = key.toLowercase();
        require(!KEYSTATE[_lower], "key character duplicated");
        RESERVEDKEYS.push(_lower);
        KEYSTATE[_lower] = true;
    }

    function setNounLen(uint len) external onlyOwner{
        require(len > 0, "nouns length too short");
        nounsLen = len;
    }
    function keyWordIn(string memory word) public view returns (bool){
        string memory _lower = word.toLowercase();
        return KEYWORDSTATE[_lower];
    }

    function keyIn(string memory key) public view returns (bool){
        string memory _lower = key.toLowercase();
        return KEYSTATE[_lower];
    }

    function IllegalkeyIn(string memory key) public view returns (bool){
        string memory _lower = key.toLowercase();
        return ILLEGALSTATE[_lower];
    }

    function getWords() public view returns ( string[] memory){
        return RESERVEDWORDS;
    }

    function getKeys() public view returns ( string[] memory){
        return RESERVEDKEYS;
    }

    function contain(string memory key) public view returns (bool){
        for(uint i = 0; i < RESERVEDKEYS.length; i++){
            if(key.compareNocase(RESERVEDKEYS[i]) == 0){
                return true;
            }
        }
        return false;
    }

    function isLegal(string memory onekey) external view returns (bool){
        string memory _lower = onekey.toLowercase();
        for(uint i = 0; i< ILLEGALKEYS.length; i++){
            if(_lower.indexOf(ILLEGALKEYS[i]) >= 0){
                return false;
            }
        }
        return true;
    }
}