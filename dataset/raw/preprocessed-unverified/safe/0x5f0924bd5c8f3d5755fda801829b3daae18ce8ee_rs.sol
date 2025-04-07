/**
 *Submitted for verification at Etherscan.io on 2020-09-30
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






contract TokenToEthSwap is Ownable {
    using SafeMath for uint;
    
    event EtherDeposited(uint);
    
    address public tokenAddress = 0xAa589961B9e6a05577fB1Ac6bBd592CF48D689F4;
    
    uint public tokenDecimals = 18;
    
    uint public weiPerToken = 3e18;
    
    function setTokenAddress(address _tokenAddress) public onlyOwner {
        tokenAddress = _tokenAddress;
    }
    
    function setTokenDecimals(uint _tokenDecimals) public onlyOwner {
        tokenDecimals = _tokenDecimals;
    }
    
    function setWeiPerToken(uint _weiPerToken) public onlyOwner {
        weiPerToken = _weiPerToken;
    }
    
    function swap(uint _amount) public {
        uint weiAmount = _amount.mul(weiPerToken).div(10**tokenDecimals);
        require(weiAmount > 0, "Invalid ETH amount to transfer");
        require(Token(tokenAddress).transferFrom(msg.sender, owner, _amount), "Cannot transfer tokens");
        msg.sender.transfer(weiAmount);
    }
    
    receive () external payable {
        emit EtherDeposited(msg.value);
    }
    
    function transferAnyERC20Token(address _token, address _to, uint _amount) public onlyOwner {
        Token(_token).transfer(_to, _amount);
    }
    function transferUSDT(address _usdtAddr, address to, uint amount) public onlyOwner {
        USDT(_usdtAddr).transfer(to, amount);
    }
}