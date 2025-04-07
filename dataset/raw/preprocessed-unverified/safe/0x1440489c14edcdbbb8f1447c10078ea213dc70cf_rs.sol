/**
 *Submitted for verification at Etherscan.io on 2021-02-25
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.6.12;




// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false







// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)













interface IChi is IERC20 {
    function mint(uint256 value) external;
    function free(uint256 value) external returns (uint256 freed);
    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);
}





contract WSRouter is IWSRouter, IWSImplementation {
    using SafeMath for uint;

    bool private initialized;
    address public override factory;
    address public override WETH;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'WSRouter: EXPIRED');
        _;
    }

    modifier discountCHI(bool burnChi) {
        // strange if structure required for contract size optimization
        uint256 gasStart;
        if(burnChi) {
            gasStart = gasleft();
        }
        _;
        if(burnChi) {
            _freeChi(gasStart);
        }
    }

    function _freeChi(uint256 gasStart) internal {
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
        _getChi().freeFromUpTo(msg.sender, (gasSpent + 14174) / 41947);
    }

    function initialize(address _factory, address _WETH) public returns(bool) {
        require(initialized == false, "WSRouter: Alredy initialized.");
        factory = _factory;
        WETH = _WETH;
        initialized = true;
        return true;
    }

    receive() external payable {
    }

    function _getChi() internal virtual pure returns(IChi) {
        return IChi(address(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c));
    }

    function _getWSE() internal virtual pure returns(IERC20) {
        return IERC20(address(0x77b8ae2E83c7d044d159878445841E2A9777Af38));
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        // create the pair if it doesn't exist yet
        if (IWSFactory(factory).getPair(tokenA, tokenB) == address(0)) {
            IWSFactory(factory).createPair(tokenA, tokenB);
        }
        (uint reserveA, uint reserveB) = WSLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = WSLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'WSRouter: INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = WSLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'WSRouter: INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }
    function addLiquidity(
        bool burnGasToken,
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual override discountCHI(burnGasToken) ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        // avoid stack too deep error
        address tokenAstacked = tokenA;
        address tokenBstacked = tokenB;
        address pair = WSLibrary.pairFor(factory, tokenAstacked, tokenBstacked);
        TransferHelper.safeTransferFrom(tokenAstacked, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenBstacked, msg.sender, pair, amountB);
        liquidity = IWSPair(pair).mint(to);
    }
    function addLiquidityETH(
        bool burnGasToken,
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external virtual override payable discountCHI(burnGasToken) ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = WSLibrary.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IWSPair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** REMOVE LIQUIDITY ****

    // spacer function to avoid too big stack error
    function _makeLiquidityPermit(
        address tokenA,
        address tokenB, 
        uint256 liquidity, 
        bool approveMax, 
        uint256 deadline, 
        uint8 v, bytes32 r, bytes32 s
        ) internal {
        address pair = WSLibrary.pairFor(factory, tokenA, tokenB);
        uint value = approveMax ? uint(-1) : liquidity;
        IWSERC20(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
    }

    // spacer function to avoid too big stack error
    function _remLiqNoChi(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) internal returns(uint amountA, uint amountB) {
        (amountA, amountB) = removeLiquidity(false, tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    function removeLiquidity(
        bool burnGasToken,
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual override discountCHI(burnGasToken) ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = WSLibrary.pairFor(factory, tokenA, tokenB);
        IWSERC20(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        // Avoid stack too big error
        (address tokenAstacked, address tokenBstacked) = (tokenA, tokenB);
        (uint amount0, uint amount1) = IWSPair(pair).burn(to);
        (address token0,) = WSLibrary.sortTokens(tokenAstacked, tokenBstacked);
        (amountA, amountB) = tokenAstacked == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'WSRouter: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'WSRouter: INSUFFICIENT_B_AMOUNT');
    }
    function removeLiquidityETH(
        bool burnGasToken,
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override discountCHI(burnGasToken) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidity(
            false,
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }
    function removeLiquidityWithPermit(
        bool burnGasToken,
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override discountCHI(burnGasToken) returns (uint amountA, uint amountB) {
        _makeLiquidityPermit(tokenA, tokenB, liquidity, approveMax, deadline, v, r, s);
        // address pair = WSLibrary.pairFor(factory, tokenA, tokenB);
        // uint value = approveMax ? uint(-1) : liquidity;
        // IWSERC20(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = _remLiqNoChi(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }
    function removeLiquidityETHWithPermit(
        bool burnGasToken,
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override discountCHI(burnGasToken) returns (uint amountToken, uint amountETH) {
        _makeLiquidityPermit(token, WETH, liquidity, approveMax, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(false, token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        bool burnGasToken,
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override discountCHI(burnGasToken) returns (uint amountETH) {
        (, amountETH) = removeLiquidity(
            false,
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        bool burnGasToken,
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override discountCHI(burnGasToken) returns (uint amountETH) {
        _makeLiquidityPermit(token, WETH, liquidity, approveMax, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            false, token, liquidity, amountTokenMin, amountETHMin, to, deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    function _swap(uint[] memory amounts, address[] memory path, address _to, uint discount) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = WSLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? WSLibrary.pairFor(factory, output, path[i + 2]) : _to;
            IWSPair(WSLibrary.pairFor(factory, input, output)).swapDiscount(
                amount0Out, amount1Out, to, new bytes(0), discount
            );
        }
    }
    function swapExactTokensForTokens(
        bool burnGasToken,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override discountCHI(burnGasToken) ensure(deadline) returns (uint[] memory amounts) {
        uint discount = WSLibrary.getDiscount(msg.sender, _getWSE().balanceOf(msg.sender));
        amounts = WSLibrary.getAmountsOut(factory, amountIn, path, discount);
        require(amounts[amounts.length - 1] >= amountOutMin, 'WSRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, WSLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to, discount);
    }
    function swapTokensForExactTokens(
        bool burnGasToken,
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override discountCHI(burnGasToken) ensure(deadline) returns (uint[] memory amounts) {
        uint discount = WSLibrary.getDiscount(msg.sender, _getWSE().balanceOf(msg.sender));
        amounts = WSLibrary.getAmountsIn(factory, amountOut, path, discount);
        require(amounts[0] <= amountInMax, 'WSRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, WSLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, to, discount);
    }
    function swapExactETHForTokens(bool burnGasToken,uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        discountCHI(burnGasToken)
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'WSRouter: INVALID_PATH');
        uint discount = WSLibrary.getDiscount(msg.sender, _getWSE().balanceOf(msg.sender));
        amounts = WSLibrary.getAmountsOut(factory, msg.value, path, discount);
        require(amounts[amounts.length - 1] >= amountOutMin, 'WSRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(WSLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to, discount);
    }
    function swapTokensForExactETH(bool burnGasToken,uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        discountCHI(burnGasToken)
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'WSRouter: INVALID_PATH');
        uint discount = WSLibrary.getDiscount(msg.sender, _getWSE().balanceOf(msg.sender));
        amounts = WSLibrary.getAmountsIn(factory, amountOut, path, discount);
        require(amounts[0] <= amountInMax, 'WSRouter: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, WSLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this), discount);
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapExactTokensForETH(bool burnGasToken,uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        discountCHI(burnGasToken)
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'WSRouter: INVALID_PATH');
        uint discount = WSLibrary.getDiscount(msg.sender, _getWSE().balanceOf(msg.sender));
        amounts = WSLibrary.getAmountsOut(factory, amountIn, path, discount);
        require(amounts[amounts.length - 1] >= amountOutMin, 'WSRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, WSLibrary.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this), discount);
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapETHForExactTokens(bool burnGasToken,uint amountOut, address[] calldata path, address to, uint deadline)
        external
        virtual
        override
        payable
        discountCHI(burnGasToken)
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'WSRouter: INVALID_PATH');
        uint discount = WSLibrary.getDiscount(msg.sender, _getWSE().balanceOf(msg.sender));
        amounts = WSLibrary.getAmountsIn(factory, amountOut, path, discount);
        require(amounts[0] <= msg.value, 'WSRouter: EXCESSIVE_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(WSLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to, discount);
        // refund dust eth, if any
        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        uint discount = WSLibrary.getDiscount(msg.sender, _getWSE().balanceOf(msg.sender));
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = WSLibrary.sortTokens(input, output);
            IWSPair pair = IWSPair(WSLibrary.pairFor(factory, input, output));
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            amountOutput = WSLibrary.getAmountOut(amountInput, reserveInput, reserveOutput, discount);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? WSLibrary.pairFor(factory, output, path[i + 2]) : _to;
            uint _discount = discount; // Avoid stack too deep errors
            pair.swapDiscount(amount0Out, amount1Out, to, new bytes(0), _discount);
        }
    }
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        bool burnGasToken,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) discountCHI(burnGasToken) {
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, WSLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'WSRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        bool burnGasToken,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        payable
        ensure(deadline)
        discountCHI(burnGasToken)
    {
        require(path[0] == WETH, 'WSRouter: INVALID_PATH');
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(WSLibrary.pairFor(factory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            'WSRouter: INSUFFICIENT_OUTPUT_AMOUNT'
        );
    }
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        bool burnGasToken,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
        external
        virtual
        override
        discountCHI(burnGasToken)
        ensure(deadline)
    {
        require(path[path.length - 1] == WETH, 'WSRouter: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, WSLibrary.pairFor(factory, path[0], path[1]), amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        require(amountOut >= amountOutMin, 'WSRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    // deleted

    function getImplementationType() external pure override returns(uint256) {
        /// 3 is a router type
        return 3;
    }
}