/**
 *Submitted for verification at Etherscan.io on 2021-08-03
*/

pragma solidity ^0.6.12;


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


/// @title RewardVault
/// @notice A contract for generating rewards in the starlink ecosystem
contract RewardVault is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    event RewardClaimed(
        uint256 indexed tokenId,
        uint256 amount,
        uint256 timestamp
    );

    ISateNFT sateNft;
    IERC20 token;

    mapping(uint256 => uint256) lastUpdatedTime;

    constructor(ISateNFT _sateNft, IERC20 _token) public {
        sateNft = _sateNft;
        token = _token;
    }

    function claimable(uint256 _tokenId) public view returns (uint256) {
        (, , uint256 stLaunchTime, uint256 stLaunchPrice, , uint8 stAPR) = sateNft.sateInfo(_tokenId);

        uint256 lastUpdated;
        if (stLaunchTime > lastUpdatedTime[_tokenId]) {
            if (stLaunchTime >= _getNow()) return 0;

            lastUpdated = stLaunchTime;
        }
        else {
            lastUpdated = lastUpdatedTime[_tokenId];
        }
        return _getNow().sub(lastUpdated).mul(stLaunchPrice).mul(stAPR).div(100).div(31536000);
    }

    function claimRewards(uint256 _tokenId) external {
        require(sateNft.ownerOf(_tokenId) == _msgSender(), "Must be owner");
        
        uint256 amount = claimable(_tokenId);
        if (amount > 0) {
            token.safeTransfer(_msgSender(), amount);
            lastUpdatedTime[_tokenId] = _getNow();
            emit RewardClaimed(_tokenId, amount, _getNow());
        }
    }

    function _getNow() internal view returns (uint256) {
        return block.timestamp;
    }
}