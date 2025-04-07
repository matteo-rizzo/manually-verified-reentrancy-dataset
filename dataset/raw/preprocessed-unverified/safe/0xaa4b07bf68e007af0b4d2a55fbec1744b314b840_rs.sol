/**
 *Submitted for verification at Etherscan.io on 2021-04-07
*/

// SPDX-License-Identifier: MIT

// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol

// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: @openzeppelin/contracts/math/SafeMath.sol



// pragma solidity ^0.6.0;

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



// Dependency file: @openzeppelin/contracts/utils/Address.sol



// pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */



// Dependency file: @openzeppelin/contracts/token/ERC20/SafeERC20.sol



// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// Dependency file: @openzeppelin/contracts/cryptography/MerkleProof.sol



// pragma solidity ^0.6.0;

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */



// Dependency file: contracts/interfaces/IMerkleDistributor.sol

// pragma solidity >=0.5.0;

// Allows anyone to claim a token if they exist in a merkle root.


// Dependency file: contracts/MerkleDistributor.sol

// pragma solidity =0.6.11;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/cryptography/MerkleProof.sol";
// import "contracts/interfaces/IMerkleDistributor.sol";

contract MerkleDistributor is IMerkleDistributor {
    address public immutable override token;
    bytes32 public immutable override merkleRoot;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) private claimedBitMap;

    constructor(address token_, bytes32 merkleRoot_) public {
        token = token_;
        merkleRoot = merkleRoot_;
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
}


// Root file: contracts/MerkleDistributor2.sol

pragma solidity =0.6.11;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import "@openzeppelin/contracts/cryptography/MerkleProof.sol";
// import "contracts/MerkleDistributor.sol";

contract MerkleDistributor2 {
    using SafeERC20 for IERC20;

    MerkleDistributor immutable public baskBond;
    MerkleDistributor immutable public sushiLP;

    address immutable public owner;

    constructor(
        address _baskBond,
        bytes32 _baskBondMerkleRoot,
        address _sushiLP,
        bytes32 _sushiLPMerkleRoot
    ) public {
        baskBond = new MerkleDistributor(_baskBond, _baskBondMerkleRoot);
        sushiLP = new MerkleDistributor(_sushiLP, _sushiLPMerkleRoot);

        owner = msg.sender;
    }

    function claimBoth(
        uint256 indexBaskBond,
        address accountBaskBond,
        uint256 amountBaskBond,
        bytes32[] calldata merkleProofBaskBond,
        uint256 indexSushiLP,
        address accountSushiLP,
        uint256 amountSushiLP,
        bytes32[] calldata merkleProofSushiLP
    ) external {
        baskBond.claim(indexBaskBond, accountBaskBond, amountBaskBond, merkleProofBaskBond);
        sushiLP.claim(indexSushiLP, accountSushiLP, amountSushiLP, merkleProofSushiLP);
    }

    function recoverERC20(address _token) public {
        require(msg.sender == owner);
        IERC20(_token).safeTransfer(_token, IERC20(_token).balanceOf(address(this)));
    }
}