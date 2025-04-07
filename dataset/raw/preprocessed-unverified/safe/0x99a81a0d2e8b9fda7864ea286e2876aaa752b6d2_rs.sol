/**
 *Submitted for verification at Etherscan.io on 2021-06-22
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;
pragma experimental ABIEncoderV2;



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}







abstract contract Ownable is Context {
    address private _owner;
    address private _dev;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        _dev = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function dev() public view returns (address) {
        return _dev;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyDev() {
        require(_dev == _msgSender(), "Ownable: caller is not the dev");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transferDevship(address newDev) public virtual onlyDev {
        require(newDev != address(0), "Ownable: new dev is the zero address");
        _dev = newDev;
    }
}











interface IUniswapV2Router02 is IUniswapV2Router01 {
}

interface TokenInterface is IERC20 {
    function deposit() external payable;

    function withdraw(uint256) external;
}





contract SwapBot is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for TokenInterface;

    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    TokenInterface private _weth;

    IUniswapV2Router02[] public _routers;
    IUniswapV2Factory[] public _factories;
    address[] private _runners;

    struct Root {
        uint8[] routerIds;
        address[] inTokens;
        uint256 startAmount;
        uint256 estimateProfit;
        uint256 chiAmount;
    }

    struct PairInfo {
        IUniswapV2Pair pair;
        uint256 outputAmount;
        bool isReserveIn;
    }

    modifier onlyRunner() {
        (bool exist, ) = checkRunner(_msgSender());
        require(exist, "caller is not the runner");
        _;
    }

    modifier discountCHI(uint256 chiAmount) {
        if (chiAmount > 0) {
            uint256 gasStart = gasleft();
            _;
            uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            chi.freeFromUpTo(_msgSender(), Math.min((gasSpent + 14154) / 41947, chiAmount));
        } else {
            _;
        }
    }

    constructor() {
        _weth = TokenInterface(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));

        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D));
        IUniswapV2Router02 sushiswapV2Router = IUniswapV2Router02(address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F));

        _routers.push(uniswapV2Router);
        _routers.push(sushiswapV2Router);

        _factories.push(IUniswapV2Factory(uniswapV2Router.factory()));
        _factories.push(IUniswapV2Factory(sushiswapV2Router.factory()));

        _runners.push(_msgSender());
    }

    receive() external payable {
    }

    function deposit(uint256 depositAmount) public onlyDev {
        _weth.deposit{value: depositAmount}();
    }

    function runnerLength() public view returns (uint8) {
        return uint8(_runners.length);
    }
    
    function checkRunner(address runner)
        public
        view
        returns (bool exist, uint8 index)
    {
        uint8 length = runnerLength();
        exist = false;
        for (uint8 i = 0; i < length; i++) {
            if (_runners[i] == runner) {
                exist = true;
                index = i;
                break;
            }
        }
    }

    function addRunner(address runner) external onlyDev {
        require(runner != address(0), "Invalid runner address.");

        _runners.push(address(runner));
    }

    function withdrawProfit(address withdrawAddress, uint256 withdrawAmount)
        public
        onlyOwner
        returns (bool sent)
    {
        uint256 balance = _weth.balanceOf(address(this));
        require(balance > withdrawAmount, "Invalid Withdraw Amount");

        _weth.withdraw(withdrawAmount);
        (sent, ) = withdrawAddress.call{value: withdrawAmount}("");
        require(sent, "Invalid withdraw ETH");
    }

    function emergencyWithdraw(address withdrawAddress) 
        public
        onlyDev
        returns (bool sent)
    {
        uint256 withdrawAmount = _weth.balanceOf(address(this));
        _weth.withdraw(withdrawAmount);
        uint256 ethAmount = address(this).balance;
        (sent, ) = withdrawAddress.call{value: ethAmount}("");
        require(sent, "Invalid withdraw ETH");
    }

    function checkEstimatedProfit(
        uint8[] memory routerIds,
        uint256 startAmount,
        address[] memory inTokens
    ) 
        public 
        view 
        returns (
            uint256,
            PairInfo[] memory
        )
    {
        uint256 len = inTokens.length;
        uint256 amountIn = startAmount;
        bool isReserveIn;
        PairInfo[] memory pairList = new PairInfo[](len - 1);


        for (uint256 i = 0; i < len - 1; i++) {
            IUniswapV2Factory factory = _factories[routerIds[i]];

            IUniswapV2Pair pair = IUniswapV2Pair(factory.getPair(inTokens[i], inTokens[i + 1]));

            (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();

            isReserveIn = pair.token0() == inTokens[i] ? true : false;

            amountIn = UniswapV2Library.getAmountOut(
                amountIn,
                isReserveIn ? reserve0 : reserve1,
                !isReserveIn ? reserve0 : reserve1
            );

            pairList[i] = PairInfo(
                pair,
                amountIn,
                isReserveIn
            );
        }

        uint256 profit = amountIn <= startAmount ? 0 : amountIn.sub(startAmount);
        return (profit, pairList);
    }

    function run(
        Root memory router
    ) public onlyRunner discountCHI(router.chiAmount) {
        (uint256 estimateProfit, PairInfo[] memory pairList)
            = checkEstimatedProfit(router.routerIds, router.startAmount, router.inTokens);

        if (estimateProfit < router.estimateProfit) {
            return;
        }

        uint256 len = router.inTokens.length;
        uint256 amountIn = router.startAmount;

        for (uint256 i = 0; i < len - 1; i++) {
            amountIn = _swapTokenToToken(
                amountIn,
                router.inTokens[i],
                router.inTokens[i + 1],
                pairList[i]
            );
        }
        return;
    }

    function bulkRun(Root[] memory roots)
        external
        onlyRunner
        returns (bool)
    {
        uint256 length = roots.length;

        uint256 maxProfit = 0;
        uint256 goalRoot = 0;
        for (uint256 i = 0; i < length; i++) {
            Root memory root = roots[i];

            (uint256 profit, ) = checkEstimatedProfit(
                root.routerIds,
                root.startAmount,
                root.inTokens
            );

            if (profit > maxProfit) {
                maxProfit = profit;
                goalRoot = i;
            }
        }

        if (maxProfit > 0) {
            Root memory root = roots[goalRoot];
            run(root);
        }

        return true;
    }

    function _swapTokenToToken(
        uint256 tokenInAmount,
        address inToken,
        address outToken,
        PairInfo memory pairInfo
    ) private returns (uint256 amountOut) {
        uint256 oldTokenOutAmount = TokenInterface(outToken).balanceOf(address(this));

        TokenInterface(inToken).safeTransfer(address(pairInfo.pair), tokenInAmount);
        _swapSupportingFeeOnTransferTokens(
            pairInfo
        );
        
        uint256 newTokenOutAmount = TokenInterface(outToken).balanceOf(address(this));
        amountOut = newTokenOutAmount.sub(oldTokenOutAmount);
    }

    function _swapSupportingFeeOnTransferTokens(
        PairInfo memory pairInfo
    ) internal virtual {
        (uint256 amount0Out, uint256 amount1Out) =
            pairInfo.isReserveIn
                ? (uint256(0), pairInfo.outputAmount)
                : (pairInfo.outputAmount, uint256(0));

        pairInfo.pair.swap(amount0Out, amount1Out, address(this), new bytes(0));
    }
}