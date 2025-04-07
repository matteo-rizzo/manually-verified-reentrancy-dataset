/**
 *Submitted for verification at Etherscan.io on 2021-03-24
*/

// SPDX-License-Identifier: UNLICENSED

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



// Part: IProxy



// Part: IUniswapV2Pair



// Part: IUniswapV2Router01



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


// Part: AgentManager

contract AgentManager is IAgentManager, Ownable {
    mapping(address => mapping(string => bool)) public userAgents;

    struct AgentKeys {
        address coldAddress;
        address hotAddress;
        address previousHotAddress;
        uint256 lastUpdatedBlock;
    }

    mapping(string => AgentKeys) public agents;

    uint256 public PREVIOUS_HOT_ADDRESS_BLOCK_LIFE;
    uint256 public HOT_ADDRESS_BLOCK_LIFE;

    constructor(uint256 _previousHotAddressBlocks, uint256 _hotAddressBlocks) {
        PREVIOUS_HOT_ADDRESS_BLOCK_LIFE = _previousHotAddressBlocks;
        HOT_ADDRESS_BLOCK_LIFE = _hotAddressBlocks;
    }

    function registerAgentForUser(
        string calldata agentId,
        address _coldAddress,
        address _hotAddress
    ) external override returns (bool) {
        require(
            !userAgents[msg.sender][agentId],
            "Agent id already registered for this user"
        );

        // Checks the mapping to ensure the agentId is not already registered
        require(
            agents[agentId].coldAddress == address(0),
            "AgentId already registered for another user"
        );

        require(
            _coldAddress != address(0) && _hotAddress != address(0),
            "Addresses can't be zero address"
        );

        agents[agentId] = AgentKeys({
            coldAddress: _coldAddress,
            hotAddress: _hotAddress,
            previousHotAddress: address(0),
            lastUpdatedBlock: block.number
        });

        emit AgentUpdated(agentId, _coldAddress, _hotAddress);

        userAgents[msg.sender][agentId] = true;

        emit userAgentRegistered(msg.sender, agentId);

        return true;
    }

    function veryifyAgentAddress(
        string calldata agentId,
        address senderAddress,
        address userAddress
    ) internal view returns (bool) {
        AgentKeys memory keys = agents[agentId];
        if (
            keys.coldAddress == senderAddress ||
            keys.hotAddress == senderAddress
        ) {
            if (HOT_ADDRESS_BLOCK_LIFE == 0) {
                return userAgents[userAddress][agentId];
            }
            
            return
                (block.number <=
                    keys.lastUpdatedBlock + HOT_ADDRESS_BLOCK_LIFE) &&
                userAgents[userAddress][agentId];
        }

        if (keys.previousHotAddress == senderAddress) {
            return
                (block.number <=
                    keys.lastUpdatedBlock + PREVIOUS_HOT_ADDRESS_BLOCK_LIFE) &&
                userAgents[userAddress][agentId];
        }

        return false;
    }

    function updateAgentColdAddress(string calldata agentId, address _coldAddress)
        external
        override
        returns (bool)
    {
        require(
            msg.sender == agents[agentId].coldAddress &&
                _coldAddress != address(0),
            "Cold address can't be updated"
        );
        agents[agentId].coldAddress = _coldAddress;

        emit AgentUpdated(agentId, _coldAddress, agents[agentId].hotAddress);

        return true;
    }

    function updateAgentHotAddress(string calldata agentId, address _hotAddress)
        external
        override
        returns (bool)
    {
        require(
            _hotAddress != address(0) &&
                (msg.sender == agents[agentId].coldAddress ||
                    msg.sender == agents[agentId].hotAddress),
            "Hot address can't be updated"
        );
        agents[agentId].previousHotAddress = agents[agentId].hotAddress;
        agents[agentId].hotAddress = _hotAddress;
        agents[agentId].lastUpdatedBlock = block.number;

        emit AgentUpdated(agentId, agents[agentId].coldAddress, _hotAddress);

        return true;
    }

    function updatePreviousHotAddressBlockDifference(uint256 newBlockDifference)
        external
        onlyOwner
    {
        PREVIOUS_HOT_ADDRESS_BLOCK_LIFE = newBlockDifference;
    }

    function updateHotAddressBlockDifference(uint256 newBlockDifference)
        external
        onlyOwner
    {
        HOT_ADDRESS_BLOCK_LIFE = newBlockDifference;
    }
}

// File: Proxy.sol

contract Proxy is IProxy, AgentManager, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address;

    IUniswapV2Router02 public uniswapRouter;
    mapping(address => uint256) public userAgent;
    uint256 private deadline =
        0xf000000000000000000000000000000000000000000000000000000000000000;

    constructor(
        address uniswapRouterAddress,
        uint256 _previousHotAddressBlocks,
        uint256 _hotAddressBlocks
    ) AgentManager(_previousHotAddressBlocks, _hotAddressBlocks) {
        uniswapRouter = IUniswapV2Router02(uniswapRouterAddress);
    }

    function withdrawAll(
        string calldata agentId,
        address user,
        address pairAddress
    ) external override nonReentrant returns (bool) {
        require(
            veryifyAgentAddress(agentId, msg.sender, user),
            "Agent not authorised to withdraw for provided user"
        );

        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        uint256 approvedBalance =
            IERC20(pairAddress).allowance(user, address(this));
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
        IERC20(pairAddress).safeApprove(address(uniswapRouter), balance);

        if (pair.token1() == uniswapRouter.WETH()) {
            (uint256 amountA, uint256 amountB) =
                uniswapRouter.removeLiquidityETH(
                    pair.token0(),
                    balance,
                    1,
                    1,
                    user,
                    deadline
                );

            emit fundsWithdrawn(
                user,
                pairAddress,
                pair.token0(),
                pair.token1(),
                amountA,
                amountB
            );
        } else if (pair.token0() == uniswapRouter.WETH()) {
            (uint256 amountA, uint256 amountB) =
                uniswapRouter.removeLiquidityETH(
                    pair.token1(),
                    balance,
                    1,
                    1,
                    user,
                    deadline
                );

            emit fundsWithdrawn(
                user,
                pairAddress,
                pair.token0(),
                pair.token1(),
                amountA,
                amountB
            );
        } else {
            (uint256 amountA, uint256 amountB) =
                uniswapRouter.removeLiquidity(
                    pair.token0(),
                    pair.token1(),
                    balance,
                    1,
                    1,
                    user,
                    deadline
                );

            emit fundsWithdrawn(
                user,
                pairAddress,
                pair.token0(),
                pair.token1(),
                amountA,
                amountB
            );
        }

        return true;
    }

    function updateRouterContract(address uniswapRouterAddress)
        external
        override
        onlyOwner
        returns (bool)
    {
        uniswapRouter = IUniswapV2Router02(uniswapRouterAddress);
        return true;
    }
}