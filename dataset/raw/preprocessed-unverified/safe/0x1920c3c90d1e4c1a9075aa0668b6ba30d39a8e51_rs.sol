/**
 *Submitted for verification at Etherscan.io on 2021-08-21
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;













interface weth9 is erc20 {
    function deposit() external payable;
    function withdraw(uint256) external;
}



contract Keep3rV1Pair {
    
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    
    uint public totalSupply = 0;
    
    mapping(address => mapping (address => uint)) public allowance;
    mapping(address => uint) public balanceOf;
    
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    
    address public immutable token0;
    address public immutable token1;
    
    address public immutable pool;
    
    address public governance;
    address public pendingGovernance;

    int24 constant tickLower = -887200;
    int24 constant tickUpper = 887200;
    
    weth9 constant weth = weth9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    
    uint24 immutable fee;
    
    function _safeTransfer(address token,address to,uint256 value) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(erc20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }
    
    function _safeTransferFrom(address token, address from, address to, uint256 value) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(erc20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }

    constructor(address _pool) {
        pool = _pool;
        address _token0 = univ3(_pool).token0();
        address _token1 = univ3(_pool).token1();
        token0 =  _token0;
        token1 =  _token1;
        fee = univ3(_pool).fee();
        name = string(abi.encodePacked("Keep3rV1 - ", erc20(_token0).symbol(), "/", erc20(_token1).symbol()));
        symbol = string(abi.encodePacked("kLP-", erc20(_token0).symbol(), "/", erc20(_token1).symbol()));
        governance = msg.sender;
    }
    
    modifier gov() {
        require(msg.sender == governance);
        _;
    }
    
    function setGovernance(address _governance) external gov {
        pendingGovernance = _governance;
    }
    
    function acceptGovernance() external {
        require(msg.sender == pendingGovernance);
        governance = pendingGovernance;
    }
    
    struct MintCallbackData {
        PoolAddress.PoolKey poolKey;
        address payer;
    }
    
    /// @notice Add liquidity to an initialized pool
    function _addLiquidity(uint amount0Desired, uint amount1Desired, uint amount0Min, uint amount1Min)
        internal
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        )
    {
        PoolAddress.PoolKey memory poolKey =
            PoolAddress.PoolKey({token0: token0, token1: token1, fee: fee});
            
        // compute the liquidity amount
        {
            (uint160 sqrtPriceX96, , , , , , ) = univ3(pool).slot0();
            uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
            uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);

            liquidity = LiquidityAmounts.getLiquidityForAmounts(
                sqrtPriceX96,
                sqrtRatioAX96,
                sqrtRatioBX96,
                amount0Desired,
                amount1Desired
            );
        }

        (amount0, amount1) = univ3(pool).mint(
            address(this),
            tickLower,
            tickUpper,
            liquidity,
            abi.encode(MintCallbackData({poolKey: poolKey, payer: msg.sender}))
        );

        require(amount0 >= amount0Min && amount1 >= amount1Min, 'Price slippage check');
    }
    
    function _pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == address(weth) && address(this).balance >= value) {
            // pay with WETH9
            weth.deposit{value: value}(); // wrap only what is needed to pay
            weth.transfer(recipient, value);
        } else if (payer == address(this)) {
            _safeTransfer(token, recipient, value);
        } else {
            _safeTransferFrom(token, payer, recipient, value);
        }
    }
    
    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
    
    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external {
        MintCallbackData memory decoded = abi.decode(data, (MintCallbackData));
        require(msg.sender == pool);
        if (amount0Owed > 0) _pay(decoded.poolKey.token0, decoded.payer, pool, amount0Owed);
        if (amount1Owed > 0) _pay(decoded.poolKey.token1, decoded.payer, pool, amount1Owed);
    }
    
    // this low-level function should be called from a contract which performs important safety checks
    function mint(uint amount0Desired, uint amount1Desired, uint amount0Min, uint amount1Min, address to) external payable returns (uint128 liquidity) {
       (liquidity,,) = _addLiquidity(amount0Desired, amount1Desired, amount0Min, amount1Min);
       _mint(to, liquidity);
       if (address(this).balance > 0) _safeTransferETH(msg.sender, address(this).balance);
    }
    
    function position() external view returns (uint128 liquidity, uint feeGrowthInside0LastX128, uint feeGrowthInside1LastX128, uint128 tokensOwed0, uint128 tokensOwed1) {
        (liquidity,feeGrowthInside0LastX128,feeGrowthInside1LastX128,tokensOwed0,tokensOwed1) = univ3(pool).positions(keccak256(abi.encodePacked(address(this), tickLower, tickUpper)));
    }
    
    function collect() external gov returns (uint amount0, uint amount1) {
        (,,,uint128 tokensOwed0, uint128 tokensOwed1) = univ3(pool).positions(keccak256(abi.encodePacked(address(this), tickLower, tickUpper)));
        (amount0, amount1) = univ3(pool).collect(governance, tickLower, tickUpper, tokensOwed0, tokensOwed1);
    }
    
    function burn(uint128 liquidity, uint amount0Min, uint amount1Min, address to) external returns (uint amount0, uint amount1) {
        (amount0, amount1) = univ3(pool).burn(tickLower, tickUpper, liquidity);
        require(amount0 >= amount0Min && amount1 >= amount1Min, 'Price slippage check');
        univ3(pool).collect(to, tickLower, tickUpper, uint128(amount0), uint128(amount1));
        _burn(msg.sender, liquidity);
    }
    
    function _mint(address dst, uint amount) internal {
        totalSupply += amount;
        balanceOf[dst] += amount;
        emit Transfer(address(0), dst, amount);
    }
        
    function _burn(address dst, uint amount) internal {
        totalSupply -= amount;
        balanceOf[dst] -= amount;
        emit Transfer(dst, address(0), amount);
    }

    function approve(address spender, uint amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address dst, uint amount) external returns (bool) {
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    function transferFrom(address src, address dst, uint amount) external returns (bool) {
        address spender = msg.sender;
        uint spenderAllowance = allowance[src][spender];

        if (spender != src && spenderAllowance != type(uint).max) {
            uint newAllowance = spenderAllowance - amount;
            allowance[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function _transferTokens(address src, address dst, uint amount) internal {
        balanceOf[src] -= amount;
        balanceOf[dst] += amount;
        
        emit Transfer(src, dst, amount);
    }
}