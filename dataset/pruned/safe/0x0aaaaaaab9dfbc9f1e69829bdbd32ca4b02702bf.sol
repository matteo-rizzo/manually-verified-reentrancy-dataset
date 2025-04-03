/**
 *Submitted for verification at Etherscan.io on 2021-02-27
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts/math/SafeMath.sol


pragma solidity ^0.6.0;

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


// File: @openzeppelin/contracts/utils/Address.sol


pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol


pragma solidity ^0.6.0;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: @openzeppelin/contracts/cryptography/MerkleProof.sol


pragma solidity ^0.6.0;

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */


// File: @openzeppelin/contracts/GSN/Context.sol


pragma solidity ^0.6.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


pragma solidity ^0.6.0;

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

// File: contracts/AirDropper.sol

pragma solidity >= 0.6.11;






contract AirDropper is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct AirDrop {
        address token;
        bytes32 merkleRoot;
        uint256 amount;
        mapping(uint256 => uint256) claimedBitMap;
    }
    mapping(uint256 => AirDrop) public airDrops;
    mapping(uint8 => bool) public isPaused;

    event AddedAirdrop(uint256 airdropId, address token, uint256 amount);
    event Claimed(uint256 airdropId, uint256 index, address account, uint256 amount);

    function addAirdrop(uint256 airdropId, address token, uint256 amount, bytes32 merkleRoot) external payable {
        require(!isPaused[0], "Paused");

        AirDrop storage airDrop = airDrops[airdropId];
        require(airDrop.token == address(0), "Airdrop already exists");
        // require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Can't transfer tokens from msg.sender");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        airDrop.token = token;
        airDrop.merkleRoot = merkleRoot;
        airDrop.amount = amount;
        emit AddedAirdrop(airdropId, token, amount);
    }

    function isClaimed(uint256 airdropId, uint256 index) public view returns (bool) {
        // to save the gas, whether user claim the token is stored in bitmap
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        AirDrop storage airDrop = airDrops[airdropId];
        uint256 claimedWord = airDrop.claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 airdropId, uint256 index) private {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        AirDrop storage airDrop = airDrops[airdropId];
        airDrop.claimedBitMap[claimedWordIndex] = airDrop.claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(uint256 airdropId, uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external {
        require(!isPaused[1], "Paused");

        AirDrop storage airDrop = airDrops[airdropId];
        require(airDrop.token != address(0), "Airdrop with given Id doesn't exists");
        require(!isClaimed(airdropId, index), "Account already claimed tokens.");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProof.verify(merkleProof, airDrop.merkleRoot, node), "Invalid Merkle-proof.");

        airDrop.amount.sub(amount);
        // Mark it claimed and send the token.
        _setClaimed(airdropId, index);
        IERC20(airDrop.token).safeTransfer(account, amount);

        emit Claimed(airdropId, index, account, amount);
    }

    event Received(address, uint);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function withdrawFee() onlyOwner external {
        msg.sender.transfer(address(this).balance);
    }

    function setPause(uint8 i, bool on)  onlyOwner external {
        isPaused[i] = on;
    }
}