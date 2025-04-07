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





contract DEFISocialLockGaming is Ownable {
    using SafeMath for uint;
    
    event Transferred(address holder, uint amount);
    // DEFISocial token contract address
    address public constant tokenAddress = 0x731A30897bF16597c0D5601205019C947BF15c6E;
    
    uint256 tokens = 0;
    uint256 relaseTime = 60 days;
    uint256 timing ;
    

    function getTiming()  public view returns (uint256){
        return now.sub(timing);
    }
    
    function deposit(uint amountToStake) public onlyOwner{
        require( tokens == 0, "Cannot deposit more Tokens");
        require( amountToStake > 0, "Cannot deposit  Tokens");
        require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        tokens = amountToStake;
        timing = now;
    }
    
    function withdraw() public onlyOwner{
        require( tokens>0, "Deposit first");
        require(now.sub(timing)>relaseTime, "Not yet"); // 1 month locked
        
        require(Token(tokenAddress).transfer(owner, tokens), "Could not transfer tokens.");
        
        tokens = tokens.sub(tokens);
        emit Transferred(owner, tokens);
        }
    
    
    
    
    
    }