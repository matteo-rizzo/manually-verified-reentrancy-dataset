/**
 *Submitted for verification at Etherscan.io on 2021-08-02
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.7.6;



// Part: Address

/**
 * @dev Collection of functions related to the address type
 */


// Part: Context

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// Part: IAgentManager



// Part: IERC20



// Part: IUniswapV2Pair



// Part: IUniswapV2Router01



// Part: IWithdrawLiquidityProxy



// Part: ReentrancyGuard

contract ReentrancyGuard {
    bool private _notEntered;

    constructor() {
        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;
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
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }
}

// Part: SafeMath

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

// Part: Ownable

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// Part: SafeERC20

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// Part: BaseProxy

/**
 * @title Proxy
 * @notice This contract is the base proxy contract that all proxy contracts should use
 * It deals with the agentManager contract dependency and imports all necessary utilities
 */
contract BaseProxy is Ownable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant FEE_PRECISION = 10**6;

    uint256 public actionFee;
    address public feeDepositAddress;
    IAgentManager internal agentManager;

    event feeDeposited(
        address indexed depositAddress,
        address indexed tokenAddress,
        uint256 indexed amount
    );

    modifier agentVerified(string calldata agentId, address user) {
        require(
            agentManager.verifyAgentAddress(agentId, msg.sender, user),
            "Agent not authorised for provided user"
        );
        _;
    }

    /**
     * @param _agentManagerAddress: The agent manager address to connect to
     * @param _actionFee: The action fee value
     * @param _feeDepositAddress: The fee deposit address
     */
    constructor(
        address _agentManagerAddress,
        uint256 _actionFee,
        address _feeDepositAddress
    ) {
        agentManager = IAgentManager(_agentManagerAddress);
        actionFee = _actionFee;
        feeDepositAddress = _feeDepositAddress;
    }

    function calcAndTransferFee(address tokenAddress, uint256 inputAmount)
        internal
        returns (uint256)
    {
        uint256 feeAmount = inputAmount.mul(actionFee).div(100).div(
            FEE_PRECISION
        );

        if (feeAmount > 0) {
            IERC20(tokenAddress).safeTransfer(feeDepositAddress, feeAmount);
            emit feeDeposited(feeDepositAddress, tokenAddress, feeAmount);
        }

        return inputAmount.sub(feeAmount);
    }

    /**
     * @notice Updates agent manager contract, can only be called by owner of the contract
     * @param agentManagerAddress: New agent manager address
     */
    function updateAgentManagerContract(address agentManagerAddress)
        external
        onlyOwner
        returns (bool)
    {
        agentManager = IAgentManager(agentManagerAddress);
        return true;
    }

    /**
     * @notice Updates action fee, can only be called by owner of the contract
     * @param _actionFee: New action fee value
     */
    function setActionFee(uint256 _actionFee)
        external
        onlyOwner
        returns (bool)
    {
        require(_actionFee < FEE_PRECISION.mul(10**2), "Invalid action fee");
        actionFee = _actionFee;
        return true;
    }

    /**
     * @notice Updates fee deposit address, can only be called by owner of the contract
     * @param _feeDepositAddress: New fee deposit address
     */
    function setFeeDepositAddress(address _feeDepositAddress)
        external
        onlyOwner
        returns (bool)
    {
        feeDepositAddress = _feeDepositAddress;
        return true;
    }
}

// File: WithdrawLiquidityProxy.sol

/**
 * @title Proxy
 * @notice This contract is responsible for enabling agents to withdraw liquidity
 * in uniswap pool on behalf of the users
 * @dev Inherits the agent manager contract for agent registration & authorization
 * the modifier agentVerified deals with that
 */
