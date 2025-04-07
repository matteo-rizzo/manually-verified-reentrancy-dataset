/**
 *Submitted for verification at Etherscan.io on 2021-07-12
*/

pragma solidity =0.7.6;
pragma abicoder v2;

// File: contracts/interfaces/IHotPotV2FundFactory.sol
/// @title The interface for the HotPotFunds V2 Factory
/// @notice The HotPotFunds V2 Factory facilitates creation of HotPotFunds V2 funds


// File: contracts/interfaces/fund/IHotPotV2FundManagerActions.sol
/// @notice 基金经理操作接口定义


// File: contracts/interfaces/controller/IManagerActions.sol
/// @title 控制器合约基金经理操作接口定义


// File: contracts/interfaces/controller/IGovernanceActions.sol
/// @title 治理操作接口定义


// File: contracts/interfaces/controller/IControllerState.sol
/// @title HotPotV2Controller 状态变量及只读函数


// File: contracts/interfaces/controller/IControllerEvents.sol
/// @title HotPotV2Controller 事件接口定义


// File: contracts/interfaces/IHotPotV2FundController.sol
/// @title Hotpot V2 控制合约接口定义.
/// @notice 基金经理和治理均需通过控制合约进行操作.
interface IHotPotV2FundController is IManagerActions, IGovernanceActions, IControllerState, IControllerEvents {
    /// @notice 基金分成全部用于销毁HPT
    /// @dev 任何人都可以调用本函数
    /// @param token 用于销毁时购买HPT的代币类型
    /// @param amount 代币数量
    /// @return burned 销毁数量
    function harvest(address token, uint amount) external returns(uint burned);
}

// File: contracts/interfaces/IHotPotV2FundDeployer.sol
/// @title An interface for a contract that is capable of deploying Hotpot V2 Funds
/// @notice A contract that constructs a fund must implement this to pass arguments to the fund
/// @dev This is used to avoid having constructor arguments in the fund contract, which results in the init code hash
/// of the fund being constant allowing the CREATE2 address of the fund to be cheaply computed on-chain


// File: @uniswap/v3-core/contracts/interfaces/callback/IUniswapV3MintCallback.sol
/// @title Callback for IUniswapV3PoolActions#mint
/// @notice Any contract that calls IUniswapV3PoolActions#mint must implement this interface


// File: @uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol
/// @title The interface for the Uniswap V3 Factory
/// @notice The Uniswap V3 Factory facilitates creation of Uniswap V3 pools and control over the protocol fees


// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolImmutables.sol
/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values


// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol
/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction


// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolDerivedState.sol
/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.


// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolActions.sol
/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone


// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolOwnerActions.sol
/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner


// File: @uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolEvents.sol
/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool


// File: @uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol
/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

// File: @uniswap/v3-core/contracts/libraries/TickMath.sol
/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128


// File: @uniswap/v3-core/contracts/libraries/FullMath.sol
/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits


// File: @uniswap/v3-core/contracts/libraries/FixedPoint128.sol
/// @title FixedPoint128
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)


// File: @uniswap/v3-core/contracts/libraries/LowGasSafeMath.sol
/// @title Optimized overflow and underflow safe math operations
/// @notice Contains methods for doing math operations that revert on overflow or underflow for minimal gas cost


// File: @uniswap/v3-core/contracts/libraries/SafeCast.sol
/// @title Safe casting methods
/// @notice Contains methods for safely casting between types


// File: @uniswap/v3-core/contracts/libraries/UnsafeMath.sol
/// @title Math functions that do not check inputs or outputs
/// @notice Contains methods that perform common math functions but do not do any overflow or underflow checks


// File: @uniswap/v3-core/contracts/libraries/FixedPoint96.sol
/// @title FixedPoint96
/// @notice A library for handling binary fixed point numbers, see https://en.wikipedia.org/wiki/Q_(number_format)
/// @dev Used in SqrtPriceMath.sol


