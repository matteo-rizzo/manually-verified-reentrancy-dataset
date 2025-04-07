/**
 *Submitted for verification at Etherscan.io on 2021-02-11
*/

// SPDX-License-Identifier: unlicensed

pragma solidity ^0.5.12;










contract ReentrancyGuard {
    bool private _notEntered;

    constructor() internal {
        _notEntered = true;
    }

    modifier nonReentrant() {
        require(_notEntered, "ReentrancyGuard: reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }
}

contract Context {
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address payable public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    constructor() internal {
        address payable msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address payable newOwner) internal {
        require( newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




























contract SushiswapAddLiquidity is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    bool public stopped = false;
    uint16 public goodwill = 0; 

    address public goodwillAddress              = address(0);   
    address private constant wethTokenAddress   = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 private constant deadline           = 0xf000000000000000000000000000000000000000000000000000000000000000;

    IUniswapV2Factory  private constant UniSwapV2FactoryAddress  = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IUniswapV2Factory  private constant sushiSwapFactoryAddress  = IUniswapV2Factory(0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac);
    IUniswapV2Router02 private constant sushiSwapRouter          = IUniswapV2Router02(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    constructor(uint16 _goodwill, address payable _goodwillAddress) public {
        goodwill = _goodwill;
        goodwillAddress = _goodwillAddress;
    }

    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    function AddLiquidity(
        address _FromTokenContractAddress,
        address _pairAddress,
        uint256 _amount,
        uint256 _minPoolTokens,
        address _allowanceTarget,
        address _swapTarget,
        bytes calldata swapData
    ) external payable nonReentrant stopInEmergency returns (uint256) {
        uint256 toInvest;
        if (_FromTokenContractAddress == address(0)) {
            require(msg.value > 0, "Error: ETH not sent");
            toInvest = msg.value;
        } else {
            require(msg.value == 0, "Error: ETH sent");
            require(_amount > 0, "Error: Invalid ERC amount");
            IERC20(_FromTokenContractAddress).safeTransferFrom(msg.sender, address(this), _amount);
            toInvest = _amount;
        }

        uint256 LPBought = _performAddLiquidity(
            _FromTokenContractAddress,
            _pairAddress,
            toInvest,
            _allowanceTarget,
            _swapTarget,
            swapData
        );

        require(LPBought >= _minPoolTokens, "ERR: High Slippage");
        uint256 goodwillPortion = _transferGoodwill(_pairAddress, LPBought);
        IERC20(_pairAddress).safeTransfer( msg.sender, SafeMath.sub(LPBought, goodwillPortion));
           
        return SafeMath.sub(LPBought, goodwillPortion);
    }

    function _getPairTokens(address _pairAddress) internal pure returns (address token0, address token1){
        IUniswapV2Pair sushiPair = IUniswapV2Pair(_pairAddress);
        token0 = sushiPair.token0();
        token1 = sushiPair.token1();
    }

    function _performAddLiquidity(
        address _FromTokenContractAddress,
        address _pairAddress,
        uint256 _amount,
        address _allowanceTarget,
        address _swapTarget,
        bytes memory swapData
    ) internal returns (uint256) {
        uint256 intermediateAmt;
        address intermediateToken;
        (address _ToSushipoolToken0, address _ToSushipoolToken1) = _getPairTokens(_pairAddress);
            
        if (_FromTokenContractAddress != _ToSushipoolToken0 && _FromTokenContractAddress != _ToSushipoolToken1) {
            (intermediateAmt, intermediateToken) = _fillQuote(
                _FromTokenContractAddress,
                _pairAddress,
                _amount,
                _allowanceTarget,
                _swapTarget,
                swapData
            );
        } else {
            intermediateToken = _FromTokenContractAddress;
            intermediateAmt = _amount;
        }

        (uint256 token0Bought, uint256 token1Bought) = _swapIntermediate(
            intermediateToken,
            _ToSushipoolToken0,
            _ToSushipoolToken1,
            intermediateAmt
        );

        return _sushiDeposit(
            _ToSushipoolToken0,
            _ToSushipoolToken1,
            token0Bought,
            token1Bought
        );
    }

    function _sushiDeposit(address _ToUnipoolToken0, address _ToUnipoolToken1, uint256 token0Bought, uint256 token1Bought) internal returns (uint256) {
        IERC20(_ToUnipoolToken0).safeApprove(address(sushiSwapRouter), 0);
        IERC20(_ToUnipoolToken1).safeApprove(address(sushiSwapRouter), 0);
        IERC20(_ToUnipoolToken0).safeApprove(address(sushiSwapRouter), token0Bought);
        IERC20(_ToUnipoolToken1).safeApprove(address(sushiSwapRouter), token1Bought);
            
        (uint256 amountA, uint256 amountB, uint256 LP) = sushiSwapRouter.addLiquidity(
            _ToUnipoolToken0,
            _ToUnipoolToken1,
            token0Bought,
            token1Bought,
            1,
            1,
            address(this),
            deadline
        );

        if (token0Bought.sub(amountA) > 0) {
            IERC20(_ToUnipoolToken0).safeTransfer(msg.sender, token0Bought.sub(amountA));
        }

        if (token1Bought.sub(amountB) > 0) {
            IERC20(_ToUnipoolToken1).safeTransfer(msg.sender, token1Bought.sub(amountB)); 
        }

        return LP;
    }

    function _fillQuote(
        address _fromTokenAddress,
        address _pairAddress,
        uint256 _amount,
        address _allowanceTarget,
        address _swapTarget,
        bytes memory swapCallData
    ) internal returns (uint256 amountBought, address intermediateToken) {
        uint256 valueToSend;
        if (_fromTokenAddress == address(0)) {
            valueToSend = _amount;
        } else {
            IERC20 fromToken = IERC20(_fromTokenAddress);
            fromToken.safeApprove(address(_allowanceTarget), 0);
            fromToken.safeApprove(address(_allowanceTarget), _amount);
        }

        (address _token0, address _token1) = _getPairTokens(_pairAddress);
        IERC20 token0 = IERC20(_token0);
        IERC20 token1 = IERC20(_token1);
        uint256 initialBalance0 = token0.balanceOf(address(this));
        uint256 initialBalance1 = token1.balanceOf(address(this));

        (bool success, ) = _swapTarget.call.value(valueToSend)(swapCallData);
        require(success, "Error Swapping Tokens 1");

        uint256 finalBalance0 = token0.balanceOf(address(this)).sub(initialBalance0);
        uint256 finalBalance1 = token1.balanceOf(address(this)).sub(initialBalance1);

        if (finalBalance0 > finalBalance1) {
            amountBought = finalBalance0;
            intermediateToken = _token0;
        } else {
            amountBought = finalBalance1;
            intermediateToken = _token1;
        }

        require(amountBought > 0, "Swapped to Invalid Intermediate");
    }

    function _swapIntermediate(address _toContractAddress, address _ToSushipoolToken0, address _ToSushipoolToken1, uint256 _amount) internal returns (uint256 token0Bought, uint256 token1Bought) {
        IUniswapV2Pair pair = IUniswapV2Pair(sushiSwapFactoryAddress.getPair(_ToSushipoolToken0,_ToSushipoolToken1));
            
        (uint256 res0, uint256 res1, ) = pair.getReserves();
        if (_toContractAddress == _ToSushipoolToken0) {
            uint256 amountToSwap = calculateSwapInAmount(res0, _amount);

            if (amountToSwap <= 0) amountToSwap = _amount.div(2);
            token1Bought = _token2Token(_toContractAddress, _ToSushipoolToken1, amountToSwap);
            token0Bought = _amount.sub(amountToSwap);
        } else {
            uint256 amountToSwap = calculateSwapInAmount(res1, _amount);

            if (amountToSwap <= 0) amountToSwap = _amount.div(2);
            token0Bought = _token2Token(_toContractAddress, _ToSushipoolToken0, amountToSwap);
            token1Bought = _amount.sub(amountToSwap);
        }
    }

    function calculateSwapInAmount(uint256 reserveIn, uint256 userIn) internal pure returns (uint256){
        return Babylonian.sqrt(reserveIn.mul(userIn.mul(3988000) + reserveIn.mul(3988009))).sub(reserveIn.mul(1997)) / 1994;        
    }

    function _token2Token( address _FromTokenContractAddress, address _ToTokenContractAddress, uint256 tokens2Trade ) internal returns (uint256 tokenBought) {
        if (_FromTokenContractAddress == _ToTokenContractAddress) {
            return tokens2Trade;
        }

        IERC20(_FromTokenContractAddress).safeApprove( address(sushiSwapRouter), 0);
        IERC20(_FromTokenContractAddress).safeApprove( address(sushiSwapRouter), tokens2Trade);

        if (_FromTokenContractAddress != wethTokenAddress) {
            if (_ToTokenContractAddress != wethTokenAddress) {
                // check output via tokenA -> tokenB
                address pairA = UniSwapV2FactoryAddress.getPair( _FromTokenContractAddress, _ToTokenContractAddress);
                address[] memory pathA = new address[](2);
                pathA[0] = _FromTokenContractAddress;
                pathA[1] = _ToTokenContractAddress;
                uint256 amtA;
                if (pairA != address(0)) {
                    amtA = sushiSwapRouter.getAmountsOut( tokens2Trade, pathA)[1];
                }

                // check output via tokenA -> weth -> tokenB
                address[] memory pathB = new address[](3);
                pathB[0] = _FromTokenContractAddress;
                pathB[1] = wethTokenAddress;
                pathB[2] = _ToTokenContractAddress;

                uint256 amtB = sushiSwapRouter.getAmountsOut( tokens2Trade, pathB)[2];

                if (amtA >= amtB) {
                    tokenBought = sushiSwapRouter.swapExactTokensForTokens(tokens2Trade, 1, pathA, address(this), deadline)[pathA.length - 1];
                } else {
                    tokenBought = sushiSwapRouter.swapExactTokensForTokens(tokens2Trade, 1, pathB, address(this), deadline)[pathB.length - 1];
                }
            } else {
                address[] memory path = new address[](2);
                path[0] = _FromTokenContractAddress;
                path[1] = wethTokenAddress;

                tokenBought = sushiSwapRouter.swapExactTokensForTokens(tokens2Trade, 1, path, address(this), deadline)[path.length - 1]; 
            }
        } else {
            address[] memory path = new address[](2);
            path[0] = wethTokenAddress;
            path[1] = _ToTokenContractAddress;
            tokenBought = sushiSwapRouter.swapExactTokensForTokens(tokens2Trade, 1, path, address(this), deadline)[path.length - 1];
        }

        require(tokenBought > 0, "Error Swapping Tokens 2");
    }

    function _transferGoodwill( address _tokenContractAddress, uint256 tokens2Trade) internal returns (uint256 goodwillPortion) {
        goodwillPortion = SafeMath.div(SafeMath.mul(tokens2Trade, goodwill), 10000);
           
        if (goodwillPortion == 0) {
            return 0;
        }

        IERC20(_tokenContractAddress).safeTransfer( goodwillAddress, goodwillPortion);
    }

    function setNewGoodwill(uint16 _new_goodwill) public onlyOwner {
        require(_new_goodwill >= 0 && _new_goodwill < 10000, "GoodWill Value not allowed");
        goodwill = _new_goodwill;
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.safeTransfer(owner(), qty);
    }

    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    function setNewGoodwillAddress(address _newGoodwillAddress) public onlyOwner{
        goodwillAddress = _newGoodwillAddress;
    }

    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        address payable _to = owner().toPayable();
        _to.transfer(contractBalance);
    }
}