contract WithdrawLiquidityProxy is IWithdrawLiquidityProxy, BaseProxy, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;

    event fundsWithdrawn(
        address indexed user,
        address indexed pairAddress,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB
    );

    IUniswapV2Router02 public uniswapRouter;
    mapping(address => uint256) public userAgent;
    uint256 private deadline =
        0xf000000000000000000000000000000000000000000000000000000000000000;

    /**
     * @param uniswapRouterAddress: The uniswap router address for managing uniswap pool liquidity
     * @param agentManagerAddress: The agentManager address for managing user agents
     * @param actionFee: The action fee value, zero for no fees
     * @param feeDepositAddress: The fee deposit address
     */
    constructor(
        address uniswapRouterAddress,
        address agentManagerAddress,
        uint256 actionFee,
        address feeDepositAddress
    ) BaseProxy(agentManagerAddress, actionFee, feeDepositAddress) {
        uniswapRouter = IUniswapV2Router02(uniswapRouterAddress);
    }

    /**
     * @notice Function that withdraws liquidity amount as much approved by the user to this contract
     * If approval > liquidity balance, all of the liquidity amount/balance is withdrawn
     * @param agentId: unique id of the agent doing the transaction
     * @param user: user address to withdraw liquidity for
     * @param pairAddress: Liquidity pool token/pair address
     */
    function withdrawAll(
        string calldata agentId,
        address user,
        address pairAddress
    ) external override nonReentrant agentVerified(agentId, user) returns (bool) {
        uint256 approvedBalance = IERC20(pairAddress).allowance(
            user,
            address(this)
        );
        uint256 actualBalance = IERC20(pairAddress).balanceOf(user);

        require(
            actualBalance > 0 && approvedBalance > 0,
            "User has no pool tokens approved for this pair"
        );

        uint256 balance = approvedBalance;

        if (actualBalance < approvedBalance) {
            balance = actualBalance;
        }

        IERC20(pairAddress).safeTransferFrom(user, address(this), balance);
        balance = IERC20(pairAddress).balanceOf(address(this));

        uint256 withdrawAmount = calcAndTransferFee(pairAddress, balance);
        
        IERC20(pairAddress).safeApprove(address(uniswapRouter), withdrawAmount);

        return _withdrawLiquidity(pairAddress, withdrawAmount, user);
    }

    /**
     * @notice Internal function to withdraw liquidity from uniswap
     * @param pairAddress: Liquidity pool address
     * @param amount: Amount of pool tokens
     * @param to: address to send the removed liquidity to
     */
    function _withdrawLiquidity(
        address pairAddress,
        uint256 amount,
        address to
    ) internal returns (bool) {
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        address token0 = pair.token0();
        address token1 = pair.token1();

        if (token1 == uniswapRouter.WETH()) {
            (uint256 amountA, uint256 amountB) = uniswapRouter
            .removeLiquidityETH(token0, amount, 1, 1, to, deadline);

            emit fundsWithdrawn(
                to,
                pairAddress,
                token0,
                token1,
                amountA,
                amountB
            );
        } else if (token0 == uniswapRouter.WETH()) {
            (uint256 amountA, uint256 amountB) = uniswapRouter
            .removeLiquidityETH(token1, amount, 1, 1, to, deadline);

            emit fundsWithdrawn(
                to,
                pairAddress,
                token0,
                token1,
                amountA,
                amountB
            );
        } else {
            (uint256 amountA, uint256 amountB) = uniswapRouter.removeLiquidity(
                token0,
                token1,
                amount,
                1,
                1,
                to,
                deadline
            );

            emit fundsWithdrawn(
                to,
                pairAddress,
                token0,
                token1,
                amountA,
                amountB
            );
        }

        return true;
    }

    /**
     * @notice Updates uniswap router contract, can only be called by owner of the contract
     * @param uniswapRouterAddress: New uniswap router address
     */
    function updateRouterContract(address uniswapRouterAddress)
        external
        onlyOwner
        returns (bool)
    {
        uniswapRouter = IUniswapV2Router02(uniswapRouterAddress);
        return true;
    }

    function getAgentManager() external override view returns (address) {
        return address(agentManager);
    }
}