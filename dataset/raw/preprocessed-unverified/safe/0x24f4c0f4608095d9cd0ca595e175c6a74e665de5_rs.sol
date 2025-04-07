/**
 *Submitted for verification at Etherscan.io on 2020-06-30
*/

pragma solidity ^0.5.0;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

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
contract Context is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Initializable, Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}

/**
 * Base contract for all modules
 */
contract Base is Initializable, Context, Ownable {
    address constant  ZERO_ADDRESS = address(0);

    function initialize() public initializer {
        Ownable.initialize(_msgSender());
    }

}

contract CoreInterface {

    /* Module manipulation events */

    event ModuleAdded(string name, address indexed module);

    event ModuleRemoved(string name, address indexed module);

    event ModuleReplaced(string name, address indexed from, address indexed to);


    /* Functions */

    function set(string memory  _name, address _module, bool _constant) public;

    function setMetadata(string memory _name, string  memory _description) public;

    function remove(string memory _name) public;
    
    function contains(address _module)  public view returns (bool);

    function size() public view returns (uint);

    function isConstant(string memory _name) public view returns (bool);

    function get(string memory _name)  public view returns (address);

    function getName(address _module)  public view returns (string memory);

    function first() public view returns (address);

    function next(address _current)  public view returns (address);
}

/**
 * @dev Double linked list with address items
 */


/**
 * @dev Iterable by index (string => address) mapping structure
 *      with reverse resolve and fast element remove
 */


contract Pool is Base, CoreInterface {

    /* Short description */
    string  public name;
    string  public description;
    address public founder;

    /* Modules map */
    AddressMap.Data modules;

    using AddressList for AddressList.Data;
    using AddressMap for AddressMap.Data;

    /* Module constant mapping */
    mapping(bytes32 => bool) public is_constant;

    /**
     * @dev Contract ABI storage
     *      the contract interface contains source URI
     */
    mapping(address => string) public abiOf;
    
    function initialize() public initializer {
        Base.initialize();
        founder = _msgSender();
    }

    function setMetadata(string memory _name, string  memory _description) public onlyOwner {
        name = _name;
        description = _description;
    }
      
    /**
     * @dev Set new module for given name
     * @param _name infrastructure node name
     * @param _module infrastructure node address
     * @param _constant have a `true` value when you create permanent name of module
     */
    function set(string memory _name, address _module, bool _constant) public onlyOwner {
        
        require(!isConstant(_name), "Pool: module address can not be replaced");

        // Notify
        if (modules.get(_name) != ZERO_ADDRESS)
            emit ModuleReplaced(_name, modules.get(_name), _module);
        else
            emit ModuleAdded(_name, _module);
 
        // Set module in the map
        modules.set(_name, _module);

        // Register constant flag 
        is_constant[keccak256(abi.encodePacked(_name))] = _constant;
    }

     /**
     * @dev Remove module by name
     * @param _name module name
     */
    function remove(string memory _name)  public onlyOwner {
        require(!isConstant(_name), "Pool: module can not be removed");

        // Notify
        emit ModuleRemoved(_name, modules.get(_name));

        // Remove module
        modules.remove(_name);
    }

    /**
     * @dev Fast module exist check
     * @param _module is a module address
     * @return `true` wnen core contains module
     */
    function contains(address _module) public view returns (bool)
    {
        return modules.items.contains(_module);
    }

    /**
     * @dev Modules counter
     * @return count of modules in core
     */
    function size() public view returns (uint)
    {
        return modules.size();
    }

    /**
     * @dev Check for module have permanent name
     * @param _name is a module name
     * @return `true` when module have permanent name
     */
    function isConstant(string memory _name) public view returns (bool)
    {
        return is_constant[keccak256(abi.encodePacked(_name))];
    }

    /**
     * @dev Get module by name
     * @param _name is module name
     * @return module address
     */
    function get(string memory _name) public view returns (address)
    {
        return modules.get(_name);
    }

    /**
     * @dev Get module name by address
     * @param _module is a module address
     * @return module name
     */
    function getName(address _module) public view returns (string memory)
    {
        return modules.keyOf[_module];
    }

    /**
     * @dev Get first module
     * @return first address
     */
    function first() public view returns (address)
    {
        return modules.items.head;
    }

    /**
     * @dev Get next module
     * @param _current is an current address
     * @return next address
     */
    function next(address _current) public view returns (address)
    {
        return modules.items.next(_current);
    }

}