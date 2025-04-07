pragma solidity ^0.4.24;

contract IBancorConverter {
    function getReturn(address _fromToken, address _toToken, uint256 _amount) public view returns (uint256);
}

contract IExchange {
    function ethToTokens(uint _ethAmount) public view returns(uint);
    function tokenToEth(uint _amountOfTokens) public view returns(uint);
    function tokenToEthRate() public view returns(uint);
    function ethToTokenRate() public view returns(uint);
}



contract Exchange is Owned, IExchange {
    using SafeMath for uint;

    IBancorConverter public bntConverter;
    IBancorConverter public tokenConverter;

    address public ethToken;
    address public bntToken;
    address public token;

    event Initialized(address _bntConverter, address _tokenConverter, address _ethToken, address _bntToken, address _token);

    constructor() public { 
    }

    function initialize(address _bntConverter, address _tokenConverter, address _ethToken, address _bntToken, address _token) external onlyOwner {
       bntConverter = IBancorConverter(_bntConverter);
       tokenConverter = IBancorConverter(_tokenConverter);

       ethToken = _ethToken;
       bntToken = _bntToken;
       token = _token;

       emit Initialized(_bntConverter, _tokenConverter, _ethToken, _bntToken, _token);
    }

    function ethToTokens(uint _ethAmount) public view returns(uint) {
        uint bnt = bntConverter.getReturn(ethToken, bntToken, _ethAmount);
        uint amountOfTokens = tokenConverter.getReturn(bntToken, token, bnt);
        return amountOfTokens;
    }

    function tokenToEth(uint _amountOfTokens) public view returns(uint) {
        uint bnt = tokenConverter.getReturn(token, bntToken, _amountOfTokens);
        uint eth = bntConverter.getReturn(bntToken, ethToken, bnt);
        return eth;
    }

    function tokenToEthRate() public view returns(uint) {
        uint eth = tokenToEth(1 ether);
        return eth;
    }

    function ethToTokenRate() public view returns(uint) {
        uint tkn = ethToTokens(1 ether);
        return tkn;
    }
}

