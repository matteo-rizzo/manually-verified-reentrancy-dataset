/**
 *Submitted for verification at Etherscan.io on 2021-01-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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


interface IBPool is IERC20 {
    function version() external view returns (uint256);

    function swapExactAmountIn(
        address,
        uint256,
        address,
        uint256,
        uint256
    ) external returns (uint256, uint256);

    function swapExactAmountOut(
        address,
        uint256,
        address,
        uint256,
        uint256
    ) external returns (uint256, uint256);

    function calcInGivenOut(
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) external pure returns (uint256);

    function calcOutGivenIn(
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) external pure returns (uint256);

    function getDenormalizedWeight(address) external view returns (uint256);

    function swapFee() external view returns (uint256);

    function setSwapFee(uint256 _swapFee) external;

    function bind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;

    function rebind(
        address token,
        uint256 balance,
        uint256 denorm
    ) external;

    function finalize(
        uint256 _swapFee,
        uint256 _initPoolSupply,
        address[] calldata _bindTokens,
        uint256[] calldata _bindDenorms
    ) external;

    function setPublicSwap(bool _publicSwap) external;

    function setController(address _controller) external;

    function setExchangeProxy(address _exchangeProxy) external;

    function getFinalTokens() external view returns (address[] memory tokens);

    function getTotalDenormalizedWeight() external view returns (uint256);

    function getBalance(address token) external view returns (uint256);

    function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;

    function joinPoolFor(
        address account,
        uint256 rewardAmountOut,
        uint256[] calldata maxAmountsIn
    ) external;

    function joinswapPoolAmountOut(
        address tokenIn,
        uint256 poolAmountOut,
        uint256 maxAmountIn
    ) external returns (uint256 tokenAmountIn);

    function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;

    function exitswapPoolAmountIn(
        address tokenOut,
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external returns (uint256 tokenAmountOut);

    function exitswapExternAmountOut(
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 maxPoolAmountIn
    ) external returns (uint256 poolAmountIn);

    function joinswapExternAmountIn(
        address tokenIn,
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external returns (uint256 poolAmountOut);

    function finalizeRewardFundInfo(address _rewardFund, uint256 _unstakingFrozenTime) external;

    function addRewardPool(
        IERC20 _rewardToken,
        uint256 _startBlock,
        uint256 _endRewardBlock,
        uint256 _rewardPerBlock,
        uint256 _lockRewardPercent,
        uint256 _startVestingBlock,
        uint256 _endVestingBlock
    ) external;

    function isBound(address t) external view returns (bool);

    function getSpotPrice(address tokenIn, address tokenOut) external view returns (uint256 spotPrice);
}









/**
 * @dev This contract will collect vesting Shares, stake to the Boardroom and rebalance BSD, DAI, USDC according to DAO.
 */
