/**
 *Submitted for verification at Etherscan.io on 2021-09-24
*/

// Sources flattened with hardhat v2.4.3 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/[email protected]


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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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


// File @openzeppelin/contracts/token/ERC20/[email protected]




/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// File @openzeppelin/contracts/utils/[email protected]




/**
 * @dev Collection of functions related to the address type
 */



// File @openzeppelin/contracts/token/ERC20/utils/[email protected]


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



// File @openzeppelin/contracts/utils/cryptography/[email protected]



/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */



// File contracts/Airdrop.sol

/**
 * @author Victor Fage <[email protected]>
 *
 * @notice Contract which provides a basic one ERC20 token airdrop, where an address can claim an amount
 * of reward ERC20 tokens, with the signature of the owner
 * Also the owner of the contract can remove the tokens
 * Before who the claimer send the claim the contract must was funded with reward ERC20 token
 */
contract Airdrop is Ownable {
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    // Events

    event EmergencyWithdraw(
        IERC20 token,
        uint256 amount
    );

    event ClaimAirdrop(
        IERC20 token,
        uint256 amount
    );

    // Storage

    /// @dev Store the users who already claim your rewards
    mapping(address => bool) public claimedAddress;

    function claimAirdrop(
        IERC20 _token,
        uint256 _amount,
        bytes calldata _signature
    ) external {
        address sender = msg.sender;

        require(!claimedAddress[sender], "Airdrop::claimAirdrop: The sender has already claimed the tokens");

        claimedAddress[sender] = true;

        bytes32 signatureMsg = keccak256(
            abi.encodePacked(
                address(this),
                sender,
                _token,
                _amount
            )
        );

        _token.safeTransfer(sender, _amount);

        require(
            owner() == signatureMsg.toEthSignedMessageHash().recover(_signature),
            "Airdrop::claimAirdrop: Invalid owner signature"
        );

        emit ClaimAirdrop(_token, _amount);
    }

    // OnlyOwner functions

    /**
     * @dev Use to withdraw ERC20 tokens or ETH in emergency cases
     *
     * @param _token The ERC20 token, if is address 0, ETH currency
     * @param _amount The amount of ERC20 token or ETH
     *
     * Requirements:
     *
     * - Only the owner can send this function
     */
    function emergencyWithdraw(IERC20 _token, uint256 _amount) external onlyOwner {
        address sender = msg.sender;

        if (address(_token) != address(0))
            _token.safeTransfer(sender, _amount);
        else
            payable(sender).transfer(_amount);

        emit EmergencyWithdraw(_token, _amount);
    }
}