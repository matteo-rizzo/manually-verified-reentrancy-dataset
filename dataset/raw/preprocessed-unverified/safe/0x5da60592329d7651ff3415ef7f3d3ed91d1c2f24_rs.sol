/**
 *Submitted for verification at Etherscan.io on 2019-11-15
*/

pragma solidity 0.4.25;



contract StockShares is Ownable {
    event Transfer(address indexed fromAddress, uint256 value);
    event Withdraw(address indexed toAddress, uint256 value);
    
    function () payable public {
        require(msg.value > 0);
        require(msg.sender != address(0));
        emit Transfer(msg.sender, msg.value);
    }
    
    function withdraw (address toAddress, uint256 amount) onlyOwner public  {
        require(amount > 0);
        require(address(this).balance >= amount);
        require(toAddress != address(0));
        toAddress.transfer(amount);
        emit Withdraw(toAddress, amount);
    }
    
}