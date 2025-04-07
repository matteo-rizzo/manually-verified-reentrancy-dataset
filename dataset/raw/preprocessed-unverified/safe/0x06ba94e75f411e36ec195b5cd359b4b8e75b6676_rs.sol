/**
 *Submitted for verification at Etherscan.io on 2021-07-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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











contract DexAdapterCore {
    using SafeERC20 for IERC20;

    address public router;
    address public WETH;
    address public USDT;

    constructor(
        address _router,
        address _weth,
        address _usdt
    ) {
        router = _router;
        WETH = _weth;
        USDT = _usdt;
    }

    receive() external payable {}

    function swapETHToUnderlying(address underlying) external payable {
        if (underlying == WETH) {
            IWETH(WETH).deposit{value: msg.value}();
            IERC20(WETH).transfer(msg.sender, msg.value);
        } else {
            address[] memory path = getPath(WETH, underlying);
            IUniswapV2Router01(router).swapExactETHForTokens{value: msg.value}(0, path, msg.sender, block.timestamp + 100);
        }
    }

    function swapUndelyingsToETH(uint256[] memory underlyingAmounts, address[] memory underlyings) external {
        uint256 balance;
        for (uint256 i = 0; i < underlyings.length; i++) {
            IERC20(underlyings[i]).safeTransferFrom(msg.sender, address(this), underlyingAmounts[i]);

            if (underlyings[i] == WETH) {
                IWETH(WETH).withdraw(underlyingAmounts[i]);
                (bool success, ) = msg.sender.call{value: underlyingAmounts[i]}("");
                require(success, "ETH transfer failed");
            } else {
                balance = IERC20(underlyings[i]).balanceOf(address(this));
                IERC20(underlyings[i]).safeApprove(router, 0);
                IERC20(underlyings[i]).safeApprove(router, balance);

                address[] memory path = getPath(underlyings[i], WETH);
                IUniswapV2Router01(router).swapExactTokensForETH(balance, 0, path, msg.sender, block.timestamp + 100);
            }
        }
    }

    function swapTokenToToken(
        uint256 _amountToSwap,
        address _tokenToSwap,
        address _tokenToReceive
    ) external returns (uint256) {
        address[] memory path = getPath(_tokenToSwap, _tokenToReceive);

        IERC20(_tokenToSwap).safeTransferFrom(msg.sender, address(this), _amountToSwap);
        IERC20(_tokenToSwap).safeApprove(router, 0);
        IERC20(_tokenToSwap).safeApprove(router, _amountToSwap);

        return IUniswapV2Router01(router).swapExactTokensForTokens(_amountToSwap, 0, path, msg.sender, block.timestamp + 100)[path.length - 1];
    }

    function getUnderlyingAmount(
        uint256 _amount,
        address _tokenToSwap,
        address _tokenToReceive
    ) external view returns (uint256) {
        if (_tokenToSwap == address(0)) {
            _tokenToSwap = WETH;
        }
        if (_tokenToSwap == _tokenToReceive && _tokenToSwap == WETH) return _amount;
        address[] memory path = getPath(_tokenToSwap, _tokenToReceive);

        return IUniswapV2Router01(router).getAmountsOut(_amount, path)[path.length - 1];
    }

    function getTokensPrices(address[] memory _tokens) external view returns (uint256[] memory) {
        address[] memory path = new address[](2);
        path[1] = WETH;

        uint256[] memory prices = new uint256[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (_tokens[i] == WETH) {
                prices[i] = 10**18;
            } else {
                path[0] = _tokens[i];
                prices[i] = IUniswapV2Router01(router).getAmountsOut(10**IERC20Extend(_tokens[i]).decimals(), path)[1];
            }
        }
        return prices;
    }

    function getEthPrice() external view returns (uint256) {
        address[] memory path = getPath(WETH, USDT);
        return IUniswapV2Router01(router).getAmountsOut(10**18, path)[1];
    }

    function getDHVPrice(address _dhvToken) external view returns (uint256) {
        address[] memory path = getPath(_dhvToken, WETH);
        return IUniswapV2Router01(router).getAmountsOut(10**18, path)[1];
    }

    function getPath(address _tokenToSwap, address _tokenToReceive) public view returns (address[] memory) {
        address[] memory path = _tokenToSwap == WETH || _tokenToReceive == WETH ? new address[](2) : new address[](3);
        if (path.length == 2) {
            path[0] = _tokenToSwap;
            path[1] = _tokenToReceive;
        } else {
            path[0] = _tokenToSwap;
            path[1] = WETH;
            path[2] = _tokenToReceive;
        }

        return path;
    }
}