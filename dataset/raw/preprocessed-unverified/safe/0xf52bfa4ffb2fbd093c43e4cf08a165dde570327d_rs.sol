/**
 *Submitted for verification at Etherscan.io on 2021-04-13
*/

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.6.11;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */




contract MerkleDistributor  {
    address public token;
    bytes32 public merkleRoot;
    uint256 public  startTimestamp;
    
    event Claimed(uint256 index, address account, uint256 amount);

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(address token_, bytes32 merkleRoot_, uint256 _startTimestamp) public {
        token = token_;
        merkleRoot = merkleRoot_;
        startTimestamp = _startTimestamp == 0 ? blockTimestamp() : _startTimestamp;
    }
    
    function blockTimestamp() public view virtual returns (uint256) {
       return block.timestamp;
   }

    function isClaimed(uint256 index) public view  returns (bool) {
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

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external  {
        require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');
        require(blockTimestamp()>startTimestamp,'Airdrop not start yet');

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

        // Mark it claimed and send the token.
        _setClaimed(index);
        require(IERC20(token).transfer(account, amount), 'MerkleDistributor: Transfer failed.');

        emit Claimed(index, account, amount);
    }
}