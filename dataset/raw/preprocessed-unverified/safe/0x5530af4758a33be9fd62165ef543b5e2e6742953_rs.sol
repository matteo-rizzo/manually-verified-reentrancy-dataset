/**
 *Submitted for verification at Etherscan.io on 2020-11-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.3;








contract YUICrowdSale is Ownable{
    
    using SafeMath for uint256;
    
    uint256 public priceFactor;
    uint256 public totalSold;
    address public tokenAddress;
    uint256 public startTime = 1605290400;
    uint256 public endTime = 1605636000;
    
    uint256 public minimumBuyAmount = 10 ** 17;
    address payable public walletAddress;
    event TokensSold(address indexed to, uint256 amount);
    
    constructor() {
        priceFactor = uint256(20);
        walletAddress = 0x5958C4C4385883F940809698826e9780146a96f7;
        tokenAddress = address(0x0);
    }
    
    receive() external payable {
        buy();
    }
    
    function changeWallet (address payable _walletAddress) onlyOwner public {
        walletAddress = _walletAddress;
    }
    
    function setToken(address _tokenAddress) onlyOwner public {
        tokenAddress = _tokenAddress;
    }
    
    function buy() public payable {
        require((block.timestamp > startTime ) && (block.timestamp < endTime)  , "YUI Token Crowdsate is not active");
        uint256 weiValue = msg.value;
        require(weiValue >= minimumBuyAmount, "Minimum amount is 0.1 eth");
        uint256 amount = weiValue.mul(priceFactor);
        Token token = Token(tokenAddress);
        require(walletAddress.send(weiValue));
        require(token.tokensSold(msg.sender, amount));
        totalSold += amount;
        emit TokensSold(msg.sender, amount);
    }
    
    function burnUnsold() onlyOwner public {
        require((block.timestamp > endTime), "YUI Token Crowdsate is still active");
        Token token = Token(tokenAddress);
        uint256 amount = token.balanceOf(address(this));
        token.burn(amount);
    }
    
}