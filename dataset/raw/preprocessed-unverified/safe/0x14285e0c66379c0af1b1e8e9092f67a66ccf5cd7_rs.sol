/**
 *Submitted for verification at Etherscan.io on 2020-11-08
*/

// Dependency file: @openzeppelin/contracts/utils/EnumerableSet.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */



// Dependency file: @openzeppelin/contracts/GSN/Context.sol


// pragma solidity ^0.6.0;

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


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity ^0.6.0;

// import "@openzeppelin/contracts/GSN/Context.sol";
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



// Dependency file: @openzeppelin/contracts/math/Math.sol


// pragma solidity ^0.6.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */



// Dependency file: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// pragma solidity ^0.6.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: contracts/interfaces/IAlpaToken.sol


// pragma solidity 0.6.12;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

interface IAlpaToken is IERC20 {
    function mint(address _to, uint256 _amount) external;
}


// Dependency file: contracts/interfaces/IAlpaSupplier.sol


// pragma solidity 0.6.12;




// Root file: contracts/AlpaSupplier/AlpaSupplier.sol


pragma solidity 0.6.12;

// import "@openzeppelin/contracts/utils/EnumerableSet.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "@openzeppelin/contracts/math/Math.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// import "contracts/interfaces/IAlpaToken.sol";
// import "contracts/interfaces/IAlpaSupplier.sol";

contract AlpaSupplier is Ownable, IAlpaSupplier, ReentrancyGuard {
    using SafeMath for uint256;
    using Math for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    // The ALPA ERC20 token
    IAlpaToken public alpa;

    // Set of address that are approved consumer
    EnumerableSet.AddressSet private approvedConsumers;

    // map of consumer address to consumer info
    mapping(address => ConsumerInfo) public consumerInfo;

    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;

    // number of ALPA tokens created per block.
    uint256 public alpaPerBlock;

    // dev address.
    address public devAddr;

    // community address.
    address public communityAddr;

    // Info of each consumer.
    struct ConsumerInfo {
        // Address of consumer.
        address consumer;
        // How many allocation points assigned to this consumer
        uint256 allocPoint;
        // Last block number that ALPAs distribution occurs.
        uint256 lastDistributeBlock;
    }

    constructor(
        IAlpaToken _alpa,
        uint256 _alpaPerBlock,
        address _devAddr,
        address _communityAddr
    ) public {
        alpa = _alpa;
        alpaPerBlock = _alpaPerBlock;
        devAddr = _devAddr;
        communityAddr = _communityAddr;
    }

    function isApprovedConsumer(address _consumer) public view returns (bool) {
        return approvedConsumers.contains(_consumer);
    }

    function distribute(uint256 _since)
        public
        override
        onlyApprovedConsumer
        nonReentrant
        returns (uint256)
    {
        address sender = _msgSender();

        ConsumerInfo storage consumer = consumerInfo[sender];
        uint256 multiplier = _getMultiplier(
            consumer.lastDistributeBlock,
            block.number,
            _since
        );
        if (multiplier == 0) {
            return 0;
        }

        consumer.lastDistributeBlock = block.number;
        uint256 amount = multiplier
            .mul(alpaPerBlock)
            .mul(consumer.allocPoint)
            .div(totalAllocPoint);

        // 10% of total reward goes to dev
        uint256 devReward = amount.div(10);
        alpa.mint(devAddr, devReward);

        // 10% of total reward goes to community
        uint256 communityReward = amount.div(10);
        alpa.mint(communityAddr, communityReward);

        //  rest goes to consumer
        uint256 consumerReward = amount.sub(devReward).sub(communityReward);
        alpa.mint(sender, consumerReward);

        return consumerReward;
    }

    function preview(address _consumer, uint256 _since)
        public
        override
        view
        returns (uint256)
    {
        require(
            approvedConsumers.contains(_consumer),
            "AlpaSupplier: consumer isn't approved"
        );

        ConsumerInfo storage consumer = consumerInfo[_consumer];
        uint256 multiplier = _getMultiplier(
            consumer.lastDistributeBlock,
            block.number,
            _since
        );
        if (multiplier == 0) {
            return 0;
        }

        uint256 amount = multiplier
            .mul(alpaPerBlock)
            .mul(consumer.allocPoint)
            .div(totalAllocPoint);

        // 80% of token goes to consumer
        return amount.mul(8).div(10);
    }

    // Return reward multiplier over the given _from to _to block.
    function _getMultiplier(
        uint256 _from,
        uint256 _to,
        uint256 _since
    ) private pure returns (uint256) {
        return _to.sub(_from.max(_since));
    }

    /* ========== OWNER ============= */

    /**
     * @dev Add a new consumer. Can only be called by the owner
     */
    function add(
        uint256 _allocPoint,
        address _consumer,
        uint256 _startBlock
    ) public onlyOwner {
        approvedConsumers.add(_consumer);
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        consumerInfo[_consumer] = ConsumerInfo({
            consumer: _consumer,
            allocPoint: _allocPoint,
            lastDistributeBlock: _startBlock
        });
    }

    /**
     * @dev Removes a consumer. Can only be called by the owner
     */
    function remove(address _consumer) public onlyOwner {
        require(
            approvedConsumers.contains(_consumer),
            "AlpaSupplier: consumer isn't approved"
        );

        approvedConsumers.remove(_consumer);

        totalAllocPoint = totalAllocPoint.sub(
            consumerInfo[_consumer].allocPoint
        );

        delete consumerInfo[_consumer];
    }

    /**
     * @dev Update the given consumer's ALPA allocation point. Can only be called by the owner.
     */
    function set(address _consumer, uint256 _allocPoint) public onlyOwner {
        require(
            approvedConsumers.contains(_consumer),
            "AlpaSupplier: consumer isn't approved"
        );

        totalAllocPoint = totalAllocPoint.add(_allocPoint).sub(
            consumerInfo[_consumer].allocPoint
        );
        consumerInfo[_consumer].allocPoint = _allocPoint;
    }

    // Transfer alpa owner to `_owner`
    // EMERGENCY ONLY
    function setAlpaOwner(address _owner) external onlyOwner {
        Ownable(address(alpa)).transferOwnership(_owner);
    }

    // Update number of ALPA to mint per block
    function setAlpaPerBlock(uint256 _alpaPerBlock) external onlyOwner {
        alpaPerBlock = _alpaPerBlock;
    }

    // Update dev address by the previous dev.
    function setDevAddr(address _devAddr) external {
        require(devAddr == _msgSender(), "AlpaSupplier: unauthorized");
        devAddr = _devAddr;
    }

    // Update community pool addr address by the previous dev.
    function setCommunityAddr(address _communityAddr) external {
        require(communityAddr == _msgSender(), "AlpaSupplier: unauthorized");
        communityAddr = _communityAddr;
    }

    /* ========== MODIFIER ========== */

    modifier onlyApprovedConsumer() {
        require(
            approvedConsumers.contains(_msgSender()),
            "AlpaSupplier: unauthorized"
        );
        _;
    }
}