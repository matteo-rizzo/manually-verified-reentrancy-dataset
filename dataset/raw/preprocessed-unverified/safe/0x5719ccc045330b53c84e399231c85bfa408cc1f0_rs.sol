/**
 *Submitted for verification at Etherscan.io on 2019-07-23
*/

pragma solidity 0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */




/**
 * @title ERC20
 * @dev ERC20 token interface
 */
 contract ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
 }

 contract Faucet is Ownable {
     using SafeMath for uint256;

     /* --- EVENTS --- */

     event TokenExchanged(address receiver, uint etherReceived, uint tokenSent);

     /* --- FIELDS / CONSTANTS --- */

     address public tokenAddress;
     uint16 public exchangeRate; // ETH -> token exchange rate
     uint public exchangeLimit; // Max amount of ether allowed to exchange

     /* --- PUBLIC/EXTERNAL FUNCTIONS --- */

     constructor(address _tokenAddress, uint16 _exchangeRate, uint _exchangeLimit) public {
         tokenAddress = _tokenAddress;
         exchangeRate = _exchangeRate;
         exchangeLimit = _exchangeLimit;
     }

     function() public payable {
         require(msg.value <= exchangeLimit);

         uint denomintator = 100000000000000; // 14 decimals
         uint transferAmount = msg.value.mul(exchangeRate).div(denomintator);
         require(transferAmount > 0);
         require(ERC20(tokenAddress).transfer(msg.sender, transferAmount), "insufficient erc20 token balance");

         emit TokenExchanged(msg.sender, msg.value, transferAmount);
     }

     function withdrawEther(uint amount) onlyOwner public {
         owner.transfer(amount);
     }

     function withdrawToken(uint amount) onlyOwner public {
         ERC20(tokenAddress).transfer(owner, amount);
     }

     function getTokenBalance() public view returns (uint) {
         return ERC20(tokenAddress).balanceOf(this);
     }

     function getEtherBalance() public view returns (uint) {
         return address(this).balance;
     }

     function updateExchangeRate(uint16 newExchangeRate) onlyOwner public {
         exchangeRate = newExchangeRate;
     }

     function updateExchangeLimit(uint newExchangeLimit) onlyOwner public {
         exchangeLimit = newExchangeLimit;
     }
 }