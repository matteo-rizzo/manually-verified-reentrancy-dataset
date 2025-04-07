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



























contract BalancerRemoveLiquidity is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using Address for address;

    bool private stopped = false;
    uint16 public goodwill = 0;

    address public goodwillAddress = 0xE737b6AfEC2320f616297e59445b60a11e3eF75F;
    address private constant wethTokenAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 private constant deadline = 0xf000000000000000000000000000000000000000000000000000000000000000;
       
    IUniswapV2Factory private constant UniSwapV2FactoryAddress = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    IUniswapV2Router02 private constant uniswapRouter          = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IBFactory private constant BalancerFactory                 = IBFactory(0x9424B1412450D0f8Fc2255FAf6046b98213B76Bd);
 
    event RemovedLiquidity(address _toWhomToIssue, address _fromBalancerPoolAddress, address _toTokenContractAddress, uint256 _OutgoingAmount);

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

    function RemoveLiquidity(address _ToTokenContractAddress, address _FromBalancerPoolAddress, uint256 _IncomingBPT, uint256 _minTokensRec) public payable nonReentrant stopInEmergency returns (uint256) {
        require(BalancerFactory.isBPool(_FromBalancerPoolAddress), "Invalid Balancer Pool");

        address _FromTokenAddress;
        if (IBPool_Balancer_RemoveLiquidity_V1_1(_FromBalancerPoolAddress).isBound( _ToTokenContractAddress)) {
            _FromTokenAddress = _ToTokenContractAddress;
        } else if (_ToTokenContractAddress == address(0) && IBPool_Balancer_RemoveLiquidity_V1_1(_FromBalancerPoolAddress).isBound(wethTokenAddress)) {
            _FromTokenAddress = wethTokenAddress;
        } else {
            _FromTokenAddress = _getBestDeal(_FromBalancerPoolAddress, _IncomingBPT); 
        }

        return (_performRemoveLiquidity(msg.sender, _ToTokenContractAddress, _FromBalancerPoolAddress, _IncomingBPT, _FromTokenAddress, _minTokensRec));
    }

    function _performRemoveLiquidity(
        address payable _toWhomToIssue,
        address _ToTokenContractAddress,
        address _FromBalancerPoolAddress,
        uint256 _IncomingBPT,
        address _IntermediateToken,
        uint256 _minTokensRec
    ) internal returns (uint256) {
        uint256 goodwillPortion = _transferGoodwill(_FromBalancerPoolAddress, _IncomingBPT);

        require(IERC20(_FromBalancerPoolAddress).transferFrom( msg.sender, address(this), SafeMath.sub(_IncomingBPT, goodwillPortion)));

        if (IBPool_Balancer_RemoveLiquidity_V1_1(_FromBalancerPoolAddress).isBound(_ToTokenContractAddress)) {
            return (
                _directRemoveLiquidity(
                    _FromBalancerPoolAddress,
                    _ToTokenContractAddress,
                    _toWhomToIssue,
                    SafeMath.sub(_IncomingBPT, goodwillPortion),
                    _minTokensRec
                )
            );
        }

        //exit balancer
        uint256 _returnedTokens = _exitBalancer(
            _FromBalancerPoolAddress,
            _IntermediateToken,
            SafeMath.sub(_IncomingBPT, goodwillPortion)
        );

        if (_ToTokenContractAddress == address(0)) {
            uint256 ethBought = _token2Eth(
                _IntermediateToken,
                _returnedTokens,
                _toWhomToIssue
            );

            require(ethBought >= _minTokensRec, "High slippage");
            emit RemovedLiquidity(
                _toWhomToIssue,
                _FromBalancerPoolAddress,
                _ToTokenContractAddress,
                ethBought
            );
            return ethBought;
        } else {
            uint256 tokenBought = _token2Token(
                _IntermediateToken,
                _toWhomToIssue,
                _ToTokenContractAddress,
                _returnedTokens
            );
            require(tokenBought >= _minTokensRec, "High slippage");
            emit RemovedLiquidity(
                _toWhomToIssue,
                _FromBalancerPoolAddress,
                _ToTokenContractAddress,
                tokenBought
            );
            return tokenBought;
        }
    }

    function _directRemoveLiquidity(
        address _FromBalancerPoolAddress,
        address _ToTokenContractAddress,
        address _toWhomToIssue,
        uint256 tokens2Trade,
        uint256 _minTokensRec
    ) internal returns (uint256 returnedTokens) {
        returnedTokens = _exitBalancer(_FromBalancerPoolAddress, _ToTokenContractAddress, tokens2Trade);

        require(returnedTokens >= _minTokensRec, "High slippage");

        emit RemovedLiquidity(_toWhomToIssue, _FromBalancerPoolAddress, _ToTokenContractAddress, returnedTokens);
        IERC20(_ToTokenContractAddress).transfer(_toWhomToIssue, returnedTokens);   
    }

    function _transferGoodwill(address _tokenContractAddress, uint256 tokens2Trade)internal returns (uint256 goodwillPortion) {
        if (goodwill == 0) {
            return 0;
        }

        goodwillPortion = SafeMath.div(SafeMath.mul(tokens2Trade, goodwill),10000);
        require(IERC20(_tokenContractAddress).transferFrom(msg.sender, goodwillAddress, goodwillPortion), "Error in transferring BPT:1");
        return goodwillPortion;
    }

    function _getBestDeal(address _FromBalancerPoolAddress, uint256 _IncomingBPT) internal view returns (address _token) {
        address[] memory tokens = IBPool_Balancer_RemoveLiquidity_V1_1(_FromBalancerPoolAddress).getFinalTokens();

        uint256 maxEth;

        for (uint256 index = 0; index < tokens.length; index++) {
            uint256 tokensForBPT = _getBPT2Token(_FromBalancerPoolAddress,_IncomingBPT,tokens[index]);

            if (tokens[index] != wethTokenAddress) {
                if (UniSwapV2FactoryAddress.getPair(tokens[index], wethTokenAddress) == address(0)) {
                    continue;
                }

                address[] memory path = new address[](2);
                path[0] = tokens[index];
                path[1] = wethTokenAddress;
                uint256 ethReturned = uniswapRouter.getAmountsOut(tokensForBPT, path)[1];

                if (maxEth < ethReturned) {
                    maxEth = ethReturned;
                    _token = tokens[index];
                }
            } else {
                if (maxEth < tokensForBPT) {
                    maxEth = tokensForBPT;
                    _token = tokens[index];
                }
            }
        }
    }

    function _getBPT2Token(address _FromBalancerPoolAddress, uint256 _IncomingBPT, address _toToken) internal view returns (uint256 tokensReturned) {
        uint256 totalSupply = IBPool_Balancer_RemoveLiquidity_V1_1(_FromBalancerPoolAddress).totalSupply();
        uint256 swapFee = IBPool_Balancer_RemoveLiquidity_V1_1(_FromBalancerPoolAddress).getSwapFee();
        uint256 totalWeight = IBPool_Balancer_RemoveLiquidity_V1_1(_FromBalancerPoolAddress).getTotalDenormalizedWeight();
        uint256 balance = IBPool_Balancer_RemoveLiquidity_V1_1(_FromBalancerPoolAddress).getBalance(_toToken);
        uint256 denorm = IBPool_Balancer_RemoveLiquidity_V1_1(_FromBalancerPoolAddress).getDenormalizedWeight(_toToken);
        tokensReturned = IBPool_Balancer_RemoveLiquidity_V1_1(_FromBalancerPoolAddress).calcSingleOutGivenPoolIn(
            balance,
            denorm,
            totalSupply,
            totalWeight,
            _IncomingBPT,
            swapFee
        );
    }

    function _exitBalancer(address _FromBalancerPoolAddress, address _ToTokenContractAddress, uint256 _amount) internal returns (uint256 returnedTokens) {
        require(IBPool_Balancer_RemoveLiquidity_V1_1(_FromBalancerPoolAddress).isBound(_ToTokenContractAddress),"Token not bound");
        uint256 minTokens = _getBPT2Token(_FromBalancerPoolAddress, _amount, _ToTokenContractAddress);
        minTokens = SafeMath.div(SafeMath.mul(minTokens, 98), 100);
        returnedTokens = IBPool_Balancer_RemoveLiquidity_V1_1(_FromBalancerPoolAddress).exitswapPoolAmountIn(_ToTokenContractAddress, _amount, minTokens);
        require(returnedTokens > 0, "Error in exiting balancer pool");
    }

    function _token2Token(address _FromTokenContractAddress, address _ToWhomToIssue, address _ToTokenContractAddress, uint256 tokens2Trade) internal returns (uint256 tokenBought) {
        TransferHelper.safeApprove(_FromTokenContractAddress, address(uniswapRouter), tokens2Trade);

        if (_FromTokenContractAddress != wethTokenAddress) {
            address[] memory path = new address[](3);
            path[0] = _FromTokenContractAddress;
            path[1] = wethTokenAddress;
            path[2] = _ToTokenContractAddress;
            tokenBought = uniswapRouter.swapExactTokensForTokens(tokens2Trade, 1, path, _ToWhomToIssue, deadline)[path.length - 1];
        } else {
            address[] memory path = new address[](2);
            path[0] = wethTokenAddress;
            path[1] = _ToTokenContractAddress;
            tokenBought = uniswapRouter.swapExactTokensForTokens(tokens2Trade, 1, path, _ToWhomToIssue, deadline)[path.length - 1];
        }

        require(tokenBought > 0, "Error in swapping ERC: 1");
    }

    function _token2Eth(address _FromTokenContractAddress, uint256 tokens2Trade, address payable _toWhomToIssue) internal returns (uint256 ethBought) {
        if (_FromTokenContractAddress == wethTokenAddress) {
            IWETH(wethTokenAddress).withdraw(tokens2Trade);
            _toWhomToIssue.transfer(tokens2Trade);
            return tokens2Trade;
        }

        IERC20(_FromTokenContractAddress).approve(address(uniswapRouter), tokens2Trade);

        address[] memory path = new address[](2);
        path[0] = _FromTokenContractAddress;
        path[1] = wethTokenAddress;
        ethBought = uniswapRouter.swapExactTokensForETH(tokens2Trade, 1, path, _toWhomToIssue, deadline)[path.length - 1];

        require(ethBought > 0, "Error in swapping Eth: 1");
    }

    function setNewGoodwill(uint16 _new_goodwill) public onlyOwner {
        require(_new_goodwill >= 0 && _new_goodwill < 10000,"GoodWill Value not allowed");
        goodwill = _new_goodwill;
    }

    function setNewGoodwillAddress(address payable _newGoodwillAddress) public onlyOwner{
        goodwillAddress = _newGoodwillAddress;
    }

    function inCaseTokengetsStuck(IERC20 _TokenAddress) public onlyOwner {
        uint256 qty = _TokenAddress.balanceOf(address(this));
        _TokenAddress.transfer(owner(), qty);
    }

    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }

    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        address payable _to = owner().toPayable();
        _to.transfer(contractBalance);
    }

    function() external payable {}
}