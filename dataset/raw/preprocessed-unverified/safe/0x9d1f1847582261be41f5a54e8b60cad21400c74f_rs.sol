/**
 *Submitted for verification at Etherscan.io on 2021-05-04
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.7;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */


// Allows anyone to claim a token if they exist in a merkle root.


contract MerkleDistributor is IMerkleDistributor {
    address public immutable override token;
    bytes32 public immutable override merkleRoot;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    address public immutable treasury;

    uint256 private constant RECLAIM_LENGTH = 90 days;
    uint256 public immutable reclaimDate;

    constructor(address token_, bytes32 merkleRoot_, address treasury_) public {
        token = token_;
        merkleRoot = merkleRoot_;
        treasury = treasury_;
        reclaimDate = block.timestamp + RECLAIM_LENGTH;
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

    function reclaim() external {
        require(msg.sender == treasury, "MerkleDistributor: Not treasury.");
        require(block.timestamp > reclaimDate, "MerkleDistributor: Claim period active.");
        IERC20(token).transfer(treasury, IERC20(token).balanceOf(address(this)));
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external override {
        require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

        // Mark it claimed and send the token.
        _setClaimed(index);
        require(IERC20(token).transfer(account, amount), 'MerkleDistributor: Transfer failed.');

        emit Claimed(index, account, amount);
    }
}