// File: @uniswap/v3-core/contracts/libraries/SqrtPriceMath.sol
/// @title Functions based on Q64.96 sqrt price and liquidity
/// @notice Contains the math that uses square root of price as a Q64.96 and liquidity to compute deltas


// File: @uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol
/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface


// File: @uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol
/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}

// File: @uniswap/v3-periphery/contracts/libraries/LiquidityAmounts.sol
/// @title Liquidity amount functions
/// @notice Provides functions for computing liquidity amounts from token amounts and prices


// File: @uniswap/v3-periphery/contracts/libraries/PositionKey.sol


// File: @uniswap/v3-periphery/contracts/libraries/PoolAddress.sol
/// @title Provides functions for deriving a pool address from the factory, tokens, and the fee


// File: @uniswap/v3-periphery/contracts/libraries/BytesLib.sol
/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <[email protected]>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 */


// File: @uniswap/v3-periphery/contracts/libraries/Path.sol
/// @title Functions for manipulating path data for multihop swaps


// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @uniswap/v3-periphery/contracts/libraries/TransferHelper.sol


// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol
/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: contracts/interfaces/IHotPotV2FundERC20.sol

/// @title Hotpot V2 基金份额代币接口定义
interface IHotPotV2FundERC20 is IERC20{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

// File: contracts/interfaces/fund/IHotPotV2FundEvents.sol
/// @title Hotpot V2 事件接口定义


// File: contracts/interfaces/fund/IHotPotV2FundState.sol
/// @title Hotpot V2 状态变量及只读函数


// File: contracts/interfaces/fund/IHotPotV2FundUserActions.sol
/// @title Hotpot V2 用户操作接口定义
/// @notice 存入(deposit)函数适用于ERC20基金; 如果是ETH基金(内部会转换为WETH9)，应直接向基金合约转账; 


// File: contracts/interfaces/IHotPotV2Fund.sol
/// @title Hotpot V2 基金接口
/// @notice 接口定义分散在多个接口文件
interface IHotPotV2Fund is 
    IHotPotV2FundERC20, 
    IHotPotV2FundEvents, 
    IHotPotV2FundState, 
    IHotPotV2FundUserActions, 
    IHotPotV2FundManagerActions
{    
}

// File: contracts/interfaces/external/IWETH9.sol
/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}