contract CommunityFund {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IFreeFromUpTo public constant chi = IFreeFromUpTo(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    modifier discountCHI(uint8 flag) {
        if ((flag & 0x1) == 0) {
            _;
        } else {
            uint256 gasStart = gasleft();
            _;
            uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
            chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41130);
        }
    }

    /* ========== STATE VARIABLES ========== */

    // governance
    address public operator;

    // flags
    bool public initialized = false;
    bool public publicAllowed; // set to true to allow public to call rebalance()

    // price
    uint256 public dollarPriceCeiling;

    address public dollar = address(0x003e0af2916e598Fa5eA5Cb2Da4EDfdA9aEd9Fde);
    address public bond = address(0x9f48b2f14517770F2d238c787356F3b961a6616F);
    address public share = address(0xE7C9C188138f7D70945D420d75F8Ca7d8ab9c700);

    address public dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address public usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    address public boardroom = address(0xb9Fb8a22908c570C09a4Dbf5F89b87f9D91FBf4a);
    address public dollarOracle = address(0x90F42043E638094d710bdCF1D1CbE6268AEB22d7);

    mapping(address => address) public vliquidPools; // DAI/USDC -> value_liquid_pool

    uint256 private usdcDecimalFactor;

    // DAO parameters - https://docs.basisdollar.fi/DAO
    uint256[] public expansionPercent;
    uint256[] public contractionPercent;

    /* ========== EVENTS ========== */

    event Initialized(address indexed executor, uint256 at);
    event SwapToken(address inputToken, address outputToken, uint256 amount);

    /* ========== Modifiers =============== */

    modifier onlyOperator() {
        require(operator == msg.sender, "CommunityFund: caller is not the operator");
        _;
    }

    modifier notInitialized() {
        require(!initialized, "CommunityFund: already initialized");
        _;
    }

    modifier checkPublicAllow() {
        require(publicAllowed || msg.sender == operator, "CommunityFund: caller is not the operator nor public call not allowed");
        _;
    }

    /* ========== GOVERNANCE ========== */

    function initialize(
        address _dollar,
        address _bond,
        address _share,
        address _dai,
        address _usdc,
        address _boardroom,
        address _dollarOracle
    ) public notInitialized {
        dollar = _dollar;
        bond = _bond;
        share = _share;
        dai = _dai;
        usdc = _usdc;
        boardroom = _boardroom;
        dollarOracle = _dollarOracle;
        dollarPriceCeiling = 1010 finney; // $1.01
        vliquidPools[dai] = address(0xc1b6296e55b6cA1882a9cefD72Ac246ACdE91414);
        vliquidPools[usdc] = address(0xCDD2bD61D07b8d42843175dd097A4858A8f764e7);
        usdcDecimalFactor = 10**12; // USDC's decimals = 6
        expansionPercent = [20, 40, 40]; // dollar (20%), DAI (40%), USDC (40%) during expansion period
        contractionPercent = [80, 10, 10]; // dollar (80%), DAI (10%), USDC (10%) during contraction period
        publicAllowed = true;
        initialized = true;
        operator = msg.sender;
        emit Initialized(msg.sender, block.number);
    }

    function setOperator(address _operator) external onlyOperator {
        operator = _operator;
    }

    function setPublicAllowed(bool _publicAllowed) external onlyOperator {
        publicAllowed = _publicAllowed;
    }

    function setExpansionPercent(
        uint256 _dollarPercent,
        uint256 _daiPercent,
        uint256 _usdcPercent
    ) external onlyOperator {
        require(_dollarPercent.add(_daiPercent).add(_usdcPercent) == 100, "!100%");
        expansionPercent[0] = _dollarPercent;
        expansionPercent[1] = _daiPercent;
        expansionPercent[2] = _usdcPercent;
    }

    function setContractionPercent(
        uint256 _dollarPercent,
        uint256 _daiPercent,
        uint256 _usdcPercent
    ) external onlyOperator {
        require(_dollarPercent.add(_daiPercent).add(_usdcPercent) == 100, "!100%");
        contractionPercent[0] = _dollarPercent;
        contractionPercent[1] = _daiPercent;
        contractionPercent[2] = _usdcPercent;
    }

    function setDollarPriceCeiling(uint256 _dollarPriceCeiling) external onlyOperator {
        require(_dollarPriceCeiling >= 950 finney && _dollarPriceCeiling <= 1050 finney, "_dollarPriceCeiling: out of range"); // [$0.95, $1.05]
        dollarPriceCeiling = _dollarPriceCeiling;
    }

    function withdrawShare(uint256 _amount) external onlyOperator {
        IBoardroom(boardroom).withdraw(_amount);
    }

    function exitBoardroom() external onlyOperator {
        IBoardroom(boardroom).exit();
    }

    function grandFund(
        address _token,
        uint256 _amount,
        address _to
    ) external onlyOperator {
        IERC20(_token).transfer(_to, _amount);
    }

    /* ========== VIEW FUNCTIONS ========== */

    function earned() public view returns (uint256) {
        return IBoardroom(boardroom).earned(address(this));
    }

    function stablecoinBalances()
        public
        view
        returns (
            uint256 _dollarBal,
            uint256 _daiBal,
            uint256 _usdcBal,
            uint256 _totalBal
        )
    {
        _dollarBal = IERC20(dollar).balanceOf(address(this));
        _daiBal = IERC20(dai).balanceOf(address(this));
        _usdcBal = IERC20(usdc).balanceOf(address(this));
        _totalBal = _dollarBal.add(_daiBal).add(_usdcBal.mul(usdcDecimalFactor));
    }

    function stablecoinPercents()
        public
        view
        returns (
            uint256 _dollarPercent,
            uint256 _daiPercent,
            uint256 _usdcPercent
        )
    {
        (uint256 _dollarBal, uint256 _daiBal, uint256 _usdcBal, uint256 _totalBal) = stablecoinBalances();
        if (_totalBal > 0) {
            _dollarPercent = _dollarBal.mul(100).div(_totalBal);
            _daiPercent = _daiBal.mul(100).div(_totalBal);
            _usdcPercent = _usdcBal.mul(usdcDecimalFactor).mul(100).div(_totalBal);
        }
    }

    function getDollarPrice() public view returns (uint256 dollarPrice) {
        try IOracle(dollarOracle).consult(dollar, 1e18) returns (uint256 price) {
            return price;
        } catch {
            revert("CommunityFund: failed to consult dollar price from the oracle");
        }
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function collectShareRewards() public checkPublicAllow {
        if (IShare(share).unclaimedTreasuryFund() > 0) {
            IShare(share).claimRewards();
        }
    }

    function claimAndRestake() public checkPublicAllow {
        if (IBoardroom(boardroom).canClaimReward(address(this))) {
            // only restake more if at this epoch we could claim pending dollar rewards
            if (earned() > 0) {
                IBoardroom(boardroom).claimReward();
            }
            uint256 _shareBal = IERC20(share).balanceOf(address(this));
            if (_shareBal > 0) {
                IERC20(share).safeApprove(boardroom, 0);
                IERC20(share).safeApprove(boardroom, _shareBal);
                IBoardroom(boardroom).stake(_shareBal);
            }
        }
    }

    function rebalance(uint8 flag) public discountCHI(flag) checkPublicAllow {
        collectShareRewards();
        claimAndRestake();
        (uint256 _dollarBal, uint256 _daiBal, uint256 _usdcBal, uint256 _totalBal) = stablecoinBalances();
        if (_totalBal > 0) {
            uint256 _dollarPercent = _dollarBal.mul(100).div(_totalBal);
            uint256 _daiPercent = _daiBal.mul(100).div(_totalBal);
            uint256 _usdcPercent = _usdcBal.mul(usdcDecimalFactor).mul(100).div(_totalBal);
            if (getDollarPrice() >= dollarPriceCeiling) {
                // expansion: sell BSD
                if (_dollarPercent > expansionPercent[0]) {
                    uint256 _sellingBSD = _dollarBal.mul(_dollarPercent.sub(expansionPercent[0])).div(100);
                    if (_daiPercent >= expansionPercent[1]) {
                        // enough DAI
                        if (_usdcPercent < expansionPercent[2]) {
                            // short of USDC: buy USDC
                            _swapToken(dollar, usdc, _sellingBSD);
                        } else {
                            if (_daiPercent.sub(expansionPercent[1]) <= _usdcPercent.sub(expansionPercent[2])) {
                                // has more USDC than DAI: buy DAI
                                _swapToken(dollar, dai, _sellingBSD);
                            } else {
                                // has more DAI than USDC: buy USDC
                                _swapToken(dollar, usdc, _sellingBSD);
                            }
                        }
                    } else {
                        // short of DAI
                        if (_usdcPercent >= expansionPercent[2]) {
                            // enough USDC: buy DAI
                            _swapToken(dollar, dai, _sellingBSD);
                        } else {
                            // short of USDC
                            uint256 _shortDaiPercent = expansionPercent[1].sub(_daiPercent);
                            uint256 _shortUsdcPercent = expansionPercent[2].sub(_usdcPercent);
                            uint256 _sellingBSDToDai = _sellingBSD.mul(_shortDaiPercent).div(_shortDaiPercent.add(_shortUsdcPercent));
                            _swapToken(dollar, dai, _sellingBSDToDai);
                            _swapToken(dollar, usdc, _sellingBSD.sub(_sellingBSDToDai));
                        }
                    }
                }
            } else {
                // contraction: buy BSD
                if (_daiPercent >= contractionPercent[1]) {
                    // enough DAI
                    if (_usdcPercent <= contractionPercent[2]) {
                        // short of USDC: sell DAI
                        uint256 _sellingDAI = _daiBal.mul(_daiPercent.sub(contractionPercent[1])).div(100);
                        _swapToken(dai, dollar, _sellingDAI);
                    } else {
                        if (_daiPercent.sub(contractionPercent[1]) > _usdcPercent.sub(contractionPercent[2])) {
                            // has more DAI than USDC: sell DAI
                            uint256 _sellingDAI = _daiBal.mul(_daiPercent.sub(contractionPercent[1])).div(100);
                            _swapToken(dai, dollar, _sellingDAI);
                        } else {
                            // has more USDC than DAI: sell USDC
                            uint256 _sellingUSDC = _usdcBal.mul(_usdcPercent.sub(contractionPercent[2])).div(100);
                            _swapToken(usdc, dollar, _sellingUSDC);
                        }
                    }
                } else {
                    // short of DAI
                    if (_usdcPercent > contractionPercent[2]) {
                        // enough USDC: sell USDC
                        uint256 _sellingUSDC = _usdcBal.mul(_usdcPercent.sub(contractionPercent[2])).div(100);
                        _swapToken(usdc, dollar, _sellingUSDC);
                    }
                }
            }
        }
    }

    function _bpoolSwap(
        address _pool,
        address _input,
        address _output,
        uint256 _amount
    ) internal {
        IERC20(_input).safeApprove(_pool, 0);
        IERC20(_input).safeApprove(_pool, _amount);
        IBPool(_pool).swapExactAmountIn(_input, _amount, _output, 1, type(uint256).max);
        emit SwapToken(_input, _output, _amount);
    }

    function _swapToken(
        address _inputToken,
        address _outputToken,
        uint256 _amount
    ) internal {
        if (_amount == 0) return;
        address _pool;
        if (_outputToken == dollar) {
            // buying BSD
            _pool = vliquidPools[_inputToken];
        } else if (_inputToken == dollar) {
            // selling BSD
            _pool = vliquidPools[_outputToken];
        }
        require(_pool != address(0), "!pool");
        _bpoolSwap(_pool, _inputToken, _outputToken, _amount);
    }
}