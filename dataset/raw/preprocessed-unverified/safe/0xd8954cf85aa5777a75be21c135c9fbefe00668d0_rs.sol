/**
 *Submitted for verification at Etherscan.io on 2021-02-15
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



























contract CurveRemoveLiquidity is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    bool public stopped = false;
    uint16 public goodwill = 0;
    ICurveRegistry public curveReg;

    address public goodwillAddress      = address(0);
    address private constant wethToken  = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant wbtcToken  = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public intermediateStable   = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    uint256 private constant deadline   = 0xf000000000000000000000000000000000000000000000000000000000000000;

    IUniswapV2Factory private constant UniSwapV2FactoryAddress = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IUniswapV2Router02 private constant uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    modifier stopInEmergency {
        if (stopped) {
            revert("Temporarily Paused");
        } else {
            _;
        }
    }

    constructor(uint16 _goodwill, address payable _goodwillAddress, ICurveRegistry _curveRegistry) public {
        goodwill = _goodwill;
        goodwillAddress = _goodwillAddress;
        curveReg = _curveRegistry;
    }

    function RemoveLiquidity(
        address payable toWhomToIssue,
        address swapAddress,
        uint256 incomingCrv,
        address toToken,
        uint256 minToTokens
    ) external stopInEmergency returns (uint256 ToTokensBought) {
        address poolTokenAddress = curveReg.getTokenAddress(swapAddress);
        uint256 goodwillPortion;
        if (goodwill > 0) {
            goodwillPortion = SafeMath.div(SafeMath.mul(incomingCrv, goodwill), 10000);
            IERC20(poolTokenAddress).safeTransferFrom(msg.sender, goodwillAddress, goodwillPortion);  
        }
        IERC20(poolTokenAddress).safeTransferFrom(msg.sender, address(this), SafeMath.sub(incomingCrv, goodwillPortion));

        (bool isUnderlying, uint8 underlyingIndex) = curveReg.isUnderlyingToken(swapAddress, toToken);

        if (isUnderlying) {
            ToTokensBought = _exitCurve(swapAddress, incomingCrv, underlyingIndex);
        } else if (curveReg.isMetaPool(swapAddress)) {
            address[4] memory poolTokens = curveReg.getPoolTokens(swapAddress);
            address intermediateSwapAddress;
            uint8 i;
            for (; i < 4; i++) {
                if (curveReg.metaPools(poolTokens[i]) != address(0)) {
                    intermediateSwapAddress = curveReg.metaPools(poolTokens[i]);
                    break;
                }
            }

            uint256 intermediateBought = _exitCurve(swapAddress, incomingCrv, i);

            ToTokensBought = _performRemoveLiquidity(intermediateSwapAddress, intermediateBought, toToken);
        } else {
            ToTokensBought = _performRemoveLiquidity(swapAddress, incomingCrv, toToken);
        }

        require(ToTokensBought >= minToTokens, "High Slippage");
        if (toToken == address(0)) {
            Address.sendValue(toWhomToIssue, ToTokensBought);
        } else {
            IERC20(toToken).safeTransfer(toWhomToIssue, ToTokensBought);
        }
    }

    function _performRemoveLiquidity( address swapAddress, uint256 incomingCrv, address toToken) internal returns (uint256 ToTokensBought) {
        if (curveReg.isBtcPool(swapAddress)) {
            (, uint8 wbtcIndex) = curveReg.isUnderlyingToken(swapAddress, wbtcToken);
            uint256 intermediateBought = _exitCurve(swapAddress, incomingCrv, wbtcIndex);
            ToTokensBought = _token2Token(wbtcToken, toToken, intermediateBought);
        } else {
            (bool isUnderlyingIntermediate, uint8 intermediateStableIndex) = curveReg.isUnderlyingToken(swapAddress, intermediateStable);
            require(isUnderlyingIntermediate, "Pool does not support intermediate");
            uint256 intermediateBought = _exitCurve(swapAddress, incomingCrv, intermediateStableIndex);
            ToTokensBought = _token2Token(intermediateStable, toToken, intermediateBought);
        }
    }

    function _exitCurve(address swapAddress, uint256 incomingCrv, uint256 index) internal returns (uint256 tokensReceived) {
        address exitTokenAddress = curveReg.getPoolTokens(swapAddress)[index];
        uint256 iniTokenBal = IERC20(exitTokenAddress).balanceOf(address(this));

        address tokenAddress = curveReg.getTokenAddress(swapAddress);
        IERC20(tokenAddress).safeApprove(swapAddress, 0);
        IERC20(tokenAddress).safeApprove(swapAddress, incomingCrv);
        ICurveSwap(swapAddress).remove_liquidity_one_coin(incomingCrv, int128(index), 0);

        tokensReceived = (IERC20(exitTokenAddress).balanceOf(address(this))).sub(iniTokenBal);
            
    }

    function _token2Token(address fromToken, address toToken, uint256 tokens2Trade) internal returns (uint256 tokenBought) {
        if (fromToken == toToken) {
            return tokens2Trade;
        }

        if (fromToken == address(0)) {
            if (toToken == wethToken) {
                IWETH(wethToken).deposit.value(tokens2Trade)();
                return tokens2Trade;
            }

            address[] memory path = new address[](2);
            path[0] = wethToken;
            path[1] = toToken;
            tokenBought = uniswapRouter.swapExactETHForTokens.value(tokens2Trade)(1, path, address(this), deadline)[path.length - 1];
                
           
        } else if (toToken == address(0)) {
            if (fromToken == wethToken) {
                IWETH(wethToken).withdraw(tokens2Trade);
                return tokens2Trade;
            }

            IERC20(fromToken).safeApprove(address(uniswapRouter), tokens2Trade);

            address[] memory path = new address[](2);
            path[0] = fromToken;
            path[1] = wethToken;
            tokenBought = uniswapRouter.swapExactTokensForETH(tokens2Trade, 1, path, address(this), deadline)[path.length - 1];
        } else {
            IERC20(fromToken).safeApprove(address(uniswapRouter), tokens2Trade);

            if (fromToken != wethToken) {
                if (toToken != wethToken) {
                    address pairA = UniSwapV2FactoryAddress.getPair(fromToken, toToken);
                    address[] memory pathA = new address[](2);
                    pathA[0] = fromToken;
                    pathA[1] = toToken;
                    uint256 amtA;
                    if (pairA != address(0)) {
                        amtA = uniswapRouter.getAmountsOut(tokens2Trade, pathA)[1];
                    }

                    address[] memory pathB = new address[](3);
                    pathB[0] = fromToken;
                    pathB[1] = wethToken;
                    pathB[2] = toToken;

                    uint256 amtB = uniswapRouter.getAmountsOut(tokens2Trade, pathB)[2];
                        
                    if (amtA >= amtB) {
                        tokenBought = uniswapRouter.swapExactTokensForTokens(tokens2Trade, 1, pathA, address(this), deadline)[pathA.length - 1];
                    } else {
                        tokenBought = uniswapRouter.swapExactTokensForTokens(tokens2Trade, 1, pathB, address(this), deadline)[pathB.length - 1]; 
                    }
                } else {
                    address[] memory path = new address[](2);
                    path[0] = fromToken;
                    path[1] = wethToken;

                    tokenBought = uniswapRouter.swapExactTokensForTokens(tokens2Trade, 1, path, address(this), deadline)[path.length - 1];
                }
            } else {
                address[] memory path = new address[](2);
                path[0] = wethToken;
                path[1] = toToken;
                tokenBought = uniswapRouter.swapExactTokensForTokens( tokens2Trade, 1, path, address(this), deadline)[path.length - 1];   
            }
        }
        require(tokenBought > 0, "Error Swapping Tokens");
    }

    function updateCurveRegistry(ICurveRegistry newCurveRegistry) external onlyOwner{
        require(newCurveRegistry != curveReg, "Already using this Registry");
        curveReg = newCurveRegistry;
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) external onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        IERC20(_TokenAddress).safeTransfer(_owner, qty);
    }

    function setNewGoodwill(uint16 _new_goodwill) public onlyOwner {
        require(_new_goodwill >= 0 && _new_goodwill < 10000, "GoodWill Value not allowed");
        goodwill = _new_goodwill;
    }

    function setNewGoodwillAddress(address _newGoodwillAddress) public onlyOwner{
        goodwillAddress = _newGoodwillAddress;
    }

    function toggleContractActive() external onlyOwner {
        stopped = !stopped;
    }

    function withdraw() external onlyOwner {
        _owner.transfer(address(this).balance);
    }

    function updateIntermediateStable(address newIntermediate) external onlyOwner{
        require(newIntermediate != intermediateStable, "Already using this intermediate");
        intermediateStable = newIntermediate;
    }

    function() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}