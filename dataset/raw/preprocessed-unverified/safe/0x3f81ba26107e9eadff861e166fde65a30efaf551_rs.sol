/**
 *Submitted for verification at Etherscan.io on 2020-12-27
*/

pragma solidity ^0.7.0;
//SPDX-License-Identifier: UNLICENSED



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Presale is Context {
    
    using SafeMath for uint;
    IERC20 token;
    uint public tokensBought;
    bool public isStopped = false;
    address payable owner;

    uint256 public ethSent;
    uint256 tokensPerETH = 80;
    bool transferPaused;
    uint256 public lockedLiquidityAmount;

    mapping(address => uint) ethSpent;

     modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    
    constructor(IERC20 _token) {
        owner = msg.sender; 
        token = _token;
      
    }
    
    
    receive() external payable {
        
        buyTokens();
    }
    

    function buyTokens() public payable {
        require(!isStopped);
        require(msg.value >= 0.1 ether, "You sent less than 0.1 ETH");
        require(msg.value <= 20 ether, "You sent more than 20 ETH");
        require(ethSent < 250 ether, "Hard cap reached");
        require(ethSpent[msg.sender].add(msg.value) <= 20 ether, "You can't buy more");
        uint256 tokens = msg.value.mul(tokensPerETH);
        require(token.balanceOf(address(this)) >= tokens, "Not enough tokens in the contract");
        token.transfer(msg.sender, tokens);
        ethSpent[msg.sender] = ethSpent[msg.sender].add(msg.value);
        tokensBought = tokensBought.add(tokens);
        ethSent = ethSent.add(msg.value);
    }
   
    function userEthSpenttInPresale(address user) external view returns(uint){
        return ethSpent[user];
    }
    
    function pausePresale(bool stopped) external onlyOwner{
        isStopped = stopped;
    }
    
    function withdrawEthBalance() external onlyOwner{
    owner.transfer(address(this).balance); 
    }
    
    function withdrawTokenBalance() external onlyOwner {
    token.transfer(owner, token.balanceOf(address(this)));
    }
}

    

