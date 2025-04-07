/**
 *Submitted for verification at Etherscan.io on 2021-03-10
*/

pragma solidity ^0.5.16;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


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
contract Context {
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
     * NOTE: Renouncing ownership will leave the contract without an owner,
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
}

contract IReleaser {
    function release() external;

    function isReleaser() external pure returns (bool) {
        return true;
    }
}

// Based on "@openzeppelin<2.5.1>/contracts/drafts/TokenVesting.sol";
contract MonthlyTokenVesting is IReleaser, Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  event TokensReleased(address token, uint256 amount);

  address public _beneficiary;
  bool public _beneficiaryIsReleaser;

  // Durations and timestamps are expressed in UNIX time, the same units as block.timestamp.
  uint256 private _cliff;
  uint256 private _start;
  uint256 private _duration;

  mapping(address => uint256) private _released;

  uint256 private SECONDS_GAP = 60 * 60 * 24 * 30;

  /**
   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
   * beneficiary, gradually in a linear fashion until start + duration. By then all
   * of the balance will have vested.
   * @param beneficiary address of the beneficiary to whom vested tokens are transferred
   * @param cliffDuration duration in seconds of the cliff in which tokens will begin to vest
   * @param duration duration in seconds of the period in which the tokens will vest
   */
  constructor(
    address beneficiary,
    bool beneficiaryIsReleaser,
    uint256 cliffDuration,
    uint256 duration
  ) public {
    require(
      beneficiary != address(0),
      "TokenVesting: beneficiary is the zero address"
    );
    require(duration > 0, "TokenVesting: duration is 0");
    // if announced as releaser - should implement interface 
    require(
      !beneficiaryIsReleaser || IReleaser(beneficiary).isReleaser(),
      "TokenVesting: beneficiary releaser status wrong"
    );

    _beneficiary = beneficiary;
    _beneficiaryIsReleaser = beneficiaryIsReleaser;
    _duration = duration;
    _cliff = cliffDuration;
  }

  function release() public onlyOwner {
    _start = block.timestamp;
    _cliff = _start.add(_cliff);
  }

  /**
   * @return the beneficiary of the tokens.
   */
  function beneficiary() public view returns (address) {
    return _beneficiary;
  }

  /**
   * @return the cliff time of the token vesting.
   */
  function cliff() public view returns (uint256) {
    return _cliff;
  }

  /**
   * @return the start time of the token vesting.
   */
  function start() public view returns (uint256) {
    return _start;
  }

  /**
   * @return the duration of the token vesting.
   */
  function duration() public view returns (uint256) {
    return _duration;
  }

  /**
   * @return the amount of the token released.
   */
  function released(address token) public view returns (uint256) {
    return _released[token];
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   * @param token ERC20 token which is being vested
   */
  function claim(IERC20 token) public {
    require(_start > 0, "TokenVesting: start is not set");

    uint256 unreleased = _releasableAmount(token);

    require(unreleased > 0, "TokenVesting: no tokens are due");

    _released[address(token)] = _released[address(token)].add(unreleased);

    token.safeTransfer(_beneficiary, unreleased);
    if (_beneficiaryIsReleaser) {
      IReleaser(_beneficiary).release();
    }

    emit TokensReleased(address(token), unreleased);
  }
    
  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   * @param token ERC20 token which is being vested
   */
  function _releasableAmount(IERC20 token) private view returns (uint256) {
    return _vestedAmount(token).sub(_released[address(token)]);
  }

  /**
   * @dev Calculates the amount that has already vested.
   * @param token ERC20 token which is being vested
   */
  function _vestedAmount(IERC20 token) private view returns (uint256) {
    uint256 currentBalance = token.balanceOf(address(this));
    uint256 totalBalance = currentBalance.add(_released[address(token)]);

    if (block.timestamp < _cliff) {
      return 0;
    } else if (block.timestamp >= _cliff.add(_duration)) {
      return totalBalance;
    } else {
      uint256 elapsed = block.timestamp.sub(_cliff);
      elapsed = elapsed.div(SECONDS_GAP).add(1).mul(SECONDS_GAP);
      return totalBalance.mul(elapsed).div(_duration);
    }
  }
}

contract TokenVestingVaultA is MonthlyTokenVesting {
  constructor(
    address beneficiary,
    bool beneficiaryIsReleaser,
    uint256 cliffDuration,
    uint256 duration
  ) public MonthlyTokenVesting(
    beneficiary,
    beneficiaryIsReleaser,
    cliffDuration,
    duration) {
  }
}