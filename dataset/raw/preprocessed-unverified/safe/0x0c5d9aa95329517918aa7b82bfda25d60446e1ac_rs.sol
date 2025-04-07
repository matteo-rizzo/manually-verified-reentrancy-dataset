/**
 *Submitted for verification at Etherscan.io on 2021-05-10
*/

// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.6.11;

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


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


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



interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}



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

//!! Locker does not support locks for rebasing tokens or fee tokens!
//!! Meant to be used for only standard ERC20 tokens
contract Locker is Ownable, ReentrancyGuard {
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    // --------- Contract Variables ---------
    
    uint public constant MAX_LOCK_DURATION = 365 days;
    address public constant PLATFORM_TOKEN = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17;
    
    // Minimum basetoken value (eg. 1.8%) should be transferred to contract
    // to create a lock, there's no max, any amount may be transferred for max
    uint public constant MINIMUM_BASETOKEN_PERCENT_ETH_X_100 = 100;
    uint public constant ONE_HUNDRED_X_100 = 10000;
    uint public constant SLIPPAGE_TOLERANCE_X_100 = 300;

    
    // -------- END Contract Variables ------
    
    event Locked(uint indexed id, address indexed token, address indexed recipient, uint amount, uint unlockTimestamp, uint platformTokensLocked, bool claimed);
    event Unlocked(uint indexed id, address indexed token, address indexed recipient, uint amount, uint unlockTimestamp, uint platformTokensLocked, bool claimed);
    
    struct Lock {
        address token;
        uint unlockTimestamp;
        uint amount;
        address recipient;
        bool claimed;
        uint platformTokensLocked;
    }
    
    uint public locksLength;
    
    // token => balance
    mapping (address => uint) public tokenBalances;
    
    // lock id => Lock
    mapping (uint => Lock) public locks;
    
    EnumerableSet.AddressSet private lockedTokens;
    EnumerableSet.AddressSet private baseTokens;
    
    
    EnumerableSet.UintSet private activeLockIds;
    EnumerableSet.UintSet private inactiveLockIds;
    
    mapping (address => EnumerableSet.UintSet) private activeLockIdsByRecipient;
    mapping (address => EnumerableSet.UintSet) private activeLockIdsByToken;
    
    mapping (address => EnumerableSet.UintSet) private inactiveLockIdsByRecipient;
    mapping (address => EnumerableSet.UintSet) private inactiveLockIdsByToken;
    
    // Contracts are not allowed to execute functions
    modifier noContractsAllowed() {
        require(!(address(msg.sender).isContract()) && tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }
    
    IUniswapV2Router02 public uniswapRouterV2;
    
    constructor() public {
        uniswapRouterV2 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        addBaseToken(uniswapRouterV2.WETH());
    }
    
    function getActiveLockIdsLength() external view returns (uint) {
        return activeLockIds.length();
    }
    function getActiveLockIds(uint startIndex, uint endIndex) external view returns (uint[] memory result) {
        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= activeLockIds.length(), "Invalid endIndex!");
        result = new uint[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = activeLockIds.at(startIndex.add(i));   
        }
    }
    
    function getInactiveLockIdsLength() external view returns (uint) {
        return inactiveLockIds.length();
    }
    function getInactiveLockIds(uint startIndex, uint endIndex) external view returns (uint[] memory result) {
        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= inactiveLockIds.length(), "Invalid endIndex!");
        result = new uint[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = inactiveLockIds.at(startIndex.add(i));   
        }
    }
    
    function getInactiveLockIdsLengthByToken(address token) external view returns (uint) {
        return inactiveLockIdsByToken[token].length();
    }
    function getInactiveLockIdsByToken(address token, uint startIndex, uint endIndex) external view returns (uint[] memory result) {
        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= inactiveLockIdsByToken[token].length(), "Invalid endIndex!");
        result = new uint[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = inactiveLockIdsByToken[token].at(startIndex.add(i));   
        }
    }
    
    function getInactiveLockIdsLengthByRecipient(address recipient) external view returns (uint) {
        return inactiveLockIdsByRecipient[recipient].length();
    }
    function getInactiveLockIdsByRecipient(address recipient, uint startIndex, uint endIndex) external view returns (uint[] memory result) {
        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= inactiveLockIdsByRecipient[recipient].length(), "Invalid endIndex!");
        result = new uint[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = inactiveLockIdsByRecipient[recipient].at(startIndex.add(i));   
        }
    }
    
    function getActiveLockIdsLengthByToken(address token) external view returns (uint) {
        return activeLockIdsByToken[token].length();
    }
    function getActiveLockIdsByToken(address token, uint startIndex, uint endIndex) external view returns (uint[] memory result) {
        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= activeLockIdsByToken[token].length(), "Invalid endIndex!");
        result = new uint[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = activeLockIdsByToken[token].at(startIndex.add(i));   
        }
    }
    
    function getActiveLockIdsLengthByRecipient(address recipient) external view returns (uint) {
        return activeLockIdsByRecipient[recipient].length();
    }
    function getActiveLockIdsByRecipient(address recipient, uint startIndex, uint endIndex) external view returns (uint[] memory result) {
        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= activeLockIdsByRecipient[recipient].length(), "Invalid endIndex!");
        result = new uint[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = activeLockIdsByRecipient[recipient].at(startIndex.add(i));   
        }
    }
    
    function getBaseTokensLength() external view returns (uint) {
        return baseTokens.length();
    }
    function getBaseTokens(uint startIndex, uint endIndex) external view returns (address[] memory result) {
        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= baseTokens.length(), "Invalid endIndex!");
        result = new address[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            result[i] = baseTokens.at(startIndex.add(i));   
        }
    }
    
    
    
    function createLock(address pair, address baseToken, uint amount, uint unlockTimestamp) external noContractsAllowed nonReentrant payable {
        require(amount > 0, "Cannot lock 0 liquidity!");
        require(unlockTimestamp.sub(block.timestamp) <= MAX_LOCK_DURATION, "Cannot lock for too long!");
        
        IUniswapV2Pair _pair = IUniswapV2Pair(pair);
        
        require(_pair.token0() == baseToken || _pair.token1() == baseToken, "Base token does not exist in pair!");
        require(baseTokens.contains(baseToken), "Base token does not exist!");
        
        uint minLockCreationFee = getMinLockCreationFeeInWei(pair, baseToken, amount);
        require(minLockCreationFee > 0, "Trying to lock too small amount!");
        require(msg.value >= minLockCreationFee, "Insufficient Ether fee sent!");
        
        transferTokenIn(pair, _msgSender(), amount);
        
        uint oldPlatformTokenBalance = IERC20(PLATFORM_TOKEN).balanceOf(address(this));

        // --- swap eth to platform token here! ----
        address[] memory path = new address[](2);
        path[0] = uniswapRouterV2.WETH();
        path[1] = PLATFORM_TOKEN;
        
        uint estimatedAmountOut = uniswapRouterV2.getAmountsOut(msg.value, path)[1];
        uint amountOutMin = estimatedAmountOut.mul(ONE_HUNDRED_X_100.sub(SLIPPAGE_TOLERANCE_X_100)).div(ONE_HUNDRED_X_100);
        
        uniswapRouterV2.swapExactETHForTokens{value: msg.value}(amountOutMin, path, address(this), block.timestamp);
        // ---- end swap eth to plaform tokens -----
        
        uint newPlatformTokenBalance = IERC20(PLATFORM_TOKEN).balanceOf(address(this));
        uint platformTokensLocked = newPlatformTokenBalance.sub(oldPlatformTokenBalance);
        require(platformTokensLocked > 0, "0 platform tokens swapped!");
        addPlatformTokenBalance(platformTokensLocked);
        
        
        // ------- create the lock below -------
        locksLength = locksLength.add(1);
        
        Lock memory lock;
        
        lock.recipient = _msgSender();
        lock.unlockTimestamp = unlockTimestamp;
        lock.amount = lock.amount.add(amount);
        lock.token = pair;
        lock.platformTokensLocked = platformTokensLocked;
        
        locks[locksLength] = lock;
        
        addActiveLockId(locksLength);
        // ------- end create the lock -------
        
        emit Locked(locksLength, pair, _msgSender(), amount, unlockTimestamp, platformTokensLocked, lock.claimed);
    }
    
    function claimUnlocked(uint lockId) external noContractsAllowed nonReentrant {
        require(activeLockIds.contains(lockId), "Lock not yet active!");
        require(!locks[lockId].claimed, "Already claimed!");
        require(locks[lockId].recipient == _msgSender(), "Invalid lock recipient");
        require(block.timestamp >= locks[lockId].unlockTimestamp, "Not yet unlocked! Please wait till unlock time!");
        locks[lockId].claimed = true;
        
        transferTokenOut(locks[lockId].token, locks[lockId].recipient, locks[lockId].amount);
        
        IERC20(PLATFORM_TOKEN).safeTransfer(locks[lockId].recipient, locks[lockId].platformTokensLocked);
        
        deductPlatformTokenBalance(locks[lockId].platformTokensLocked);
        
        removeActiveLockId(lockId);
        emit Unlocked(lockId, locks[lockId].token, locks[lockId].recipient, locks[lockId].amount, locks[lockId].unlockTimestamp, locks[lockId].platformTokensLocked, locks[lockId].claimed);
    }
    
    function transferTokenOut(address token, address recipient, uint amount) private {
        IERC20(token).safeTransfer(recipient, amount);
        tokenBalances[token] = tokenBalances[token].sub(amount);
        if (tokenBalances[token] == 0) {
            lockedTokens.remove(token);
        }
    }
    function transferTokenIn(address token, address from, uint amount) private {
        IERC20(token).safeTransferFrom(from, address(this), amount);
        tokenBalances[token] = tokenBalances[token].add(amount);
        lockedTokens.add(token);
    }
    function addPlatformTokenBalance(uint amount) private {
        tokenBalances[PLATFORM_TOKEN] = tokenBalances[PLATFORM_TOKEN].add(amount);
    }
    function deductPlatformTokenBalance(uint amount) private {
        tokenBalances[PLATFORM_TOKEN] = tokenBalances[PLATFORM_TOKEN].sub(amount);
    }
    
    function addBaseToken(address baseToken) public onlyOwner {
        baseTokens.add(baseToken);
    }
    function removeBaseToken(address baseToken) public onlyOwner {
        baseTokens.remove(baseToken);
    }
    
    function addActiveLockId(uint lockId) private {
        activeLockIds.add(lockId);
        activeLockIdsByRecipient[locks[lockId].recipient].add(lockId);
        activeLockIdsByToken[locks[lockId].token].add(lockId);
    }
    function removeActiveLockId(uint lockId) private {
        activeLockIds.remove(lockId);
        activeLockIdsByRecipient[locks[lockId].recipient].remove(lockId);
        activeLockIdsByToken[locks[lockId].token].remove(lockId);
        
        inactiveLockIds.add(lockId);
        inactiveLockIdsByRecipient[locks[lockId].recipient].add(lockId);
        inactiveLockIdsByToken[locks[lockId].token].add(lockId);
    }
    
    function claimExtraTokens(address token) external onlyOwner {
        uint diff = IERC20(token).balanceOf(address(this)).sub(tokenBalances[token]);
        IERC20(token).safeTransfer(_msgSender(), diff);
    }
    
    receive () external payable {
        // receive eth do nothing
    }
    
    // No ETH should remain on the contract
    // If remaining, owner may transfer out ETH
    function claimEther() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }
    
    function getLockedTokensLength() external view returns (uint) {
        return lockedTokens.length();
    }
    function getLockedTokens(uint startIndex, uint endIndex) external view returns (address[] memory tokens) {
        require(endIndex > startIndex, "Invalid indexes provided!");
        require(endIndex <= lockedTokens.length(), "Invalid endIndex!");
        tokens = new address[](endIndex.sub(startIndex));
        for (uint i = 0; i < endIndex.sub(startIndex); i = i.add(1)) {
            tokens[i] = lockedTokens.at(startIndex.add(i));   
        }
    }
    
    function getTokensBalances(address[] memory tokens) external view returns (uint[] memory balances) {
        balances = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i = i.add(1)) {
            balances[i] = tokenBalances[tokens[i]];
        }
    }
    
    function getLockById(uint id) public view returns (
        address token,
        uint unlockTimestamp,
        uint amount,
        address recipient,
        bool claimed,
        uint platformTokensLocked
    ) {
        token = locks[id].token;
        unlockTimestamp = locks[id].unlockTimestamp;
        amount = locks[id].amount;
        recipient = locks[id].recipient;
        claimed = locks[id].claimed;
        platformTokensLocked = locks[id].platformTokensLocked;
    }
    
    function getLocksByIds(uint[] memory ids) public view returns (
        uint[] memory _ids,
        address[] memory tokens,
        uint[] memory unlockTimestamps,
        uint[] memory amounts,
        address[] memory recipients,
        bool[] memory claimeds,
        uint[] memory platformTokensLockeds
    ) {
        _ids = ids;
        tokens = new address[](ids.length);
        unlockTimestamps = new uint[](ids.length);
        amounts = new uint[](ids.length);
        recipients = new address[](ids.length);
        claimeds = new bool[](ids.length);
        platformTokensLockeds = new uint[](ids.length);
        for (uint i = 0; i < ids.length; i = i.add(1)) {
            (address token, uint unlockTimestamp, uint amount, address recipient, bool claimed, uint platformTokensLocked) = getLockById(ids[i]);
        
            tokens[i] = token;
            unlockTimestamps[i] = unlockTimestamp;
            amounts[i] = amount;
            recipients[i] = recipient;
            claimeds[i] = claimed;
            platformTokensLockeds[i] = platformTokensLocked;
        }
    }
    
    function getMinLockCreationFeeInWei(address pair, address baseToken, uint amount) public view returns (uint) {
        uint baseTokenBalance = IERC20(baseToken).balanceOf(pair);
        uint totalSupply = IERC20(pair).totalSupply();
        uint baseTokenInReceivedLP = baseTokenBalance.mul(amount).div(totalSupply);
        uint feeBaseToken = baseTokenInReceivedLP.mul(MINIMUM_BASETOKEN_PERCENT_ETH_X_100).div(ONE_HUNDRED_X_100);

        if (baseToken == uniswapRouterV2.WETH()) return feeBaseToken;
        
        address[] memory path = new address[](2);
        
        path[0] = baseToken;
        path[1] = uniswapRouterV2.WETH();
        uint ethAmount = uniswapRouterV2.getAmountsOut(feeBaseToken, path)[1];
        return ethAmount;
    }
}