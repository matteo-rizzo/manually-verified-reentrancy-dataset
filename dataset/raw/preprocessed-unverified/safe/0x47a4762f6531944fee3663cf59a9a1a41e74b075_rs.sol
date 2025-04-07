/**
 *Submitted for verification at Etherscan.io on 2021-04-07
*/

pragma solidity ^0.7.0;


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */


/**
 * @dev interface of MomijiToken
 *
 */


/**
 Author: DokiDoki Dev: Kaki
 */
contract MomijiTokenManager is Ownable {
    using EnumerableSet for EnumerableSet.UintSet;

    IMomijiToken public momijiToken;
    mapping(address => EnumerableSet.UintSet) private _tokensForCreator;
    mapping(address => bool) public whitelist;
    uint256 whitelistCount;

    bool public onlyForWhitelist = true;

    constructor(IMomijiToken _momijiToken) {
        momijiToken = _momijiToken;
    }

    // After creating a new card, will mint it automatically.
    function create(uint256 tokenId, uint256 maxSupply, string memory uri, bytes calldata data) public {
        if (onlyForWhitelist) {
            require(whitelist[msg.sender], "Open to only whitelist.");
        }
        momijiToken.create(tokenId, maxSupply, uri, data);
        momijiToken.addMinter(tokenId, address(this));
        momijiToken.mint(tokenId, msg.sender, maxSupply, data);
        momijiToken.removeMintManuallyQuantity(tokenId, maxSupply);
        momijiToken.transferCreator(tokenId, msg.sender);
        _tokensForCreator[msg.sender].add(tokenId);
    }

    // Get how many cards of a creator.
    function getTokenAmountOfCreator(address account) view public returns(uint256) {
        return _tokensForCreator[account].length();
    }

    // Get tokenid of the creator with an index
    function getTokenIdOfCreator(address account, uint256 index) view public returns(uint256) {
        return _tokensForCreator[account].at(index);
    }

    // Add a new card to this creator
    function addCardManually(uint256 cardId) public {
        require(msg.sender == momijiToken.creators(cardId), "You are not the creator of this NFT.");
        _tokensForCreator[msg.sender].add(cardId);
    }

    // Remove a card from set of creator.
    function removeCardManually(uint256 cardId) public {
        require(_tokensForCreator[msg.sender].contains(cardId), "This NFT is not in your creation.");
        _tokensForCreator[msg.sender].remove(cardId);
    }

    // add a new artist
    function addToWhitelist(address account) public onlyOwner {
        whitelist[account] = true;
        whitelistCount += 1;
    }

    // Remove an artist
    function removeFromWhitelist(address account) public onlyOwner {
        whitelist[account] = false;
    }

    function openToEveryone() public onlyOwner {
        onlyForWhitelist = false;
    }

    function openOnlyToWhitelist() public onlyOwner {
        onlyForWhitelist = true;
    }
}