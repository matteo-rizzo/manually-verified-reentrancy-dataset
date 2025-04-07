/**
 *Submitted for verification at Etherscan.io on 2021-05-07
*/

// Sources flattened with hardhat v2.2.1 https://hardhat.org

// File contracts/token/ERC20/IERC20.sol





/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// File contracts/utils/Address.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */



// File contracts/token/ERC20/utils/SafeERC20.sol






/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// File contracts/utils/Context.sol





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


// File contracts/access/Ownable.sol





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


// File contracts/mulan/WhitelistForSelf.sol





abstract contract WhitelistForSelf is Ownable {
    //      caller
    mapping(address => bool) public canBeModified;

    function addRelationByOwner(address caller) external virtual onlyOwner {
        canBeModified[caller] = true;
    }

    modifier allowModification() {
        require(canBeModified[msg.sender], "modification not allowed");
        _;
    }
}


// File contracts/mulan/timelock.sol






contract timelocks is WhitelistForSelf {
    using SafeERC20 for IERC20;

    IERC20 private immutable _token;

    event LockCreated(
        address indexed user,
        uint256 indexed lockNumber,
        uint256 value,
        uint256 reward,
        uint256 startTime,
        uint256 releaseTime
    );
    event Released(
        address indexed user,
        uint256 indexed lockNumber,
        uint256 actualReleaseTime
    );

    uint256 public lockedTotal;
    uint256 public rewardTotal;

    constructor(IERC20 token_) {
        _token = token_;
    }

    struct LockDetail {
        uint256 value;  //locked mulan value
        uint256 reward; //reward mulanV2 value
        uint256 releaseTime;
        bool released;
    }

    mapping(address => LockDetail[]) public userLocks;

    function getTotalLocksOf(address _user) public view returns (uint256) {
        return userLocks[_user].length;
    }

    function getDetailOf(address _user, uint256 _lockNumber)
        public
        view
        returns (
            uint256 value,
            uint256 reward,
            uint256 releaseTime,
            bool released
        )
    {
        LockDetail memory detail = userLocks[_user][_lockNumber];
        return (
            detail.value,
            detail.reward,
            detail.releaseTime,
            detail.released
        );
    }

    ///@dev it's caller's responsibility to transfer _value token to this contract
    function lockByWhitelist(
        address _user,
        uint256 _value,
        uint256 _reward,
        uint256 _releaseTime
    ) external virtual allowModification returns (bool) {
        require(
            _releaseTime >= block.timestamp,
            "lock time should be after current time"
        );
        require(_value > 0, "value should be above 0");
        uint256 lockNumber = userLocks[_user].length;
        userLocks[_user].push(LockDetail(_value, _reward, _releaseTime, false));
        lockedTotal += _value;
        rewardTotal += _reward;
        emit LockCreated(
            _user,
            lockNumber,
            _value,
            _reward,
            block.timestamp,
            _releaseTime
        );
        return true;
    }

    function canRelease(address _user, uint256 _lockNumber)
        public
        view
        virtual
        returns (bool)
    {
        return
            userLocks[_user][_lockNumber].releaseTime <= block.timestamp &&
            !userLocks[_user][_lockNumber].released;
    }

    function releaseByWhitelist(address _user, uint256 _lockNumber)
        public
        virtual
        allowModification
        returns (bool)
    {
        require(
            canRelease(_user, _lockNumber),
            "still locked or already released"
        );
        LockDetail memory detail = userLocks[_user][_lockNumber];
        _token.safeTransfer(_user, detail.value);
        userLocks[_user][_lockNumber].released = true;
        emit Released(_user, _lockNumber, block.timestamp);
        return true;
    }

}