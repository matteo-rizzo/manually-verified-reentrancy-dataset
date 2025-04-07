/**
 *Submitted for verification at Etherscan.io on 2021-05-26
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.11;

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
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */


// Allows anyone to claim a token if they exist in a merkle root.


contract MerkleDistributor is IMerkleDistributor {
    address public operator;
    uint256 public startTime;

    address public immutable override token;
    bytes32 public immutable override merkleRoot;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    mapping(address => bool) public blacklisted; // if the snapshot is wrong we need to block the account to receive token
    bool public paused;

    constructor(address token_, bytes32 merkleRoot_) public {
        token = token_;
        merkleRoot = merkleRoot_;
        operator = msg.sender;
        startTime = block.timestamp;
    }

    modifier onlyOperator() {
        require(operator == msg.sender, "caller is not the operator");
        _;
    }

    modifier notPaused() {
        require(!paused, "distribution is paused");
        _;
    }

    function pause() external onlyOperator {
        paused = true;
    }

    function unpause() external onlyOperator {
        paused = false;
    }

    function setBlacklisted(address _account, bool _status) external onlyOperator {
        blacklisted[_account] = _status;
    }

    function isClaimed(uint256 index) public view override returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external override notPaused {
        require(!isClaimed(index), "MerkleDistributor: Drop already claimed.");
        require(!blacklisted[account], "MerkleDistributor: Account is blocked.");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), "MerkleDistributor: Invalid proof.");

        // Mark it claimed and send the token.
        _setClaimed(index);
        require(IERC20(token).transfer(account, amount), "MerkleDistributor: Transfer failed.");

        emit Claimed(index, account, amount);
    }

    function governanceRecoverUnsupported(address _token, uint256 _amount) external onlyOperator {
        IERC20(_token).transfer(operator, _amount);
    }
}