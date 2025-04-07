/**
 *Submitted for verification at Etherscan.io on 2021-06-04
*/

// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.6.12;



// Part: IBPool



// Part: IConverter



// Part: IUniswapRouter



// Part: OpenZeppelin/[email protected]/Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: OpenZeppelin/[email protected]/Context

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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


// Part: OpenZeppelin/[email protected]/Ownable

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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


// File: Converter.sol

contract Converter is IConverter, Ownable {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address internal uniswap;
    address immutable public weth;
    address internal bpool;
    address internal idle;
    uint256 internal minAmountIn;

    constructor(
        address _uniswap,
        address _weth,
        address _bpool,
        address _idle,
        uint256 _minAmountIn
    ) public {
        uniswap = _uniswap;
        weth = _weth;
        bpool = _bpool;
        idle = _idle;
        minAmountIn = _minAmountIn;
    }

    function getUniswap() external view returns (address) {
        return uniswap;
    }

    function getBPool() external view returns (address) {
        return bpool;
    }

    function getMinAmountIn() external view returns (uint256) {
        return minAmountIn;
    }

    function convert(
        uint amountIn,
        uint amountOutMin,
        address assetIn,
        address assetOut,
        address to
    ) external override returns (uint convertedAmount) {
        IERC20(assetIn).safeTransferFrom(msg.sender, address(this), amountIn);

        // Balancer has a minAmount to swap otherwise revert with ERR_MATH_APPROX
        if (assetIn == idle && amountIn >= minAmountIn) {
            _ensureAllowance(assetIn, bpool, amountIn);

            // Convert always IDLE to WETH
            (convertedAmount, ) = IBPool(bpool).swapExactAmountIn(
                assetIn,
                amountIn,
                weth,
                amountOutMin,
                type(uint256).max
            );

            // Return immediately in the case assetOut WETH
            // Otw swap with the default method
            if (assetOut == weth) {
                IERC20(weth).safeTransfer(to, convertedAmount);
                return convertedAmount;
            }

            // assetIn becomes weth and amountIn the returned WETH
            assetIn = weth;
            amountIn = convertedAmount;
        }

        _ensureAllowance(assetIn, uniswap, amountIn);

        uint[] memory amounts = IUniswapRouter(uniswap).swapExactTokensForTokens(
            amountIn, amountOutMin, _getPath(assetIn, assetOut), to, now.add(1800)
        );

        convertedAmount = amounts[amounts.length.sub(1)];
    }

    function _ensureAllowance(address token, address spender, uint256 amount) internal {
        if (IERC20(token).allowance(address(this), spender) < amount) {
            IERC20(token).safeApprove(spender, 0);
            IERC20(token).safeApprove(spender, type(uint256).max);
        }
    }

    function _getPath(address assetIn, address assetOut) internal view returns (address[] memory path) {
        if (assetIn == weth || assetOut == weth) {
            path = new address[](2);
            path[0] = assetIn;
            path[1] = assetOut;
        } else {
            path = new address[](3);
            path[0] = assetIn;
            path[1] = weth;
            path[2] = assetOut;
        }
    }

    function getAmountOut(uint256 amountIn, address assetIn, address assetOut) external override view returns (uint256 amountOut) {
        address[] memory path = _getPath(assetIn, assetOut);
        uint256[] memory amounts = IUniswapRouter(uniswap).getAmountsOut(amountIn, path);
        return amounts[path.length.sub(1)];
    }

    function getAmountIn(uint256 amountOut, address assetIn, address assetOut) external override view returns (uint256 amountIn) {
        address[] memory path = _getPath(assetIn, assetOut);
        uint256[] memory amounts = IUniswapRouter(uniswap).getAmountsIn(amountIn, path);
        return amounts[0];
    }

    function sweep(address _token) external onlyOwner {
        IERC20(_token).safeTransfer(owner(), IERC20(_token).balanceOf(address(this)));
    }

    function setUniswap(address _uniswap) external onlyOwner {
        uniswap = _uniswap;
    }

    function setBPool(address _bpool) external onlyOwner {
        bpool = _bpool;
    }

    function setMinAmountIn(uint256 _minAmountIn) external onlyOwner {
        minAmountIn = _minAmountIn;
    }
}