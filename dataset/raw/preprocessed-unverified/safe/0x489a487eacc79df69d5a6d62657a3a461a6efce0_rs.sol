/**
 *Submitted for verification at Etherscan.io on 2021-06-07
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Interface of the ERC20 with Burning method
 */
interface IERC20Burnable is IERC20 {
  function burn(uint256 amount) external;
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
 * @dev Contract where tokens are blocked forever
 */
contract BurnValley {
  event TokensDestroyed(address burner, uint256 amount);

  /**
    * @dev Method for burning any token from contract balance.
    * All tokens which will be sent here should be locked forever or burned
    * For better transparency everybody can call this method and burn tokens
    * Emits a {TokensDestroyed} event.
    */
  function burnAllTokens(address _token) external {
    IERC20Burnable token = IERC20Burnable(_token);

    uint256 balance = token.balanceOf(address(this));
    token.burn(balance);

    emit TokensDestroyed(msg.sender, balance);
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

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
  /**
    * @dev Emitted when the pause is triggered by `account`.
    */
  event Paused(address account);

  /**
    * @dev Emitted when the pause is lifted by `account`.
    */
  event Unpaused(address account);

  bool private _paused;

  /**
    * @dev Initializes the contract in unpaused state.
    */
  constructor () internal {
    _paused = false;
  }

  /**
    * @dev Returns true if the contract is paused, and false otherwise.
    */
  function paused() public view returns (bool) {
    return _paused;
  }

  /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    *
    * Requirements:
    *
    * - The contract must not be paused.
    */
  modifier whenNotPaused() {
    require(!_paused, "Pausable: paused");
    _;
  }

  /**
    * @dev Modifier to make a function callable only when the contract is paused.
    *
    * Requirements:
    *
    * - The contract must be paused.
    */
  modifier whenPaused() {
    require(_paused, "Pausable: not paused");
    _;
  }

  /**
    * @dev Triggers stopped state.
    *
    * Requirements:
    *
    * - The contract must not be paused.
    */
  function _pause() internal virtual whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }

  /**
    * @dev Returns to normal state.
    *
    * Requirements:
    *
    * - The contract must be paused.
    */
  function _unpause() internal virtual whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }
}

/**
 * @dev EVOT tokens swap contract
 */
contract Swap is Ownable, Pausable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  address public immutable burnValley;
  uint256 public constant MIN_EVOT = 40 * 10**18;

  IERC20 public constant EVOT = IERC20(0x5dE805154A24Cb824Ea70F9025527f35FaCD73a1);
  IERC20 public constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

  mapping(address => uint256) public usdcPerUser;

  event UsersRemoved(address[] users);
  event UsersWhitelisted(address[] users, uint256[] amounts);
  event TokensSwapped(address indexed user, uint256 evotAmount, uint256 usdcAmount);


  //  ------------------------
  //  CONSTRUCTOR
  //  ------------------------


	constructor() public {
    // Deploy burn valley contract for locking tokens
    burnValley = address(new BurnValley());
	}


  //  ------------------------
  //  USER METHODS
  //  ------------------------

	function swap(uint256 evotAmount) external whenNotPaused {
		require(evotAmount >= MIN_EVOT, "swap: Less EVOT then required!");

    address user = _msgSender();
    require(usdcPerUser[user] > 0, "swap: User not allowed to swap!");

    // Transfer user tokens to burn valley contract
    EVOT.safeTransferFrom(user, burnValley, evotAmount);

    // Save amount which user will receive
    uint256 usdcAmount = usdcPerUser[user];
    usdcPerUser[user] = 0;

    USDC.safeTransfer(user, usdcAmount);

    // Transfer new tokens to sender
		emit TokensSwapped(user, evotAmount, usdcAmount);
	}

  //  ------------------------
  //  OWNER METHODS
  //  ------------------------

  function whitelistUsers(address[] calldata users, uint256[] calldata amounts) external onlyOwner {
    uint256 usersCount = users.length;
    require(usersCount == amounts.length, "whitelistUsers: Arrays are not equal!");
    require(usersCount > 0, "whitelistUsers: Empty arrays!");

    for (uint256 i = 0; i < usersCount; i++) {
      address user = users[i];
      uint256 amount = amounts[i];

      // Update contract storage with provided values
      usdcPerUser[user] = amount;
    }

    emit UsersWhitelisted(users, amounts);
  }

  function removeUsers(address[] calldata users) external onlyOwner {
    uint256 usersCount = users.length;
    require(usersCount > 0, "removeUsers: Empty array!");

    for (uint256 i = 0; i < usersCount; i++) {
      address user = users[i];
      usdcPerUser[user] = 0;
    }

    emit UsersRemoved(users);
  }

  function pause() external onlyOwner whenNotPaused {
    _pause();
  }

  function unpause() external onlyOwner whenPaused {
    _unpause();
  }

  function withdrawUsdc(address receiver) external onlyOwner {
    USDC.safeTransfer(receiver, USDC.balanceOf(address(this)));
  }

  function withdrawUsdc(address receiver, uint256 amount) external onlyOwner {
    USDC.safeTransfer(receiver, amount);
  }
}