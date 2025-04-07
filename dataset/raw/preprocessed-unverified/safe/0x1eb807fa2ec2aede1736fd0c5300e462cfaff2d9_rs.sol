/**
 *Submitted for verification at Etherscan.io on 2021-01-13
*/

pragma solidity ^0.7.4;








contract UtrinCrowdSale is Ownable{
    
    using SafeMath for uint256;
    
    uint256 public priceFactor;
    uint256 public totalSold;
    address public tokenAddress;
    uint256 public startTime =  1611054000;                                     //GMT Tuesday 19 January 2021 11:00:00
    uint256 public endTime =    1611572400;                                     //GMT Monday 25 January 2021 11:00:00
    
    uint256 public minimumBuyAmount = 10 ** 17;                                 //Set to 0.1 ETH.
    address payable public walletAddress;
    event TokensSold(address indexed to, uint256 amount);
    
    constructor() {
        priceFactor = uint256(1500);                                            //1 ETH = 1500 Utrin.   
        walletAddress = 0x22bAF3bF140928201962dD1a01A63EE158BcC616;             
        tokenAddress = address(0x0);
    }
    
    receive() external payable {
        buy();
    }
    
    function setToken(address _tokenAddress) onlyOwner public {
        tokenAddress = _tokenAddress;
    }
    
    function buy() public payable {
        require((block.timestamp > startTime ) && (block.timestamp < endTime)  , "UTRIN crowdsale is not active");
        uint256 weiValue = msg.value;
        require(weiValue >= minimumBuyAmount, "Minimum amount is 0.1 eth");
        uint256 amount = weiValue.mul(priceFactor);
        Token token = Token(tokenAddress);
        require(walletAddress.send(weiValue));
        require(token.tokensSoldCrowdSale(msg.sender, amount));
        totalSold += amount;
        emit TokensSold(msg.sender, amount);
    }
    
    function burnUnsold() onlyOwner public {
        require((block.timestamp > endTime), "UTRIN crowdsale is still active");
        Token token = Token(tokenAddress);
        uint256 amount = token.balanceOf(address(this));
        token.burn(amount);
    }
    
}