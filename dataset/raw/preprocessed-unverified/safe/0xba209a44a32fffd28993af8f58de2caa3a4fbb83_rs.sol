/**
 *Submitted for verification at Etherscan.io on 2021-02-27
*/

// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity 0.5.17;

















contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

contract DextokenExchange is IDextokenExchange, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    uint constant MAX = uint(-1);

    address public owner;
    IERC20 public WETH;

    constructor(address _token0) public {
        owner = msg.sender;
        WETH = IERC20(_token0);        
    }

    function swapMaxAmountOut(
        address poolIn,
        address poolOut, 
        uint maxAmountOut,
        uint deadline
    ) 
        external 
        nonReentrant
    {
        require(poolIn != address(0), "exchange: Invalid token address");
        require(poolOut != address(0), "exchange: Invalid token address");
        require(maxAmountOut > 0, "exchange: Invalid maxAmountOut");

        IERC20 poolInToken = IERC20(IDextokenPool(poolIn).getToken());
        IERC20 poolOutToken = IERC20(IDextokenPool(poolOut).getToken());
        IERC20 _WETH = WETH;

        /// calculate the pair price
        uint closingPrice;
        {
            uint priceIn = IDextokenPool(poolIn).getPrice();
            uint priceOut = IDextokenPool(poolOut).getPrice();
            closingPrice = priceOut.mul(1e18).div(priceIn);
        }

        /// evalucate the swap in amount
        uint amountSwapIn = maxAmountOut.mul(closingPrice).div(1e18);
        require(amountSwapIn >= 1e2, "exchange: invalid amountSwapIn");    

        /// transfer tokens in
        poolInToken.safeTransferFrom(msg.sender, address(this), amountSwapIn);
        require(poolInToken.balanceOf(address(this)) >= amountSwapIn, "exchange: Invalid token balance");

        if (poolInToken.allowance(address(this), poolIn) < amountSwapIn) {       
            poolInToken.approve(poolIn, MAX);
        }

        IDextokenPool(poolIn).swapExactTokensForETH(
            amountSwapIn,
            0,
            0,
            deadline
        );

        uint balanceETH = _WETH.balanceOf(address(this));
        uint spotPriceOut = IDextokenPool(poolOut).getSpotPrice(
            IDextokenPool(poolOut).getCirculatingSupply(),
            IDextokenPool(poolOut).getUserbase().add(balanceETH)
        );
        uint minAmountOut = balanceETH.mul(1e18).div(spotPriceOut);

        /// swap ETH for tokens
        if (_WETH.allowance(address(this), poolOut) < balanceETH) {         
            _WETH.approve(poolOut, MAX);
        }

        IDextokenPool(poolOut).swapExactETHForTokens(
            balanceETH,
            minAmountOut,
            spotPriceOut,
            deadline
        );

        /// transfer all tokens
        uint exactAmountOut = poolOutToken.balanceOf(address(this));
        require(exactAmountOut <= maxAmountOut, "exchange: Exceed maxAmountOut");
        poolOutToken.safeTransfer(msg.sender, exactAmountOut);

        emit SwapExactAmountOut(poolIn, amountSwapIn, poolOut, exactAmountOut, msg.sender);
    }

    function swapExactAmountIn(
        address poolIn,
        address poolOut, 
        uint exactAmountIn,
        uint deadline
    ) 
        external 
        nonReentrant
    {
        require(poolIn != address(0), "exchange: Invalid token address");
        require(poolOut != address(0), "exchange: Invalid token address");
        require(exactAmountIn > 0, "exchange: Invalid exactAmountIn");

        IERC20 poolInToken = IERC20(IDextokenPool(poolIn).getToken());
        IERC20 poolOutToken = IERC20(IDextokenPool(poolOut).getToken());
        IERC20 _WETH = WETH;

        /// transfer tokens in
        poolInToken.safeTransferFrom(msg.sender, address(this), exactAmountIn);
        require(poolInToken.balanceOf(address(this)) >= exactAmountIn, "exchange: Invalid token balance");

        if (poolInToken.allowance(address(this), poolIn) < exactAmountIn) {
            poolInToken.approve(address(poolIn), MAX);
        }

        uint balanceETH = IDextokenPool(poolIn).swapExactTokensForETH(
            exactAmountIn,
            0,
            0,
            deadline
        );

        if (_WETH.allowance(address(this), poolOut) < balanceETH) {       
            _WETH.approve(address(poolOut), MAX);
        }

        uint exactAmountOut = IDextokenPool(poolOut).swapExactETHForTokens(
            balanceETH,
            0,
            MAX,
            deadline
        );

        /// transfer all tokens
        poolOutToken.safeTransfer(msg.sender, exactAmountOut);

        emit SwapExactAmountIn(poolIn, exactAmountIn, poolOut, exactAmountOut, msg.sender);
    }            
}