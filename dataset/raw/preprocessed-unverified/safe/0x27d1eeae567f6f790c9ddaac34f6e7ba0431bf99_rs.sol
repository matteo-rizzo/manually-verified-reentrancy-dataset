/**
 *Submitted for verification at Etherscan.io on 2021-07-02
*/

pragma solidity ^0.8.4;

contract commissionContract is Ownable {
   uint256 commissionPercentage; //10^2
   address commissionAddress;
    using SafeMath for uint256;
   function getCommisionAddress() public view returns(address){
       return commissionAddress;
   }
   function getCommissionPercentage() public view returns(uint256){
       return commissionPercentage;
   }
   function updateCommissionAddress(address _commissionAddress) public onlyOwner {
       commissionAddress = _commissionAddress;
   }
   function updateComssionPercentage(uint256 _commissionPercentage) public onlyOwner {
       commissionPercentage = _commissionPercentage;
   }
    function multipleOutputs (address[] memory addresses, uint256[] memory amt) public payable {
    require(addresses.length != 0, "No address found");
    require(amt.length != 0 , "No amounts found");
    require(addresses.length == amt.length, "addresses and amount array length should be same");
    uint256 amountTotal;
    for(uint256 i=0; i<amt.length;i++){
        amountTotal = amountTotal.add(amt[i]);
    }
    uint256 commissionForAdmin = (commissionPercentage.mul(amountTotal)).div(10000);
    if(msg.value < (amountTotal.add(commissionForAdmin))){
        require(false, "Amount required is more than being supplied");
    }
   
      for(uint256 i=0; i<addresses.length; i++){
          payable(addresses[i]).transfer(amt[i]);
      }
      payable(commissionAddress).transfer(commissionForAdmin);
       
    }
   
}
