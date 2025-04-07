/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

/**
 *Submitted for verification at Etherscan.io on 2020-10-08
*/

pragma solidity 0.6.12;

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





contract DEFISocialLockReserves is Ownable {
    using SafeMath for uint;
    
    event Transferred(address holder, uint amount);
    // DEFISocial token contract address
    address public constant tokenAddress = 0x731A30897bF16597c0D5601205019C947BF15c6E;
    
    uint256 tokens = 0;
    bool firstWith =  false;
    bool secondWith = false;
    bool thirdWith =  false;
    uint256 relaseTime = 30 days;
    uint256 relaseTime2 = 120 days;
    uint256 relaseTime3 = 180 days;
    uint256 timing ;
    

    function getTiming()  public view returns (uint256){
        return now.sub(timing);
    }
    
    function deposit(uint amountToStake) public onlyOwner{
        require( tokens == 0, "Cannot deposit more Tokens");
        require( amountToStake > 0, "Cannot deposit  Tokens");
        require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        tokens = amountToStake;
        firstWith = true;
        timing = now;
    }
    
    function withdraw1() public onlyOwner{
        require( firstWith, "Deposit first");
        require(now.sub(timing)>relaseTime, "Not yet");
        uint256 amount = tokens.div(3);   //33% available after 30 days
        require(Token(tokenAddress).transfer(owner, amount), "Could not transfer tokens.");
        tokens = tokens.sub(amount);
        firstWith = false;
        secondWith = true;
        emit Transferred(owner, amount);
        }
    
    
    function withdraw2() public onlyOwner{
        require( secondWith, "With1 first");
        require(now.sub(timing)>relaseTime2, "Not yet");
        uint256 amount = tokens.div(2); //33% available after 
        require(Token(tokenAddress).transfer(owner, amount), "Could not transfer tokens.");
        tokens = tokens.sub(amount);  //80%available after 120 days
        emit Transferred(owner, amount);
        secondWith = false;
        thirdWith = true;
        }
        
    function withdraw3() public onlyOwner{
        require( thirdWith, "With2 first");
        require(now.sub(timing)>relaseTime3, "Not yet");
        require(Token(tokenAddress).transfer(owner, tokens), "Could not transfer tokens.");
        tokens = tokens.sub(tokens);  //33% available after 180 days
        emit Transferred(owner, tokens);
        }
    
    
    
    
    }