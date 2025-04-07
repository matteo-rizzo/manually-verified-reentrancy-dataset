/**
 *Submitted for verification at Etherscan.io on 2021-05-17
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.6.11;



// Part: IMerkleDistributor



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/Context

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

// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/MerkleProof

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: OpenZeppelin/[email protected]/Ownable

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

// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: MerkleDistributor.sol

contract MerkleDistributor is IMerkleDistributor, Ownable {
  using SafeERC20 for IERC20;

  address public immutable override token;
  bytes32 public immutable override merkleRoot;

  // This is a packed array of booleans.
  mapping(uint => uint) private claimedBitMap;

  event WithdrawTokens(address indexed withdrawer, address token, uint amount);
  event WithdrawRewardTokens(address indexed withdrawer, uint amount);
  event WithdrawAllRewardTokens(address indexed withdrawer, uint amount);
  event Deposit(address indexed depositor, uint amount);

  constructor(address token_, bytes32 merkleRoot_) public {
    token = token_;
    merkleRoot = merkleRoot_;
  }

  function isClaimed(uint index) public view override returns (bool) {
    uint claimedWordIndex = index / 256;
    uint claimedBitIndex = index % 256;
    uint claimedWord = claimedBitMap[claimedWordIndex];
    uint mask = (1 << claimedBitIndex);
    return claimedWord & mask == mask;
  }

  function _setClaimed(uint index) private {
    uint claimedWordIndex = index / 256;
    uint claimedBitIndex = index % 256;
    claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
  }

  function claim(
    uint index,
    address account,
    uint amount,
    bytes32[] calldata merkleProof
  ) external override {
    require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

    // Verify the merkle proof.
    bytes32 node = keccak256(abi.encodePacked(index, account, amount));
    require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

    // Mark it claimed and send the token.
    _setClaimed(index);
    require(IERC20(token).transfer(account, amount), 'MerkleDistributor: Transfer failed.');

    emit Claimed(index, account, amount);
  }

  // Deposit token for merkle distribution
  function deposit(uint _amount) external onlyOwner {
    IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
    emit Deposit(msg.sender, _amount);
  }

  // Emergency withdraw tokens for admin
  function withdrawTokens(address _token, uint _amount) external onlyOwner {
    IERC20(_token).safeTransfer(msg.sender, _amount);
    emit WithdrawTokens(msg.sender, _token, _amount);
  }

  // Emergency withdraw reward tokens for admin
  function withdrawRewardTokens(uint _amount) external onlyOwner {
    IERC20(token).safeTransfer(msg.sender, _amount);
    emit WithdrawRewardTokens(msg.sender, _amount);
  }

  // Emergency withdraw ALL reward tokens for admin
  function withdrawAllRewardTokens() external onlyOwner {
    uint amount = IERC20(token).balanceOf(address(this));
    IERC20(token).safeTransfer(msg.sender, amount);
    emit WithdrawAllRewardTokens(msg.sender, amount);
  }

  function renounceOwnership() public override onlyOwner {
    revert('');
  }
}