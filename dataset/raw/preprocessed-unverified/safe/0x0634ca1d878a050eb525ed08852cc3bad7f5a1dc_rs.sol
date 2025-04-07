/**
 *Submitted for verification at Etherscan.io on 2021-08-25
*/

// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: @openzeppelin/contracts/cryptography/MerkleProof.sol


// pragma solidity ^0.6.0;

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */



// Dependency file: contracts/interfaces/IMerkleDistributor.sol

// pragma solidity >=0.5.0;

// Allows anyone to claim a token if they exist in a merkle root.


// Root file: contracts/MerkleDistributor.sol

pragma solidity =0.6.11;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/cryptography/MerkleProof.sol";
// import "contracts/interfaces/IMerkleDistributor.sol";

contract MerkleDistributor is IMerkleDistributor {
    address public immutable override token;
    bytes32 public immutable override merkleRoot;
    address public immutable override funder;
    uint256 public immutable override fundingAmount;
    bool public override isFunded;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(address token_, bytes32 merkleRoot_, address funder_, uint256 fundingAmount_) public {
        token = token_;
        merkleRoot = merkleRoot_;
        funder = funder_;
        fundingAmount = fundingAmount_;
        isFunded = false;
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

    function fund() external override {
        require(!isFunded, 'MerkleDistributor: Distributor has already been funded.');

        isFunded = true;

        require(IERC20(token).transferFrom(funder, address(this), fundingAmount), 'MerkleDistributor: Funding failed.');

        emit Funded(funder, fundingAmount);
    }
}