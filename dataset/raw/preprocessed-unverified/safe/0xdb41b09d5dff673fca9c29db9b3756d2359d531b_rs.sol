/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

pragma solidity 0.5.17;




contract SZO {
	     event Transfer(address indexed from, address indexed to, uint256 tokens);
       event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

   	   function totalSupply() public view returns (uint256);
       function balanceOf(address tokenOwner) public view returns (uint256 balance);
       function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

       function transfer(address to, uint256 tokens) public returns (bool success);
       
       function approve(address spender, uint256 tokens) public returns (bool success);
       function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
  
	   function createKYCData(bytes32 _KycData1, bytes32 _kycData2,address  _wallet) public returns(uint256);
}

contract WSZO3ndShare is  Ownable {
     SZO wszoToken;
    
     
     constructor() public {
         wszoToken = SZO(0x5538Ac3ce36e73bB851921f2a804b4657b5307bf); // wszo
      }
       
     function transferAllToShareHolder() public onlyOwners returns(bool){
         
            wszoToken.transfer(0x85B4C6180099557aF2787964c651980382D24361,1020000 ether); //1
            wszoToken.transfer(0x85B4C6180099557aF2787964c651980382D24361,673200 ether); //2
            wszoToken.transfer(0x137b159F631A215513DC511901982025e32404C2,408000 ether); //3
            wszoToken.transfer(0x0D49112c7D5ecC8ae1Aa891C681f1f761f7C9E2b,357000 ether); //4
            wszoToken.transfer(0xa7bADCcA8F2B636dCBbD92A42d53cB175ADB7435,323000 ether); //5
            wszoToken.transfer(0x005BaBb7da64B22B21Bac94e0a829CF519Fa236A,113220 ether); //6
            wszoToken.transfer(0x859e099277B88d51Fa3a6Fe49B7B6eE3DBA66dD8,100300 ether); //7
            wszoToken.transfer(0x10c8c627121D018e23b71EE4a00c01b441f35414,71400 ether); //8
            wszoToken.transfer(0x1b2b1FC2aeDc8194B738fc265407a92a909Acf76,68000 ether); //9
            wszoToken.transfer(0x99d2e820264D7353eC260BcD1351c6BCE964468E,68000 ether); //10
            wszoToken.transfer(0x45A05B3f4f5e2cfA19dE42e37f4B3890Bd9f639B,61880 ether); //11
            wszoToken.transfer(0xA461D372AB2F1D8717630014F9F8Cb1B946FB83f,25500 ether); //12
            wszoToken.transfer(0xFEE4d3C5D98Fa7323f5eB9c0819Fa7E6E9519C64,17000 ether); //13
            wszoToken.transfer(0xa79406e200DAA9a605661E883BC393064133940d,17000 ether); //14
            wszoToken.transfer(0x5703948EDB483599624c74aFde5CDf9c1dbb2AdB,13600 ether); //15
            wszoToken.transfer(0x0A43E3fC2c5778D0A9BAcC4752A10609E3d3cf21,6800 ether); //16
            wszoToken.transfer(0x5c89aAa59E3268d7612F2c8DF59A6864b7db90Aa,3740 ether); //17
            wszoToken.transfer(0x2cda19Ac5F75e9b7b48c0bD7A655be29E579a807,3400 ether); //18
            wszoToken.transfer(0xa4f929a976dD20c03CCAB5D7998F9702332F15D7,3400 ether); //19
            wszoToken.transfer(0x0758c1620924a6787af7755Cd528fcC78B86e2C8,17000 ether); //20

     }
     
      function transferToken(address _to,uint256 _amount,address _token) public onlyOwners returns(bool){
          // Emegency Call just in case have problem
          return SZO(_token).transfer(_to,_amount);
      }


      function transfer(address _to,uint256 _amount) public onlyOwners returns(bool){
          // Emegency Call just in case have problem
          return wszoToken.transfer(_to,_amount);
      }

 
}