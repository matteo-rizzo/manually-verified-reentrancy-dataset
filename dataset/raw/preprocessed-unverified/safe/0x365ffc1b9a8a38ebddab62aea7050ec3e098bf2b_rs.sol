/**
 *Submitted for verification at Etherscan.io on 2021-10-10
*/

pragma solidity ^0.8.0;

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





contract Swap {
    using SafeERC20 for IERC20;
    IERC20 weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function arb(
        address fromRouterAddress,
        address toRouterAddress,
        address tokenAddress,
        uint256 minOutputTokens,
        uint256 minOutputEth
    ) public payable {
        require(msg.sender == owner);

        IERC20 token = IERC20(tokenAddress);

        UniRouter fromRouter = UniRouter(fromRouterAddress);
        UniRouter toRouter = UniRouter(toRouterAddress);

        // Swap ETH for tokens
        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(token);
        fromRouter.swapExactETHForTokens{value: msg.value}(
            minOutputTokens,
            path,
            address(this),
            block.timestamp + 1 hours
        );

        // Approve token if needed
        uint256 tokensReceived = token.balanceOf(address(this));
        uint256 allowance = token.allowance(address(this), toRouterAddress);
        if (allowance < tokensReceived) {
            if (allowance > 0) {
                token.safeApprove(toRouterAddress, 0);
            }
            token.safeApprove(toRouterAddress, tokensReceived);
        }

        // Swap tokens back to ETH
        address[] memory path2 = new address[](2);
        path2[0] = address(token);
        path2[1] = address(weth);
        toRouter.swapExactTokensForETH(
            tokensReceived,
            minOutputEth,
            path2,
            msg.sender,
            block.timestamp + 1 hours
        ); // as per documentation of the swapExactTokensForETH function, the second argument is the minimum output value so if the output eth < minOutputEth, the txn will revert.
    }
}