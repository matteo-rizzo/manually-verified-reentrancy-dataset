/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

pragma solidity >=0.7.0;

// SPDX-License-Identifier: BSD-3-Clause

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */





contract B26_TeamTokens is Ownable {
    using SafeMath for uint;
    
    // token contract address
    address public constant tokenAddress = 0x481dE76d5ab31e28A33B0EA1c1063aDCb5B1769A;
    
    uint256 public tokens = 0;
    uint256 public tokensToUnlock ;
    
    bool public firstWith =  false;
    bool public secondWith = false;
    bool public thirdWith =  false;
    bool public fourthWith =  false;
    bool public fiveWith =  false;
    bool public sixWith =  false;
    uint256 public relaseTime = 30 days;
    uint256 public relaseTime2 = 60 days;
    uint256 public relaseTime3 = 90 days;
    uint256 public relaseTime4 = 120 days;
    uint256 public relaseTime5 = 150 days;
    uint256 public relaseTime6 = 180 days;
    uint256 public timing ;
    

    function getTiming()  public view returns (uint256){
        return block.timestamp.sub(timing);
    }
    
    function deposit(uint amountToStake) public onlyOwner{
        require( tokens == 0, "Cannot deposit more Tokens");
        require( amountToStake > 0, "Cannot deposit  Tokens");
        
        require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        tokens = amountToStake;
        tokensToUnlock = amountToStake.div(6);
        firstWith = true;
        timing = block.timestamp;
        
        }
    
    function withdraw1() public onlyOwner{
        require( firstWith, "Deposit first");
        require(block.timestamp.sub(timing)>relaseTime, "Not yet");
        
        firstWith = false;
        secondWith = true;
        require(Token(tokenAddress).transfer(owner, tokensToUnlock), "Could not transfer tokens.");
        tokens = tokens.sub(tokensToUnlock);
        
        }
    
    
    function withdraw2() public onlyOwner{
        require( secondWith, "With1 first");
        require(block.timestamp.sub(timing)>relaseTime2, "Not yet");
        
        secondWith = false;
        thirdWith = true;
        require(Token(tokenAddress).transfer(owner, tokensToUnlock), "Could not transfer tokens.");
        tokens = tokens.sub(tokensToUnlock);  
        
        }
        
    function withdraw3() public onlyOwner{
        require( thirdWith, "With2 first");
        require(block.timestamp.sub(timing)>relaseTime3, "Not yet");
        
        thirdWith = false;
        fourthWith = true;
        require(Token(tokenAddress).transfer(owner, tokensToUnlock), "Could not transfer tokens.");
        tokens = tokens.sub(tokensToUnlock); 
        }
        
    function withdraw4() public onlyOwner{
        require( fourthWith, "With3 first");
        require(block.timestamp.sub(timing)>relaseTime4, "Not yet");
        
        fourthWith = false;
        fiveWith = true;
        require(Token(tokenAddress).transfer(owner, tokensToUnlock), "Could not transfer tokens.");
        tokens = tokens.sub(tokensToUnlock); 
    }
    
    function withdraw5() public onlyOwner{
        require( fiveWith, "With4 first");
        require(block.timestamp.sub(timing)>relaseTime5, "Not yet");
        
        fiveWith = false;
        sixWith = true;
        require(Token(tokenAddress).transfer(owner, tokensToUnlock), "Could not transfer tokens.");
        tokens = tokens.sub(tokensToUnlock);
        }
        
    function withdraw6() public onlyOwner{
        require( sixWith, "With5 first");
        require(block.timestamp.sub(timing)>relaseTime6, "Not yet");
        
        sixWith = false;
        require(Token(tokenAddress).transfer(owner, tokensToUnlock), "Could not transfer tokens.");
        tokens = tokens.sub(tokensToUnlock);  
        }
    
    
    
    
    }