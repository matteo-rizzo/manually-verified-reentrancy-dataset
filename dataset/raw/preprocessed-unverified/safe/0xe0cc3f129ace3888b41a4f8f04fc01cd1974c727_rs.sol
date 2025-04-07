/**
 *Submitted for verification at Etherscan.io on 2020-12-03
*/

// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol

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


// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/GSN/ContextUpgradeable.sol


// pragma solidity ^0.6.0;
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

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


// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol


// pragma solidity ^0.6.0;

// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/GSN/ContextUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
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


// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol


// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol


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



// Dependency file: /Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/cryptography/MerkleProofUpgradeable.sol


// pragma solidity ^0.6.0;

/**
 * @dev These functions deal with verification of Merkle trees (hash trees),
 */



// Dependency file: /Users/present/code/brownie-sett/interfaces/badger/IMerkleDistributor.sol

// pragma solidity >=0.5.0;

// Allows anyone to claim a token if they exist in a merkle root.


// Dependency file: contracts/badger-hunt/MerkleDistributor.sol

// SP-License-upgradeable-Identifier: UNLICENSED
// pragma solidity ^0.6.11;

// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/cryptography/MerkleProofUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
// import "/Users/present/code/brownie-sett/interfaces/badger/IMerkleDistributor.sol";

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


// Root file: contracts/badger-hunt/BadgerHunt.sol

pragma solidity ^0.6.11;

// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
// import "/Users/present/code/brownie-sett/deps/@openzeppelin/contracts-upgradeable/cryptography/MerkleProofUpgradeable.sol";
// import "/Users/present/code/brownie-sett/interfaces/badger/IMerkleDistributor.sol";
// import "contracts/badger-hunt/MerkleDistributor.sol";

contract BadgerHunt is MerkleDistributor, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;
    uint256 public constant MAX_BPS = 10000;

    uint256 public claimsStart;
    uint256 public gracePeriod;

    uint256 public epochDuration;
    uint256 public rewardReductionPerEpoch;
    uint256 public currentRewardRate;
    uint256 public finalEpoch;

    address public rewardsEscrow;

    event Hunt(uint256 index, address indexed account, uint256 amount, uint256 userClaim, uint256 rewardsEscrowClaim);

    function initialize(
        address token_,
        bytes32 merkleRoot_,
        uint256 epochDuration_,
        uint256 rewardReductionPerEpoch_,
        uint256 claimsStart_,
        uint256 gracePeriod_,
        address rewardsEscrow_,
        address owner_
    ) public initializer {
        __MerkleDistributor_init(token_, merkleRoot_);

        __Ownable_init();
        transferOwnership(owner_);

        epochDuration = epochDuration_;
        rewardReductionPerEpoch = rewardReductionPerEpoch_;
        claimsStart = claimsStart_;
        gracePeriod = gracePeriod_;

        rewardsEscrow = rewardsEscrow_;

        currentRewardRate = 10000;

        finalEpoch = (currentRewardRate / rewardReductionPerEpoch_) - 1;
    }

    /// ===== View Functions =====
    /// @dev Get grace period end timestamp
    function getGracePeriodEnd() public view returns (uint256) {
        return claimsStart.add(gracePeriod);
    }

    /// @dev Get claims start timestamp
    function getClaimsStartTime() public view returns (uint256) {
        return claimsStart;
    }

    /// @dev Get the next epoch start
    function getNextEpochStart() public view returns (uint256) {
        uint256 epoch = getCurrentEpoch();

        if (epoch == 0) {
            return getGracePeriodEnd();
        } else {
            return getGracePeriodEnd().add(epochDuration.mul(epoch));
        }
    }

    function getTimeUntilNextEpoch() public view returns (uint256) {
        uint256 epoch = getCurrentEpoch();

        if (epoch == 0) {
            return getGracePeriodEnd().sub(now);
        } else {
            return (getGracePeriodEnd().add(epochDuration.mul(epoch))).sub(now);
        }
    }

    /// @dev Get the current epoch number
    function getCurrentEpoch() public view returns (uint256) {
        uint256 gracePeriodEnd = claimsStart.add(gracePeriod);

        if (now < gracePeriodEnd) {
            return 0;
        }
        uint256 secondsPastGracePeriod = now.sub(gracePeriodEnd);
        return (secondsPastGracePeriod / epochDuration).add(1);
    }

    /// @dev Get the rewards % of current epoch
    function getCurrentRewardsRate() public view returns (uint256) {
        uint256 epoch = getCurrentEpoch();
        if (epoch == 0) return MAX_BPS;
        if (epoch > finalEpoch) return 0;
        else return MAX_BPS.sub(epoch.mul(rewardReductionPerEpoch));
    }

    /// @dev Get the rewards % of following epoch
    function getNextEpochRewardsRate() public view returns (uint256) {
        uint256 epoch = getCurrentEpoch().add(1);
        if (epoch == 0) return MAX_BPS;
        if (epoch > finalEpoch) return 0;
        else return MAX_BPS.sub(epoch.mul(rewardReductionPerEpoch));
    }

    /// ===== Public Actions =====

    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external virtual override {
        require(now >= claimsStart, "BadgerDistributor: Before claim start.");
        require(account == msg.sender, "BadgerDistributor: Can only claim for own account.");
        require(getCurrentRewardsRate() > 0, "BadgerDistributor: Past rewards claim period.");
        require(!isClaimed(index), "BadgerDistributor: Drop already claimed.");

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        require(MerkleProofUpgradeable.verify(merkleProof, merkleRoot, node), "BadgerDistributor: Invalid proof.");

        // Mark it claimed and send the token.
        _setClaimed(index);

        uint256 claimable = amount.mul(getCurrentRewardsRate()).div(MAX_BPS);

        require(IERC20Upgradeable(token).transfer(account, claimable), "Transfer to user failed.");
        emit Hunt(index, account, amount, claimable, amount.sub(claimable));
    }

    /// ===== Gated Actions: Owner =====

    /// @notice After hunt is complete, transfer excess funds to rewardsEscrow
    function recycleExcess() external onlyOwner {
        require(getCurrentRewardsRate() == 0 && getCurrentEpoch() > finalEpoch, "Hunt period not finished");
        uint256 remainingBalance = IERC20Upgradeable(token).balanceOf(address(this));
        IERC20Upgradeable(token).transfer(rewardsEscrow, remainingBalance);
    }
}