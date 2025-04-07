/**
 *Submitted for verification at Etherscan.io on 2020-11-27
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






// a library for performing various math operations














abstract contract BaseConverter is ILpPairConverter {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    address public governance;

    IUniswapV2Router public uniswapRouter = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router public sushiswapRouter = IUniswapV2Router(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    address public lpUni;
    address public lpSlp;
    address public lpBpt;

    // To calculate virtual_price (dollar value)
    OneSplitAudit public oneSplitAudit = OneSplitAudit(0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E);
    IERC20 public tokenUSDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    uint private unlocked = 1;
    uint public preset_virtual_price = 0;

    modifier lock() {
        require(unlocked == 1, 'Converter: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    constructor (
        IUniswapV2Router _uniswapRouter,
        IUniswapV2Router _sushiswapRouter,
        address _lpUni, address _lpSlp, address _lpBpt,
        OneSplitAudit _oneSplitAudit,
        IERC20 _usdc
    ) public {
        if (address(_uniswapRouter) != address(0)) uniswapRouter = _uniswapRouter;
        if (address(_sushiswapRouter) != address(0)) sushiswapRouter = _sushiswapRouter;

        lpUni = _lpUni;
        lpSlp = _lpSlp;
        lpBpt = _lpBpt;

        address token0_ = IUniswapV2Pair(lpUni).token0();
        address token1_ = IUniswapV2Pair(lpUni).token1();

        IERC20(lpUni).safeApprove(address(uniswapRouter), type(uint256).max);
        IERC20(token0_).safeApprove(address(uniswapRouter), type(uint256).max);
        IERC20(token1_).safeApprove(address(uniswapRouter), type(uint256).max);

        IERC20(lpSlp).safeApprove(address(sushiswapRouter), type(uint256).max);
        IERC20(token0_).safeApprove(address(sushiswapRouter), type(uint256).max);
        IERC20(token1_).safeApprove(address(sushiswapRouter), type(uint256).max);

        IERC20(token0_).safeApprove(address(lpBpt), type(uint256).max);
        IERC20(token1_).safeApprove(address(lpBpt), type(uint256).max);

        if (address(_oneSplitAudit) != address(0)) oneSplitAudit = _oneSplitAudit;
        if (address(_usdc) != address(0)) tokenUSDC = _usdc;

        governance = msg.sender;
    }

    function getName() public virtual pure returns (string memory);

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function approveForSpender(IERC20 _token, address _spender, uint _amount) external {
        require(msg.sender == governance, "!governance");
        _token.safeApprove(_spender, _amount);
    }

    function set_preset_virtual_price(uint _preset_virtual_price) public {
        require(msg.sender == governance, "!governance");
        preset_virtual_price = _preset_virtual_price;
    }

    /**
     * This function allows governance to take unsupported tokens out of the contract. This is in an effort to make someone whole, should they seriously mess up.
     * There is no guarantee governance will vote to return these. It also allows for removal of airdropped tokens.
     */
    function governanceRecoverUnsupported(IERC20 _token, uint256 amount, address to) external {
        require(msg.sender == governance, "!governance");
        _token.transfer(to, amount);
    }
}

