/**
 *Submitted for verification at Etherscan.io on 2019-09-05
*/

pragma solidity ^0.4.17;
//Zep





contract KlownGasDrop {


//receivers
    mapping(address => bool) public receivers;
// token balances
    mapping ( address => uint256 ) public balances;
	//amount per receiver (with decimals)
	uint256 amountToClaim = 50000000;
	uint256 public totalSent = 0;
	
	address  _owner;
	address  whoSent;
	uint256 dappBalance;

//debugging breakpoints, quick and easy 
    uint public brpt = 0;
    uint public brpt1 = 0;

    IERC20 currentToken ;


//modifiers	
	modifier onlyOwner() {
      require(msg.sender == _owner);
      _;
  }
    /// Create new - constructor
     function  KlownGasDrop() public {
		_owner = msg.sender;
		dappBalance = 0;
    }

//address of token contract, not token sender!    
	address currentTokenAddress = 0x2462b6481af155709a3044ac1bde096d861a877b;


    //deposit
      function deposit(uint tokens) public onlyOwner {


    // add the deposited tokens into existing balance 
    balances[msg.sender]+= tokens;

    // transfer the tokens from the sender to this contract
    IERC20(currentTokenAddress).transferFrom(msg.sender, address(this), tokens);
    whoSent = msg.sender;
    
  }

function hasReceived(address received)  internal  view returns(bool)
{
    bool result = false;
    if(receivers[received] == true)
        result = true;
    
    return result;
}

uint256 temp = 0;
 /// claim gas drop amount (only once per address)
    function claimGasDrop() public returns(bool) {



		//have they already receivered?
        if(receivers[msg.sender] != true)
	    {

    	    //brpt = 1;
    		if(amountToClaim <= balances[whoSent])
    		{
    		    //brpt = 2; 
    		    balances[whoSent] -= amountToClaim;
    			//brpt = 3;
    			IERC20(currentTokenAddress).transfer(msg.sender, amountToClaim);
    			
    			receivers[msg.sender] = true;
    			totalSent += amountToClaim;
    			
    			//brpt = 4;
    			
    			
    		}

	    }
		

	   
    }


 //which currentToken is used here?
  function setCurrentToken(address currentTokenContract) external onlyOwner {
        currentTokenAddress = currentTokenContract;
        currentToken = IERC20(currentTokenContract);
        dappBalance = currentToken.balanceOf(address(this));
      
  }



 //set amount per gas claim (amount each address will receive)
  function setGasClaim(uint256 amount) external onlyOwner {
    
      amountToClaim = amount;
      
  }
//get amount per gas claim (amount each address will receive)
  function getGasClaimAmount()  public view returns (uint256)  {
    
      return amountToClaim;
      
  }
  
  


}