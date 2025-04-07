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






contract xStakeToUsdt is Ownable {
    using SafeMath for uint;
    
    address public usdtAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public xstakeAddress = 0xb6aa337C9005FBf3a10Edde47DDde3541adb79Cb;
    
    function swap(uint _amount) payable public {
        require(msg.value >= 1e16, "Invalid ETH fee for swap.");
        owner.transfer(msg.value);
        uint usdtAmount = _amount.div(1e12);
        require(usdtAmount > 0, "Invalid USDT amount to transfer");
        require(Token(xstakeAddress).transferFrom(msg.sender, owner, _amount), "Cannot transfer tokens");
        USDT(usdtAddress).transferFrom(owner, msg.sender, usdtAmount);
    }
    
    function transferAnyERC20Token(address _token, address _to, uint _amount) public onlyOwner {
        Token(_token).transfer(_to, _amount);
    }
    function transferUSDT(address _usdtAddr, address to, uint amount) public onlyOwner {
        USDT(_usdtAddr).transfer(to, amount);
    }
}