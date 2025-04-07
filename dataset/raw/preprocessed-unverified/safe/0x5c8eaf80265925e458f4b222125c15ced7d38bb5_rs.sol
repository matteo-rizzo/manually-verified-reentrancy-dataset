/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity 0.5.10;



contract S1ERC20 {
	   event Transfer(address indexed from, address indexed to, uint256 tokens);
       event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

   	   function totalSupply() public view returns (uint256);
       function balanceOf(address tokenOwner) public view returns (uint256 balance);
       function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

       function transfer(address to, uint256 tokens) public returns (bool success);
       
       function approve(address spender, uint256 tokens) public returns (bool success);
       function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
       
       function intTransfer(address _from, address _to, uint256 _amount) external returns(bool);
}

contract ShuttleOne_InternalTran is Ownable {
    
    S1ERC20  public wdai;
    S1ERC20  public szo;
    address public feeAddr;
    address public feeSZOAddr;
    constructor() public {
         wdai = S1ERC20(0x76eA49614b6c34194e441Fd8027c93e71AFB199a); // wdai address
     }
     
     function setSZOAddr(address _addr) public onlyOwners returns (bool){
         szo = S1ERC20(_addr);
     }
     
     function setFeeAddr(address _addr) public onlyOwners returns (bool){
         feeAddr = _addr;
         return true;
     }
     
     function setSZOFeeAddr(address _addr) public onlyOwners returns (bool){
         feeSZOAddr = _addr;
     }
     
   function transferWithFee(address _from, address _to, uint256 _value,uint256 _fee) external onlyOwners returns(bool){
        wdai.intTransfer(_from,_to,_value - _fee);
        wdai.intTransfer(_from,feeAddr,_fee);
        return true;
   }   
   
   function transferFeeWithSZO(address _from, address _to, uint256 _value,uint256 _fee) external onlyOwners returns(bool){
        wdai.intTransfer(_from,_to,_value);
        szo.intTransfer(_from,feeSZOAddr,_fee);
        return true;
   }   
}