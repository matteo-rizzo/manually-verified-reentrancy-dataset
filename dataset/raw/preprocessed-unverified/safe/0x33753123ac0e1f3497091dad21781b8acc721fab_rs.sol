/**
 *Submitted for verification at Etherscan.io on 2021-04-05
*/

// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



// Part: IUniswapV2Router01



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// Part: OpenZeppelin/[email protected]/SafeMath

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


// Part: IUniswapV2Router02

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

// Part: OpenZeppelin/[email protected]/SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: AlphaDistributor.sol

contract AlphaDistributor {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public governance = 0x16388463d60FFE0661Cf7F1f31a7D658aC790ff7;
    address public strategist = 0xC3D6880fD95E06C816cB030fAc45b3ffe3651Cb0;

    address public uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public sushiswapRouter = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    address public router = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;

    address public daiStrat = 0x7D960F3313f3cB1BBB6BF67419d303597F3E2Fa8;
    address public usdcStrat = 0x86Aa49bf28d03B1A4aBEb83872cFC13c89eB4beD;

    address[] public usdcPath;
    address[] public daiPath;

    address public alpha = 0xa1faa113cbE53436Df28FF0aEe54275c13B40975;
    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    constructor() public{
        usdcPath = new address[](3);
        usdcPath[0] = alpha;
        usdcPath[1] = weth;
        usdcPath[2] = usdc;

        daiPath = new address[](3);
        daiPath[0] = alpha;
        daiPath[1] = weth;
        daiPath[2] = dai;

        IERC20(alpha).safeApprove(uniswapRouter, type(uint256).max);
        IERC20(alpha).safeApprove(sushiswapRouter, type(uint256).max);
    }
    modifier onlyAuthorized() {
        require(msg.sender == strategist || msg.sender == governance, "!authorized");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance, "!authorized");
        _;
    }


    function setUseSushi(bool _useSushi) public onlyAuthorized {
        if(_useSushi){
            router = sushiswapRouter;
        }else{
            router = uniswapRouter;
        }
    }

    function setUseSushi(bool _usdc,  address[] memory path) public onlyGovernance {
       if(_usdc){
           usdcPath = path;
       }else{
           daiPath = path;
       }
    }
    function setStrat(bool _usdc,  address _strat) public onlyGovernance {
       if(_usdc){
           usdcStrat = _strat;
       }else{
           daiStrat = _strat;
       }
    }

    function sellUsdc(uint256 amount) public onlyAuthorized{
        IUniswapV2Router02(router).swapExactTokensForTokens(amount, 0, usdcPath, usdcStrat, now);
    }

    function sellDai(uint256 amount) public onlyAuthorized{
        IUniswapV2Router02(router).swapExactTokensForTokens(amount, 0, daiPath, daiStrat, now);
    }

}