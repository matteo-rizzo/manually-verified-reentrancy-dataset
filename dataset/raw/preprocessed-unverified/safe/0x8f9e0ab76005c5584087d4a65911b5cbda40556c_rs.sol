/**
 *Submitted for verification at Etherscan.io on 2021-05-12
*/

pragma solidity ^0.6.8;


// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint wad) external;
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








/// @notice Plasmaswap Handler used to execute an order
contract PlasmaswapHandler is IHandler {
    using SafeMath for uint256;

    IWETH public immutable WETH;
    address public immutable FACTORY;
    bytes32 public immutable FACTORY_CODE_HASH;

    /**
     * @notice Creates the handler
     * @param _factory - Address of the plasmaswap factory contract
     * @param _weth - Address of WETH contract
     * @param _codeHash - Bytes32 of the plasmaswap pair contract unit code hash
     */
    constructor(address _factory, IWETH _weth, bytes32 _codeHash) public {
        FACTORY = _factory;
        WETH = _weth;
        FACTORY_CODE_HASH = _codeHash;
    }

    /// @notice receive ETH
    receive() external override payable {
        require(msg.sender != tx.origin, "PlasmaswapHandler#receive: NO_SEND_ETH_PLEASE");
    }

    /**
     * @notice Handle an order execution
     * @param _inputToken - Address of the input token
     * @param _outputToken - Address of the output token
     * @param _data - Bytes of arbitrary data
     * @return bought - Amount of output token bought
     */
    function handle(
        IERC20 _inputToken,
        IERC20 _outputToken,
        uint256,
        uint256,
        bytes calldata _data
    ) external payable override returns (uint256 bought) {
         // Load real initial balance, don't trust provided value
        uint256 amount = HyperUtils.balanceOf(_inputToken, address(this));
        address inputToken = address(_inputToken);
        address outputToken = address(_outputToken);
        address weth = address(WETH);

        // Decode extra data
        (,address relayer, uint256 fee) = abi.decode(_data, (address, address, uint256));

        if (inputToken == weth || inputToken == HyperUtils.ETH_ADDRESS) {
            // Swap WETH -> outputToken
            amount = amount.sub(fee);

            // Convert from ETH to WETH if necessary
            if (inputToken == HyperUtils.ETH_ADDRESS) {
                WETH.deposit{ value: amount }();
                inputToken = weth;
            } else {
                WETH.withdraw(fee);
            }

            // Trade
            bought = _swap(inputToken, outputToken, amount, msg.sender);
        } else if (outputToken == weth || outputToken == HyperUtils.ETH_ADDRESS) {
            // Swap inputToken -> WETH
            bought = _swap(inputToken, weth, amount, address(this));

            // Convert from WETH to ETH if necessary
            if (outputToken == HyperUtils.ETH_ADDRESS) {
                WETH.withdraw(bought);
            } else {
                WETH.withdraw(fee);
            }

            // Transfer amount to sender
            bought = bought.sub(fee);
            HyperUtils.transfer(IERC20(outputToken), msg.sender, bought);
        } else {
            // Swap inputToken -> WETH -> outputToken
            //  - inputToken -> WETH
            bought = _swap(inputToken, weth, amount, address(this));

            // Withdraw fee
            WETH.withdraw(fee);

            // - WETH -> outputToken
            bought = _swap(weth, outputToken, bought.sub(fee), msg.sender);
        }

        // Send fee to relayer
        (bool successRelayer,) = relayer.call{value: fee}("");
        require(successRelayer, "PlasmaswapHandler#handle: TRANSFER_ETH_TO_RELAYER_FAILED");
    }

    /**
     * @notice Check whether can handle an order execution
     * @param _inputToken - Address of the input token
     * @param _outputToken - Address of the output token
     * @param _inputAmount - uint256 of the input token amount
     * @param _minReturn - uint256 of the min return amount of output token
     * @param _data - Bytes of arbitrary data
     * @return bool - Whether the execution can be handled or not
     */
    function canHandle(
        IERC20 _inputToken,
        IERC20 _outputToken,
        uint256 _inputAmount,
        uint256 _minReturn,
        bytes calldata _data
    ) external override view returns (bool) {
        address inputToken = address(_inputToken);
        address outputToken = address(_outputToken);
        address weth = address(WETH);

        // Decode extra data
        (,, uint256 fee) = abi.decode(_data, (address, address, uint256));

        if (inputToken == weth || inputToken == HyperUtils.ETH_ADDRESS) {
            if (_inputAmount <= fee) {
                 return false;
            }

            return _estimate(weth, outputToken, _inputAmount.sub(fee)) >= _minReturn;
        } else if (outputToken == weth || outputToken == HyperUtils.ETH_ADDRESS) {
            uint256 bought = _estimate(inputToken, weth, _inputAmount);

            if (bought <= fee) {
                 return false;
            }

            return bought.sub(fee) >= _minReturn;
        } else {
            uint256 bought = _estimate(inputToken, weth, _inputAmount);
            if (bought <= fee) {
                return false;
            }

            return _estimate(weth, outputToken, bought.sub(fee)) >= _minReturn;
        }
    }

    /**
     * @notice Simulate an order execution
     * @param _inputToken - Address of the input token
     * @param _outputToken - Address of the output token
     * @param _inputAmount - uint256 of the input token amount
     * @param _minReturn - uint256 of the min return amount of output token
     * @param _data - Bytes of arbitrary data
     * @return bool - Whether the execution can be handled or not
     * @return uint256 - Amount of output token bought
     */
    function simulate(
        IERC20 _inputToken,
        IERC20 _outputToken,
        uint256 _inputAmount,
        uint256 _minReturn,
        bytes calldata _data
    ) external view returns (bool, uint256) {
        address inputToken = address(_inputToken);
        address outputToken = address(_outputToken);
        address weth = address(WETH);

        // Decode extra data
        (,, uint256 fee) = abi.decode(_data, (address, address, uint256));

        uint256 bought;

        if (inputToken == weth || inputToken == HyperUtils.ETH_ADDRESS) {
            if (_inputAmount <= fee) {
                return (false, 0);
            }

            bought = _estimate(weth, outputToken, _inputAmount.sub(fee));
        } else if (outputToken == weth || outputToken == HyperUtils.ETH_ADDRESS) {
            bought = _estimate(inputToken, weth, _inputAmount);
            if (bought <= fee) {
                 return (false, 0);
            }

            bought = bought.sub(fee);
        } else {
            bought = _estimate(inputToken, weth, _inputAmount);
            if (bought <= fee) {
                return (false, 0);
            }

            bought = _estimate(weth, outputToken, bought.sub(fee));
        }
        return (bought >= _minReturn, bought);
    }

    /**
     * @notice Estimate output token amount
     * @param _inputToken - Address of the input token
     * @param _outputToken - Address of the output token
     * @param _inputAmount - uint256 of the input token amount
     * @return bought - Amount of output token bought
     */
    function _estimate(address _inputToken, address _outputToken, uint256 _inputAmount) internal view returns (uint256 bought) {
        // Get plasmaswap trading pair
        (address token0, address token1) = PlasmaswapUtils.sortTokens(_inputToken, _outputToken);
        IPlasmaswapPair pair = IPlasmaswapPair(PlasmaswapUtils.pairForSorted(FACTORY, token0, token1, FACTORY_CODE_HASH));

        // Compute limit for plasmaswap trade
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();

        // Optimal amounts for plasmaswap trade
        uint256 reserveIn; uint256 reserveOut;
        if (_inputToken == token0) {
            reserveIn = reserve0;
            reserveOut = reserve1;
        } else {
            reserveIn = reserve1;
            reserveOut = reserve0;
        }

        bought = PlasmaswapUtils.getAmountOut(_inputAmount, reserveIn, reserveOut);
    }

    /**
     * @notice Swap input token to output token
     * @param _inputToken - Address of the input token
     * @param _outputToken - Address of the output token
     * @param _inputAmount - uint256 of the input token amount
     * @param _recipient - Address of the recipient
     * @return bought - Amount of output token bought
     */
    function _swap(address _inputToken, address _outputToken, uint256 _inputAmount, address _recipient) internal returns (uint256 bought) {
        // Get plasmaswap trading pair
        (address token0, address token1) = PlasmaswapUtils.sortTokens(_inputToken, _outputToken);
        IPlasmaswapPair pair = IPlasmaswapPair(PlasmaswapUtils.pairForSorted(FACTORY, token0, token1, FACTORY_CODE_HASH));

        uint256 inputAmount = _inputAmount;
        uint256 prevPairBalance;
        if (_inputToken != address(WETH)) {
            prevPairBalance = HyperUtils.balanceOf(IERC20(_inputToken), address(pair));
        }

        // Send tokens to plasmaswap pair
        require(SafeERC20.transfer(IERC20(_inputToken), address(pair), inputAmount), "PlasmaswapHandler#_swap: ERROR_SENDING_TOKENS");

        if (_inputToken != address(WETH)) {
            inputAmount = HyperUtils.balanceOf(IERC20(_inputToken), address(pair)).sub(prevPairBalance);
        }

        // Get current reserves
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();

        // Optimal amounts for plasmaswap trade
        {
            uint256 reserveIn; uint256 reserveOut;
            if (_inputToken == token0) {
                reserveIn = reserve0;
                reserveOut = reserve1;
            } else {
                reserveIn = reserve1;
                reserveOut = reserve0;
            }
            bought = PlasmaswapUtils.getAmountOut(inputAmount, reserveIn, reserveOut);
        }

        // Determine if output amount is token1 or token0
        uint256 amount1Out; uint256 amount0Out;
        if (_inputToken == token0) {
            amount1Out = bought;
        } else {
            amount0Out = bought;
        }

        // Execute swap
        pair.swap(amount0Out, amount1Out, _recipient, bytes(""));
    }
}