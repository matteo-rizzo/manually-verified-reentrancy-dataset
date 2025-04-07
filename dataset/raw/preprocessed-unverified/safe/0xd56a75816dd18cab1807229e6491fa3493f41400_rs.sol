/**
 *Submitted for verification at Etherscan.io on 2021-04-29
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.6.12;



// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/MerkleProof

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */


// File: MooncatDistributor.sol

contract MooncatDistributor {
	using MerkleProof for bytes32[];

	IERC20 public token;

	bytes32 public merkleRoot;
	mapping(uint256 => uint256) public claimedBitMap;
	uint256 expiryDate;
	address owner;

	event Claimed(uint256 index, address account, uint256 amount);

	constructor(address _token, bytes32 _root, uint256 _expiry, address _owner) public {
		token = IERC20(_token);
		merkleRoot = _root;
		expiryDate = _expiry;
		owner = _owner;
	}

	function fetchUnclaimed() external {
		require(block.timestamp > expiryDate, "!date");
		require(token.transfer(owner, token.balanceOf(address(this))), "Token transfer failed");
	}

	function isClaimed(uint256 _index) public view returns(bool) {
		uint256 wordIndex = _index / 256;
		uint256 bitIndex = _index % 256;
		uint256 word = claimedBitMap[wordIndex];
		uint256 bitMask = 1 << bitIndex;
		return word & bitMask == bitMask;
	}

	function _setClaimed(uint256 _index) internal {
		uint256 wordIndex = _index / 256;
		uint256 bitIndex = _index % 256;
		claimedBitMap[wordIndex] |= 1 << bitIndex;
	}

	function claim(uint256 _index, address _account, uint256 _amount, bytes32[] memory _proof) external {
		require(!isClaimed(_index), "Claimed already");
		bytes32 node = keccak256(abi.encodePacked(_index, _account, _amount));
		require(_proof.verify(merkleRoot, node), "Wrong proof");
		
		_setClaimed(_index);
		require(token.transfer(_account, _amount), "Token transfer failed");
		emit Claimed(_index, _account, _amount);
	}
}