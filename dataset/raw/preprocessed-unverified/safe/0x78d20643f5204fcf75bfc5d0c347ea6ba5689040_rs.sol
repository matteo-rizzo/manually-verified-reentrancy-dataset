/**
 *Submitted for verification at Etherscan.io on 2021-07-10
*/

/**
 *Submitted for verification at Etherscan.io on 2021-07-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */


contract CliffVesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public immutable cliff;
    uint256 public immutable start;
    uint256 public immutable duration;
    uint256 public released;

    // Beneficiary of token after they are released
    address public immutable beneficiary;
    IERC20 public immutable token;

    event TokensReleased(uint256 amount);

    // ------------------------
    // CONSTRUCTOR
    // ------------------------

    /// @dev Creates a vesting contract that vests its balance of any ERC20 token to the
    /// beneficiary, gradually in a linear fashion until start + duration. By then all
    /// of the balance will have vested.
    /// @param beneficiary_ address of the beneficiary to whom vested token are transferred
    /// @param cliffDuration_ duration in seconds of the cliff in which token will begin to vest
    /// @param duration_ duration in seconds of the period in which the token will vest
    /// @param token_ address of the locked token
    constructor(
        address beneficiary_,
        uint256 cliffDuration_,
        uint256 duration_,
        address token_
    ) {
        require(beneficiary_ != address(0));
        require(token_ != address(0));
        require(cliffDuration_ <= duration_);
        require(duration_ > 0);

        beneficiary = beneficiary_;
        token = IERC20(token_);
        duration = duration_;
        start = block.timestamp;
        cliff = block.timestamp.add(cliffDuration_);
    }

    // ------------------------
    // SETTERS
    // ------------------------

    /// @notice Transfers vested tokens to beneficiary
    function release() external {
        uint256 unreleased = _releasableAmount();

        require(unreleased > 0);

        released = released.add(unreleased);

        token.safeTransfer(beneficiary, unreleased);

        emit TokensReleased(unreleased);
    }

    // ------------------------
    // INTERNAL
    // ------------------------

    /// @notice Calculates the amount that has already vested but hasn't been released yet
    function _releasableAmount() private view returns (uint256) {
        return _vestedAmount().sub(released);
    }

    /// @notice Calculates the amount that has already vested
    function _vestedAmount() private view returns (uint256) {
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(released);

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start.add(duration)) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(start)).div(duration);
        }
    }
}