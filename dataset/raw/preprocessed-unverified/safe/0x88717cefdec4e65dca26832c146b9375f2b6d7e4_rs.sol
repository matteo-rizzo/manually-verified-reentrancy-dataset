/**
 *Submitted for verification at Etherscan.io on 2021-04-05
*/

// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */


// 
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

// 
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

// 
// Allows anyone to claim a token if they exist in a merkle root.


// 
contract MerkleDistributor is IMerkleDistributor, Ownable {
  address public immutable override token;
  bytes32 public immutable override merkleRoot;
  uint256 public immutable override endTime;

  // This is a packed array of booleans.
  mapping(uint256 => uint256) private _claimedBitMap;

  constructor(
    address _token,
    bytes32 _merkleRoot,
    uint256 _endTime
  ) public {
    token = _token;
    merkleRoot = _merkleRoot;
    require(block.timestamp < _endTime, "Invalid endTime");
    endTime = _endTime;
  }

  /** @dev Modifier to check that claim period is active.*/
  modifier whenActive() {
    require(isActive(), "Claim period has ended");
    _;
  }

  function claim(
    uint256 _index,
    address _account,
    uint256 _amount,
    bytes32[] calldata merkleProof
  ) external override whenActive {
    require(!isClaimed(_index), "Drop already claimed");

    // Verify the merkle proof.
    bytes32 node = keccak256(abi.encodePacked(_index, _account, _amount));
    require(MerkleProof.verify(merkleProof, merkleRoot, node), "Invalid proof");

    // Mark it claimed and send the token.
    _setClaimed(_index);
    require(IERC20(token).transfer(_account, _amount), "Transfer failed");

    emit Claimed(_index, _account, _amount);
  }

  function isClaimed(uint256 _index) public view override returns (bool) {
    uint256 claimedWordIndex = _index / 256;
    uint256 claimedBitIndex = _index % 256;
    uint256 claimedWord = _claimedBitMap[claimedWordIndex];
    uint256 mask = (1 << claimedBitIndex);
    return claimedWord & mask == mask;
  }

  function isActive() public view override returns (bool) {
    return block.timestamp < endTime;
  }

  function recoverERC20(address _tokenAddress, uint256 _tokenAmount) public onlyOwner {
    IERC20(_tokenAddress).transfer(owner(), _tokenAmount);
  }

  function _setClaimed(uint256 _index) private {
    uint256 claimedWordIndex = _index / 256;
    uint256 claimedBitIndex = _index % 256;
    _claimedBitMap[claimedWordIndex] = _claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
  }
}