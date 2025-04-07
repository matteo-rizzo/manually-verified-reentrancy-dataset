/**
 *Submitted for verification at Etherscan.io on 2020-10-05
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






contract QuickToEthSwap is Ownable {
    using SafeMath for uint;
    
    event EtherDeposited(uint);
    
    address public tokenAddress = 0x76FAf827b0E2E870c8c059e151e4c81CDF8F9873;
    
    uint public tokenDecimals = 18;
    
    uint public weiPerToken = 2e18;
    
    function setTokenAddress(address _tokenAddress) public onlyOwner {
        tokenAddress = _tokenAddress;
    }
    
    function setTokenDecimals(uint _tokenDecimals) public onlyOwner {
        tokenDecimals = _tokenDecimals;
    }
    
    function setWeiPerToken(uint _weiPerToken) public onlyOwner {
        weiPerToken = _weiPerToken;
    }
    
    function swap(address payable sender, uint _amount) internal {
        require(_amount <= 5 * 10**tokenDecimals, "Cannot swap more than 5 tokens!");
        uint weiAmount = _amount.mul(weiPerToken).div(10**tokenDecimals);
        require(weiAmount > 0, "Invalid ETH amount to transfer");
        require(Token(tokenAddress).transferFrom(sender, owner, _amount), "Cannot transfer tokens");
        sender.transfer(weiAmount);
    }
    
    function receiveApproval(address _from, uint _value, bytes memory _extraData) public {
        require(msg.sender == tokenAddress, "Only token contract can execute this function!");
        address payable sender = address(uint160(_from));
        swap(sender, _value);
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