// File: contracts/base/HotPotV2FundERC20.sol
abstract contract HotPotV2FundERC20 is IHotPotV2FundERC20{
    using LowGasSafeMath for uint;

    string public override constant name = 'Hotpot V2';
    string public override constant symbol = 'HPT-V2';
    uint8 public override constant decimals = 18;
    uint public override totalSupply;

    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;

    constructor() {
    }

    function _mint(address to, uint value) internal {
        require(to != address(0), "ERC20: mint to the zero address");

        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        require(from != address(0), "ERC20: burn from the zero address");

        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function approve(address spender, uint value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function _transfer(address from, address to, uint value) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from, 
        address to, 
        uint value
    ) external override returns (bool) {
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }
}

// File: contracts/libraries/Position.sol


// File: contracts/libraries/Array2D.sol


// File: contracts/HotPotV2Fund.sol
contract HotPotV2Fund is HotPotV2FundERC20, IHotPotV2Fund, IUniswapV3MintCallback, ReentrancyGuard {
    using LowGasSafeMath for uint;
    using SafeCast for int256;
    using Path for bytes;
    using Position for Position.Info;
    using Position for Position.Info[];
    using Array2D for uint[][];

    uint constant DIVISOR = 100 << 128;
    uint constant MANAGER_FEE = 10 << 128;
    uint constant FEE = 10 << 128;

    address immutable WETH9;
    address immutable uniV3Factory;
    address immutable uniV3Router;

    address public override immutable controller;
    address public override immutable manager;
    address public override immutable token;
    bytes32 public override descriptor;

    uint public override totalInvestment;

    /// @inheritdoc IHotPotV2FundState
    mapping (address => uint) override public investmentOf;

    /// @inheritdoc IHotPotV2FundState
    mapping(address => bytes) public override buyPath;
    /// @inheritdoc IHotPotV2FundState
    mapping(address => bytes) public override sellPath;

    /// @inheritdoc IHotPotV2FundState
    address[] public override pools;
    /// @inheritdoc IHotPotV2FundState
    Position.Info[][] public override positions;

    modifier onlyController() {
        require(msg.sender == controller, "OCC");
        _;
    }

    constructor () {
        address _token;
        address _uniV3Router;
        (WETH9, uniV3Factory, _uniV3Router, controller, manager, _token, descriptor) = IHotPotV2FundDeployer(msg.sender).parameters();
        token = _token;
        uniV3Router = _uniV3Router;

        //approve for add liquidity and swap. 2**256-1 never used up.
        TransferHelper.safeApprove(_token, _uniV3Router, 2**256-1);
    }

    /// @inheritdoc IHotPotV2FundUserActions
    function deposit(uint amount) external override returns(uint share) {
        require(amount > 0, "DAZ");
        uint total_assets = totalAssets();
        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amount);

        return _deposit(amount, total_assets);
    }

    function _deposit(uint amount, uint total_assets) internal returns(uint share) {
        if(totalSupply == 0)
            share = amount;
        else
            share =  FullMath.mulDiv(amount, totalSupply, total_assets);

        investmentOf[msg.sender] = investmentOf[msg.sender].add(amount);
        totalInvestment = totalInvestment.add(amount);
        _mint(msg.sender, share);
        emit Deposit(msg.sender, amount, share);
    }

    receive() external payable {
        //当前是WETH9基金
        if(token == WETH9){
            // 普通用户发起的转账ETH，认为是deposit
            if(msg.sender != WETH9 && msg.value > 0){
                uint totals = totalAssets();
                IWETH9(WETH9).deposit{value: address(this).balance}();
                _deposit(msg.value, totals);
            } //else 接收WETH9向合约转账ETH
        }
        // 不是WETH基金, 不接受ETH转账
        else revert();
    }

    /// @inheritdoc IHotPotV2FundUserActions
    function withdraw(uint share) external override nonReentrant returns(uint amount) {
        uint balance = balanceOf[msg.sender];
        require(share > 0 && share <= balance, "ISA");
        uint investment = FullMath.mulDiv(investmentOf[msg.sender], share, balance);

        address fToken = token;
        // 构造amounts数组
        uint value = IERC20(fToken).balanceOf(address(this));
        uint _totalAssets = value;
        uint[][] memory amounts = new uint[][](pools.length);
        for(uint i=0; i<pools.length; i++){
            uint _amount;
            (_amount, amounts[i]) = _assetsOfPool(i);
            _totalAssets = _totalAssets.add(_amount);
        }

        amount = FullMath.mulDiv(_totalAssets, share, totalSupply);
        // 从大到小从头寸中撤资.
        if(amount > value) {
            uint remainingAmount = amount.sub(value);
            while(true) {
                // 取最大的头寸索引号
                (uint poolIndex, uint positionIndex, uint desirableAmount) = amounts.max();
                if(desirableAmount == 0) break;

                if(remainingAmount <= desirableAmount){
                    positions[poolIndex][positionIndex].subLiquidity(Position.SubParams({
                        proportionX128: FullMath.mulDiv(remainingAmount, DIVISOR, desirableAmount),
                        pool: pools[poolIndex],
                        token: fToken,
                        uniV3Router: uniV3Router
                    }), sellPath);
                    break;
                }
                else {
                    positions[poolIndex][positionIndex].subLiquidity(Position.SubParams({
                            proportionX128: DIVISOR,
                            pool: pools[poolIndex],
                            token: fToken,
                            uniV3Router: uniV3Router
                        }), sellPath);
                    remainingAmount = remainingAmount.sub(desirableAmount);
                    amounts[poolIndex][positionIndex] = 0;
                }
            }
            /// @dev 从流动池中撤资时，按比例撤流动性, 同时tokensOwed已全部提取，所以此时的基金本币余额会超过用户可提金额.
            value = IERC20(fToken).balanceOf(address(this));
            // 如果计算值比实际取出值大
            if(amount > value)
                amount = value;
            // 如果是最后一个人withdraw
            else if(totalSupply == share)
                amount = value;
        }

        // 处理基金经理分成和基金分成
        if(amount > investment){
            uint _manager_fee = FullMath.mulDiv(amount.sub(investment), MANAGER_FEE, DIVISOR);
            uint _fee = FullMath.mulDiv(amount.sub(investment), FEE, DIVISOR);
            TransferHelper.safeTransfer(fToken, manager, _manager_fee);
            TransferHelper.safeTransfer(fToken, controller, _fee);
            amount = amount.sub(_fee).sub(_manager_fee);
        }
        else
            investment = amount;

        // 处理转账
        investmentOf[msg.sender] = investmentOf[msg.sender].sub(investment);
        totalInvestment = totalInvestment.sub(investment);
        _burn(msg.sender, share);

        if(fToken == WETH9){
            IWETH9(WETH9).withdraw(amount);
            TransferHelper.safeTransferETH(msg.sender, amount);
        } else {
            TransferHelper.safeTransfer(fToken, msg.sender, amount);
        }

        emit Withdraw(msg.sender, amount, share);
    }

    /// @inheritdoc IHotPotV2FundState
    function poolsLength() external override view returns(uint){
        return pools.length;
    }

    /// @inheritdoc IHotPotV2FundState
    function positionsLength(uint poolIndex) external override view returns(uint){
        return positions[poolIndex].length;
    }

    /// @inheritdoc IHotPotV2FundManagerActions
    function setPath(
        address distToken,
        bytes memory buy,
        bytes memory sell
    ) external override onlyController{
        // 要修改sellPath, 需要先清空相关pool头寸资产
        if(sellPath[distToken].length > 0){
            for(uint i = 0; i < pools.length; i++){
                IUniswapV3Pool pool = IUniswapV3Pool(pools[i]);
                if(pool.token0() == distToken || pool.token1() == distToken){
                    (uint amount,) = _assetsOfPool(i);
                    require(amount == 0, "AZ");
                }
            }
        }
        TransferHelper.safeApprove(distToken, uniV3Router, 0);
        TransferHelper.safeApprove(distToken, uniV3Router, 2**256-1);
        buyPath[distToken] = buy;
        sellPath[distToken] = sell;
    }

    /// @inheritdoc IUniswapV3MintCallback
    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external override {
        address pool = pools[abi.decode(data, (uint))];
        require(msg.sender == pool, "MQE");

        // 转账给pool
        if (amount0Owed > 0) TransferHelper.safeTransfer(IUniswapV3Pool(pool).token0(), msg.sender, amount0Owed);
        if (amount1Owed > 0) TransferHelper.safeTransfer(IUniswapV3Pool(pool).token1(), msg.sender, amount1Owed);
    }

    /// @inheritdoc IHotPotV2FundManagerActions
    function init(
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint amount
    ) external override onlyController{
        // 1、检查pool是否有效
        require(tickLower < tickUpper && token0 < token1, "ITV");
        address pool = IUniswapV3Factory(uniV3Factory).getPool(token0, token1, fee);
        require(pool != address(0), "ITF");
        int24 tickspacing = IUniswapV3Pool(pool).tickSpacing();
        require(tickLower % tickspacing == 0, "TLV");
        require(tickUpper % tickspacing == 0, "TUV");

        // 2、添加流动池
        bool hasPool = false;
        uint poolIndex;
        for(uint i = 0; i < pools.length; i++){
            // 存在相同的流动池
            if(pools[i] == pool) {
                hasPool = true;
                poolIndex = i;
                for(uint positionIndex = 0; positionIndex < positions[i].length; positionIndex++) {
                    // 存在相同的头寸, 退出
                    if(positions[i][positionIndex].tickLower == tickLower && positions[i][positionIndex].tickUpper == tickUpper)
                        revert();
                }
                break;
            }
        }
        if(!hasPool) {
            pools.push(pool);
            positions.push();
            poolIndex = pools.length - 1;
        }

        //3、新增头寸
        positions[poolIndex].push(Position.Info({
            isEmpty: true,
            tickLower: tickLower,
            tickUpper: tickUpper
        }));

        //4、投资
        if(amount > 0){
            address fToken = token;
            require(IERC20(fToken).balanceOf(address(this)) >= amount, "ATL");
            Position.Info storage position = positions[poolIndex][positions[poolIndex].length - 1];
            position.addLiquidity(Position.AddParams({
                poolIndex: poolIndex,
                pool: pool,
                amount: amount,
                amount0Max: 0,
                amount1Max: 0,
                token: fToken,
                uniV3Router: uniV3Router,
                uniV3Factory: uniV3Factory
            }), sellPath, buyPath);
        }
    }

    /// @inheritdoc IHotPotV2FundManagerActions
    function add(
        uint poolIndex,
        uint positionIndex,
        uint amount,
        bool collect
    ) external override onlyController {
        require(IERC20(token).balanceOf(address(this)) >= amount, "ATL");
        require(poolIndex < pools.length, "IPL");
        require(positionIndex < positions[poolIndex].length, "IPS");

        uint amount0Max;
        uint amount1Max;
        Position.Info storage position = positions[poolIndex][positionIndex];
        address pool = pools[poolIndex];
        // 需要复投?
        if(collect) (amount0Max, amount1Max) = position.burnAndCollect(pool, 0);

        position.addLiquidity(Position.AddParams({
            poolIndex: poolIndex,
            pool: pool,
            amount: amount,
            amount0Max: amount0Max,
            amount1Max: amount1Max,
            token: token,
            uniV3Router: uniV3Router,
            uniV3Factory: uniV3Factory
        }), sellPath, buyPath);
    }

    /// @inheritdoc IHotPotV2FundManagerActions
    function sub(
        uint poolIndex,
        uint positionIndex,
        uint proportionX128
    ) external override onlyController{
        require(poolIndex < pools.length, "IPL");
        require(positionIndex < positions[poolIndex].length, "IPS");

        positions[poolIndex][positionIndex].subLiquidity(Position.SubParams({
            proportionX128: proportionX128,
            pool: pools[poolIndex],
            token: token,
            uniV3Router: uniV3Router
        }), sellPath);
    }

    /// @inheritdoc IHotPotV2FundManagerActions
    function move(
        uint poolIndex,
        uint subIndex,
        uint addIndex,
        uint proportionX128
    ) external override onlyController {
        require(poolIndex < pools.length, "IPL");
        require(subIndex < positions[poolIndex].length, "ISI");
        require(addIndex < positions[poolIndex].length, "IAI");

        // 移除
        (uint amount0Max, uint amount1Max) = positions[poolIndex][subIndex]
            .burnAndCollect(pools[poolIndex], proportionX128);

        // 添加
        positions[poolIndex][addIndex].addLiquidity(Position.AddParams({
            poolIndex: poolIndex,
            pool: pools[poolIndex],
            amount: 0,
            amount0Max: amount0Max,
            amount1Max: amount1Max,
            token: token,
            uniV3Router: uniV3Router,
            uniV3Factory: uniV3Factory
        }), sellPath, buyPath);
    }

    /// @inheritdoc IHotPotV2FundState
    function assetsOfPosition(uint poolIndex, uint positionIndex) public override view returns (uint amount) {
        return positions[poolIndex][positionIndex].assets(pools[poolIndex], token, sellPath, uniV3Factory);
    }

    /// @inheritdoc IHotPotV2FundState
    function assetsOfPool(uint poolIndex) public view override returns (uint amount) {
        (amount, ) = _assetsOfPool(poolIndex);
    }

    /// @inheritdoc IHotPotV2FundState
    function totalAssets() public view override returns (uint amount) {
        amount = IERC20(token).balanceOf(address(this));
        for(uint i = 0; i < pools.length; i++){
            uint _amount;
            (_amount, ) = _assetsOfPool(i);
            amount = amount.add(_amount);
        }
    }

    function _assetsOfPool(uint poolIndex) internal view returns (uint amount, uint[] memory) {
        return positions[poolIndex].assetsOfPool(pools[poolIndex], token, sellPath, uniV3Factory);
    }
}

