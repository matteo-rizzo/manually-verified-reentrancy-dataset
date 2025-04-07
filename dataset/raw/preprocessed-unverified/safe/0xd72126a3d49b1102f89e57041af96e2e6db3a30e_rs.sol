pragma solidity 0.6.4;









contract SWAPCONTRACT{
    
   using SafeMath for uint256;
    
   address public V1;
   address public V2;
   bool swapEnabled;
   address administrator;
   
   constructor() public {
       
	    administrator = msg.sender;
		swapEnabled = false;
		
	}
	
//======================================ADMINSTRATION=========================================//

	modifier onlyCreator() {
        require(msg.sender == administrator, "Ownable: caller is not the administrator");
        _;
    }
   
   function tokenConfig(address _v1Address, address _v2Address) public onlyCreator returns(bool){
       require(_v1Address != address(0) && _v2Address != address(0), "Invalid address has been set");
       V1 = _v1Address;
       V2 = _v2Address;
       return true;
       
   }
   
   
   function swapStatus(bool _status) public onlyCreator returns(bool){
       require(V1 != address(0) && V2 != address(0), "V1 and V2 addresses are not set up yet");
       swapEnabled = _status;
   }
   
   
   
   
   function swap(uint256 _amount) external returns(bool){
       
       require(swapEnabled, "Swap not yet initialized");
       require(_amount > 0, "Invalid amount to swap");
       require(IERC20(V1).balanceOf(msg.sender) >= _amount, "You cannot swap more than what you hold");
       require(IERC20(V2).balanceOf(address(this)) >= _amount, "Insufficient amount of tokens to be swapped for");
       require(IERC20(V1).allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance given to contract");
       
       require(IERC20(V1).transferFrom(msg.sender, address(this), _amount), "Transaction failed on root");
       require(IERC20(V2).transfer(msg.sender, _amount), "Transaction failed from base");
       
       return true;
       
   }
   
   function swapAll() external returns(bool){
       
       require(swapEnabled, "Swap not yet initialized");
       uint v1userbalance = IERC20(V1).balanceOf(msg.sender);
       uint v2contractbalance = IERC20(V2).balanceOf(address(this));
       
       require(v1userbalance > 0, "You cannot swap on zero balance");
       require(v2contractbalance >= v1userbalance, "Insufficient amount of tokens to be swapped for");
       require(IERC20(V1).allowance(msg.sender, address(this)) >= v1userbalance, "Insufficient allowance given to contract");
       
       require(IERC20(V1).transferFrom(msg.sender, address(this), v1userbalance), "Transaction failed on root");
       require(IERC20(V2).transfer(msg.sender, v1userbalance), "Transaction failed from base");
       
       return true;
       
   }
   
   
   function GetLeftOverV1() public onlyCreator returns(bool){
      
      require(administrator != address(0));
      require(administrator != address(this));
      require(V1 != address(0) && V2 != address(0), "V1 address not set up yet");
      uint bal = IERC20(V1).balanceOf(address(this));
      require(IERC20(V1).transfer(administrator, bal), "Transaction failed");
      
  }
  
  function GetLeftOverV2() public onlyCreator returns(bool){
      
      require(administrator != address(0));
      require(administrator != address(this));
      require(V1 != address(0) && V2 != address(0), "V1 address not set up yet");
      uint bal = IERC20(V2).balanceOf(address(this));
      require(IERC20(V2).transfer(administrator, bal), "Transaction failed");
      
  }
   
    
}