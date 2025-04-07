/**
 *Submitted for verification at Etherscan.io on 2021-08-26
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

/**
 * @dev Collection of functions related to the address type
 */


/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}



/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}




interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/// @title DEX Adapter Core
/// @author Blaize.tech team
/// @notice Contract for interacting with UniswapV2Router
contract DexAdapterCore is Ownable {
    using SafeERC20 for IERC20;
    using Address for address;

    enum PathType {
        ETH_TO_TOKEN,
        TOKEN_TO_ETH,
        TOKEN_TO_TOKEN
    }

    /// @notice Address of UniswapV2Router.
    address public router;
    /// @notice Address of Wrapped ETH token.
    address public WETH;
    /// @notice Address of USDT Token.
    address public USDT;
    /// @notice Path for swapping ETH for Token.
    mapping(address => address[]) public ethToToken;
    /// @notice Path for swapping Token for ETH.
    mapping(address => address[]) public tokenToEth;

    /// @notice Performs initial setup.
    /// @param _router Address of router.
    /// @param _weth Address of Wrapped ETH.
    /// @param _usdt Address of USDT Token.
    constructor(
        address _router,
        address _weth,
        address _usdt
    ) {
        require(_router != address(0) && _weth != address(0) && _usdt != address(0), "Zero address");
        router = _router;
        WETH = _weth;
        USDT = _usdt;
    }

    receive() external payable {}

    /**********
     * SWAP INTERFACE
     **********/

    /// @notice Swaps an amount of ETH to underlying token and sends it to the sender.
    /// @param underlying Underlying token to be bought for ETH.
    function swapETHToUnderlying(address underlying, uint256 underlyingAmount) external payable virtual {
        if (underlying == WETH) {
            IWETH(WETH).deposit{value: msg.value}();
            IERC20(WETH).safeTransfer(msg.sender, msg.value);
        } else {
            address[] memory path = getPath(PathType.ETH_TO_TOKEN, WETH, underlying);
            address _router = _getRouter(underlying);
            IUniswapV2Router01(_router).swapExactETHForTokens{value: msg.value}(underlyingAmount, path, msg.sender, block.timestamp + 100);
        }
    }

    /// @notice Swaps underlyings to ETH and sends it to the sender.
    /// @param underlyingAmounts Amount of each underlying token to be swaped.
    /// @param underlyings Addresses of underlying tokens to be swaped.
    function swapUnderlyingsToETH(uint256[] memory underlyingAmounts, address[] memory underlyings) external virtual {
        uint256 balance;
        for (uint256 i = 0; i < underlyings.length; i++) {
            if (underlyingAmounts[i] == 0) {
                continue;
            }
            IERC20(underlyings[i]).safeTransferFrom(msg.sender, address(this), underlyingAmounts[i]);
            if (underlyings[i] == WETH) {
                IWETH(WETH).withdraw(underlyingAmounts[i]);
                Address.sendValue(payable(msg.sender), underlyingAmounts[i]);
            } else {
                balance = IERC20(underlyings[i]).balanceOf(address(this));
                address[] memory path = getPath(PathType.TOKEN_TO_ETH, underlyings[i], WETH);
                address _router = _getRouter(underlyings[i]);

                IERC20(underlyings[i]).safeApprove(_router, 0);
                IERC20(underlyings[i]).safeApprove(_router, balance);
                IUniswapV2Router01(_router).swapExactTokensForETH(balance, 0, path, msg.sender, block.timestamp + 100);
            }
        }
    }

    /// @notice Swaps one token to another one.
    /// @param _amountToSwap Amount of token to swap.
    /// @param _tokenToSwap Address of token to be swaped.
    /// @param _tokenToReceive Address of token to be bought.
    /// @return Amount of tokens bought.
    function swapTokenToToken(
        uint256 _amountToSwap,
        address _tokenToSwap,
        address _tokenToReceive
    ) external virtual returns (uint256) {
        address[] memory path = getPath(PathType.TOKEN_TO_TOKEN, _tokenToSwap, _tokenToReceive);

        IERC20(_tokenToSwap).safeTransferFrom(msg.sender, address(this), _amountToSwap);
        IERC20(_tokenToSwap).safeApprove(router, 0);
        IERC20(_tokenToSwap).safeApprove(router, _amountToSwap);

        return IUniswapV2Router01(router).swapExactTokensForTokens(_amountToSwap, 0, path, msg.sender, block.timestamp + 100)[path.length - 1];
    }

    /**********
     * VIEW INTERFACE
     **********/

    /// @notice Gets an amount of tokens, which can be bought for another token's amount.
    /// @param _amount Amount of tokens to be swaped.
    /// @param _tokenToSwap Address of token to be swaped.
    /// @param _tokenToReceive Address of token to be bought.
    /// @return Amount of tokens which might be bought.
    function getUnderlyingAmount(
        uint256 _amount,
        address _tokenToSwap,
        address _tokenToReceive
    ) external view virtual returns (uint256) {
        if (_tokenToSwap == _tokenToReceive) return _amount;

        address[] memory path = getPath(PathType.TOKEN_TO_TOKEN, _tokenToSwap, _tokenToReceive);
        address _router = _getRouter(_tokenToSwap);
        return IUniswapV2Router01(_router).getAmountsOut(_amount, path)[path.length - 1];
    }

    /// @notice Gets prices for underlyings in ETH.
    /// @param _tokens Array, which containt underlyings' addresses.
    /// @return Array of underlyings' prices.
    function getTokensPrices(address[] memory _tokens) external view virtual returns (uint256[] memory) {
        uint256[] memory prices = new uint256[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            if (_tokens[i] == WETH) {
                prices[i] = 1 ether;
            } else {
                address[] memory path = getPath(PathType.TOKEN_TO_ETH, _tokens[i], WETH);
                address _router = _getRouter(_tokens[i]);
                prices[i] = IUniswapV2Router01(_router).getAmountsOut(10**IERC20Metadata(_tokens[i]).decimals(), path)[path.length - 1];
            }
        }
        return prices;
    }

    /// @notice Gets ETH price in USDT tokens.
    /// @return Price for ETH in USDT.
    function getEthPrice() external view virtual returns (uint256) {
        address[] memory path = getPath(PathType.ETH_TO_TOKEN, WETH, USDT);
        return IUniswapV2Router01(router).getAmountsOut(1 ether, path)[1];
    }

    /// @notice Gets price of provided DHV token address in ETH.
    /// @param _dhvToken DHV token address.
    /// @return Price of DHV token in ETH.
    function getDHVPriceInETH(address _dhvToken) external view virtual returns (uint256) {
        address[] memory path = getPath(PathType.TOKEN_TO_ETH, _dhvToken, WETH);
        return IUniswapV2Router01(router).getAmountsOut(1 ether, path)[1];
    }

    /// @notice Gets a path for exchanging token.
    /// @param _tokenToSwap Address of token to be swaped.
    /// @param _tokenToReceive Address of token to be bought.
    /// @return Array, which contains path for exchanging token.
    function getPath(
        PathType _pathType,
        address _tokenToSwap,
        address _tokenToReceive
    ) public view virtual returns (address[] memory) {
        address[] memory path;
        if (_pathType == PathType.ETH_TO_TOKEN) {
            path = ethToToken[_tokenToReceive];
        } else if (_pathType == PathType.TOKEN_TO_ETH) {
            path = tokenToEth[_tokenToSwap];
        }

        if (path.length > 0) {
            return path;
        }

        path = _tokenToSwap == WETH || _tokenToReceive == WETH ? new address[](2) : new address[](3);
        if (path.length == 2) {
            path[0] = _tokenToSwap;
            path[1] = _tokenToReceive;
        } else {
            path[0] = _tokenToSwap;
            path[1] = WETH;
            path[2] = _tokenToReceive;
        }

        return path;
    }

    function getEthAmountWithSlippage(uint256 _amount, address _tokenToSwap) external view virtual returns (uint256) {
        if (_tokenToSwap == WETH) {
            return _amount;
        }
        address[] memory path = getPath(PathType.ETH_TO_TOKEN, WETH, _tokenToSwap);
        address _router = _getRouter(_tokenToSwap);
        return IUniswapV2Router01(_router).getAmountsIn(_amount, path)[0];
    }

    /**********
     *ADMIN INTERFACE
     **********/

    function setPath(
        PathType _pathType,
        address _underlying,
        address[] memory _path
    ) public virtual onlyOwner {
        if (_pathType == PathType.ETH_TO_TOKEN) {
            ethToToken[_underlying] = _path;
        } else if (_pathType == PathType.TOKEN_TO_ETH) {
            tokenToEth[_underlying] = _path;
        }
    }

    /**********
     *INTERNAL HELPERS
     **********/

    function _getRouter(address _token) internal view virtual returns (address) {
        return router;
    }
}

/// @title Uniswap Adapter
/// @author Blaize.tech team
/// @notice Contract for interacting with Uniswap router
contract UniswapAdapter is DexAdapterCore {
    /// @notice Performs an initial setup.
    /// @notice Sets an addresses of Uniswap router, WETH and USDT in Ethereum Mainnet.
    constructor()
        DexAdapterCore(
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), // Uniswap router
            address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2), // WETH
            address(0xdAC17F958D2ee523a2206206994597C13D831ec7) // USDT
        )
    {}
}