// File: contracts/HotPotV2FundDeployer.sol
contract HotPotV2FundDeployer is IHotPotV2FundDeployer {
    struct Parameters {
        address WETH9;
        address uniswapV3Factory;
        address uniswapV3Router;
        address controller;
        address manager;
        address token;
        bytes32 descriptor;
    }

    /// @inheritdoc IHotPotV2FundDeployer
    Parameters public override parameters;

    /// @dev Deploys a fund with the given parameters by transiently setting the parameters storage slot and then
    /// clearing it after deploying the fund.
    /// @param controller The controller address
    /// @param manager The manager address of this fund
    /// @param token The local token address
    /// @param descriptor 32 bytes string descriptor, 8 bytes manager name + 24 bytes brief description
    function deploy(
        address WETH9,
        address uniswapV3Factory,
        address uniswapV3Router,
        address controller,
        address manager,
        address token,
        bytes32 descriptor
    ) internal returns (address fund) {
        parameters = Parameters({
            WETH9: WETH9,
            uniswapV3Factory: uniswapV3Factory,
            uniswapV3Router: uniswapV3Router,
            controller: controller,
            manager: manager,
            token: token, 
            descriptor: descriptor
        });

        fund = address(new HotPotV2Fund{salt: keccak256(abi.encode(manager, token))}());
        delete parameters;
    }
}

