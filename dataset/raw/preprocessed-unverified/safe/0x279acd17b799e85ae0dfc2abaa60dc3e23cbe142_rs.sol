/**
 *Submitted for verification at Etherscan.io on 2021-05-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



// Allows anyone to claim a token if they exist in a merkle root.


contract ETHDistributor is IMerkleDistributor {
    bytes32 public immutable override merkleRoot;
    address public owner;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(bytes32 merkleRoot_) {
        merkleRoot = merkleRoot_;
        owner = msg.sender;
    }

    receive() external payable {}

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

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external override {
        require(!isClaimed(index), 'ETHDistributor: Drop already claimed.');

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'ETHDistributor: Invalid proof.');

        // Mark it claimed and send the token.
        _setClaimed(index);
        payable(account).transfer(amount);

        emit Claimed(index, account, amount);
    }

    function withdrawRemaining() external {
        require(msg.sender == owner, "ETHDistributor: wrong sender");
        payable(msg.sender).transfer(address(this).balance);
    }
}