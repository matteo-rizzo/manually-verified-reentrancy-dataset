pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title Token
 * @dev API interface for interacting with the Token contract 
 */


contract CLUB1 is Ownable {

  using SafeMath for uint256;
  Token token;

  address public CurrentTokenOwner = address(this);
  address tokenAddress = 0x0356e14C2f8De339131C668c1747dEF594467a9A;  // Address of the TOKEN CONTRACT
  uint256 public CurrentPrice = 0;

  mapping (address => bool) prevowners;
  
  event BoughtToken(address indexed to, uint256 LastPrice);

  
  function CLUB1() public payable {
       
      token = Token(tokenAddress); 
            
  }
  
  function checkprevowner(address _owner) public constant returns (bool isOwned) {

    return prevowners[_owner];

  }
  
  
  function () public payable {
   
    buyToken();
   
  }

  /**
  * @dev function that sells available tokens
  */
  function buyToken() public payable {
    
    uint256 lastholdershare = CurrentPrice * 90 / 100;
    uint256 ownershare = msg.value * 10 / 100; 

    require(msg.value > CurrentPrice);    

    BoughtToken(msg.sender, msg.value);

    token.transferFrom(CurrentTokenOwner, msg.sender);      
  
    CurrentPrice = msg.value;
      
    if (lastholdershare > 0) CurrentTokenOwner.transfer(lastholdershare);
    owner.transfer(ownershare);                            
    
    CurrentTokenOwner = msg.sender;                        
    prevowners[msg.sender] = true;
  }

   function resetToken() public payable {
    
    require(msg.sender == tokenAddress);
    uint256 lastholdershare = CurrentPrice * 90 / 100;
        
    BoughtToken(msg.sender, 0);

    CurrentPrice = 0;
    
    CurrentTokenOwner.transfer(lastholdershare);
    CurrentTokenOwner = address(this);
    
  }

   /**
   * @notice Terminate contract and refund to owner
   */
  function destroy() public onlyOwner {
   selfdestruct(owner);
  }

}