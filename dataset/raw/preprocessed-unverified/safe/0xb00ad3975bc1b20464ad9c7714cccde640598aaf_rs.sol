/**
 *Submitted for verification at Etherscan.io on 2020-11-05
*/

/**
 *Submitted for verification at Etherscan.io on 2020-11-05
*/

pragma solidity =0.6.6;


contract TDRouter {
    using SafeMath for uint;
    address public immutable  factory;
    address public immutable  WETH;
    address admin;
    mapping(address=>address) public tokenAd;
    uint tradeFeeScale; //denominator is 10000;
    uint256 public totalETH;
    uint256 public transactions;
    
    struct RocordInfo {
        uint256 totalETH;
        uint256 transactions;
        uint256 totalTD;
    }
    mapping(address=>RocordInfo) public swapInfo;
    
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'TDRouter: Dealline too low');
        _;
    }
    
    modifier onlyAdmin () {
        require(msg.sender == admin, 'You are not admin.');
        _;
    }
    
    function addTokenPair(address tokenA, address tokenB, uint256 _totalETH, uint256 _totalTD, uint256 _transactions) external onlyAdmin {
        tokenAd[tokenA] = tokenB; // taokenA is real token,such like DAI USDT,tokenB is TD-DAI/TD-USDT
        swapInfo[tokenA].totalETH = _totalETH.mul(1e18);
        swapInfo[tokenA].totalTD = _totalTD.mul(1e18); 
        swapInfo[tokenA].transactions = _transactions;
        totalETH = totalETH.add(_totalETH);
    }

    constructor() public {
        factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
        WETH    = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        admin = 0xAB4537a2BF87E9F3B1CE44590fd0d67C48f7c95a;
        tradeFeeScale = 5;  // unit: 1/10000
    }
    
    
    event print(string str, uint256 a);
    event printadd(string str,address a);

    receive() external payable {
    }
    
    
    function dividend() public onlyAdmin {
        uint256 bonus;
        address payable holder;
        uint256 scale;
        require(msg.sender == admin, "TDrouter: The function you requested does not exist");

        uint256 amount = address(this).balance;
        
        require(amount>0,'ShareHolder: Invaild amount');
        
        holder = 0x2Dc11a0A66810cd9ff57ef5c852284A6E3B394eb;
        scale  = 90;
        bonus = amount.mul(scale).div(uint256(100));
        holder.transfer(bonus);
        
        holder = 0x0B815939cF211AE89229e79C175d04C824293dCb;
        scale  = 1;
        bonus = amount.mul(scale).div(uint256(100));
        holder.transfer(bonus);
        
        holder = 0x18d98Da67be252479393481c8ECd96f50DBDa69f;
        scale  = 1;
        bonus = amount.mul(scale).div(uint256(100));
        holder.transfer(bonus);
        
        holder = 0xd5683465475418576bB1209531cAD625f5CE20b6;
        scale  = 1;
        bonus = amount.mul(scale).div(uint256(100));
        holder.transfer(bonus);
        
        holder = 0x223055E9F4015f7f20d1d66abb098BEB89d0B366;
        scale  = 1;
        bonus = amount.mul(scale).div(uint256(100));
        holder.transfer(bonus);
        
        holder = 0x5a4472C8371425A6611DEBA611E83d9844328c72;
        scale  = 1;
        bonus = amount.mul(scale).div(uint256(100));
        holder.transfer(bonus);
        
        holder = 0x7f588fC81FdE30b0CCC569E06D39b42fe5deaA48;
        scale  = 1;
        bonus = amount.mul(scale).div(uint256(100));
        holder.transfer(bonus);
        
        holder = 0x5d1dd7C0145587F837bB1Fa35CD83dB0b2BC0D75;
        scale  = 1;
        bonus = amount.mul(scale).div(uint256(100));
        holder.transfer(bonus);
        
        holder = 0x62c0007cd68512EF6c38C3a648Bb74752873c090;
        scale  = 1;
        bonus = amount.mul(scale).div(uint256(100));
        holder.transfer(bonus);
        
        holder = 0xAdd411fa15f86425bfc820F6Cd0bCBE750F3D327;
        scale  = 1;
        bonus = amount.mul(scale).div(uint256(100));
        holder.transfer(bonus);
        
        holder = 0x025c00265CA53553038d493d4caA4D18c481851a;
        scale  = 1;
        bonus = amount.mul(scale).div(uint256(100));
        holder.transfer(bonus);
    }

    function _userReward(address token, address to, uint value) internal {
        require (value > 0 && to != address(0), "TDrouter: Address or value error.");
        require(tokenAd[token] != address(0), "TDrouter: Token address error.");
        uint amount = value.mul(swapInfo[token].totalTD).div(swapInfo[token].totalETH);
        address userTdAdd = tokenAd[token];
        TransferHelper.safeTransfer(userTdAdd, to , amount);
        swapInfo[token].totalTD = swapInfo[token].totalTD.add(amount);
    }
    
    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = UniswapV2Library.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? UniswapV2Library.pairFor(factory, output, path[i + 2]) : _to;
            IUniswapV2Pair(UniswapV2Library.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }
    
    event Buy(uint256 amountOutMin, address path,address to, uint256 deadline);
    event Sell(uint amountIn, uint amountOutMin, address path,address to, uint256 deadline);
    
    function buy(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        payable
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[0] == WETH, 'TDRouter: INVALID_PATH');
        
        uint unm = msg.value;
        uint fz = unm.mul(tradeFeeScale);
        uint fee= fz.div(10000);
       
        amounts = UniswapV2Library.getAmountsOut(factory, msg.value - fee, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'TDRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]));
        _swap(amounts, path, to);
        {
            totalETH = totalETH.add(amounts[0]);
            transactions++;
            swapInfo[path[1]].totalETH = swapInfo[path[1]].totalETH.add(amounts[0]);
            swapInfo[path[1]].transactions++;
            uint val = msg.value;
            _userReward(path[1], to, val);  //send TD token.
        }
        emit Buy(amountOutMin,path[1],to,deadline);
    }


    function sell(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        virtual
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == WETH, 'TDRouter: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'TDRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);

        uint unm = amounts[amounts.length - 1];
        uint fz = unm.mul(tradeFeeScale);
        uint fee= fz.div(10000);

        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1] - fee);  //transfer ETH for user.
        {
            totalETH = totalETH.add(amounts[amounts.length - 1]);
            transactions++;
            swapInfo[path[0]].totalETH = swapInfo[path[0]].totalETH.add(amounts[amounts.length - 1]);
            swapInfo[path[0]].transactions++;
            _userReward(path[0], to, amounts[amounts.length - 1]);  //reward trander.
        }
        emit Sell(amountIn, amountOutMin,path[0],to,deadline);
    }


    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual returns (uint amountB) {
        return UniswapV2Library.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)
        public
        pure
        returns (uint amountOut)
    {
        return UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)
        public
        pure
        returns (uint amountIn)
    {
        return UniswapV2Library.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path)
        public
        view
        returns (uint[] memory amounts)
    {
        return UniswapV2Library.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path)
        public
        view
        returns (uint[] memory amounts)
    {
        return UniswapV2Library.getAmountsIn(factory, amountOut, path);
    }
}







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












interface IUniswapV2Router02 is IUniswapV2Router01 {
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