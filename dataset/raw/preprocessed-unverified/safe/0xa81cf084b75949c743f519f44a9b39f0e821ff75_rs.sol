/**
 *Submitted for verification at Etherscan.io on 2019-12-09
*/

pragma solidity 0.5.13;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */




contract TokenSwap is Ownable {
    using SafeMath for uint;
    
    // number of new token units per old token
    // 1 token = 1e18 token units
    uint public newTokenUnitsPerOldToken = 1e18;
    
    address public oldTokenAddress;
    address public newTokenAddress;
    
    function setNewTokenUnitsPerOldToken(uint _newTokenUnitsPerOldToken) public onlyOwner {
        newTokenUnitsPerOldToken = _newTokenUnitsPerOldToken;
    }
    
    function setOldTokenAddress(address _oldTokenAddress) public onlyOwner {
        oldTokenAddress = _oldTokenAddress;
    }
    
    function setNewTokenAddress(address _newTokenAddress) public onlyOwner {
        newTokenAddress = _newTokenAddress;
    }
    
    function swapTokens() public {
        // how many tokens the sender has allowed to this contract
        uint allowance = token(oldTokenAddress).allowance(msg.sender, address(this));
        
        // allowance should be greater than 0
        require(allowance > 0);

        // transfer old tokens to contract
        require(token(oldTokenAddress).transferFrom(msg.sender, address(this), allowance));
        
        // calculate new token amount to send according to set rate
        uint amount = allowance.mul(newTokenUnitsPerOldToken).div(1e18);
        
        // transfer new tokens from contract to sender
        require(token(newTokenAddress).transfer(msg.sender, amount));
        
        // burn old tokens
        token(oldTokenAddress).burn(allowance);
    }
    
    // owner can transfer out any ERC20 token from contract
    function transferAnyERC20Token(address tokenAddress, address to, uint tokenUnits) public onlyOwner {
        token(tokenAddress).transfer(to, tokenUnits);
    }
}