pragma solidity 0.5.12;





contract ERC20SafeTransfer {
    function doTransferOut(
        address _token,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        IERC20 token = IERC20(_token);
        bool result;

        token.transfer(_to, _amount);

        assembly {
            switch returndatasize()
                case 0 {
                    result := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    result := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        return result;
    }

    function doTransferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        IERC20 token = IERC20(_token);
        bool result;

        token.transferFrom(_from, _to, _amount);

        assembly {
            switch returndatasize()
                case 0 {
                    result := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    result := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        return result;
    }

    function doApprove(
        address _token,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        IERC20 token = IERC20(_token);
        bool result;

        token.approve(_to, _amount);

        assembly {
            switch returndatasize()
                case 0 {
                    result := not(0)
                }
                case 32 {
                    returndatacopy(0, 0, 32)
                    result := mload(0)
                }
                default {
                    revert(0, 0)
                }
        }
        return result;
    }
}


















contract swapUSDx is ERC20SafeTransfer, Ownable {
    using SafeMath for uint256;
    uint256 private BASE = 10 ** 18;

    event SwapUSDx(address targetToken, uint256 inputAmount, uint256 outputAmount);

    constructor () public {
        _owner = msg.sender;
    }

    IChi public chi = IChi(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    address internal USDx = 0xeb269732ab75A6fD61Ea60b06fE994cD32a83549;
    address internal DF = 0x431ad2ff6a9C365805eBaD47Ee021148d6f7DBe0;

    address internal DFEngineContract = 0x3ea496977A356024bE096c1068a57Bd0B92c7d7c;
    DFProtocol internal DFProtocolContract = DFProtocol(0x5843F1Ccc5baA448528eb0e8Bc567Cda7eD1A1E8);
    DFProtocolView internal DFProtocolViewContract = DFProtocolView(0x097Dd22173f0e382daE42baAEb9bDBC9fdf3396F);
    DFStore internal DFStoreContract = DFStore(0xD30d06b276867CfA2266542791242fF37C91BA8d);

    address internal yPool = 0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51;
    address internal paxPool = 0x06364f10B501e868329afBc005b3492902d6C763;
    address internal sUSD = 0xA5407eAE9Ba41422680e2e00537571bcC53efBfD;

    address internal uniswapRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address[] public underlyingTokens = [
        0x8E870D67F660D95d5be530380D0eC0bd388289E1, // PAX
        0x0000000000085d4780B73119b644AE5ecd22b376, // TUSD
        0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48  // USDC
    ];

    address internal USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    modifier discountCHI {
        uint256 gasStart = gasleft();
        _;
        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 *  msg.data.length;
        chi.freeFromUpTo(msg.sender, (gasSpent + 14154) / 41947);
    }

    /**
     * @dev Based on current DF price and the amount of USDx, calculate how many DF does the
     *      `msg.sender` need when destroies USDx.
     * @param _amount Total amount of USDx would be destroied.
     */
    function getDFAmount(uint256 _amount) internal view returns (uint256) {
        // 0 means DF
        uint256 _dfPrice =  DFProtocolViewContract.getPrice(uint256(0));
        // 1 means this processing is `destroy`
        uint256 _rate = DFProtocolViewContract.getFeeRate(uint256(1));
        uint256 _dfAmount = _amount.mul(_rate).mul(BASE).div(uint256(10000).mul(_dfPrice));
        return _dfAmount;
    }

    /**
     * @dev Calculate how many USDx will the `msg.sender` cost when wants to get a specific
     *      amount of DF.
     * @param _amount Total amount of DF would be cost.
     */
    function getSpendingUSDxAmount(uint256 _amount) internal view returns (uint256) {
        address[] memory _path = new address[](2);
        _path[0] = USDx;
        _path[1] = DF;
        uint[] memory _returnAmounts = IUniswapV2Router(uniswapRouter).getAmountsIn(_amount, _path);
        return _returnAmounts[0];
    }

    /**
     * @dev Uses this function to prepare for all authority needed.
     */
    function multiApprove() external onlyOwner discountCHI returns (bool) {
        // When swaps USDx to DF in the uniswap.
        require(doApprove(USDx, uniswapRouter, uint256(-1)), "multiApprove: approve uniswap failed!");
        // When destroy USDx.
        // - 1. DF.approve(DFEngineContract, -1)
        require(doApprove(DF, DFEngineContract, uint256(-1)), "multiApprove: DF approves DFEngine failed!");
        // - 2. USDx.approve(DFEngineContract, -1)
        require(doApprove(USDx, DFEngineContract, uint256(-1)), "multiApprove: USDx approves DFEngine failed!");
        // When swaps token to get USDC
        require(doApprove(underlyingTokens[0], paxPool, uint256(-1)), "multiApprove: PAX approves paxpool failed!");
        require(doApprove(underlyingTokens[1], yPool, uint256(-1)), "multiApprove: TUSD approves ypool failed!");
        // When swaps token to get USDT
        require(doApprove(underlyingTokens[2], sUSD, uint256(-1)), "multiApprove: USDC approves sUSD failed!");
    }

    /**
     * @dev Swaps USDx to DF in the Uniswap.
     * @param _inputAmount Amount of USDx to swap to get DF.
     */
    function swapUSDxToDF(uint256 _inputAmount) internal {
        uint256 _dfAmount =  getDFAmount(_inputAmount);
        uint256 _expectedUSDxAmount = getSpendingUSDxAmount(_dfAmount);
        uint256 _usdxAmount =  _expectedUSDxAmount % DFStoreContract.getMinBurnAmount() > 0
                              ? (_expectedUSDxAmount / DFStoreContract.getMinBurnAmount() + 1) * DFStoreContract.getMinBurnAmount()
                              : _expectedUSDxAmount ;

        address[] memory _path = new address[](2);
        _path[0] = USDx;
        _path[1] = DF;

        // swap parts of USDx to DF.
        IUniswapV2Router(uniswapRouter).swapExactTokensForTokens(
            _usdxAmount,
            _dfAmount,
            _path,
            address(this),
            block.timestamp + 3600
        );
    }

    /**
     * @dev Gets the final amount of target token when swaps.
     * @param _targetToken Asset that swaps to get.
     * @param _inputAmount Amount to swap.
     * @param _minReturn Minimum amount to get when swaps.
     */
    function getAmountOut(address _targetToken, uint256 _inputAmount, uint256 _minReturn) external returns (uint256) {
        // transfer USDx from user to this contract.
        require(
            doTransferFrom(
                USDx,
                msg.sender,
                address(this),
                _inputAmount
            ),
            "swap: USDx transferFrom failed!"
        );

        swapUSDxToDF(_inputAmount);

        // destroy the remaining USDx with DF.
        DFProtocolContract.destroy(0, IERC20(USDx).balanceOf(address(this)));

        if (_targetToken == underlyingTokens[2]){
            // TUSD -> USDC
            uint256 _totalAmount = IERC20(underlyingTokens[1]).balanceOf(address(this));
            Curve(yPool).exchange_underlying(int128(3), int128(1), _totalAmount,uint256(0));
            // PAX -> USDC
            _totalAmount = IERC20(underlyingTokens[0]).balanceOf(address(this));
            Curve(paxPool).exchange_underlying(int128(3), int128(1), _totalAmount,uint256(0));
        } else if (_targetToken == USDT) {
            // USDC -> USDT
            uint256 _totalAmount = IERC20(underlyingTokens[2]).balanceOf(address(this));
            Curve(sUSD).exchange_underlying(int128(1), int128(2), _totalAmount,uint256(0));
            // TUSD -> USDT
            _totalAmount = IERC20(underlyingTokens[1]).balanceOf(address(this));
            Curve(yPool).exchange_underlying(int128(3), int128(2), _totalAmount,uint256(0));
            // PAX -> USDC
            _totalAmount = IERC20(underlyingTokens[0]).balanceOf(address(this));
            Curve(paxPool).exchange_underlying(int128(3), int128(2), _totalAmount,uint256(0));
        }

        uint256 _finalBalance = IERC20(_targetToken).balanceOf(address(this));
        // transfer target token to caller`msg.sender`
        require(doTransferOut(_targetToken, msg.sender, _finalBalance), "swap: Transfer targetToken out failed!");
        require(doTransferOut(DF, msg.sender, IERC20(DF).balanceOf(address(this))), "swap: Transfer DF out failed!");

        emit SwapUSDx(_targetToken, _inputAmount, _finalBalance);
        return _finalBalance;
    }

    /**
     * @dev Swaps token to get target token.
     * @param _targetToken Asset that swaps to get.
     * @param _inputAmount Amount to swap.
     * @param _minReturn Minimum amount to get when swaps.
     */
    function swapUSDxTo(address _targetToken, uint256 _inputAmount, uint256 _minReturn) public discountCHI returns (uint256) {
        // transfer USDx from user to this contract.
        require(
            doTransferFrom(
                USDx,
                msg.sender,
                address(this),
                _inputAmount
            ),
            "swap: USDx transferFrom failed!"
        );

        swapUSDxToDF(_inputAmount);

        // destroy the remaining USDx with DF.
        DFProtocolContract.destroy(0, IERC20(USDx).balanceOf(address(this)));

        if (_targetToken == underlyingTokens[2]){
            // TUSD -> USDC
            uint256 _totalAmount = IERC20(underlyingTokens[1]).balanceOf(address(this));
            Curve(yPool).exchange_underlying(int128(3), int128(1), _totalAmount, uint256(0));
            // PAX -> USDC
            _totalAmount = IERC20(underlyingTokens[0]).balanceOf(address(this));
            Curve(paxPool).exchange_underlying(int128(3), int128(1), _totalAmount, uint256(0));
        } else if (_targetToken == USDT) {
            // USDC -> USDT
            uint256 _totalAmount = IERC20(underlyingTokens[2]).balanceOf(address(this));
            Curve(sUSD).exchange_underlying(int128(1), int128(2), _totalAmount, uint256(0));
            // TUSD -> USDT
            _totalAmount = IERC20(underlyingTokens[1]).balanceOf(address(this));
            Curve(yPool).exchange_underlying(int128(3), int128(2), _totalAmount, uint256(0));
            // PAX -> USDT
            _totalAmount = IERC20(underlyingTokens[0]).balanceOf(address(this));
            Curve(paxPool).exchange_underlying(int128(3), int128(2), _totalAmount, uint256(0));
        }

        uint256 _finalBalance = IERC20(_targetToken).balanceOf(address(this));
        require(_finalBalance >= _minReturn, "swap: Too large slippage to succeed!");
        // transfer target token to caller`msg.sender`
        require(doTransferOut(_targetToken, msg.sender, _finalBalance), "swap: Transfer targetToken out failed!");
        require(doTransferOut(DF, msg.sender, IERC20(DF).balanceOf(address(this))), "swap: Transfer DF out failed!");

        emit SwapUSDx(_targetToken, _inputAmount, _finalBalance);
        return _finalBalance;
    }

    function swapStep1(address _targetToken, uint256 _inputAmount, uint256 _minReturn) public discountCHI {
        // transfer USDx from user to this contract.
        require(
            doTransferFrom(
                USDx,
                msg.sender,
                address(this),
                _inputAmount
            ),
            "swap: USDx transferFrom failed!"
        );

        swapUSDxToDF(_inputAmount);

        // destroy the remaining USDx with DF.
        DFProtocolContract.destroy(0, IERC20(USDx).balanceOf(address(this)));
    }

    function swapStep2() public discountCHI {
        // USDC -> USDT
        uint256 _totalAmount = IERC20(underlyingTokens[2]).balanceOf(address(this));
        Curve(sUSD).exchange_underlying(int128(1), int128(2), _totalAmount, uint256(0));
    }

    function swapStep3() public discountCHI {
        // TUSD -> USDT
        uint256 _totalAmount = IERC20(underlyingTokens[1]).balanceOf(address(this));
        Curve(yPool).exchange_underlying(int128(3), int128(2), _totalAmount, uint256(0));
    }

    function swapStep4() public discountCHI {
        // PAX -> USDT
        uint256 _totalAmount = IERC20(underlyingTokens[0]).balanceOf(address(this));
        Curve(paxPool).exchange_underlying(int128(3), int128(2), _totalAmount, uint256(0));
    }

    function swapStep5(address _targetToken, uint256 _minReturn) public discountCHI {
        uint256 _finalBalance = IERC20(_targetToken).balanceOf(address(this));
        require(_finalBalance >= _minReturn, "swap: Too large slippage to succeed!");
        // transfer target token to caller`msg.sender`
        require(doTransferOut(_targetToken, msg.sender, _finalBalance), "swap: Transfer targetToken out failed!");

    }

    function swapStep6() public discountCHI {
        require(doTransferOut(DF, msg.sender, IERC20(DF).balanceOf(address(this))), "swap: Transfer DF out failed!");
    }

    /**
     * @dev Transfer unexpected toke out, but only for owner.
     */
    function transferOut(address _token, address _to, uint256 _amount) external onlyOwner {
        require(
            doTransferOut(
                _token,
                _to,
                _amount
            ),
            "transferOut: Transfer token out failed!"
        );
    }

}