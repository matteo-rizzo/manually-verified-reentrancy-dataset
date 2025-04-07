/**
 *Submitted for verification at Etherscan.io on 2020-10-17
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

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








// This class implements IValueLiquidPool to support Value Vault's strategies
// Will implement UniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens for some rare cases which takes fee for token transfer (eg. Dego.finance)
contract UniswapRouterSupportingFeeOnTransferTokens is IValueLiquidPool, IUniswapRouter {
    using SafeMath for uint256;

    address public governance;

    IUniswapRouter public unirouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    uint256 public constant FEE_DENOMINATOR = 10000;
    uint256 public performanceFee = 0; // 0% at start and can be set by governance decision

    mapping(address => mapping(address => address[])) public uniswapPaths; // [input -> output] => uniswap_path
    mapping(address => bool) public hasTransferFee; // token_address => has_transfer_fee

    constructor(address _tokenHasTransferFee) public {
        hasTransferFee[_tokenHasTransferFee] = true;
        governance = msg.sender;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function approveForSpender(ITokenInterface _token, address _spender, uint256 _amount) external {
        require(msg.sender == governance, "!governance");
        _token.approve(_spender, _amount);
    }

    function setUnirouter(IUniswapRouter _unirouter) external {
        require(msg.sender == governance, "!governance");
        unirouter = _unirouter;
    }

    function setPerformanceFee(uint256 _performanceFee) public {
        require(msg.sender == governance, "!governance");
        performanceFee = _performanceFee;
    }

    function setHasTransferFee(address _token, bool _hasFee) public {
        require(msg.sender == governance, "!governance");
        hasTransferFee[_token] = _hasFee;
    }

    function setUnirouterPath(address _input, address _output, address [] memory _path) public {
        require(msg.sender == governance, "!governance");
        uniswapPaths[_input][_output] = _path;
    }

    function swapExactAmountIn(address _tokenIn, uint _tokenAmountIn, address _tokenOut, uint _minAmountOut, uint) external override returns (uint _tokenAmountOut, uint) {
        address[] memory path = uniswapPaths[_tokenIn][_tokenOut];
        if (path.length == 0) {
            // path: _input -> _output
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        }
        ITokenInterface input = ITokenInterface(_tokenIn);
        ITokenInterface output = ITokenInterface(_tokenOut);
        input.transferFrom(msg.sender, address(this), _tokenAmountIn);
        if (performanceFee > 0) {
            uint256 performanceFeeAmount = _tokenAmountIn.mul(performanceFee).div(FEE_DENOMINATOR);
            _tokenAmountIn = _tokenAmountIn.sub(performanceFeeAmount);
            input.transfer(governance, performanceFeeAmount);
        }
        if (hasTransferFee[_tokenIn] || hasTransferFee[_tokenOut]) {
            // swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path, to, deadline)
            unirouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(_tokenAmountIn, _minAmountOut, path, msg.sender, now.add(1800));
        } else {
            // swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline)
            unirouter.swapExactTokensForTokens(_tokenAmountIn, _minAmountOut, path, msg.sender, now.add(1800));
        }
        _tokenAmountOut = output.balanceOf(address(this));
        output.transfer(msg.sender, _tokenAmountOut);
    }

    function swapExactTokensForTokens(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external override returns (uint256[] memory amounts) {
        ITokenInterface input = ITokenInterface(_path[0]);
        input.transferFrom(msg.sender, address(this), _amountIn);
        if (performanceFee > 0) {
            uint256 performanceFeeAmount = _amountIn.mul(performanceFee).div(FEE_DENOMINATOR);
            _amountIn = _amountIn.sub(performanceFeeAmount);
            input.transfer(governance, performanceFeeAmount);
        }
        amounts = unirouter.swapExactTokensForTokens(_amountIn, _amountOutMin, _path, _to, _deadline);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 _amountIn, uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external override returns (uint256[] memory amounts) {
        ITokenInterface input = ITokenInterface(_path[0]);
        input.transferFrom(msg.sender, address(this), _amountIn);
        if (performanceFee > 0) {
            uint256 performanceFeeAmount = _amountIn.mul(performanceFee).div(FEE_DENOMINATOR);
            _amountIn = _amountIn.sub(performanceFeeAmount);
            input.transfer(governance, performanceFeeAmount);
        }
        amounts = unirouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(_amountIn, _amountOutMin, _path, _to, _deadline);
    }

    /**
     * This function allows governance to take unsupported tokens out of the contract.
     * This is in an effort to make someone whole, should they seriously mess up.
     * There is no guarantee governance will vote to return these.
     * It also allows for removal of airdropped tokens.
     */
    function governanceRecoverUnsupported(ITokenInterface _token, uint256 amount, address to) external {
        require(msg.sender == governance, "!governance");
        _token.transfer(to, amount);
    }
}