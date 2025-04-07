/**
 *Submitted for verification at Etherscan.io on 2021-03-03
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





contract B26_FarmingTokensLocked is Ownable {
    using SafeMath for uint;
    
    event Transferred(address holder, uint amount);
    // B26 token contract address
    address public constant tokenAddress = 0x481dE76d5ab31e28A33B0EA1c1063aDCb5B1769A;
    
    uint256 tokens = 0;
    uint256 relaseTime = 60 days;
    uint256 timing ;
    

    function getTiming()  public view returns (uint256){
        return block.timestamp.sub(timing);
    }
    
    function deposit(uint amountToStake) public onlyOwner{
        require( tokens == 0, "Cannot deposit more Tokens");
        require( amountToStake > 0, "Cannot deposit  Tokens");
        require(Token(tokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        tokens = amountToStake;
        timing = block.timestamp;
    }
    
    function withdraw() public onlyOwner{
        require( tokens>0, "Deposit first");
        require(block.timestamp.sub(timing)>relaseTime, "Not yet"); // 60 days locked
        
        require(Token(tokenAddress).transfer(owner, tokens), "Could not transfer tokens.");
        
        tokens = tokens.sub(tokens);
        emit Transferred(owner, tokens);
        }
    
    
    
    
    
    }