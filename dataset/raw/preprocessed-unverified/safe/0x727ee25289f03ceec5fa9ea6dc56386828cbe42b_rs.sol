/**
 *Submitted for verification at Etherscan.io on 2021-04-12
*/

// File: EnumerableSet.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/EnumerableSet.sol
// Subject to the MIT license.


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

// File: Context.sol


// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/GSN/Context.sol
// Subject to the MIT license.


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
// File: Ownable.sol


// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
// Subject to the MIT license.


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
// File: PresaleFactory.sol

// @Credits Unicrypt Network 2021

// This contract logs all presales on the platform


contract PresaleFactory is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    
    EnumerableSet.AddressSet private presales;
    EnumerableSet.AddressSet private presaleGenerators;
    
    mapping(address => EnumerableSet.AddressSet) private presaleOwners;
    
    event presaleRegistered(address presaleContract);
    
    function adminAllowPresaleGenerator (address _address, bool _allow) public onlyOwner {
        if (_allow) {
            presaleGenerators.add(_address);
        } else {
            presaleGenerators.remove(_address);
        }
    }
    
    /**
     * @notice called by a registered PresaleGenerator upon Presale creation
     */
    function registerPresale (address _presaleAddress) public {
        require(presaleGenerators.contains(msg.sender), 'FORBIDDEN');
        presales.add(_presaleAddress);
        emit presaleRegistered(_presaleAddress);
    }
    
    /**
     * @notice Number of allowed PresaleGenerators
     */
    function presaleGeneratorsLength() external view returns (uint256) {
        return presaleGenerators.length();
    }
    
    /**
     * @notice Gets the address of a registered PresaleGenerator at specified index
     */
    function presaleGeneratorAtIndex(uint256 _index) external view returns (address) {
        return presaleGenerators.at(_index);
    }
    
    /**
     * @notice returns true if the presale address was generated by the Octofi presale platform
     */
    function presaleIsRegistered(address _presaleAddress) external view returns (bool) {
        return presales.contains(_presaleAddress);
    }
    
    /**
     * @notice The length of all presales on the platform
     */
    function presalesLength() external view returns (uint256) {
        return presales.length();
    }
    
    /**
     * @notice gets a presale at a specific index. Although using Enumerable Set, since presales are only added and not removed, indexes will never change
     * @return the address of the Presale contract at index
     */
    function presaleAtIndex(uint256 _index) external view returns (address) {
        return presales.at(_index);
    }
    
}