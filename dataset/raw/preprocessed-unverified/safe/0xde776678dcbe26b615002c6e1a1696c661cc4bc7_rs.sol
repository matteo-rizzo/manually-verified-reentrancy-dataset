/**
 *Submitted for verification at Etherscan.io on 2020-11-23
*/

/*
  STK3R Presale Contract
   _____ _______ _  ______  _____  
  / ____|__   __| |/ /___ \|  __ \ 
 | (___    | |  | ' /  __) | |__) |
  \___ \   | |  |  <  |__ <|  _  / 
  ____) |  | |  | . \ ___) | | \ \ 
 |_____/   |_|  |_|\_\____/|_|  \_\
 
*/

pragma solidity ^0.6.0;






contract Presale {
    using SafeMath for uint256;

    event Distribute(address participant, uint256 amount);

    uint256 constant private PRESALE_PRICE = 1200; // STK3R presale price is 1200 STK3R/ETH

    IERC20 public token;
    
    address payable public owner;
    
    constructor(address _token) public {
        require(_token != address(0), "Token address required");
        owner = msg.sender;
        token = IERC20(_token);
    }

    receive() external payable {
        require(msg.value > 0, "You need to send more than 0 Ether");
        uint256 amountTobuy = msg.value.mul(PRESALE_PRICE);
        uint256 tokenBalance = token.balanceOf(address(this));
        require(amountTobuy <= tokenBalance, "No enough token in the reserve");
        owner.transfer(msg.value);
        token.transfer(msg.sender, amountTobuy);
        emit Distribute(msg.sender, amountTobuy);
    }

    fallback() external payable {
        require(msg.value > 0, "You need to send more than 0 Ether");
        uint256 amountTobuy = msg.value.mul(PRESALE_PRICE);
        uint256 tokenBalance = token.balanceOf(address(this));
        require(amountTobuy <= tokenBalance, "No enough token in the reserve");
        owner.transfer(msg.value);
        token.transfer(msg.sender, amountTobuy);
        emit Distribute(msg.sender, amountTobuy);
    }
    
    function retrieve() external payable {
        owner.transfer(address(this).balance);
        token.transfer(owner, token.balanceOf(address(this)));
    }

}