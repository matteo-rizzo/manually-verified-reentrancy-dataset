/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: UNLICENSED

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 *
*/



// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------


contract BKP_Sales is Owned {
    
    using SafeMath for uint256;
    address public tokenAddress = 0xe1B3ecdf26aF3C631715b6a49A74470e306D455b;
    uint256 unLockingDate;
    
    struct Users{
        uint256 purchasedTokens;
        uint256 claimedTokens;
        uint256 investedInPreSale;
        uint256 investedInPubSale;
    }
    mapping(address => Users) public usersTokens;
    
    struct Sales{
        uint256 tokenRatePerEth;
        uint256 maxTokensForSale;
        uint256 soldTokens;
        uint256 maxInvestment;
        uint256 startDate;
        uint256 endDate;
    }
    mapping(uint256 => Sales) public sales;
    
    modifier unLockingOpen{
        require(block.timestamp >= unLockingDate, "unlocking will start by 2 january");
        _;
    }
    
    event CLAIMED(uint256 amount);
    
    constructor() public {
        owner = 0xAfDE309b21922dc45f20aDFb659eF36ac984A454;
        sales[0].tokenRatePerEth = 34706; //347,06
        sales[0].maxTokensForSale = 100000 * 10 ** (18); // 100,000 BKP for sale
        sales[0].soldTokens = 0;
        sales[0].maxInvestment = 5 ether;
        sales[0].startDate = 1608055200; // 15 dec 2020 6pm GMT
        sales[0].endDate = 1608314400; // 18 dec 2020 6pm GMT
        
        sales[1].tokenRatePerEth = 295;
        sales[1].maxTokensForSale = 300000 * 10 ** (18); // 300,000 BKP for sale
        sales[1].soldTokens = 0;
        sales[1].maxInvestment = 20 ether;
        sales[1].startDate = 1608660000; // 22 dec 2020 6pm GMT
        sales[1].endDate = 1609437600; // 31 dec 2020 6pm GMT

        unLockingDate = 1609545600; // 2 january, 2021 
    }
    
    receive() external payable {
        uint256 _sale;
        if(block.timestamp >= sales[0].startDate && block.timestamp <= sales[0].endDate ){
            // presale
            _sale = 0;
            require(usersTokens[msg.sender].investedInPreSale.add(msg.value) <= sales[_sale].maxInvestment, "Exceeds allowed max Investment");
            usersTokens[msg.sender].investedInPreSale = usersTokens[msg.sender].investedInPreSale.add(msg.value);
        }
        else if(block.timestamp >= sales[1].startDate && block.timestamp <= sales[1].endDate){
            // publicsale
            _sale = 1;
            require(usersTokens[msg.sender].investedInPubSale.add(msg.value) <= sales[_sale].maxInvestment, "Exceeds allowed max Investment");
            usersTokens[msg.sender].investedInPubSale = usersTokens[msg.sender].investedInPubSale.add(msg.value);
        }
        else{
            revert("sale is not open");
        }
        
        uint256 tokens;
        if(_sale == 0)
            tokens = (msg.value.mul(sales[_sale].tokenRatePerEth)).div(10 ** 2);
        else 
            tokens = (msg.value.mul(sales[_sale].tokenRatePerEth));
        
        // allocate tokens to the user
        usersTokens[msg.sender].purchasedTokens = usersTokens[msg.sender].purchasedTokens.add(tokens);
        
        require(sales[_sale].soldTokens.add(tokens) <= sales[_sale].maxTokensForSale, "Insufficient tokens for sale");
        
        sales[_sale].soldTokens = sales[_sale].soldTokens.add(tokens);

        // send received funds to the owner
        owner.transfer(msg.value);
    }
    
    function claimTokens() external unLockingOpen{
        // the private sale purchasers will claim their tokens using this function
        uint256 releasePeriod = 1 days;
        uint256 releasePercentage = 166; //1.66% is released per day
        
        uint256 totalTime = block.timestamp.sub(unLockingDate); // this will give total time 
        totalTime = totalTime.div(releasePeriod); 
        uint256 totalPercentage;
        if(block.timestamp > unLockingDate.add(60 days))
            totalPercentage = 100;
        else 
            totalPercentage = (totalTime.mul(releasePercentage)).div(100); // converts 166% to 1.66%
        
        uint256 totalTokensToClaim = onePercent(usersTokens[msg.sender].purchasedTokens).mul(totalPercentage);
        totalTokensToClaim = totalTokensToClaim.sub(usersTokens[msg.sender].claimedTokens);
        
        require(totalTokensToClaim > 0, "Nothing pending to claim");
        
        require(IToken(tokenAddress).transfer(msg.sender, totalTokensToClaim), "Insufficient balance of sale contract!");
        
        usersTokens[msg.sender].claimedTokens = usersTokens[msg.sender].claimedTokens.add(totalTokensToClaim);
        
        emit CLAIMED(totalTokensToClaim);
    }
    
    function onePercent(uint256 _tokens) internal pure returns (uint256){
        uint256 roundValue = _tokens.ceil(100);
        uint onePercentofTokens = roundValue.mul(100).div(100 * 10**uint(2));
        return onePercentofTokens;
    }
}