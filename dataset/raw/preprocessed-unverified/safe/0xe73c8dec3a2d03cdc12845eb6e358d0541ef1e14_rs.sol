/**
 *Submitted for verification at Etherscan.io on 2021-07-12
*/

pragma solidity =0.7.6;
pragma abicoder v2;

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @uniswap/v3-periphery/contracts/libraries/TransferHelper.sol


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


// File: contracts/interfaces/fund/IHotPotV2FundManagerActions.sol
/// @notice 基金经理操作接口定义


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

// File: contracts/interfaces/IHotPot.sol
/// @title HPT (Hotpot Funds) 代币接口定义.
interface IHotPot is IERC20{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function burn(uint value) external returns (bool) ;
    function burnFrom(address from, uint value) external returns (bool);
}

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

// File: contracts/interfaces/IMulticall.sol
/// @title Multicall
/// @notice Enables calling multiple methods in a single call to the contract


// File: contracts/base/Multicall.sol
/// @title Multicall
/// @notice Enables calling multiple methods in a single call to the contract
abstract contract Multicall is IMulticall {
    /// @inheritdoc IMulticall
    function multicall(bytes[] calldata data) external payable override returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }
}

// File: contracts/HotPotV2FundController.sol
// SPDX-License-Identifier: BUSL-1.1

contract HotPotV2FundController is IHotPotV2FundController, Multicall {
    using Path for bytes;

    address public override immutable uniV3Factory;
    address public override immutable uniV3Router;
    address public override immutable hotpot;
    address public override governance;
    address public override immutable WETH9;

    mapping (address => bool) public override verifiedToken;
    mapping (address => bytes) public override harvestPath;

    modifier onlyManager(address fund){
        require(msg.sender == IHotPotV2Fund(fund).manager(), "OMC");
        _;
    }

    modifier onlyGovernance{
        require(msg.sender == governance, "OGC");
        _;
    }

    constructor(
        address _hotpot,
        address _governance,
        address _uniV3Router,
        address _uniV3Factory,
        address _weth9
    ) {
        hotpot = _hotpot;
        governance = _governance;
        uniV3Router = _uniV3Router;
        uniV3Factory = _uniV3Factory;
        WETH9 = _weth9;
    }

    /// @inheritdoc IGovernanceActions
    function setHarvestPath(address token, bytes memory path) external override onlyGovernance {
        bytes memory _path = path;
        (address tokenIn, address tokenOut, uint24 fee) = path.decodeFirstPool();
        while (true) {
            // pool is exist
            require(IUniswapV3Factory(uniV3Factory).getPool(tokenIn, tokenOut, fee) != address(0), "PIE");
            if (path.hasMultiplePools()) {
                path = path.skipToken();
                (tokenIn, tokenOut, fee) = path.decodeFirstPool();
            } else {
                //最后一个交易对：输入WETH9, 输出hotpot
                require(tokenIn == WETH9 && tokenOut == hotpot, "IOT");
                break;
            }
        }
        harvestPath[token] = _path;
        emit SetHarvestPath(token, _path);
    }

    /// @inheritdoc IHotPotV2FundController
    function harvest(address token, uint amount) external override returns(uint burned) {
        uint value = amount <= IERC20(token).balanceOf(address(this)) ? amount : IERC20(token).balanceOf(address(this));
        TransferHelper.safeApprove(token, uniV3Router, value);

        ISwapRouter.ExactInputParams memory args = ISwapRouter.ExactInputParams({
            path: harvestPath[token],
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: value,
            amountOutMinimum: 0
        });
        burned = ISwapRouter(uniV3Router).exactInput(args);
        IHotPot(hotpot).burn(burned);
        emit Harvest(token, amount, burned);
    }

    /// @inheritdoc IGovernanceActions
    function setGovernance(address account) external override onlyGovernance {
        require(account != address(0));
        governance = account;
        emit SetGovernance(account);
    }

    /// @inheritdoc IGovernanceActions
    function setVerifiedToken(address token, bool isVerified) external override onlyGovernance {
        verifiedToken[token] = isVerified;
        emit ChangeVerifiedToken(token, isVerified);
    }

    /// @inheritdoc IManagerActions
    function setPath(
        address fund,
        address distToken,
        bytes memory path
    ) external override onlyManager(fund){
        require(verifiedToken[distToken]);

        address fundToken = IHotPotV2Fund(fund).token();
        bytes memory _path = path;
        bytes memory _reverse;
        (address tokenIn, address tokenOut, uint24 fee) = path.decodeFirstPool();
        _reverse = abi.encodePacked(tokenOut, fee, tokenIn);
        bool isBuy;
        // 第一个tokenIn是基金token，那么就是buy路径
        if(tokenIn == fundToken){
            isBuy = true;
        } 
        // 如果是sellPath, 第一个需要是目标代币
        else{
            require(tokenIn == distToken);
        }

        while (true) {
            require(verifiedToken[tokenIn], "VIT");
            require(verifiedToken[tokenOut], "VOT");
            // pool is exist
            address pool = IUniswapV3Factory(uniV3Factory).getPool(tokenIn, tokenOut, fee);
            require(pool != address(0), "PIE");
            // at least 2 observations
            (,,,uint16 observationCardinality,,,) = IUniswapV3Pool(pool).slot0();
            require(observationCardinality >= 2, "OC");

            if (path.hasMultiplePools()) {
                path = path.skipToken();
                (tokenIn, tokenOut, fee) = path.decodeFirstPool();
                _reverse = abi.encodePacked(tokenOut, fee, _reverse);
            } else {
                /// @dev 如果是buy, 最后一个token要是目标代币;
                /// @dev 如果是sell, 最后一个token要是基金token.
                if(isBuy)
                    require(tokenOut == distToken, "OID");
                else
                    require(tokenOut == fundToken, "OIF");
                break;
            }
        }
        emit SetPath(fund, distToken, _path);
        if(!isBuy) (_path, _reverse) = (_reverse, _path);
        IHotPotV2Fund(fund).setPath(distToken, _path, _reverse);
    }

    /// @inheritdoc IManagerActions
    function init(
        address fund,
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint amount
    ) external override onlyManager(fund){
        IHotPotV2Fund(fund).init(token0, token1, fee, tickLower, tickUpper, amount);
    }

    /// @inheritdoc IManagerActions
    function add(
        address fund,
        uint poolIndex,
        uint positionIndex,
        uint amount,
        bool collect
    ) external override onlyManager(fund){
        IHotPotV2Fund(fund).add(poolIndex, positionIndex, amount, collect);
    }

    /// @inheritdoc IManagerActions
    function sub(
        address fund,
        uint poolIndex,
        uint positionIndex,
        uint proportionX128
    ) external override onlyManager(fund){
        IHotPotV2Fund(fund).sub(poolIndex, positionIndex, proportionX128);
    }

    /// @inheritdoc IManagerActions
    function move(
        address fund,
        uint poolIndex,
        uint subIndex,
        uint addIndex,
        uint proportionX128
    ) external override onlyManager(fund){
        IHotPotV2Fund(fund).move(poolIndex, subIndex, addIndex, proportionX128);
    }
}