// File: contracts/HotPotV2FundFactory.sol
// SPDX-License-Identifier: GPL-2.0-or-later

/// @title The interface for the HotPotFunds V2 Factory
/// @notice The HotPotV2Funds Factory facilitates creation of HotPot V2 fund
contract HotPotV2FundFactory is IHotPotV2FundFactory, HotPotV2FundDeployer {
    /// @inheritdoc IHotPotV2FundFactory
    address public override immutable WETH9;
    /// @inheritdoc IHotPotV2FundFactory
    address public override immutable uniV3Factory;
    /// @inheritdoc IHotPotV2FundFactory
    address public override immutable uniV3Router;
    /// @inheritdoc IHotPotV2FundFactory
    address public override immutable controller;
    /// @inheritdoc IHotPotV2FundFactory
    mapping(address => mapping(address => address)) public override getFund;

    constructor(
        address _controller, 
        address _weth9,
        address _uniV3Factory, 
        address _uniV3Router
    ){
        require(_controller != address(0));
        require(_weth9 != address(0));
        require(_uniV3Factory != address(0));
        require(_uniV3Router != address(0));

        controller = _controller;
        WETH9 = _weth9;
        uniV3Factory = _uniV3Factory;
        uniV3Router = _uniV3Router;
    }
    
    /// @inheritdoc IHotPotV2FundFactory
    function createFund(address token, bytes32 descriptor) external override returns (address fund){
        require(IHotPotV2FundController(controller).verifiedToken(token));
        require(getFund[msg.sender][token] == address(0));

        fund = deploy(WETH9, uniV3Factory, uniV3Router, controller, msg.sender, token, descriptor);
        getFund[msg.sender][token] = fund;

        emit FundCreated(msg.sender, token, fund);
    }
}