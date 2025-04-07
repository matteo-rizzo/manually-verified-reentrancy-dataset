/**
 *Submitted for verification at Etherscan.io on 2021-02-04
*/

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;


// SPDX-License-Identifier: MIT
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
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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





interface IDefiPointCaller is ISafeERC20Extension {
    struct CallDescription {
        uint256 targetWithMandatory;
        uint256 gasLimit;
        uint256 value;
        bytes data;
    }

    function makeCall(CallDescription memory desc) external;
    function makeCalls(CallDescription[] memory desc) external payable;
}





contract DefiPointExchange is Ownable, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using DefiPointERC20 for IERC20;

    uint256 private constant _PARTIAL_FILL = 0x01;
    uint256 private constant _REQUIRES_EXTRA_ETH = 0x02;
    uint256 private constant _SHOULD_CLAIM = 0x04;
    uint256 private constant _BURN_FROM_MSG_SENDER = 0x08;
    uint256 private constant _BURN_FROM_TX_ORIGIN = 0x10;

    struct SwapDescription {
        IERC20 srcToken;
        IERC20 dstToken;
        address srcReceiver;
        address dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 guaranteedAmount;
        uint256 flags;
        address referrer;
        bytes permit;
    }

    event Swapped(
        address indexed sender,
        IERC20 indexed srcToken,
        IERC20 indexed dstToken,
        address dstReceiver,
        uint256 amount,
        uint256 spentAmount,
        uint256 returnAmount,
        uint256 minReturnAmount,
        uint256 guaranteedAmount,
        address referrer
    );

    event Error(
        string reason
    );

    function swap(
        IDefiPointCaller caller,
        SwapDescription calldata desc,
        IDefiPointCaller.CallDescription[] calldata calls
    )
        external
        payable
        whenNotPaused
        returns (uint256 returnAmount)
    {
        require(desc.minReturnAmount > 0, "Min return should not be 0");
        require(calls.length > 0, "Call data should exist");

        uint256 flags = desc.flags;
        IERC20 srcToken = desc.srcToken;
        IERC20 dstToken = desc.dstToken;

        if (flags & _REQUIRES_EXTRA_ETH != 0) {
            require(msg.value > (srcToken.isETH() ? desc.amount : 0), "Invalid msg.value");
        } else {
            require(msg.value == (srcToken.isETH() ? desc.amount : 0), "Invalid msg.value");
        }

        if (flags & _SHOULD_CLAIM != 0) {
            require(!srcToken.isETH(), "Claim token is ETH");
            _claim(srcToken, desc.srcReceiver, desc.amount, desc.permit);
        }

        address dstReceiver = (desc.dstReceiver == address(0)) ? msg.sender : desc.dstReceiver;
        uint256 initialSrcBalance = (flags & _PARTIAL_FILL != 0) ? srcToken.uniBalanceOf(msg.sender) : 0;
        uint256 initialDstBalance = dstToken.uniBalanceOf(dstReceiver);

        caller.makeCalls{value: msg.value}(calls);

        uint256 spentAmount = desc.amount;
        returnAmount = dstToken.uniBalanceOf(dstReceiver).sub(initialDstBalance);

        if (flags & _PARTIAL_FILL != 0) {
            spentAmount = initialSrcBalance.add(desc.amount).sub(srcToken.uniBalanceOf(msg.sender));
            require(returnAmount.mul(desc.amount) >= desc.minReturnAmount.mul(spentAmount), "Return amount is not enough");
        } else {
            require(returnAmount >= desc.minReturnAmount, "Return amount is not enough");
        }

        _emitSwapped(desc, srcToken, dstToken, dstReceiver, spentAmount, returnAmount);
    }

    function _emitSwapped(
        SwapDescription calldata desc,
        IERC20 srcToken,
        IERC20 dstToken,
        address dstReceiver,
        uint256 spentAmount,
        uint256 returnAmount
     ) private {
        emit Swapped(
            msg.sender,
            srcToken,
            dstToken,
            dstReceiver,
            desc.amount,
            spentAmount,
            returnAmount,
            desc.minReturnAmount,
            desc.guaranteedAmount,
            desc.referrer
        );
    }

    function _claim(IERC20 token, address dst, uint256 amount, bytes calldata permit) private {
        // TODO: Is it safe to call permit on tokens without implemented permit? Fallback will be called. Is it bad for proxies?

        if (permit.length == 32 * 7) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success, bytes memory result) = address(token).call(abi.encodeWithSelector(IERC20Permit.permit.selector, permit));
            if (!success) {
                revert(RevertReasonParser.parse(result, "Permit call failed: "));
            }
        }

        token.safeTransferFrom(msg.sender, dst, amount);
    }

    function rescueFunds(IERC20 token, uint256 amount) external onlyOwner {
        token.uniTransfer(msg.sender, amount);
    }

    function pause() external onlyOwner {
        _pause();
    }
}