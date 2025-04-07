/**
 *Submitted for verification at Etherscan.io on 2021-05-27
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.5.17;



// Part: IERC1155



// Part: IERC1155TokenReceiver

/**
 * @dev ERC-1155 interface for accepting safe transfers.
 */


// Part: OpenZeppelin/[email protected]/Context

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: OpenZeppelin/[email protected]/Ownable

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: NFTBoosterVault.sol

contract NFTBoosterVault is IERC1155TokenReceiver, Ownable {
    using SafeMath for uint256;

    IERC1155 private nft;
    mapping(address => uint256) private stakedNFT;

    event Staked(address indexed user, uint256 indexed nftId);
    event Unstaked(address indexed user, uint256 indexed nftId);

    constructor(address _nft) public {
        nft = IERC1155(_nft);
    }

    function getNFTAddress() external view returns (address) {
        return address(nft);
    }

    function getStakedNFT(address user) external view returns (uint256) {
        return stakedNFT[user];
    }

    function stake(uint256 _nftId) external {
        require(stakedNFT[msg.sender] == 0, "already staked");
        stakedNFT[msg.sender] = _nftId;
        emit Staked(msg.sender, _nftId);
        nft.safeTransferFrom(msg.sender, address(this), _nftId, 1, "");
    }

    function unstake() external {
        uint256 nftId = stakedNFT[msg.sender];
        require(nftId != 0, "not staked");
        stakedNFT[msg.sender] = 0;
        emit Unstaked(msg.sender, nftId);
        nft.safeTransferFrom(address(this), msg.sender, nftId, 1, "");
    }

    function claimLockedNFTs(
        uint256[] calldata _ids,
        uint256[] calldata _amounts
    ) external onlyOwner {
        nft.safeBatchTransferFrom(
            address(this),
            msg.sender,
            _ids,
            _amounts,
            ""
        );
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external returns (bytes4) {
        // Accept only StakeDAO NFT
        if (msg.sender == address(nft)) {
            return 0xf23a6e61;
        }
        revert("nft not accepted");
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external returns (bytes4) {
        revert("batch transfer not accepted");
    }

    function supportsInterface(bytes4 interfaceID)
        external
        view
        returns (bool)
    {
        if (interfaceID == 0x4e2312e0) {
            return true;
        }
        return false;
    }
}