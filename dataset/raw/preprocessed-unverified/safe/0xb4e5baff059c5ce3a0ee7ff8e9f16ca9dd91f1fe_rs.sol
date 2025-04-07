/**
 *Submitted for verification at Etherscan.io on 2021-09-08
*/

pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;

contract YamGoverned {
    event NewGov(address oldGov, address newGov);
    event NewPendingGov(address oldPendingGov, address newPendingGov);

    address public gov;
    address public pendingGov;

    modifier onlyGov {
        require(msg.sender == gov, "!gov");
        _;
    }

    function _setPendingGov(address who)
        public
        onlyGov
    {
        address old = pendingGov;
        pendingGov = who;
        emit NewPendingGov(old, who);
    }

    function _acceptGov()
        public
    {
        require(msg.sender == pendingGov, "!pendingGov");
        address oldgov = gov;
        gov = pendingGov;
        pendingGov = address(0);
        emit NewGov(oldgov, gov);
    }
}

contract YamSubGoverned is YamGoverned {
    /**
     * @notice Event emitted when a sub gov is enabled/disabled
     */
    event SubGovModified(
        address account,
        bool isSubGov
    );
    /// @notice sub governors
    mapping(address => bool) public isSubGov;

    modifier onlyGovOrSubGov() {
        require(msg.sender == gov || isSubGov[msg.sender]);
        _;
    }

    function setIsSubGov(address subGov, bool _isSubGov)
        public
        onlyGov
    {
        isSubGov[subGov] = _isSubGov;
        emit SubGovModified(subGov, _isSubGov);
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method


// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))


// library with helper methods for oracles that are concerned with computing average prices






contract TWAPBoundLib {
    using SafeMath for uint256;

    uint256 public constant BASE = 10**18;

    function getCurrentDestinationAmount(
        IUniswapV2Pair pool1,
        IUniswapV2Pair pool2,
        address sourceToken,
        address destinationToken,
        uint256 sourceAmount
    ) internal view returns (uint256) {
        bool sourceIsToken0 = pool1.token0() == sourceToken;
        uint256 inReserves;
        uint256 outReserves;
        (inReserves, outReserves, ) = pool1.getReserves();
        uint256 destinationAmount = UniswapV2Library.getAmountOut(
            sourceAmount,
            sourceIsToken0 ? inReserves : outReserves,
            sourceIsToken0 ? outReserves : inReserves
        );
        if (address(pool2) != address(0x0)) {
            bool middleIsToken0 = pool2.token1() == destinationToken;
            (inReserves, outReserves, ) = pool2.getReserves();
            destinationAmount = UniswapV2Library.getAmountOut(
                destinationAmount,
                middleIsToken0 ? inReserves : outReserves,
                middleIsToken0 ? outReserves : inReserves
            );
        }
        return destinationAmount;
    }

    event TestTWAPDestinationAmount(
        uint256 twap,
        uint256 minimum,
        uint256 obtained
    );

    function withinBounds(
        IUniswapV2Pair pool1,
        IUniswapV2Pair pool2,
        address sourceToken,
        address destinationToken,
        uint256 sourceAmount,
        uint256 destinationAmount,
        uint256 lastCumulativePricePool1,
        uint256 lastCumulativePricePool2,
        uint256 timeSinceLastCumulativePriceUpdate,
        uint64 slippageLimit
    ) internal returns (bool) {
        uint256 twapDestinationAmount = getTWAPDestinationAmount(
            pool1,
            pool2,
            sourceToken,
            destinationToken,
            sourceAmount,
            lastCumulativePricePool1,
            lastCumulativePricePool2,
            timeSinceLastCumulativePriceUpdate
        );
        uint256 minimum = twapDestinationAmount.mul(BASE.sub(slippageLimit)).div(
            BASE
        );
        emit TestTWAPDestinationAmount(
            twapDestinationAmount,
            minimum,
            destinationAmount
        );
        return destinationAmount >= minimum;
    }

    // Returns the current cumulative prices for pool1 and pool2. cumulativePricePool2 will be 0 if there is no pool 2
    function getCumulativePrices(
        IUniswapV2Pair pool1,
        IUniswapV2Pair pool2,
        address sourceToken,
        address destinationToken
    )
        internal
        view
        returns (uint256 cumulativePricePool1, uint256 cumulativePricePool2)
    {
        (cumulativePricePool1, ) = UniswapV2OracleLibrary
            .currentCumulativePrices(
                address(pool1),
                pool1.token0() == sourceToken
            );

        if (address(pool2) != address(0x0)) {
            // For when 2 pools are used
            (cumulativePricePool2, ) = UniswapV2OracleLibrary
                .currentCumulativePrices(
                    address(pool2),
                    pool2.token1() == destinationToken
                );
        }
    }

    // Returns the current TWAP
    function getTWAPDestinationAmount(
        IUniswapV2Pair pool1,
        IUniswapV2Pair pool2,
        address sourceToken,
        address destinationToken,
        uint256 sourceAmount,
        uint256 lastCumulativePricePool1,
        uint256 lastCumulativePricePool2,
        uint256 timeSinceLastCumulativePriceUpdate
    ) internal view returns (uint256 price) {
        uint256 cumulativePricePool1;
        uint256 cumulativePricePool2;
        (cumulativePricePool1, cumulativePricePool2) = getCumulativePrices(
            pool1,
            pool2,
            sourceToken,
            destinationToken
        );
        uint256 priceAverageHop1 = uint256(
            uint224(
                (cumulativePricePool1 - lastCumulativePricePool1) /
                    timeSinceLastCumulativePriceUpdate
            )
        );

        if (priceAverageHop1 > uint192(-1)) {
            // eat loss of precision
            // effectively: (x / 2**112) * 1e18
            priceAverageHop1 = (priceAverageHop1 >> 112) * BASE;
        } else {
            // cant overflow
            // effectively: (x * 1e18 / 2**112)
            priceAverageHop1 = (priceAverageHop1 * BASE) >> 112;
        }

        uint256 outputAmount = sourceAmount.mul(priceAverageHop1).div(BASE);

        if (address(pool2) != address(0)) {
            uint256 priceAverageHop2 = uint256(
                uint224(
                    (cumulativePricePool2 - lastCumulativePricePool2) /
                        timeSinceLastCumulativePriceUpdate
                )
            );

            if (priceAverageHop2 > uint192(-1)) {
                // eat loss of precision
                // effectively: (x / 2**112) * 1e18
                priceAverageHop2 = (priceAverageHop2 >> 112) * BASE;
            } else {
                // cant overflow
                // effectively: (x * 1e18 / 2**112)
                priceAverageHop2 = (priceAverageHop2 * BASE) >> 112;
            }

            outputAmount = outputAmount.mul(priceAverageHop2).div(BASE);
        }
        return outputAmount;
    }
}


// Swapper allows the governor to create swaps
// A swap executes trustlessly and minimizes slippage to a set amount by using TWAPs
// Swaps can be broken up, TWAPs repeatedly updated, etc. 
// Anyone can update TWAPs or execute a swap
contract Swapper is YamSubGoverned, TWAPBoundLib {
    /** Structs */
    struct SwapParams {
        address sourceToken;
        address destinationToken;
        address router;
        address pool1;
        address pool2;
        uint128 sourceAmount;
        uint64 slippageLimit;
    }

    struct SwapState {
        SwapParams params;
        uint256 lastCumulativePriceUpdate;
        uint256 lastCumulativePricePool1;
        uint256 lastCumulativePricePool2;
    }

    /** Constants */
    uint64 private constant MIN_TWAP_TIME = 1 hours;
    uint64 private constant MAX_TWAP_TIME = 3 hours;

    /** State */
    SwapState[] public swaps;

    address public reserves;

    constructor(address _gov, address _reserves) public {
        gov = _gov;
        reserves = _reserves;
    }

    /** Gov functions */
    function addSwap(SwapParams calldata params) external onlyGovOrSubGov {
        swaps.push(
            SwapState({
                params: params,
                lastCumulativePriceUpdate: 0,
                lastCumulativePricePool1: 0,
                lastCumulativePricePool2: 0
            })
        );
    }
 
    function setReserves(address _reserves) external onlyGovOrSubGov {
        reserves = _reserves;
    }
    function removeSwap(uint16 index) external onlyGovOrSubGov {
        _removeSwap(index);
    }

    /** Execution functions */

    function execute(
        uint16 swapId,
        uint128 amountToTrade,
        uint256 minDestinationAmount
    ) external {
        SwapState memory swap = swaps[swapId];
        // Check if there is any left to trade
        require(swap.params.sourceAmount > 0);
        // Can't be trying to trade more than the remaining amount
        require(amountToTrade <= swap.params.sourceAmount);
        uint256 timestamp = block.timestamp;
        uint256 timeSinceLastCumulativePriceUpdate = timestamp -
            swap.lastCumulativePriceUpdate;
        // Require that the cumulative prices were last updated between MIN_TWAP_TIME and MAX_TWAP_TIME
        require(
            timeSinceLastCumulativePriceUpdate >= MIN_TWAP_TIME &&
                timeSinceLastCumulativePriceUpdate <= MAX_TWAP_TIME
        );
        IERC20(swap.params.sourceToken).transferFrom(
            reserves,
            address(this),
            amountToTrade
        );
        if (
            IERC20(swap.params.sourceToken).allowance(
                address(this),
                swap.params.router
            ) < amountToTrade
        ) {
            IERC20(swap.params.sourceToken).approve(
                swap.params.router,
                uint256(-1)
            );
        }
        address[] memory path;
        if (swap.params.pool2 == address(0x0)) {
            path = new address[](2);
            path[0] = swap.params.sourceToken;
            path[1] = swap.params.destinationToken;
        } else {
            address token0 = IUniswapV2Pair(swap.params.pool1).token0();
            path = new address[](3);
            path[0] = swap.params.sourceToken;
            path[1] = token0 == swap.params.sourceToken
                ? IUniswapV2Pair(swap.params.pool1).token1()
                : token0;
            path[2] = swap.params.destinationToken;
        }
        uint256[] memory amounts = UniRouter2(swap.params.router)
            .swapExactTokensForTokens(
                uint256(amountToTrade),
                minDestinationAmount,
                path,
                reserves,
                timestamp
            );

        require(
            TWAPBoundLib.withinBounds(
                IUniswapV2Pair(swap.params.pool1),
                IUniswapV2Pair(swap.params.pool2),
                swap.params.sourceToken,
                swap.params.destinationToken,
                uint256(amountToTrade),
                amounts[amounts.length - 1],
                swap.lastCumulativePricePool1,
                swap.lastCumulativePricePool2,
                timeSinceLastCumulativePriceUpdate,
                swap.params.slippageLimit
            )
        );
        if(amountToTrade == swap.params.sourceAmount){
            _removeSwap(swapId);
        } else {
            swaps[swapId].params.sourceAmount -= amountToTrade;
        }
    }

    function updateCumulativePrice(uint16 swapId) external {
        SwapState memory swap = swaps[swapId];
        uint256 timestamp = block.timestamp;
        require(timestamp - swap.lastCumulativePriceUpdate > MAX_TWAP_TIME);
        (
            swaps[swapId].lastCumulativePricePool1,
            swaps[swapId].lastCumulativePricePool2
        ) = TWAPBoundLib.getCumulativePrices(
            IUniswapV2Pair(swap.params.pool1),
            IUniswapV2Pair(swap.params.pool2),
            swap.params.sourceToken,
            swap.params.destinationToken
        );
        swaps[swapId].lastCumulativePriceUpdate = timestamp;
    }

    /** Internal functions */

    function _removeSwap(uint16 index) internal {
        swaps[index] = SwapState({
            params: SwapParams(
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000,
                0,
                0
            ),
            lastCumulativePriceUpdate: 0,
            lastCumulativePricePool1: 0,
            lastCumulativePricePool2: 0
        });
    }
}