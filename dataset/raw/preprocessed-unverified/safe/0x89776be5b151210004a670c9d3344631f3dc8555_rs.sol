/**
 *Submitted for verification at Etherscan.io on 2021-03-20
*/

pragma solidity =0.6.6;









interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}





contract FlashLoaner {
    address immutable uni_factory;
    address immutable sushi_factory;
    IUniswapV2Router02 immutable sushiRouter;
    IUniswapV2Router02 immutable uniRouter;
    bool public useUniRouter = false;
    address owner;

    modifier isOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    constructor(
        address _uni_factory,
        address _sushi_factory,
        address _uniRouter,
        address _sushiRouter
    ) public {
        uni_factory = _uni_factory;
        sushi_factory = _sushi_factory;
        uniRouter = IUniswapV2Router02(_uniRouter);
        sushiRouter = IUniswapV2Router02(_sushiRouter);
        owner = msg.sender;
    }

    function uniswapV2Call(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata _data
    ) external {
        address[] memory path = new address[](2);
        uint256 amountToken = _amount0 == 0 ? _amount1 : _amount0;

        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();

	address factory = useUniRouter ? uni_factory : sushi_factory;

        require(
            msg.sender == UniswapV2Library.pairFor(factory, token0, token1),
            "Unauthorized"
        );
        require(_amount0 == 0 || _amount1 == 0);

        path[0] = _amount0 == 0 ? token1 : token0;
        path[1] = _amount0 == 0 ? token0 : token1;

        IERC20 token = IERC20(_amount0 == 0 ? token1 : token0);

        if (useUniRouter == true) {
            token.approve(address(uniRouter), amountToken);
            uint256 amountRequired =
                UniswapV2Library.getAmountsIn(factory, amountToken, path)[0];
            uint256 amountReceived =
                uniRouter.swapExactTokensForTokens(
                    amountToken,
                    amountRequired,
                    path,
                    msg.sender,
                    now + 10 days
                )[1];

            // YEAHH PROFIT
            token.transfer(_sender, amountReceived - amountRequired);
        } else {
            token.approve(address(sushiRouter), amountToken);
            uint256 amountRequired =
                UniswapV2Library.getAmountsIn(factory, amountToken, path)[0];
            uint256 amountReceived =
                sushiRouter.swapExactTokensForTokens(
                    amountToken,
                    amountRequired,
                    path,
                    msg.sender,
                    now + 1 days
                )[1];

            // YEAHH PROFIT
            token.transfer(_sender, amountReceived - amountRequired);
        }

        // no need for require() check, if amount required is not sent uniRo226uter will revert
    }

    function setUseUniRouter(bool _value) public isOwner {
        useUniRouter = _value;
    }
}