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





contract DEFISocialLockTeam is Ownable {
    using SafeMath for uint;
    
    event Transferred(address holder, uint amount);
    // DEFISocial token contract address
    address public constant tokenAddress = 0x731A30897bF16597c0D5601205019C947BF15c6E;
    
    uint256 tokens = 0;
    bool firstWith = false;
    uint256 relaseTime = 30 days;
    uint256 relaseTime2 = 120 days;
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
        require( firstWith, "Already done");
        require(now.sub(timing)>relaseTime, "Not yet");
        uint256 amount = tokens.div(5);   //20% available after 21 days
        require(Token(tokenAddress).transfer(owner, amount), "Could not transfer tokens.");
        tokens = tokens.sub(amount);
        firstWith = false;
        emit Transferred(owner, amount);
        }
    
    
    function withdraw2() public onlyOwner{
        require(now.sub(timing)>relaseTime2, "Not yet");
        require(Token(tokenAddress).transfer(owner, tokens), "Could not transfer tokens.");
        tokens = tokens.sub(tokens);  //80%available after 4 months
        emit Transferred(owner, tokens);
        }
    
    
    
    
    }