contract BalancerLpPairConverter_EthWbtc is BaseConverter {
    // lpUni = 0xBb2b8038a1640196FbE3e38816F3e67Cba72D940
    // lpSlp = 0xCEfF51756c56CeFFCA006cD410B03FFC46dd3a58
    // lpBpt = 0x1efF8aF5D577060BA4ac8A29A13525bb0Ee2A3D5
    constructor (
        IUniswapV2Router _uniswapRouter,
        IUniswapV2Router _sushiswapRouter,
        address _lpUni, address _lpSlp, address _lpBpt,
        OneSplitAudit _oneSplitAudit,
        IERC20 _usdc
    ) public BaseConverter(_uniswapRouter, _sushiswapRouter, _lpUni, _lpSlp, _lpBpt, _oneSplitAudit, _usdc) {
    }

    function getName() public override pure returns (string memory) {
        return "BalancerLpPairConverter:EthWbtc";
    }

    function lpPair() external override view returns (address) {
        return lpBpt;
    }

    function token0() public override view returns (address) {
        return IUniswapV2Pair(lpSlp).token0();
    }

    function token1() public override view returns (address) {
        return IUniswapV2Pair(lpSlp).token1();
    }

    function accept(address _input) external override view returns (bool) {
        return (_input == lpUni) || (_input == lpSlp) || (_input == lpBpt);
    }

    function get_virtual_price() external override view returns (uint) {
        if (preset_virtual_price > 0) return preset_virtual_price;
        Balancer _bPool = Balancer(lpBpt);
        uint _totalSupply = _bPool.totalSupply();
        IDecimals _token0 = IDecimals(token0());
        uint _reserve0 = _bPool.getBalance(address(_token0));
        uint _amount = uint(10) ** _token0.decimals(); // 0.1% pool
        if (_amount > _reserve0.div(1000)) {
            _amount = _reserve0.div(1000);
        }
        uint _returnAmount;
        (_returnAmount,) = oneSplitAudit.getExpectedReturn(address(_token0), address(tokenUSDC), _amount, 1, 0);
        // precision 1e18
        uint _tmp = _returnAmount.mul(_reserve0).div(_amount).mul(10 ** 30).div(_totalSupply);
        return _tmp.mul(_bPool.getTotalDenormalizedWeight()).div(_bPool.getDenormalizedWeight(address(_token0)));
    }

    function convert_rate(address _input, address _output, uint _inputAmount) external override view returns (uint _outputAmount) {
        if (_input == _output) return 1;
        if (_inputAmount == 0) return 0;
        if ((_input == lpUni || _input == lpSlp) && _output == lpBpt) {// convert SLP,UNI -> BPT
            return ConverterHelper.convertRateUniLpToBpt(_input, _output, _inputAmount);
        }
        if (_input == lpBpt && (_output == lpSlp || _output == lpUni)) {// convert BPT -> SLP,UNI
            return ConverterHelper.convertRateBptToUniLp(_input, _output, _inputAmount);
        }
        revert("Not supported");
    }

    function calc_add_liquidity(uint _amount0, uint _amount1) external override view returns (uint) {
        return ConverterHelper.calculateAddUniLpLiquidity(IUniswapV2Pair(lpSlp), _amount0, _amount1);
    }

    function calc_remove_liquidity(uint _shares) external override view returns (uint _amount0, uint _amount1) {
        return ConverterHelper.calculateRemoveUniLpLiquidity(IUniswapV2Pair(lpSlp), _shares);
    }

    function convert(address _input, address _output, address _to) external lock override returns (uint _outputAmount) {
        require(_input != _output, "same asset");
        if (_input == lpUni && _output == lpBpt) {// convert UniLp -> BPT
            return ConverterHelper.convertUniLpToBpt(_input, _output, uniswapRouter, _to);
        }
        if (_input == lpSlp && _output == lpBpt) {// convert SLP -> BPT
            return ConverterHelper.convertUniLpToBpt(_input, _output, sushiswapRouter, _to);
        }
        if (_input == lpBpt && _output == lpSlp) {// convert BPT -> SLP
            return ConverterHelper.convertBPTToUniLp(_input, _output, sushiswapRouter, _to);
        }
        if (_input == lpBpt && _output == lpUni) {// convert BPT -> UniLp
            return ConverterHelper.convertBPTToUniLp(_input, _output, uniswapRouter, _to);
        }
        revert("Not supported");
    }

    function add_liquidity(address _to) external lock virtual override returns (uint _outputAmount) {
        Balancer _balPool = Balancer(lpBpt);
        address _token0 = token0();
        address _token1 = token1();
        uint _amount0 = IERC20(_token0).balanceOf(address(this));
        uint _amount1 = IERC20(_token1).balanceOf(address(this));
        uint _poolAmountOut = ConverterHelper.calculateAddBptLiquidity(_balPool, _token0, _token1, _amount0, _amount1);
        return ConverterHelper.addBalancerLiquidity(_balPool, _poolAmountOut, _to);
    }

    function remove_liquidity(address _to) external lock override returns (uint _amount0, uint _amount1) {
        ConverterHelper.removeBptLiquidity(Balancer(lpBpt));
        _amount0 = ConverterHelper.skim(token0(), _to);
        _amount1 = ConverterHelper.skim(token1(), _to);
    }
}