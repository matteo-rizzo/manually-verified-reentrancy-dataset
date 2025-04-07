/**
 *Submitted for verification at Etherscan.io on 2021-02-09
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



























contract UniswapV2RemoveLiquidity is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    bool public stopped = false;
    uint16 public goodwill = 0;

    address public goodwillAddress              = address(0);
    uint256 private constant deadline           = 0xf000000000000000000000000000000000000000000000000000000000000000;
    address private constant wethTokenAddress   = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    
    IUniswapV2Router02 private constant uniswapV2Router         = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory private constant UniSwapV2FactoryAddress  = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
   

    
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

    function RemoveLiquidity2PairToken(address _FromUniPoolAddress, uint256 _IncomingLP) public nonReentrant stopInEmergency returns (uint256 amountA, uint256 amountB){
        IUniswapV2Pair pair = IUniswapV2Pair(_FromUniPoolAddress);

        require(address(pair) != address(0), "Error: Invalid Unipool Address");

        address token0 = pair.token0();
        address token1 = pair.token1();

        IERC20(_FromUniPoolAddress).safeTransferFrom( msg.sender, address(this), _IncomingLP);

        uint256 goodwillPortion = _transferGoodwill( _FromUniPoolAddress, _IncomingLP);
 
        IERC20(_FromUniPoolAddress).safeApprove(address(uniswapV2Router), SafeMath.sub(_IncomingLP, goodwillPortion));

        if (token0 == wethTokenAddress || token1 == wethTokenAddress) {
            address _token = token0 == wethTokenAddress ? token1 : token0;
            (amountA, amountB) = uniswapV2Router.removeLiquidityETH(_token, SafeMath.sub(_IncomingLP, goodwillPortion), 1, 1, msg.sender, deadline);
        } else {
            (amountA, amountB) = uniswapV2Router.removeLiquidity( token0, token1, SafeMath.sub(_IncomingLP, goodwillPortion), 1, 1, msg.sender, deadline);
        }
    }

    function RemoveLiquidity(
        address _ToTokenContractAddress,
        address _FromUniPoolAddress,
        uint256 _IncomingLP, 
        uint256 _minTokensRec
    ) public nonReentrant stopInEmergency returns (uint256) {
        IUniswapV2Pair pair = IUniswapV2Pair(_FromUniPoolAddress);

        require(address(pair) != address(0), "Error: Invalid Unipool Address");

        address token0 = pair.token0();
        address token1 = pair.token1();

        IERC20(_FromUniPoolAddress).safeTransferFrom( msg.sender, address(this), _IncomingLP);
   
        uint256 goodwillPortion = _transferGoodwill(_FromUniPoolAddress, _IncomingLP);

        IERC20(_FromUniPoolAddress).safeApprove(address(uniswapV2Router), SafeMath.sub(_IncomingLP, goodwillPortion));

        (uint256 amountA, uint256 amountB) = uniswapV2Router.removeLiquidity( token0, token1, SafeMath.sub(_IncomingLP, goodwillPortion), 1, 1, address(this), deadline);

        uint256 tokenBought;
        if (canSwapFromV2(_ToTokenContractAddress, token0) && canSwapFromV2(_ToTokenContractAddress, token1)) {
            tokenBought = swapFromV2(token0, _ToTokenContractAddress, amountA);
            tokenBought += swapFromV2(token1, _ToTokenContractAddress, amountB);
        } else if (canSwapFromV2(_ToTokenContractAddress, token0)) {
            uint256 token0Bought = swapFromV2(token1, token0, amountB);
            tokenBought = swapFromV2(token0, _ToTokenContractAddress, token0Bought.add(amountA));
        } else if (canSwapFromV2(_ToTokenContractAddress, token1)) {
            uint256 token1Bought = swapFromV2(token0, token1, amountA);
            tokenBought = swapFromV2( token1, _ToTokenContractAddress, token1Bought.add(amountB));
        }

        require(tokenBought >= _minTokensRec, "High slippage");

        if (_ToTokenContractAddress == address(0)) {
            msg.sender.transfer(tokenBought);
        } else {
            IERC20(_ToTokenContractAddress).safeTransfer(msg.sender, tokenBought);
        }

        return tokenBought;
    }

    function RemoveLiquidity2PairTokenWithPermit(
        address _FromUniPoolAddress,
        uint256 _IncomingLP,
        uint256 _approvalAmount,
        uint256 _deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external stopInEmergency returns (uint256 amountA, uint256 amountB) {
        IUniswapV2Pair(_FromUniPoolAddress).permit(msg.sender, address(this), _approvalAmount, _deadline, v, r, s);
        (amountA, amountB) = RemoveLiquidity2PairToken(_FromUniPoolAddress, _IncomingLP);
    }

    function RemoveLiquidityWithPermit(
        address _ToTokenContractAddress,
        address _FromUniPoolAddress,
        uint256 _IncomingLP,
        uint256 _minTokensRec,
        uint256 _approvalAmount,
        uint256 _deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external stopInEmergency returns (uint256) {
        IUniswapV2Pair(_FromUniPoolAddress).permit(msg.sender, address(this), _approvalAmount, _deadline, v, r, s);
        return (RemoveLiquidity(_ToTokenContractAddress, _FromUniPoolAddress, _IncomingLP, _minTokensRec));
    }

    function swapFromV2(address _fromToken, address _toToken, uint256 amount) internal returns (uint256) {
        require(_fromToken != address(0) || _toToken != address(0), "Invalid Exchange values");
        if (_fromToken == _toToken) return amount;
        require(canSwapFromV2(_fromToken, _toToken), "Cannot be exchanged");
        require(amount > 0, "Invalid amount");

        if (_fromToken == address(0)) {
            if (_toToken == wethTokenAddress) {
                IWETH(wethTokenAddress).deposit.value(amount)();
                return amount;
            }

            address[] memory path = new address[](2);
            path[0] = wethTokenAddress;
            path[1] = _toToken;
            uint256 minTokens = uniswapV2Router.getAmountsOut(amount, path)[1];

            minTokens = SafeMath.div(SafeMath.mul(minTokens, SafeMath.sub(10000, 200)), 10000);

            uint256[] memory amounts = uniswapV2Router.swapExactETHForTokens.value(amount)(minTokens, path, address(this), deadline);
                
            return amounts[1];
        } else if (_toToken == address(0)) {
            if (_fromToken == wethTokenAddress) {
                IWETH(wethTokenAddress).withdraw(amount);
                return amount;
            }
            address[] memory path = new address[](2);
            IERC20(_fromToken).safeApprove(address(uniswapV2Router), amount);
            path[0] = _fromToken;
            path[1] = wethTokenAddress;
            uint256 minTokens = uniswapV2Router.getAmountsOut(amount, path)[1];

            minTokens = SafeMath.div(SafeMath.mul(minTokens, SafeMath.sub(10000, 200)), 10000);

            uint256[] memory amounts = uniswapV2Router.swapExactTokensForETH(amount, minTokens, path, address(this), deadline);

            return amounts[1];
        } else {
            IERC20(_fromToken).safeApprove(address(uniswapV2Router), amount);
            uint256 returnedAmount = _swapTokenToTokenV2(_fromToken, _toToken, amount);
            require(returnedAmount > 0, "Error in swap");
            return returnedAmount;
        }
    }

    function _swapTokenToTokenV2(address _fromToken, address _toToken, uint256 amount) internal returns (uint256) {
        IUniswapV2Pair pair1 = IUniswapV2Pair(UniSwapV2FactoryAddress.getPair(_fromToken, wethTokenAddress));
        IUniswapV2Pair pair2 = IUniswapV2Pair(UniSwapV2FactoryAddress.getPair(_toToken, wethTokenAddress));
        IUniswapV2Pair pair3 = IUniswapV2Pair(UniSwapV2FactoryAddress.getPair(_fromToken, _toToken));

        uint256[] memory amounts;

        if (_haveReserve(pair3)) {
            address[] memory path = new address[](2);
            path[0] = _fromToken;
            path[1] = _toToken;
            uint256 minTokens = uniswapV2Router.getAmountsOut(amount, path)[1];
            minTokens = SafeMath.div(SafeMath.mul(minTokens, SafeMath.sub(10000, 200)), 10000);
            amounts = uniswapV2Router.swapExactTokensForTokens(amount, minTokens, path, address(this), deadline);

            return amounts[1];
        } else if (_haveReserve(pair1) && _haveReserve(pair2)) {
            address[] memory path = new address[](3);
            path[0] = _fromToken;
            path[1] = wethTokenAddress;
            path[2] = _toToken;
            uint256 minTokens = uniswapV2Router.getAmountsOut(amount, path)[2];
            minTokens = SafeMath.div(SafeMath.mul(minTokens, SafeMath.sub(10000, 200)), 10000);
            amounts = uniswapV2Router.swapExactTokensForTokens(amount, minTokens, path, address(this), deadline);

            return amounts[2];
        }
        return 0;
    }

    function canSwapFromV2(address _fromToken, address _toToken) internal view returns (bool){
        require(_fromToken != address(0) || _toToken != address(0), "Invalid Exchange values");
 
        if (_fromToken == _toToken) return true;

        if (_fromToken == address(0) || _fromToken == wethTokenAddress) {
            if (_toToken == wethTokenAddress || _toToken == address(0))
                return true;
            IUniswapV2Pair pair = IUniswapV2Pair(UniSwapV2FactoryAddress.getPair(_toToken, wethTokenAddress));
                
            if (_haveReserve(pair)) return true;

        } else if (_toToken == address(0) || _toToken == wethTokenAddress) {
            if (_fromToken == wethTokenAddress || _fromToken == address(0))
                return true;
            IUniswapV2Pair pair = IUniswapV2Pair(UniSwapV2FactoryAddress.getPair(_fromToken, wethTokenAddress));
                
            if (_haveReserve(pair)) return true;
            
        } else {
            IUniswapV2Pair pair1 = IUniswapV2Pair(UniSwapV2FactoryAddress.getPair(_fromToken, wethTokenAddress));
            IUniswapV2Pair pair2 = IUniswapV2Pair(UniSwapV2FactoryAddress.getPair(_toToken, wethTokenAddress));  
            IUniswapV2Pair pair3 = IUniswapV2Pair(UniSwapV2FactoryAddress.getPair(_fromToken, _toToken));
                
            if (_haveReserve(pair1) && _haveReserve(pair2)) return true;
            if (_haveReserve(pair3)) return true;
        }

        return false;
    }

    function _haveReserve(IUniswapV2Pair pair) internal view returns (bool) {
        if (address(pair) != address(0)) {
            uint256 totalSupply = pair.totalSupply();
            if (totalSupply > 0) return true;
        }
    }

     function _transferGoodwill(address _tokenContractAddress, uint256 tokens2Trade) internal returns (uint256 goodwillPortion) {
        if (goodwill == 0) {
            return 0;
        }

        goodwillPortion = SafeMath.div(SafeMath.mul(tokens2Trade, goodwill), 10000);

        IERC20(_tokenContractAddress).safeTransfer(goodwillAddress,goodwillPortion);
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

    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        address payable _to = owner().toPayable();
        _to.transfer(contractBalance);
    }

    function setNewGoodwillAddress(address _newGoodwillAddress) public onlyOwner{
        goodwillAddress = _newGoodwillAddress;
    }

    function() external payable {
        require(msg.sender != tx.origin, "Do not send ETH directly");
    }
}