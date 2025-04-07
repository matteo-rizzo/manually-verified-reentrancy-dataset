/**
 *Submitted for verification at Etherscan.io on 2021-02-21
*/

pragma solidity ^0.6.2;

// SPDX-License-Identifier: MIT







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




contract Pump is Ownable {
    using SafeERC20 for IERC20;

    address public asset;
    address public bridge;
    address public destination;

    uint public rewardDivisor;

    mapping (bytes => bool) public executionMap;

    constructor (address _asset, address _bridge, address _destination, uint _rewardDivisor)
    public {
        asset = _asset;
        bridge = _bridge;
        destination = _destination;
        rewardDivisor = _rewardDivisor;
    }

    function pump(bytes calldata _data, bytes calldata _signatures)
    external {
        // check if this has already been executed
        require(executionMap[_data] == false, "Pump: This request has already been executed");

        // execute the signature via the arbitrary message bridge
        IAMB(bridge).executeSignatures(_data, _signatures);

        // send the caller (1 / rewardDivisor) of the current balance
        IERC20(asset).safeTransfer(msg.sender, IERC20(asset).balanceOf(address(this)) / rewardDivisor);

        // send the remaining balance to the destination
        IERC20(asset).safeTransfer(destination, IERC20(asset).balanceOf(address(this)));

        // mark the execution map so this can't be executed again
        executionMap[_data] = true;
    }

    function update(address _asset, address _bridge, address _destination, uint _rewardDivisor)
    external onlyOwner {
        asset = _asset;
        bridge = _bridge;
        destination = _destination;
        rewardDivisor = _rewardDivisor;
    }
}