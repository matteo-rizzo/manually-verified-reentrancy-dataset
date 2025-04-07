/**
 *Submitted for verification at Etherscan.io on 2020-10-22
*/

pragma solidity ^0.6.12;





/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */









/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 */







contract BalancerZAP {

    using SafeMath for uint256;

    address public _token;
    address public _balancerPool;
    address public _tokenWETHPair;
    IWETH public _WETH;
    bool private initialized;

    function initBalancerZAP(address token, address balancerPool, address WETH, address tokenWethPair) public  {
        require(!initialized);
        _token = token;
        _balancerPool = balancerPool;
        require(IERC20(_token).approve(balancerPool, uint(-1)));
        _WETH = IWETH(WETH);
        _tokenWETHPair = tokenWethPair;
        initialized = true;
    }

    fallback() external payable {
        if(msg.sender != address(_WETH)){
             addLiquidityETHOnly(msg.sender);
        }
    }
    receive() external payable {
        if(msg.sender != address(_WETH)){
             addLiquidityETHOnly(msg.sender);
        }
    }

    function addLiquidityETHOnly(address payable to) public payable {
        require(to != address(0), "Invalid address");

        uint256 buyAmount = msg.value;
        require(buyAmount > 0, "Insufficient ETH amount");
        _WETH.deposit{value : msg.value}();

        (uint256 reserveWeth, uint256 reserveTokens) = getPairReserves();
        uint256 outTokens = UniswapV2Library.getAmountOut(buyAmount, reserveWeth, reserveTokens);
        
        _WETH.transfer(_tokenWETHPair, buyAmount);

        (address token0, address token1) = UniswapV2Library.sortTokens(address(_WETH), _token);
        IUniswapV2Pair(_tokenWETHPair).swap(_token == token0 ? outTokens : 0, _token == token1 ? outTokens : 0, address(this), "");

        _addLiquidity(outTokens, to);

    }

    function addLiquidityTokenOnly(uint256 tokenAmount, address payable to) public payable {
        require(to != address(0), "Invalid address");
        require(tokenAmount > 0, "Insufficient token amount");

        require(IERC20(_token).transferFrom(msg.sender, address(this), tokenAmount)); 
        _addLiquidity(tokenAmount, to);

    }

    function _addLiquidity(uint256 tokenAmount, address payable to) internal {

        //mint BPTs 
        uint256 bptTokens = IBPool(_balancerPool).joinswapExternAmountIn( _token, tokenAmount, 0);
        require(bptTokens > 0, "Insufficient BPT amount");
    
        //transfer tokens to user
        require(IBPool(_balancerPool).transfer(to, bptTokens));

    }

    function getPairReserves() internal view returns (uint256 wethReserves, uint256 tokenReserves) {
        (address token0,) = UniswapV2Library.sortTokens(address(_WETH), _token);
        (uint256 reserve0, uint reserve1,) = IUniswapV2Pair(_tokenWETHPair).getReserves();
        (wethReserves, tokenReserves) = token0 == _token ? (reserve1, reserve0) : (reserve0, reserve1);
    }


}