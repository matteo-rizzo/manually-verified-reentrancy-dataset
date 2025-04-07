/**
 *Submitted for verification at Etherscan.io on 2021-06-25
*/

// Dependency file: @openzeppelin/contracts/utils/EnumerableSet.sol

// SPDX-License-Identifier: MIT

// pragma solidity >=0.6.0 <0.8.0;

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
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */



// Dependency file: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// pragma solidity >=0.6.0 <0.8.0;

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
abstract contract ReentrancyGuard {
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


// Dependency file: @openzeppelin/contracts/utils/Context.sol


// pragma solidity >=0.6.0 <0.8.0;

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


// pragma solidity >=0.6.0 <0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";
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
    constructor () internal {
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


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// Dependency file: @openzeppelin/contracts/math/SafeMath.sol


// pragma solidity >=0.6.0 <0.8.0;

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



// Dependency file: src/contracts/IPriceFetcher.sol


// pragma solidity 0.7.6;

abstract contract IPriceFetcher {
    function decimals() public view virtual returns (uint8);
    function currentPrice(address tokenAddress) external view virtual returns (uint256);
}

// Dependency file: src/contracts/IMigrationAgent.sol


// pragma solidity 0.7.6;

abstract contract IMigrationAgent {
    function makeMigration(address owner, uint256 depositIndex) external virtual;
    function migrationTarget() external virtual returns (address payable);
    receive() external payable virtual;
}


// Root file: src/contracts/CryptoFreezer.sol


pragma solidity 0.7.6;

// import "@openzeppelin/contracts/utils/EnumerableSet.sol";
// import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/math/SafeMath.sol";
// import "src/contracts/IPriceFetcher.sol";
// import "src/contracts/IMigrationAgent.sol";

contract CryptoFreezer is Ownable, ReentrancyGuard {
    struct Deposit {
        address token;
        uint256 value;
        uint256 unlockTimeUTC;
        uint256 minPrice;
    }

    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    uint256 public maxTimeLockPeriod = 5 * 365 days;

    EnumerableSet.AddressSet private _supportedTokens;
    // user => deposits[]
    mapping(address => Deposit[]) public deposits;
    IPriceFetcher public priceFetcher = IPriceFetcher(0x0);

    address payable public migrationAgent = address(0);

    event SupportedTokenAdded(IERC20 indexed token);
    event NewDeposit(
        address indexed token,
        address indexed owner,
        uint256 value,
        uint256 unlockTimeUTC,
        uint256 minPrice,
        uint256 index
    );
    event Withdraw(address indexed token, address indexed owner, uint256 depositIndex, uint256 value, uint256 unlockTimeUTC, uint256 minPrice);
    event AddToDeposit(address indexed owner, uint256 depositIndex, uint256 value);
    event Migrated(address indexed token, address indexed owner, uint256 depositIndex, uint256 value, uint256 unlockTimeUTC, uint256 minPrice, address indexed target);

    function priceDecimals() public view returns (uint8) {
        return priceFetcher.decimals();
    }

    function addSupportedToken(IERC20 token) public onlyOwner {
        require(!isTokenSupported(token), "Token already supported");

        _supportedTokens.add(address(token));
        emit SupportedTokenAdded(token);
    }

    function setPriceFetcher(IPriceFetcher fetcher) public onlyOwner {
        priceFetcher = fetcher;
    }

    function setMaxTimeLockPeriod(uint256 newMaxTimeLockPeriod) public onlyOwner {
        maxTimeLockPeriod = newMaxTimeLockPeriod;
    }

    function isTokenSupported(IERC20 token) public view returns (bool) {
        return _supportedTokens.contains(address(token));
    }

    function isUnlocked(address owner, uint256 depositIndex) public view returns(bool) {
        return _isUnlocked(deposits[owner][depositIndex]);
    }

    function nextDepositIndex(address owner) public view returns (uint256) {
        return deposits[owner].length;
    }

    function _isUnlocked(Deposit memory deposit) internal view returns(bool) {
        if(block.timestamp < deposit.unlockTimeUTC) {
            return address(priceFetcher) != address(0x0)
                && deposit.minPrice <= priceFetcher.currentPrice(deposit.token);
        } else {
            return true;
        }
    }

    function depositERC20(IERC20 token, uint256 value, uint256 unlockTimeUTC, uint256 minPrice) public {
        depositERC20(token, value, unlockTimeUTC, minPrice, msg.sender);
    }

    function depositERC20(
        IERC20 token,
        uint256 value,
        uint256 unlockTimeUTC,
        uint256 minPrice,
        address owner
    ) public nonReentrant {
        require(value > 0, "Value is 0");
        require(unlockTimeUTC > block.timestamp, "Unlock time set in the past");
        require(isTokenSupported(token), "Token not supported");
        require(unlockTimeUTC - block.timestamp <= maxTimeLockPeriod, "Time lock period too long");
        require(owner != address(0));

        deposits[owner].push(Deposit(address(token), value, unlockTimeUTC, minPrice));
        require(token.transferFrom(msg.sender, address(this), value), "Cannot transfer ERC20 (deposit)");

        emit NewDeposit(address(token), owner, value, unlockTimeUTC, minPrice, deposits[owner].length - 1);
    }

    function withdrawERC20(
        address owner,
        uint256 depositIndex
    ) public nonReentrant {
        require(owner != address(0), "Owner address is 0");
        require(deposits[owner].length > depositIndex, "Invalid deposit index");
        Deposit memory deposit = deposits[owner][depositIndex];
        require(deposit.value > 0, "Deposit does not exist");

        require(_isUnlocked(deposit), "Deposit is locked");
        require(deposit.token != address(0), "Withdrawing wrong deposit type (ERC20)");

        IERC20 token = IERC20(deposit.token);

        // Withdrawing
        delete deposits[owner][depositIndex];
        require(token.transfer(owner, deposit.value), "Cannot transfer ERC20 (withdraw)");

        emit Withdraw(address(token), owner, deposit.value, depositIndex, deposit.unlockTimeUTC, deposit.minPrice);
    }

    function depositETH(
        uint256 unlockTimeUTC,
        uint256 minPrice
    ) public payable {
        depositETH(unlockTimeUTC, minPrice, msg.sender);
    }

    function depositETH(
        uint256 unlockTimeUTC,
        uint256 minPrice,
        address owner
    ) public payable nonReentrant {
        require(msg.value > 0, "Value is 0");
        require(unlockTimeUTC > block.timestamp, "Unlock time set in the past");
        require(unlockTimeUTC - block.timestamp <= maxTimeLockPeriod, "Time lock period too long");
        require(owner != address(0));

        deposits[owner].push(Deposit(address(0), msg.value, unlockTimeUTC, minPrice));

        emit NewDeposit(address(0), owner, msg.value, unlockTimeUTC, minPrice, deposits[owner].length - 1);
    }

    function withdrawETH(
        address payable owner,
        uint256 depositIndex
    ) public nonReentrant {
        require(owner != address(0), "Owner address is 0");
        require(deposits[owner].length > depositIndex, "Invalid deposit index");
        Deposit memory deposit = deposits[owner][depositIndex];

        require(deposit.value > 0, "Deposit does not exist");
        require(_isUnlocked(deposit), "Deposit is locked");
        require(deposit.token == address(0), "Withdrawing wrong deposit type (ETH)");

        // Withdrawing
        delete deposits[owner][depositIndex];
        owner.transfer(deposit.value);

        emit Withdraw(address(0), owner, deposit.value, depositIndex, deposit.unlockTimeUTC, deposit.minPrice);
    }

    function addToDepositERC20(
        uint256 depositIndex,
        uint256 value
    ) public {
        addToDepositERC20(depositIndex, value, msg.sender);
    }

    function addToDepositERC20(
        uint256 depositIndex,
        uint256 value,
        address owner
    ) public nonReentrant {
        require(value > 0, "Value is 0");
        require(deposits[owner].length > depositIndex, "Invalid deposit index");
        Deposit storage deposit = deposits[owner][depositIndex];
        require(deposit.value > 0, "Deposit does not exist");

        require(!_isUnlocked(deposit), "Deposit is unlocked");

        require(deposits[owner][depositIndex].token != address(0), "Adding to wrong deposit type (ERC20)");
        IERC20 token = IERC20(deposit.token);

        deposit.value = deposit.value.add(value);
        require(token.transferFrom(msg.sender, address(this), value), "Cannot transfer ERC20 (deposit)");

        emit AddToDeposit(owner, depositIndex, value);
    }

    function addToDepositETH(
        uint256 depositIndex
    ) public payable {
        addToDepositETH(depositIndex, msg.sender);
    }

    function addToDepositETH(
        uint256 depositIndex,
        address owner
    ) public payable nonReentrant {
        require(msg.value > 0, "Value is 0");
        require(deposits[owner].length > depositIndex, "Invalid deposit index");
        Deposit storage deposit = deposits[owner][depositIndex];
        require(deposit.value > 0, "Deposit does not exist");

        require(!_isUnlocked(deposit), "Deposit is unlocked");

        require(deposits[owner][depositIndex].token == address(0), "Adding to wrong deposit type (ETH)");

        deposit.value = deposit.value.add(msg.value);

        emit AddToDeposit(owner, depositIndex, msg.value);
    }

    function setMigrationAgent(address payable newMigrationAgent) public onlyOwner {
        migrationAgent = newMigrationAgent;
    }

    function migrate(uint256 depositIndex) public nonReentrant {
        require(migrationAgent != address(0));

        Deposit memory deposit = deposits[msg.sender][depositIndex];
        require(deposit.value > 0, "Deposit does not exist");

        IMigrationAgent agent = IMigrationAgent(migrationAgent);

        if(deposit.token != address(0)) {
            require(IERC20(deposit.token).transfer(agent.migrationTarget(), deposit.value));
        } else { // ETH case
            agent.migrationTarget().transfer(deposit.value);
        }

        agent.makeMigration(msg.sender, depositIndex);

        delete deposits[msg.sender][depositIndex];

        emit Migrated(
            deposit.token,
            msg.sender,
            deposit.value,
            deposit.unlockTimeUTC,
            deposit.minPrice,
            depositIndex,
            agent.migrationTarget()
        );
    }
}