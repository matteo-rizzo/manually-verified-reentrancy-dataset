/**
 *Submitted for verification at Etherscan.io on 2021-06-01
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

    uint256 private constant RECLAIM_LENGTH = 90 * 24 * 60 * 60; // 90 days
    uint256 public immutable reclaimDate;
    MerkleDistributor public immutable original;

    constructor(address token_, bytes32 merkleRoot_, address treasury_, address _original) public {
        token = token_;
        merkleRoot = merkleRoot_;
        treasury = treasury_;
        reclaimDate = now + RECLAIM_LENGTH;
        original = MerkleDistributor(_original);
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
        require(msg.sender == treasury, "TRE");
        require(now > reclaimDate, "DAT");
        IERC20(token).transfer(treasury, IERC20(token).balanceOf(address(this)));
    }

    function claimBoth(
        address account,
        uint256 index,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint256 indexOriginal,
        uint256 amountOriginal,
        bytes32[] calldata merkleProofOriginal
    ) external {
        this.claim(index, account, amount, merkleProof);
        original.claim(indexOriginal, account, amountOriginal, merkleProofOriginal);
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