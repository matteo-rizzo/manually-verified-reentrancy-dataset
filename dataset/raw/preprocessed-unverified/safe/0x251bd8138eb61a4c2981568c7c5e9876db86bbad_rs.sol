/**
 *Submitted for verification at Etherscan.io on 2021-08-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;


// 
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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Initializable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
      address indexed previousOwner,
      address indexed newOwner
    );

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function init(address sender) public initializer {
      _owner = sender;
    }

    /**
    * @return the address of the owner.
    */
    function owner() public view returns(address) {
      return _owner;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
      require(isOwner());
      _;
    }

    /**
    * @return true if `msg.sender` is the owner of the contract.
    */
    function isOwner() public view returns(bool) {
      return msg.sender == _owner;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
      emit OwnershipRenounced(_owner);
      _owner = address(0);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0));
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }

    uint256[50] private ______gap;
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for SIERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once Token is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract UBXTDistribution is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // The TOKEN TOKEN!
    address public token;

    event DistributedToken(
        address developer, uint256 amountForDeveloper, 
        address reserved, uint256 amountForReserved,
        address burning, uint256 amountForBurning,
        address pool, uint256 amountForPool);

    constructor() public
    { }
    
    function initialize(address _token, address _owner) public initializer {
        Ownable.init(_owner);
        token = _token;
    }
    
    function tokenBalance() public view returns (uint256) {
        uint256 tokenBal = IERC20(token).balanceOf(address(this));
        return tokenBal;
    }

    function tokenBalanceOf(address _address) public view returns (uint256) {
        uint256 tokenBal = IERC20(token).balanceOf(_address);
        return tokenBal;
    }

    // updated Perf pool address
    function withdrawToken(address _address, uint256 _amount) public onlyOwner {
        safeTokenTransfer(_address, _amount);
    }

    function distributeToken(
        address developer, uint256 amountForDeveloper,
        address reserved, uint256 amountForReserved,
        address burning, uint256 amountForBurning,
        address pool, uint256 amountForPool
        ) public  {
        safeTokenTransfer(developer, amountForDeveloper);
        safeTokenTransfer(reserved, amountForReserved);
        safeTokenTransfer(burning, amountForBurning);
        safeTokenTransfer(pool, amountForPool);

        emit DistributedToken(developer, amountForDeveloper, reserved, amountForReserved, burning, amountForBurning, pool, amountForPool);
    }

    // Safe token transfer function, just in case if rounding error causes to not have enough TOKENs.
    function safeTokenTransfer(address _to, uint256 _amount) internal {
        uint256 tokenBal = IERC20(token).balanceOf(address(this));
        if (_amount > tokenBal) {
            IERC20(token).transfer(_to, tokenBal);
        } else {
            IERC20(token).transfer(_to, _amount);
        }
    }
}