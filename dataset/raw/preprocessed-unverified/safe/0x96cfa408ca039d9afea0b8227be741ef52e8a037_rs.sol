/**
 *Submitted for verification at Etherscan.io on 2021-04-16
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity =0.6.12;

contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

















contract O3SwapETHUniswapBridge is Ownable {
    using SafeMath for uint256;
    using Convert for bytes;

    event LOG_AGG_SWAP (
        uint256 amountOut, // Raw swapped token amount out without aggFee
        uint256 fee
    );

    address public WETH;
    address public uniswapFactory;
    address public polySwapper;
    uint public polySwapperId;

    uint256 public aggregatorFee = 3 * 10 ** 7; // Default to 0.3%
    uint256 public constant FEE_DENOMINATOR = 10 ** 10;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'O3SwapETHUniswapBridge: EXPIRED');
        _;
    }

    constructor (
        address _weth,
        address _factory,
        address _swapper,
        uint _swapperId
    ) public {
        WETH = _weth;
        uniswapFactory = _factory;
        polySwapper = _swapper;
        polySwapperId = _swapperId;
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint swapAmountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual ensure(deadline) {
        uint amountOut = _swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, swapAmountOutMin, path);
        uint feeAmount = amountOut.mul(aggregatorFee).div(FEE_DENOMINATOR);

        emit LOG_AGG_SWAP(amountOut, feeAmount);

        uint adjustedAmountOut = amountOut.sub(feeAmount);
        TransferHelper.safeTransfer(path[path.length - 1], to, adjustedAmountOut);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokensCrossChain(
        uint amountIn,
        uint swapAmountOutMin,
        address[] calldata path,
        bytes memory to,
        uint deadline,
        uint64 toPoolId,
        uint64 toChainId,
        bytes memory toAssetHash,
        uint polyMinOutAmount,
        uint fee
    ) external virtual payable ensure(deadline) returns (bool) {
        uint polyAmountIn;
        {
            uint amountOut = _swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, swapAmountOutMin, path);
            uint feeAmount = amountOut.mul(aggregatorFee).div(FEE_DENOMINATOR);
            emit LOG_AGG_SWAP(amountOut, feeAmount);
            polyAmountIn = amountOut.sub(feeAmount);
        }

        return _cross(
            path[path.length - 1],
            toPoolId,
            toChainId,
            toAssetHash,
            to,
            polyAmountIn,
            polyMinOutAmount,
            fee
        );
    }

    function _swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path
    ) internal virtual returns (uint) {
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(uniswapFactory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(path[path.length - 1]).balanceOf(address(this)).sub(balanceBefore);
        require(amountOut >= amountOutMin, 'O3SwapETHUniswapBridge: INSUFFICIENT_OUTPUT_AMOUNT');
        return amountOut;
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint swapAmountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual payable ensure(deadline) {
        uint amountOut = _swapExactETHForTokensSupportingFeeOnTransferTokens(swapAmountOutMin, path, 0);
        uint feeAmount = amountOut.mul(aggregatorFee).div(FEE_DENOMINATOR);

        emit LOG_AGG_SWAP(amountOut, feeAmount);

        uint adjustedAmountOut = amountOut.sub(feeAmount);
        TransferHelper.safeTransfer(path[path.length - 1], to, adjustedAmountOut);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokensCrossChain(
        uint swapAmountOutMin,
        address[] calldata path,
        bytes memory to,
        uint deadline,
        uint64 toPoolId,
        uint64 toChainId,
        bytes memory toAssetHash,
        uint polyMinOutAmount,
        uint fee
    ) external virtual payable ensure(deadline) returns (bool) {
        uint polyAmountIn;
        {
            uint amountOut = _swapExactETHForTokensSupportingFeeOnTransferTokens(swapAmountOutMin, path, fee);
            uint feeAmount = amountOut.mul(aggregatorFee).div(FEE_DENOMINATOR);
            emit LOG_AGG_SWAP(amountOut, feeAmount);
            polyAmountIn = amountOut.sub(feeAmount);
        }

        return _cross(
            path[path.length - 1],
            toPoolId,
            toChainId,
            toAssetHash,
            to,
            polyAmountIn,
            polyMinOutAmount,
            fee
        );
    }

    function _swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint swapAmountOutMin,
        address[] calldata path,
        uint fee
    ) internal virtual returns (uint) {
        require(path[0] == WETH, 'O3SwapETHUniswapBridge: INVALID_PATH');
        uint amountIn = msg.value.sub(fee);
        require(amountIn > 0, 'O3SwapETHUniswapBridge: INSUFFICIENT_INPUT_AMOUNT');
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(uniswapFactory, path[0], path[1]), amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(path[path.length - 1]).balanceOf(address(this)).sub(balanceBefore);
        require(amountOut >= swapAmountOutMin, 'O3SwapETHUniswapBridge: INSUFFICIENT_OUTPUT_AMOUNT');
        return amountOut;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint swapAmountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual ensure(deadline) {
        uint amountOut = _swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, swapAmountOutMin, path);
        uint feeAmount = amountOut.mul(aggregatorFee).div(FEE_DENOMINATOR);

        emit LOG_AGG_SWAP(amountOut, feeAmount);

        IWETH(WETH).withdraw(amountOut);
        uint adjustedAmountOut = amountOut.sub(feeAmount);
        TransferHelper.safeTransferETH(to, adjustedAmountOut);
    }

    function _swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint swapAmountOutMin,
        address[] calldata path
    ) internal virtual returns (uint) {
        require(path[path.length - 1] == WETH, 'O3SwapETHUniswapBridge: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(uniswapFactory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IERC20(WETH).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this)).sub(balanceBefore);
        require(amountOut >= swapAmountOutMin, 'O3SwapETHUniswapBridge: INSUFFICIENT_OUTPUT_AMOUNT');
        return amountOut;
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(uniswapFactory, input, output));
            uint amountInput;
            uint amountOutput;
            { // scope to avoid stack too deep errors
            (uint reserve0, uint reserve1,) = pair.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
            amountOutput = UniswapV2Library.getAmountOut(amountInput, reserveInput, reserveOutput);
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(uniswapFactory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    function _cross(
        address fromAssetHash,
        uint64 toPoolId,
        uint64 toChainId,
        bytes memory toAssetHash,
        bytes memory toAddress,
        uint amount,
        uint minOutAmount,
        uint fee
    ) internal returns (bool) {
        // Allow `swapper contract` to transfer `amount` of `fromAssetHash` on belaof of this contract.
        TransferHelper.safeApprove(fromAssetHash, polySwapper, amount);

        bool result = ISwapper(polySwapper).swap{value: fee}(
            fromAssetHash,
            toPoolId,
            toChainId,
            toAssetHash,
            toAddress,
            amount,
            minOutAmount,
            fee,
            polySwapperId
        );
        require(result, "POLY CROSSCHAIN ERROR");

        return result;
    }

    receive() external payable { }

    function setPolySwapperId(uint _id) external onlyOwner {
        polySwapperId = _id;
    }

    function collect(address token) external onlyOwner {
        if (token == WETH) {
            uint256 wethBalance = IERC20(token).balanceOf(address(this));
            if (wethBalance > 0) {
                IWETH(WETH).withdraw(wethBalance);
            }
            TransferHelper.safeTransferETH(owner(), address(this).balance);
        } else {
            TransferHelper.safeTransfer(token, owner(), IERC20(token).balanceOf(address(this)));
        }
    }

    function setAggregatorFee(uint _fee) external onlyOwner {
        aggregatorFee = _fee;
    }

    function setUniswapFactory(address _factory) external onlyOwner {
        uniswapFactory = _factory;
    }

    function setPolySwapper(address _swapper) external onlyOwner {
        polySwapper = _swapper;
    }

    function setWETH(address _weth) external onlyOwner {
        WETH = _weth;
    }
}