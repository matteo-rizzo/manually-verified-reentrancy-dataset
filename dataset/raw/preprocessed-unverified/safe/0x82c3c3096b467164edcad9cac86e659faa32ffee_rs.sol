/**
 *Submitted for verification at Etherscan.io on 2021-09-26
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;





/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */









contract Buy_1Pool_Token is Ownable{
    
    using SafeMath for uint;

    address public tokenAddr;
    uint256 private bnbAmount;
    uint256 public tokenPriceEth; 
    uint256 public tokenDecimal = 18;
    uint256 public bnbDecimal = 18;
    uint256 public startedAt;
    uint256 public endAt;
    
    AggregatorV3Interface internal priceFeed;


    event TokenTransfer(address beneficiary, uint amount);
    
    mapping (address => uint256) public balances;
    mapping(address => uint256) public tokenExchanged;

    constructor(address _tokenAddr, uint256 _startDate, uint256 _endDate)  {
        startedAt = _startDate;
        endAt = _endDate;
        tokenAddr = _tokenAddr;
        priceFeed = AggregatorV3Interface(0x773616E4d11A78F511299002da57A0a94577F1f4);

    }
    
    
    
    receive() payable external {
        ExchangeBNBforToken(msg.sender, msg.value);
        balances[msg.sender] = balances[msg.sender].add(msg.value);
    }
    
    function getLatestPrice() public view returns (uint256) {
        (
            , 
            int price,
            ,
            ,
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }
    
    function ExchangeBNBforToken(address _addr, uint256 _amount) private {
        uint256 amount = _amount;
        address userAdd = _addr;
        require(block.timestamp >= startedAt, "ICO Not started");
        require(block.timestamp < endAt, "ICO Ended");
        
        tokenPriceEth = getLatestPrice();
        
        bnbAmount = ((amount.mul(10 ** uint256(tokenDecimal)).div(tokenPriceEth)).mul(10 ** uint256(tokenDecimal))).div(10 ** uint256(tokenDecimal));
        require(Token(tokenAddr).balanceOf(address(this)) >= bnbAmount, "There is low token balance in contract");
        
        require(Token(tokenAddr).transfer(userAdd, bnbAmount));
        emit TokenTransfer(userAdd, bnbAmount);
        tokenExchanged[msg.sender] = tokenExchanged[msg.sender].add(bnbAmount);
        _owner.transfer(amount);
    }
    
    function ExchangeBNBforTokenMannual() public payable {
        uint256 amount = msg.value;
        address userAdd = msg.sender;
        require(block.timestamp >= startedAt, "ICO Not started");
        require(block.timestamp < endAt, "ICO Ended");
        
        tokenPriceEth = getLatestPrice();
        
        bnbAmount = ((amount.mul(10 ** uint256(tokenDecimal)).div(tokenPriceEth)).mul(10 ** uint256(tokenDecimal))).div(10 ** uint256(tokenDecimal));
        require(Token(tokenAddr).balanceOf(address(this)) >= bnbAmount, "There is low token balance in contract");
        
        require(Token(tokenAddr).transfer(userAdd, bnbAmount));
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        emit TokenTransfer(userAdd, bnbAmount);
        tokenExchanged[msg.sender] = tokenExchanged[msg.sender].add(bnbAmount);
        _owner.transfer(amount);
        
    }
    

    function updateTokenDecimal(uint256 newDecimal) public onlyOwner {
        tokenDecimal = newDecimal;
    }
    
    function updateTokenAddress(address newTokenAddr) public onlyOwner {
        tokenAddr = newTokenAddr;
    }

    function withdrawTokens(address beneficiary) public onlyOwner {
        require(Token(tokenAddr).transfer(beneficiary, Token(tokenAddr).balanceOf(address(this))));
    }
    
    function changeStartDate(uint256 _startedAt) public onlyOwner {
        startedAt = _startedAt;
    }
     
    function changeEndDate(uint256 _endAt) public onlyOwner {
        endAt = _endAt;
    }


    function withdrawCrypto(address payable beneficiary) public onlyOwner {
        beneficiary.transfer(address(this).balance);
    }
    function tokenBalance() public view returns (uint256){
        return Token(tokenAddr).balanceOf(address(this));
    }
    function bnbBalance() public view returns (uint256){
        return address(this).balance;
    }
}