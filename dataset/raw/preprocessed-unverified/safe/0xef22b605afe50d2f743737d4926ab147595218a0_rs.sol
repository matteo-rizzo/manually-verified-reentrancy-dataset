/**
 *Submitted for verification at Etherscan.io on 2021-10-04
*/

pragma solidity 0.6.12;


// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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


// File: @openzeppelin/contracts/utils/Address.sol



/**
 * @dev Collection of functions related to the address type
 */


// File: @openzeppelin/contracts/token/ERC20/SafeERC20.sol






/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// File: contracts/kwikswapv2/interfaces/IKwikswapV2Pair.sol




// File: contracts/kwikswapv2/interfaces/IKwikswapV2Router01.sol




// File: contracts/kwikswapv2/interfaces/IKwikswapV2Factory.sol




// File: contracts/kwikswapv2/libraries/SafeMath.sol


// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)



// File: contracts/kwikswapv2/libraries/KwikswapV2Library.sol






// File: contracts/KwikRoll.sol








// KwikRoll helps your migrate your existing Kwikswap LP tokens to KwikSwap LP ones
contract KwikRoll {
    using SafeERC20 for IERC20;

    IKwikswapV2Router01 public oldRouter;
    IKwikswapV2Router01 public router;

    constructor(IKwikswapV2Router01 _oldRouter, IKwikswapV2Router01 _router) public {
        oldRouter = _oldRouter;
        router = _router;
    }

    function migrateWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        IKwikswapV2Pair pair = IKwikswapV2Pair(pairForOldRouter(tokenA, tokenB));
        pair.permit(msg.sender, address(this), liquidity, deadline, v, r, s);

        migrate(tokenA, tokenB, liquidity, amountAMin, amountBMin, deadline);
    }

    // msg.sender should have approved 'liquidity' amount of LP token of 'tokenA' and 'tokenB'
    function migrate(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    ) public {
        require(deadline >= block.timestamp, 'KwikSwap: EXPIRED');

        // Remove liquidity from the old router with permit
        (uint256 amountA, uint256 amountB) = removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            deadline
        );

        // Add liquidity to the new router
        (uint256 pooledAmountA, uint256 pooledAmountB) = addLiquidity(tokenA, tokenB, amountA, amountB);

        // Send remaining tokens to msg.sender
        if (amountA > pooledAmountA) {
            IERC20(tokenA).safeTransfer(msg.sender, amountA - pooledAmountA);
        }
        if (amountB > pooledAmountB) {
            IERC20(tokenB).safeTransfer(msg.sender, amountB - pooledAmountB);
        }
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    ) internal returns (uint256 amountA, uint256 amountB) {
        IKwikswapV2Pair pair = IKwikswapV2Pair(pairForOldRouter(tokenA, tokenB));
        pair.transferFrom(msg.sender, address(pair), liquidity);
        (uint256 amount0, uint256 amount1) = pair.burn(address(this));
        (address token0,) = KwikswapV2Library.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'KwikRoll: INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'KwikRoll: INSUFFICIENT_B_AMOUNT');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairForOldRouter(address tokenA, address tokenB) internal view returns (address pair) {
        (address token0, address token1) = KwikswapV2Library.sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                oldRouter.factory(),
                keccak256(abi.encodePacked(token0, token1)),
                hex'bc919ae6f6f95dca1e223fc957286afa1da81529418e9f187db8a0b2d2e963bc' // init code hash
            ))));
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired
    ) internal returns (uint amountA, uint amountB) {
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired);
        address pair = KwikswapV2Library.pairFor(router.factory(), tokenA, tokenB);
        IERC20(tokenA).safeTransfer(pair, amountA);
        IERC20(tokenB).safeTransfer(pair, amountB);
        IKwikswapV2Pair(pair).mint(msg.sender);
    }

    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired
    ) internal returns (uint256 amountA, uint256 amountB) {
        // create the pair if it doesn't exist yet
        IKwikswapV2Factory factory = IKwikswapV2Factory(router.factory());
        if (factory.getPair(tokenA, tokenB) == address(0)) {
            factory.createPair(tokenA, tokenB);
        }
        (uint256 reserveA, uint256 reserveB) = KwikswapV2Library.getReserves(address(factory), tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = KwikswapV2Library.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = KwikswapV2Library.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }
}