/**
 *Submitted for verification at Etherscan.io on 2020-10-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;


// File: @openzeppelin/contracts/math/SafeMath.sol



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


// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol




// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol



interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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

// File: contracts/core/mixins/Initializable.sol

// solhint-disable-next-line max-line-length
// https://github.com/OpenZeppelin/openzeppelin-sdk/blob/master/packages/lib/contracts/Initializable.sol


contract Initializable {
    bool public initialized;

    bool private initializing;

    modifier initializer() {
        require(initializing || !initialized, "already-initialized");

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }
}

// File: contracts/core/interfaces/IPriceFeed.sol





// File: contracts/core/interfaces/IMakerPriceFeed.sol





// File: contracts/core/libraries/UniswapV2Library.sol




// solhint-disable-next-line max-line-length
// UniswapV2Library https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol


// File: contracts/core/PriceFeed.sol









contract PriceFeed is Initializable, IPriceFeed {
    using SafeMath for uint256;

    address internal _uniswapFactory;
    address internal _weth;
    address internal _makerPriceFeed;

    function initialize(address makerPriceFeed, address uniswapRouter) public initializer {
        _makerPriceFeed = makerPriceFeed;

        IUniswapV2Router02 router = IUniswapV2Router02(uniswapRouter);
        _uniswapFactory = router.factory();
        _weth = router.WETH();
    }

    function ethPriceInUSD(uint256 amount) public override view returns (uint256) {
        uint256 price = uint256(IMakerPriceFeed(_makerPriceFeed).read());
        return price.mul(amount).div(10**18);
    }

    function erc20PriceInETH(address token, uint256 amount) public override view returns (uint256) {
        (uint256 reserve0, uint256 reserve1) = UniswapV2Library.getReserves(
            _uniswapFactory,
            token,
            _weth
        );
        if (reserve0 > 0 && reserve1 > 0) {
            return UniswapV2Library.quote(amount, reserve0, reserve1);
        }
        return 0;
    }

    function erc20PriceInUSD(address token, uint256 amount) public override view returns (uint256) {
        uint256 ethPrice = ethPriceInUSD(10**18);
        uint256 erc20Price = erc20PriceInETH(token, amount);
        return erc20Price == 0 ? 0 : ethPrice.mul(erc20Price).div(10**18);
    }
}