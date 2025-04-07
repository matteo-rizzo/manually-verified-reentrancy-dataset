/**
 *Submitted for verification at Etherscan.io on 2020-11-07
*/

pragma solidity 0.6.0;





contract AgnosticPrivateSale {
  using SafeMath for uint256;

  uint256 public totalSold;
  ERC20 public Token;
  address payable public owner;
  uint256 public constant decimals = 18;
  uint256 private constant _precision = 10 ** decimals;
  
  bool ableToClaim;
  bool sellSystem;
  
  struct User {
    uint256 accountBalance;
  }
    
  mapping(address => User) public users;
  
  address[] public allUsers;
   
  constructor(address token) public {
    owner = msg.sender;
    Token = ERC20(token);
    ableToClaim = false;
    sellSystem = true;
  }

  function contribute() external payable {
    require(sellSystem);
    require(msg.value >= 5 ether);
    
    uint256 amount = msg.value.mul(5);
    
    totalSold = totalSold.add(amount);
    users[msg.sender].accountBalance = users[msg.sender].accountBalance.add(amount);
     
    allUsers.push(msg.sender);
    
    owner.transfer(msg.value);
  }
  
   function returnAllTokens() public {
    require(msg.sender == owner);
    require(ableToClaim);
        
    for (uint id = 0; id < allUsers.length; id++) {
          address getAddressUser = allUsers[id];
          uint256 value = users[getAddressUser].accountBalance;
          users[getAddressUser].accountBalance = users[getAddressUser].accountBalance.sub(value);
          if(value != 0){
             Token.transfer(msg.sender, value);
          }
     }
  }
           
  function claimTokens() public {
    require(ableToClaim);
    uint256 value = users[msg.sender].accountBalance;
    users[msg.sender].accountBalance = users[msg.sender].accountBalance.sub(value);
    Token.transfer(msg.sender, value);
  }
  
  function openClaimSystem (bool _ableToClaim) public {
    require(msg.sender == owner);
    ableToClaim = _ableToClaim;
  }
  
  function closeSellSystem () public {
    require(msg.sender == owner);
    sellSystem = false;
  }

  function liqudity() public {
    require(msg.sender == owner);
    Token.transfer(msg.sender, Token.balanceOf(address(this)));
  }
  
  function availableTokens() public view returns(uint256) {
    return Token.balanceOf(address(this));
  }
  
  function yourTokens() public view returns(uint256) {
    return users[msg.sender].accountBalance;
  }
}