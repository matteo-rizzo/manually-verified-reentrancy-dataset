/**
 *Submitted for verification at Etherscan.io on 2021-05-13
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

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
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {}

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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

    uint256[49] private __gap;
}



// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)






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



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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


abstract contract IPopMarketplace {
    function submitMlp(
        address _token0,
        address _token1,
        uint256 _liquidity,
        uint256 _endDate,
        uint256 _bonusToken0,
        uint256 _bonusToken1
    ) public virtual returns (uint256);

    function endMlp(uint256 _mlpId) public virtual returns (uint256);

    function cancelMlp(uint256 _mlpId) public virtual;
}

abstract contract IFeesController {
    function feesTo() public virtual returns (address);

    function setFeesTo(address) public virtual;

    function feesPpm() public virtual returns (uint256);

    function setFeesPpm(uint256) public virtual;
}

contract PreMlp is Initializable, OwnableUpgradeSafe {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    address public uniswapFactory;
    uint256 public pendingPreMlpCount;
    uint256 private maxSlippage = 10;
    IPopMarketplace public popMarketplace;
    IUniswapV2Router02 public uniswapRouter;
    IFeesController public feesController;
    mapping(uint256 => PendingPreMlp) public getPreMlp;

    struct PendingPreMlp {
        address maker;
        address taker;
        uint256 liquidity;
        uint256 endDate;
        PreMlpStatus status;
        IERC20 token0;
        IERC20 token1;
        uint256 amountToken0;
        uint256 amountToken1;
        uint256 bonusToken0;
        uint256 bonusToken1;
        uint256 duration;
        uint256 deadline;
        uint256 pendingMlpId;
    }

    enum PreMlpStatus {PENDING, APPROVED, CANCELED, ENDED, REVERTED}

    event PreMlpCreated(uint256 pendingMlpId, uint256 id, address indexed token0, address indexed token1, address indexed pair, uint256 bonusTokenAmount);
    event PreMlpSubmitted(uint256 id, uint256 bonusTokenAmount);
    event PreMlpCanceled(uint256 id);
    event PreMlpReverted(uint256 id);
    event PreMlpLiquidityReleased(uint256 id, uint256 liquidity, address indexed maker, uint256 amount0, address indexed taker, uint256 amount1);

    function initialize(
        address _uniswapFactory,
        address _uniswapRouter,
        address _popMarketplace,
        address _feesController
    ) public initializer {
        OwnableUpgradeSafe.__Ownable_init();
        uniswapFactory = _uniswapFactory;
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        popMarketplace = IPopMarketplace(_popMarketplace);
        feesController = IFeesController(_feesController);
    }

    function makePreMlp(
        address _token0,
        uint256 _amount,
        uint256 _duration,
        uint256 _bonusTokenAmount,
        address _taker,
        uint256 _deadline
    ) external {
        require(_deadline > now, "deadline can not be higher than now");

        IERC20 token = IERC20(_token0);
        token.safeTransferFrom(msg.sender, address(this), _amount.add(_bonusTokenAmount));
        getPreMlp[pendingPreMlpCount++] = PendingPreMlp({
            maker: msg.sender,
            taker: _taker,
            liquidity: 0,
            endDate: 0,
            status: PreMlpStatus.PENDING,
            token0: IERC20(_token0),
            token1: IERC20(address(0)),
            amountToken0: _amount,
            amountToken1: 0,
            bonusToken0: _bonusTokenAmount,
            bonusToken1: 0,
            duration: _duration,
            deadline: _deadline,
            pendingMlpId: 0
        });
        emit PreMlpSubmitted(pendingPreMlpCount - 1, _bonusTokenAmount);
    }

    function takePreMlp(
        uint256 _PreMlpId,
        address _token1,
        uint256 _amount,
        uint256 _bonusTokenAmount
    ) external {
        PendingPreMlp storage pendingPreMlp = getPreMlp[_PreMlpId];
        require(now <= pendingPreMlp.deadline, "expired");

        require(pendingPreMlp.status == PreMlpStatus.PENDING, "mlp status must be pending");
        require(pendingPreMlp.taker == msg.sender, "not correct taker");
        pendingPreMlp.token1 = IERC20(_token1);
        pendingPreMlp.endDate = now.add(pendingPreMlp.duration);
        pendingPreMlp.token1.safeTransferFrom(msg.sender, address(this), _amount.add(_bonusTokenAmount)); //transfer token
        //calc fees
        uint256 feesAmount0 = pendingPreMlp.amountToken0.mul(feesController.feesPpm()) / 1000;
        uint256 feesAmount1 = _amount.mul(feesController.feesPpm()) / 1000;
        //take fees
        pendingPreMlp.amountToken0 = pendingPreMlp.amountToken0.sub(feesAmount0);
        pendingPreMlp.amountToken1 = _amount.sub(feesAmount1);
        pendingPreMlp.bonusToken1 = _bonusTokenAmount;

        //send fees
        pendingPreMlp.token0.safeTransfer(feesController.feesTo(), feesAmount0);
        pendingPreMlp.token1.safeTransfer(feesController.feesTo(), feesAmount1);

        pendingPreMlp.liquidity = _provideLiquidity(pendingPreMlp);
        // pendingPreMlp.taker = msg.sender;
        pendingPreMlp.status = PreMlpStatus.APPROVED;
        if (IUniswapV2Factory(uniswapFactory).getPair(address(pendingPreMlp.token0), address(pendingPreMlp.token1)) == address(0)) {
            IUniswapV2Factory(uniswapFactory).createPair(address(pendingPreMlp.token0), address(pendingPreMlp.token1));
        }
        IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(uniswapFactory, address(pendingPreMlp.token0), address(pendingPreMlp.token1)));
        IERC20(address(pair)).safeApprove(address(popMarketplace), 0);
        IERC20(address(pair)).safeApprove(address(popMarketplace), pendingPreMlp.liquidity);
        pendingPreMlp.token0.safeApprove(address(popMarketplace), 0);
        pendingPreMlp.token0.safeApprove(address(popMarketplace), pendingPreMlp.bonusToken0);
        pendingPreMlp.token1.safeApprove(address(popMarketplace), 0);
        pendingPreMlp.token1.safeApprove(address(popMarketplace), pendingPreMlp.bonusToken1);

        uint256 pendingMlpId =
            popMarketplace.submitMlp(
                address(pendingPreMlp.token0),
                address(pendingPreMlp.token1),
                pendingPreMlp.liquidity,
                pendingPreMlp.endDate,
                pendingPreMlp.bonusToken0,
                pendingPreMlp.bonusToken1
            );
        pendingPreMlp.pendingMlpId = pendingMlpId;
        emit PreMlpCreated(pendingMlpId, _PreMlpId, address(pendingPreMlp.token0), address(pendingPreMlp.token1), address(pair), _bonusTokenAmount);
    }

    function cancelPreMlp(uint256 _PreMlpId) external {
        PendingPreMlp storage pendingPreMlp = getPreMlp[_PreMlpId];
        require(pendingPreMlp.maker == msg.sender, "mlp creator must be sender");
        require(pendingPreMlp.status == PreMlpStatus.PENDING, "mlp status must be pending");
        if (pendingPreMlp.amountToken0 > 0) {
            //return bonus tokens to maker
            pendingPreMlp.token0.safeTransfer(pendingPreMlp.maker, pendingPreMlp.amountToken0);
        }
        if (pendingPreMlp.bonusToken0 > 0) {
            //return bonus tokens to maker
            pendingPreMlp.token0.safeTransfer(pendingPreMlp.maker, pendingPreMlp.bonusToken0);
        }
        pendingPreMlp.status = PreMlpStatus.CANCELED;
        emit PreMlpCanceled(_PreMlpId);
    }

    function revertMarketplaceMlp(uint256 _PreMlpId) external {
        PendingPreMlp storage pendingPreMlp = getPreMlp[_PreMlpId];

        require(pendingPreMlp.maker == msg.sender || msg.sender == pendingPreMlp.taker, "mlp creator must be sender");
        require(pendingPreMlp.status == PreMlpStatus.APPROVED, "mlp status must be approved");
        popMarketplace.cancelMlp(pendingPreMlp.pendingMlpId);
        if (pendingPreMlp.bonusToken0 > 0) {
            //return bonus tokens to maker
            pendingPreMlp.token0.safeTransfer(pendingPreMlp.maker, pendingPreMlp.bonusToken0);
        }

        if (pendingPreMlp.bonusToken1 > 0) {
            // return bonus tokens to taker
            pendingPreMlp.token1.safeTransfer(pendingPreMlp.taker, pendingPreMlp.bonusToken1);
        }

        if (pendingPreMlp.liquidity > 0) {
            //return half LP tokens to maker and taker
            IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(uniswapFactory, address(pendingPreMlp.token0), address(pendingPreMlp.token1)));
            IERC20(address(pair)).safeTransfer(pendingPreMlp.maker, pendingPreMlp.liquidity / 2);
            IERC20(address(pair)).safeTransfer(pendingPreMlp.taker, pendingPreMlp.liquidity / 2);
        }
        pendingPreMlp.status = PreMlpStatus.REVERTED;
        emit PreMlpReverted(_PreMlpId);
    }

    function releaseLiquidity(uint256 _PreMlpId) external {
        PendingPreMlp storage pendingPreMlp = getPreMlp[_PreMlpId];

        require(pendingPreMlp.maker == msg.sender || pendingPreMlp.taker == msg.sender);
        require(pendingPreMlp.status == PreMlpStatus.APPROVED, "mlp status must be approved");
        require(block.timestamp >= pendingPreMlp.endDate, "not yet ended");
        uint256 liquidity = popMarketplace.endMlp(pendingPreMlp.pendingMlpId);
        IUniswapV2Pair pair = IUniswapV2Pair(UniswapV2Library.pairFor(uniswapFactory, address(pendingPreMlp.token0), address(pendingPreMlp.token1)));
        IERC20(address(pair)).safeTransfer(pendingPreMlp.maker, liquidity / 2);
        IERC20(address(pair)).safeTransfer(pendingPreMlp.taker, liquidity / 2);
        uint256 dust = pair.balanceOf(address(this));
        if (dust > 0) {
            pair.transfer(owner(), dust);
        }
        pendingPreMlp.status = PreMlpStatus.ENDED;
        emit PreMlpLiquidityReleased(_PreMlpId, liquidity, pendingPreMlp.maker, liquidity / 2, pendingPreMlp.taker, liquidity / 2);
    }

    function _provideLiquidity(PendingPreMlp memory _preMlp) internal returns (uint256) {
        _preMlp.token0.safeApprove(address(uniswapRouter), 0);
        _preMlp.token0.safeApprove(address(uniswapRouter), _preMlp.amountToken0);
        _preMlp.token1.safeApprove(address(uniswapRouter), 0);
        _preMlp.token1.safeApprove(address(uniswapRouter), _preMlp.amountToken1);

        uint256 amountMin0 = _preMlp.amountToken0.sub(_preMlp.amountToken0.mul(maxSlippage) / 1000);
        uint256 amountMin1 = _preMlp.amountToken1.sub(_preMlp.amountToken1.mul(maxSlippage) / 1000);

        // Add the liquidity to Uniswap
        (uint256 spentAmount0, uint256 spentAmount1, uint256 liquidity) =
            uniswapRouter.addLiquidity(
                address(_preMlp.token0),
                address(_preMlp.token1),
                _preMlp.amountToken0,
                _preMlp.amountToken1,
                amountMin0,
                amountMin1,
                address(this),
                _preMlp.endDate
            );

        // Give back the exceeding tokens
        if (spentAmount0 < _preMlp.amountToken0) {
            _preMlp.token0.safeTransfer(_preMlp.maker, _preMlp.amountToken0 - spentAmount0);
        }
        if (spentAmount1 < _preMlp.amountToken1) {
            _preMlp.token1.safeTransfer(_preMlp.taker, _preMlp.amountToken1 - spentAmount1);
        }

        return liquidity;
    }

    function setMaxSlippage(uint256 _slippage) external onlyOwner {
        require(_slippage > 0, "slippage must be higher than 0");
        maxSlippage = _slippage;
    }
}