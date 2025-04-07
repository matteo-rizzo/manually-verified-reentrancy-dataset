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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




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


contract Subscription is Ownable, ReentrancyGuard {
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using Address for address;
    
    modifier noContractsAllowed() {
        require(!(address(msg.sender).isContract()) && tx.origin == msg.sender, "No Contracts Allowed!");
        _;
    }
    
    // ====================== Contract Variables ========================
    // Must be updated before live deployment
    
    uint public subscriptionFeeInDai = 75e18;
    
    uint public constant SLIPPAGE_TOLERANCE_X_100 = 3e2;
    uint public constant ONE_HUNDRED_X_100 = 100e2;
    
    address public constant TRUSTED_PLATFORM_TOKEN_ADDRESS = 0x961C8c0B1aaD0c0b10a51FeF6a867E3091BCef17;
    address public constant TRUSTED_DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    
    
    // ==================== End Contract Variables ======================
    
    
    event SupportedTokenAdded(address tokenAddress);
    event SupportedTokenRemoved(address tokenAddress);
    event SubscriptionFeeSet(uint amountDai);
    event Subscribe(address indexed account, uint platformTokenAmount);
    event Unsubscribe(address indexed account, uint platformTokenAmount);
    
    
    mapping (address => bool) public isTokenSupported;
    mapping (address => uint) public subscriptionPlatformTokenAmount;
    
    IUniswapV2Router public immutable uniswapRouterV2;
    
    constructor () public {
        uniswapRouterV2  = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    }
    
    function addSupportedToken(address tokenAddress) external noContractsAllowed onlyOwner {
        isTokenSupported[tokenAddress] = true;
        emit SupportedTokenAdded(tokenAddress);
    }
    function removeSupportedToken(address tokenAddress) external noContractsAllowed onlyOwner {
        isTokenSupported[tokenAddress] = false;
        emit SupportedTokenRemoved(tokenAddress);
    }
    function setSubscriptionFee(uint newSubscriptionFeeInDai) external noContractsAllowed onlyOwner {
        subscriptionFeeInDai = newSubscriptionFeeInDai;
        emit SubscriptionFeeSet(newSubscriptionFeeInDai);
    }
    
    function subscribe(address tokenAddress, uint amount) external noContractsAllowed nonReentrant {
        require(isTokenSupported[tokenAddress], "Token not supported!");
        require(subscriptionPlatformTokenAmount[msg.sender] == 0, "Already subscribed!");
        
        uint minTokenAmount = getEstimatedTokenSubscriptionAmount(tokenAddress);
        require(amount >= minTokenAmount, "Amount less than fee!");
        
        IERC20(tokenAddress).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(tokenAddress).safeApprove(address(uniswapRouterV2), 0);
        IERC20(tokenAddress).safeApprove(address(uniswapRouterV2), amount);
        
        uint oldPlatformTokenBalance = IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).balanceOf(address(this));
        
        address[] memory path;
        
        if (tokenAddress == uniswapRouterV2.WETH()) {
            path = new address[](2);
            path[0] = tokenAddress;
            path[1] = TRUSTED_PLATFORM_TOKEN_ADDRESS;
        } else {
            path = new address[](3);
            path[0] = tokenAddress;
            path[1] = uniswapRouterV2.WETH();
            path[2] = TRUSTED_PLATFORM_TOKEN_ADDRESS;
        }
        uint estimatedAmountOut = uniswapRouterV2.getAmountsOut(amount, path)[path.length - 1];
        uint minAmountOut = estimatedAmountOut.mul(ONE_HUNDRED_X_100.sub(SLIPPAGE_TOLERANCE_X_100)).div(ONE_HUNDRED_X_100);
        uniswapRouterV2.swapExactTokensForTokens(amount, minAmountOut, path, address(this), block.timestamp);
        uint newPlatformTokenBalance = IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).balanceOf(address(this));
        uint platformTokensReceived = newPlatformTokenBalance.sub(oldPlatformTokenBalance);
        
        subscriptionPlatformTokenAmount[msg.sender] = platformTokensReceived;
        
        emit Subscribe(msg.sender, platformTokensReceived);
    }
    function unsubscribe() external noContractsAllowed nonReentrant {
        uint subscribedPlatformTokenAmount = subscriptionPlatformTokenAmount[msg.sender];
        
        require(subscribedPlatformTokenAmount > 0, "Not subscribed yet!");
        subscriptionPlatformTokenAmount[msg.sender] = 0;
        IERC20(TRUSTED_PLATFORM_TOKEN_ADDRESS).safeTransfer(msg.sender, subscribedPlatformTokenAmount);
        
        emit Unsubscribe(msg.sender, subscribedPlatformTokenAmount);
    }
    
    function getEstimatedTokenSubscriptionAmount(address tokenAddress) public view returns (uint) {
        if (tokenAddress == TRUSTED_DAI_ADDRESS) return subscriptionFeeInDai;
        address[] memory path;
        
        if (tokenAddress == uniswapRouterV2.WETH()) {
            path = new address[](2);
            path[0] = TRUSTED_DAI_ADDRESS;
            path[1] = tokenAddress;
        } else {
            path = new address[](3);
            path[0] = TRUSTED_DAI_ADDRESS;
            path[1] = uniswapRouterV2.WETH();
            path[2] = tokenAddress;
        }
        
        return uniswapRouterV2.getAmountsOut(subscriptionFeeInDai, path)[path.length - 1];
    }
}