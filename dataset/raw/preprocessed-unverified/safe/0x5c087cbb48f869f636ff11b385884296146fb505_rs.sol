/**
 *Submitted for verification at Etherscan.io on 2021-02-18
*/

// Dependency file: /Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol

// SPDX-License-Identifier: MIT

// pragma solidity >=0.4.24 <0.7.0;


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 * 
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 * 
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}


// Dependency file: /Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/GSN/ContextUpgradeable.sol


// pragma solidity ^0.6.0;
// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}


// Dependency file: /Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol


// pragma solidity ^0.6.0;

// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/GSN/ContextUpgradeable.sol";
// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
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
contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}


// Dependency file: /Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol


// pragma solidity ^0.6.0;

// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/GSN/ContextUpgradeable.sol";
// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}


// Dependency file: /Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/cryptography/MerkleProofUpgradeable.sol


// pragma solidity ^0.6.0;

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */



// Dependency file: /Users/starfish/code/badger-system/interfaces/digg/IDigg.sol

// pragma solidity >=0.5.0 <0.8.0;




// Dependency file: /Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: /Users/starfish/code/badger-system/interfaces/badger/IMerkleDistributor.sol

// pragma solidity >=0.5.0;

// Allows anyone to claim a token if they exist in a merkle root.


// Dependency file: contracts/badger-hunt/MerkleDistributor.sol

// pragma solidity ^0.6.11;

// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/cryptography/MerkleProofUpgradeable.sol";
// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
// import "/Users/starfish/code/badger-system/interfaces/badger/IMerkleDistributor.sol";

contract MerkleDistributor is Initializable, IMerkleDistributor {
    address public token;
    bytes32 public merkleRoot;

    // This is a packed array of booleans.
    mapping(uint256 => uint256) internal claimedBitMap;

    function __MerkleDistributor_init(address token_, bytes32 merkleRoot_) public initializer {
        token = token_;
        merkleRoot = merkleRoot_;
    }

    function isClaimed(uint256 index) public override view returns (bool) {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        uint256 claimedWord = claimedBitMap[claimedWordIndex];
        uint256 mask = (1 << claimedBitIndex);
        return claimedWord & mask == mask;
    }

    function _setClaimed(uint256 index) internal {
        uint256 claimedWordIndex = index / 256;
        uint256 claimedBitIndex = index % 256;
        claimedBitMap[claimedWordIndex] = claimedBitMap[claimedWordIndex] | (1 << claimedBitIndex);
    }

    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external virtual override {
        require(!isClaimed(index), "MerkleDistributor: Drop already claimed.");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProofUpgradeable.verify(merkleProof, merkleRoot, node), "MerkleDistributor: Invalid proof.");

        // Mark it claimed and send the token.
        _setClaimed(index);
        require(IERC20Upgradeable(token).transfer(account, amount), "MerkleDistributor: Transfer failed.");

        emit Claimed(index, account, amount);
    }
}


// Root file: contracts/badger-hunt/AirdropDistributor.sol

pragma solidity ^0.6.11;

// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
// import "/Users/starfish/code/badger-system/deps/@openzeppelin/contracts-upgradeable/cryptography/MerkleProofUpgradeable.sol";
// import "/Users/starfish/code/badger-system/interfaces/digg/IDigg.sol";
// import "contracts/badger-hunt/MerkleDistributor.sol";

/* ===== AirdropDistributor =====
    Variant on MerkleDistributor that encodes claimable values in DIGG amount, rather than balances
    This means the value claimable will remain constant through rebases

    After a preset delay, an owner can recall unclaimed DIGG to the treasury
*/
contract AirdropDistributor is MerkleDistributor, OwnableUpgradeable, PausableUpgradeable {
    address public rewardsEscrow;
    uint256 public reclaimAllowedTimestamp;
    bool public isOpen;

    mapping(address => bool) public isClaimTester;

    function initialize(
        address token_,
        bytes32 merkleRoot_,
        address rewardsEscrow_,
        uint256 reclaimAllowedTimestamp_,
        address[] memory claimTesters_
    ) public initializer whenNotPaused {
        __MerkleDistributor_init(token_, merkleRoot_);
        __Ownable_init();
        __Pausable_init_unchained();
        rewardsEscrow = rewardsEscrow_;
        reclaimAllowedTimestamp = reclaimAllowedTimestamp_;
        isOpen = false;

        for (uint256 i = 0; i < claimTesters_.length; i++) {
            isClaimTester[claimTesters_[i]] = true;
        }

        // Paused on launch
        _pause();
    }

    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external virtual override whenNotPaused {
        require(!isClaimed(index), "AirdropDistributor: Drop already claimed.");

        // Only test accounts can claim before launch
        if (isOpen == false) {
            _onlyClaimTesters(msg.sender);
        }

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProofUpgradeable.verify(merkleProof, merkleRoot, node), "AirdropDistributor: Invalid proof.");

        // Mark it claimed and send the token.
        _setClaimed(index);
        require(IDigg(token).transfer(account, amount), "AirdropDistributor: Transfer failed.");

        emit Claimed(index, account, amount);
    }

    /// ===== Gated Actions: Owner =====

    /// @notice Transfer unclaimed funds to rewards escrow
    function reclaim() external onlyOwner whenNotPaused {
        require(now >= reclaimAllowedTimestamp, "AirdropDistributor: Before reclaim timestamp");
        uint256 remainingBalance = IDigg(token).balanceOf(address(this));
        require(IERC20Upgradeable(token).transfer(rewardsEscrow, remainingBalance), "AirdropDistributor: Reclaim failed");
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function openAirdrop() external onlyOwner whenNotPaused {
        isOpen = true;
    }

    /// ===== Internal Helper Functions =====
    function _onlyClaimTesters(address account) internal view {
        require(isClaimTester[account], "onlyClaimTesters");
    }
}