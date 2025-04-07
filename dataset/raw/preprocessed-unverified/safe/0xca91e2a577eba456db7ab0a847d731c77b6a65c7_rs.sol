/**
 *Submitted for verification at Etherscan.io on 2021-06-09
*/

pragma solidity ^0.5.10;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */

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
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


contract IWETH is IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;
}







contract swapV1 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event EVTCallExProxy (address indexed _in, address indexed _out, address indexed _trader, address _ex, uint256 _outAmount);
    event EVTSwapExactTokensForTokens(address indexed _in, address indexed _out, address indexed _trader, address _ex, uint256 _outAmount);
    event EVTSwapTokensForExactTokens(address indexed _in, address indexed _out, address indexed _trader, address _ex, uint256 _outAmount);
    event SwapToolCreated(address indexed router);


    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }


    //TODO
    uint256  feeFlag;
    address  payable private feeAddr = 0xF18463BD447597a3b7c4035EA1E7BcDc5d99F330;
    address public constant  WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 feeRate = 1;
    uint256 feePercent1000 = 1000;
    uint256 userFundsRate = feePercent1000 - feeRate;
    //TODO
    address private _owner;
    address emptyAddr = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    mapping(address => bool) routerMap;
    mapping(address => bytes) factoryMap;
    mapping(address => uint256) factoryFeeMap;
    IWETH wethToken;


    constructor() public {
        wethToken = IWETH(WETH);
        _owner = msg.sender;
        feeFlag = 1;
        emit SwapToolCreated(address(this));

        factoryMap[0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f] = hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f';
        factoryFeeMap[0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f] = 9970;
        factoryMap[0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac] = hex'e18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303';
        factoryFeeMap[0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac] = 9970;

        routerMap[0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D] = true;
        routerMap[0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F] = true;

    }


    function pairFor(address factory, address tokenA, address tokenB, bytes memory initCode) public pure returns (address pair) {
        return UniswapV2Library.pairFor(factory, tokenA, tokenB, initCode);
    }

    modifier onlyOwner() {
        require(tx.origin == _owner, "Ownable: caller is not the owner");
        _;
    }

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        _;
    }

    function addRouter(address router) public onlyOwner {
        routerMap[router] = true;

    }

    function isRouter(address router) public view returns (bool){
        return routerMap[router];
    }

    function addFactory(address _factory, uint256 fee, bytes memory initCode) public onlyOwner {
        factoryMap[_factory] = initCode;
        factoryFeeMap[_factory] = fee;
    }

    function setFeeFlag(uint256 f) public onlyOwner {
        feeFlag = f;
    }

    function setFeeRate(uint256 fee) public onlyOwner {
        require(fee > 0 && fee <= 10, "1-10");
        feeRate = fee;
    }

    function _needFee() internal view returns (bool){
        return feeFlag == 1;
    }


    function callExProxy(address router, IERC20 inToken, IERC20 outToken, uint256 amountIn, uint256 amountOutMin, bytes memory data) public payable {
        require(router != address(this), "Illegal");
        require(amountOutMin > 0, 'Limit Amount must be set');
        require(isRouter(router), "Illegal router address");

        if (address(inToken) != emptyAddr) {
            require(msg.value == 0, "eth 0");
            transferFromUser(inToken, msg.sender, amountIn);
        }

        approve(inToken, router);
        //swap
        (bool success,) = router.call.value(msg.value)(data);
        require(success, "call ex fail");

        uint256 tradeReturn = viewBalance(outToken, address(this));
        require(tradeReturn >= amountOutMin, 'Trade returned less than the minimum amount');

        // return any unspent funds
        uint256 leftover = viewBalance(inToken, address(this));
        if (leftover > 0) {
            sendFunds(inToken, msg.sender, leftover);
        }

        if (_needFee()) {
            sendFunds(outToken, msg.sender, tradeReturn.mul(userFundsRate).div(feePercent1000));
            sendFunds(outToken, feeAddr, tradeReturn.mul(feeRate).div(feePercent1000));
        } else {
            sendFunds(outToken, msg.sender, tradeReturn);
        }
        emit EVTCallExProxy(address(inToken), address(outToken), msg.sender, router, tradeReturn);

    }

    function swapExactTokensForTokens(address factory, IERC20 inToken, IERC20 outToken, uint256 amountIn, uint256 amountOutMin, uint deadline, address[] memory path) public payable ensure(deadline) {
        require(factory != address(this), "Illegal");
        require(amountOutMin > 0, 'Limit Amount must be set');
        require(factoryMap[factory].length > 0, "add factory before");
        bytes memory initCode = factoryMap[factory];
        uint[] memory amounts = new uint[](path.length);
        {
            uint fee = factoryFeeMap[factory];
            amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path, initCode, fee);
        }
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');

        address firstPair = UniswapV2Library.pairFor(factory, path[0], path[1], initCode);
        if (address(inToken) != emptyAddr) {
            require(msg.value == 0, "eth 0");
            safeTransferFrom(address(inToken), msg.sender, firstPair, amountIn);
        } else {
            inToken = IERC20(WETH);
            wethToken.deposit.value(msg.value)();
            inToken.safeTransfer(firstPair, msg.value);
        }
        if (_needFee()) {
            {
                _swap(factory, amounts, path, address(this), initCode);
            }

            if (address(outToken) == emptyAddr) {
                wethToken.withdraw(wethToken.balanceOf(address(this)));
            }

            uint256 tradeReturn = viewBalance(outToken, address(this));
            require(tradeReturn >= amountOutMin, 'Trade returned less than the minimum amount');

            uint256 leftover = viewBalance(inToken, address(this));
            if (leftover > 0) {
                sendFunds(inToken, msg.sender, leftover);
            }
            sendFunds(outToken, msg.sender, tradeReturn.mul(userFundsRate).div(feePercent1000));
            sendFunds(outToken, feeAddr, tradeReturn.mul(feeRate).div(feePercent1000));
        } else {

            if (address(outToken) == emptyAddr) {
                _swap(factory, amounts, path, address(this), initCode);
                uint256 tradeReturn = wethToken.balanceOf(address(this));
                wethToken.withdraw(tradeReturn);
                sendFunds(outToken, msg.sender, tradeReturn);
            } else {
                _swap(factory, amounts, path, msg.sender, initCode);
            }

        }
        emit EVTSwapExactTokensForTokens(address(inToken), address(outToken), msg.sender, factory, amounts[amounts.length - 1]);
    }


    function swapTokensForExactTokens(address factory, IERC20 inToken, IERC20 outToken, uint256 amountInMax, uint256 amountOut, uint deadline, address[] memory path) public payable ensure(deadline) {
        require(factory != address(this), "Illegal");
        require(factoryMap[factory].length > 0, "add factory before");
        bytes memory initCode = factoryMap[factory];
        uint[] memory amounts = new uint[](path.length);
        {
            uint fee = factoryFeeMap[factory];
            amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path, initCode, fee);
        }
        require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');

        address firstPair = UniswapV2Library.pairFor(factory, path[0], path[1], initCode);
        if (address(inToken) != emptyAddr) {
            require(msg.value == 0, "eth 0");
            safeTransferFrom(address(inToken), msg.sender, firstPair, amounts[0]);
        } else {
            require(amounts[0] <= msg.value, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
            inToken = IERC20(WETH);
            wethToken.deposit.value(amounts[0])();
            inToken.safeTransfer(firstPair, amounts[0]);
        }
        if (_needFee()) {
            {
                _swap(factory, amounts, path, address(this), initCode);
            }

            if (address(outToken) == emptyAddr) {
                wethToken.withdraw(wethToken.balanceOf(address(this)));
            }

            sendFunds(outToken, msg.sender, amountOut.mul(userFundsRate).div(feePercent1000));
            sendFunds(outToken, feeAddr, amountOut.mul(feeRate).div(feePercent1000));
        } else {

            if (address(outToken) == emptyAddr) {
                _swap(factory, amounts, path, address(this), initCode);
                uint256 tradeReturn = wethToken.balanceOf(address(this));
                wethToken.withdraw(tradeReturn);
                sendFunds(outToken, msg.sender, tradeReturn);
            } else {
                _swap(factory, amounts, path, msg.sender, initCode);
            }

        }
        if (msg.value > amounts[0]) {
            //eth
            msg.sender.transfer(msg.value.sub(amounts[0]));
        }

        emit EVTSwapTokensForExactTokens(address(inToken), address(outToken), msg.sender, factory, amountOut);
    }


    function transferFromUser(IERC20 erc, address _from, uint256 _inAmount) internal {
        if (
            address(erc) != emptyAddr &&
        erc.allowance(_from, address(this)) >= _inAmount
        ) {
            safeTransferFrom(address(erc), _from, address(this), _inAmount);
        }
    }

    function approve(IERC20 erc, address approvee) internal {
        if (
            address(erc) != emptyAddr &&
            erc.allowance(address(this), approvee) == 0
        ) {
            erc.safeApprove(approvee, uint256(- 1));
        }
    }

    function viewBalance(IERC20 erc, address owner) internal view returns (uint256) {
        if (address(erc) == emptyAddr) {
            return owner.balance;
        } else {
            return erc.balanceOf(owner);
        }
    }

    function sendFunds(IERC20 erc, address payable receiver, uint256 funds) internal {
        if (address(erc) == emptyAddr) {
            receiver.transfer(funds);
        } else {
            safeTransfer(address(erc), receiver, funds);
        }
    }


    function _swap(address factory, uint[] memory amounts, address[] memory path, address _to, bytes memory initCode) internal {
        //
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2], initCode) : _to;
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output, initCode)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }

    function withdrawEth() external onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function withdrawAnyToken(IERC20 erc) external onlyOwner {
        safeTransfer(address(erc), msg.sender, erc.balanceOf(address(this)));
    }

    function() external payable {
        require(msg.sender != tx.origin, "233333");
    }

}