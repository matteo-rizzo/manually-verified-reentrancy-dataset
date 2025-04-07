// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


/* @dev Wrappers over Solidity's arithmetic operations with added overflow
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
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
 * @dev A token holder contract that will allow a beneficiary to extract the
 * tokens by portions based on a metric (TVL)
 *
 * This is ported from openzeppelin-ethereum-package
 *
 * Currently the holder contract is Ownable (while the owner is current beneficiary)
 * still, this allows to check the method calls in blockchain to verify fair play.
 * In the future it will be possible to use automated calculation, e.g. using
 * https://github.com/ConcourseOpen/DeFi-Pulse-Adapters TVL calculation, then
 * ownership would be transferred to the managing contract.
 */
contract HolderTVLLock is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 private constant RELEASE_PERCENT = 2;
    uint256 private constant RELEASE_INTERVAL = 1 weeks;

    // ERC20 basic token contract being held
    IERC20 private _token;

    // beneficiary of tokens after they are released
    address private _beneficiary;

    // timestamp when token release was made last time
    uint256 private _lastReleaseTime;

    // timestamp of first possible release time
    uint256 private _firstReleaseTime;

    // TVL metric for last release time
    uint256 private _lastReleaseTVL;

    // amount that already was released
    uint256 private _released;

    event TVLReleasePerformed(uint256 newTVL);

    constructor (IERC20 token, address beneficiary, uint256 firstReleaseTime) public {
        //as contract is deployed by Holyheld token, transfer ownership to dev
        transferOwnership(beneficiary);

        // solhint-disable-next-line not-rely-on-time
        require(firstReleaseTime > block.timestamp, "release time before current time");
        _token = token;
        _beneficiary = beneficiary;
        _firstReleaseTime = firstReleaseTime;
    }

    /**
     * @return the token being held.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the beneficiary of the tokens.
     */
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }

    /**
     * @return the time when the tokens were released last time.
     */
    function lastReleaseTime() public view returns (uint256) {
        return _lastReleaseTime;
    }

    /**
     * @return the TVL marked when the tokens were released last time.
     */
    function lastReleaseTVL() public view returns (uint256) {
        return _lastReleaseTVL;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     * only owner can call this method as it will write new TVL metric value
     * into the holder contract
     */
    function release(uint256 _newTVL) public onlyOwner {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp >= _firstReleaseTime, "current time before release time");
        require(block.timestamp > _lastReleaseTime + RELEASE_INTERVAL, "release interval is not passed");
        require(_newTVL > _lastReleaseTVL, "only release if TVL is higher");

        // calculate amount that is possible to release
        uint256 balance = _token.balanceOf(address(this));
        uint256 totalBalance = balance.add(_released);

        uint256 amount = totalBalance.mul(RELEASE_PERCENT).div(100);
        require(balance > amount, "available balance depleted");

        _token.safeTransfer(_beneficiary, amount);
	    _lastReleaseTime = block.timestamp;
	    _lastReleaseTVL = _newTVL;
	    _released = _released.add(amount);

        emit TVLReleasePerformed(_newTVL);
    }
}