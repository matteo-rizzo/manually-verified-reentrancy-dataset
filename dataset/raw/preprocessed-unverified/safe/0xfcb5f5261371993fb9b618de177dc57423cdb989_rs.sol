/**
 *Submitted for verification at Etherscan.io on 2020-11-11
*/

// SPDX-License-Identifier: MIT
// ParsiqRewarder smart-contract. Let's parse it!
pragma solidity 0.6.12;

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
 * @dev These functions deal with verification of Merkle trees (hash trees),
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


contract ParsiqRewarder is Ownable {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  using MerkleProof for bytes32[];

  IERC20TransferMany public token;
  address public tokenHolder;
  mapping(uint256 => bytes32) public epochRoots;
  mapping(address => uint256) public totalPayoutsFor;
  uint256 public lastBlockNumber;
  uint256 public pricePerBlock;
  uint256 public totalUnclaimed;

  event NewEpoch(bytes32 root, uint256 pricePerBlock);
  event UnclaimedChanged(uint256 totalUnclaimed);
  event Airdrop(uint256 totalDropped);

  constructor(address _token, address _tokenHolder, uint256 _programStart, uint256 _pricePerBlock) public {
    token = IERC20TransferMany(_token);
    tokenHolder = _tokenHolder;
    lastBlockNumber = _programStart;
    pricePerBlock = _pricePerBlock;
    emit NewEpoch(0x0, pricePerBlock);
  }

  function airdrop(address[] calldata beneficiaries, uint256[] calldata totalEarnings) external onlyOwner {
    require(beneficiaries.length == totalEarnings.length, "Invalid array length");

    uint256[] memory amounts = new uint256[](totalEarnings.length);

    uint256 total = 0;
    for (uint256 i = 0; i < beneficiaries.length; i++) {
      address beneficiary = beneficiaries[i];
      uint256 totalEarned = totalEarnings[i];
      uint256 totalReceived = totalPayoutsFor[beneficiary];
      require(totalEarned >= totalReceived, "Invalid batch");
      uint256 amount = totalEarned.sub(totalReceived);

      if (amount == 0) continue;

      amounts[i] = amount;
      total = total.add(amount);
      totalPayoutsFor[beneficiary] = totalEarned;
    }

    if (total == 0) return;

    decreaseUnclaimed(total);
    token.transferMany(beneficiaries, amounts);
    emit Airdrop(total);
  }

  function setTokenHolder(address account) public onlyOwner {
    require(account != address(0), "Zero address");
    tokenHolder = account;
  }
  
  function newEpoch(bytes32 epochRoot, uint256 blockNumber, uint256 newPricePerBlock) public onlyOwner {
    require(lastBlockNumber < blockNumber, "Invalid block number");
    require(blockNumber < block.number, "Invalid block number");
    epochRoots[blockNumber] = epochRoot;

    uint256 blocks = blockNumber.sub(lastBlockNumber);
    uint256 totalReward = blocks.mul(pricePerBlock);
    pricePerBlock = newPricePerBlock;
    lastBlockNumber = blockNumber;
    increaseUnclaimed(totalReward);

    token.transferFrom(tokenHolder, address(this), totalReward);
    emit NewEpoch(epochRoot, newPricePerBlock);
  }

  function claim(address recipient, uint256 totalEarned, uint256 blockNumber, bytes32[] calldata proof) external {
    require(isValidProof(recipient, totalEarned, blockNumber, proof), "Invalid proof");

    uint256 totalReceived = totalPayoutsFor[recipient];
    require(totalEarned >= totalReceived, "Already paid");

    uint256 amount = totalEarned.sub(totalReceived);
    if (amount == 0) return;

    totalPayoutsFor[recipient] = totalEarned;
    decreaseUnclaimed(amount);
    token.transfer(recipient, amount);
  }

  function isValidProof(address recipient, uint256 totalEarned, uint256 blockNumber, bytes32[] calldata proof) public view returns (bool) {
    uint256 chainId;
    assembly {
      chainId := chainid()
    }
    bytes32 leaf = keccak256(abi.encodePacked(recipient, totalEarned, chainId, address(this)));
    bytes32 root = epochRoots[blockNumber];
    return proof.verify(root, leaf);
  }

  function recoverTokens(IERC20 erc20, address to, uint256 amount) public onlyOwner {
    uint256 balance = erc20.balanceOf(address(this));

    if (address(erc20) == address(token)) {
      balance = balance.sub(totalUnclaimed);
    }

    require(balance >= amount, "Given amount is larger than recoverable balance");
    erc20.safeTransfer(to, amount);
  }

  function increaseUnclaimed(uint256 delta) internal {
    totalUnclaimed = totalUnclaimed.add(delta);
    emit UnclaimedChanged(totalUnclaimed);
  }

  function decreaseUnclaimed(uint256 delta) internal {
    totalUnclaimed = totalUnclaimed.sub(delta);
    emit UnclaimedChanged(totalUnclaimed);
  }
}

