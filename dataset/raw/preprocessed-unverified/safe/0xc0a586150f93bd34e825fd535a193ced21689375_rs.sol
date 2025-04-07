/**
 *Submitted for verification at Etherscan.io on 2020-10-08
*/

/**
 *Submitted for verification at Etherscan.io on 2020-09-30
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.6.11;

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
    address public deployer;
    uint256 public end = 0;

    constructor(address token_, bytes32 merkleRoot_) public {
        token = token_;
        merkleRoot = merkleRoot_;
        deployer = msg.sender;
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

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) override external {
        require(!isClaimed(index), 'MerkleDistributor: Drop already claimed.');

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, merkleRoot, node), 'MerkleDistributor: Invalid proof.');

        // Mark it claimed and send the token.
        _setClaimed(index);
        require(IERC20(token).transfer(account, amount), 'MerkleDistributor: Transfer failed.');

        emit Claimed(index, account, amount);
    }

    function collectDust(address _token, uint256 _amount) external {
      require(msg.sender == deployer, "!deployer");
      require(_token != token, "!token");
      if (_token == address(0)) { // token address(0) = ETH
        payable(deployer).transfer(_amount);
      } else {
        IERC20(_token).transfer(deployer, _amount);
      }
    }
    
    function lastCall() external {
        require(msg.sender == deployer, "!deployer");
        require(end == 0, "Already last call");
        end = block.timestamp + 1 days;
    }
    
    function burn() external {
        require(end != 0, "No last call");
        require(block.timestamp > end, "Too early");
        require(IERC20(token).transfer(address(0), IERC20(token).balanceOf(address(this))), 'MerkleDistributor: Burn failed.');
    }
}