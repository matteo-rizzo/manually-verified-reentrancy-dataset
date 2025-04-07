/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

// Dependency file: @openzeppelin/contracts/GSN/Context.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

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


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/GSN/Context.sol";
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
contract Ownable is Context {
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


// Dependency file: @openzeppelin/contracts/utils/EnumerableSet.sol


// pragma solidity ^0.6.0;

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
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */



// Root file: contracts/farm/FarmFactory.sol


pragma solidity 0.6.10;

// import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
// import { EnumerableSet } from "@openzeppelin/contracts/utils/EnumerableSet.sol";

contract FarmFactory is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    /* ============ State Variables ============ */

    EnumerableSet.AddressSet private farms;
    EnumerableSet.AddressSet private farmGenerators;
    mapping(address => EnumerableSet.AddressSet) private userFarms;

    /* ============ Owner Functions ============ */

    /**
     * Allow/Disallow Farm generator.
     *
     * @param _address              Address of the farm generator contract instance
     * @param _allow                Allow or disallow the farm generator
     */
    function adminAllowFarmGenerator(address _address, bool _allow) external onlyOwner {
        if (_allow) {
            farmGenerators.add(_address);
        } else {
            farmGenerators.remove(_address);
        }
    }

    /* ============ Public/External Functions ============ */

    /**
     * Called by a registered FarmGenerator upon Farm creation
     *
     * @param _farmAddress          Address of the farm
     */
    function registerFarm(address _farmAddress) external {
        require(farmGenerators.contains(msg.sender), "FORBIDDEN");
        farms.add(_farmAddress);
    }

    /**
     * Called by a Farm contract when lp token balance changes from 0 to > 0 to allow tracking all farms a user is active in
     *
     * @param _user                 Address of the user
     */
    function userEnteredFarm(address _user) public {
        // msg.sender = farm contract
        require(farms.contains(msg.sender), "FORBIDDEN");
        EnumerableSet.AddressSet storage set = userFarms[_user];
        set.add(msg.sender);
    }

    /**
     * Called by a Farm contract when all LP tokens have been withdrawn, removing the farm from the users active farm list
     *
     * @param _user                 Address of the user
     */
    function userLeftFarm(address _user) public {
        // msg.sender = farm contract
        require(farms.contains(msg.sender), "FORBIDDEN");
        EnumerableSet.AddressSet storage set = userFarms[_user];
        set.remove(msg.sender);
    }

    /* ============ View Functions ============ */

    /**
     * Get number of allowed FarmGenerators
     */
    function farmGeneratorsLength() external view returns (uint256) {
        return farmGenerators.length();
    }

    /**
     * Get the address of a registered FarmGenerator at specifiex index
     *
     * @param _index                Index of the farm generator in the array
     */
    function farmGeneratorAtIndex(uint256 _index) external view returns (address) {
        return farmGenerators.at(_index);
    }

    /**
     * Get the length of all farms on the platform
     */
    function farmsLength() external view returns (uint256) {
        return farms.length();
    }

    /**
     * Get a farm at a specific index. Although using Enumerable Set, since farms are only added and not removed this will never change
     *
     * @param _index                Index of the farm in the array
     */
    function farmAtIndex(uint256 _index) external view returns (address) {
        return farms.at(_index);
    }

    /**
     * Get the number of farms the user is active in
     *
     * @param _user                 Address of the user
     */
    function userFarmsLength(address _user) external view returns (uint256) {
        EnumerableSet.AddressSet storage set = userFarms[_user];
        return set.length();
    }

    /**
     * Get the farm the user is active in, by the index
     *
     * @param _user                 Address of the user
     * @param _index                Index of the farm in the array
     */
    function userFarmAtIndex(address _user, uint256 _index) external view returns (address) {
        EnumerableSet.AddressSet storage set = userFarms[_user];
        return set.at(_index);
    }
}