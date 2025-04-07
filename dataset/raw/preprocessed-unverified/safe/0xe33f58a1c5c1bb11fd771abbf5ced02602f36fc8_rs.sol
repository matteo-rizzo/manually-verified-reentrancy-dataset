/**
 *Submitted for verification at Etherscan.io on 2020-03-07
*/

/**
 *Submitted for verification at Etherscan.io on 2019-09-09
 * BEB dapp for www.betbeb.com
*/
pragma solidity^0.4.24;  




contract BEBchain is Ownable{
     uint256 BuyAmount;
     tokenTransfer public bebTokenTransfer; //´ú±ÒBET
     function BEBchain(address _tokenAddress){
         bebTokenTransfer = tokenTransfer(_tokenAddress);
     }
     function sell(address _addr,uint256 _value)onlyOwner{
         uint256 AA=_value*995/1000;
         bebTokenTransfer.transfer(_addr,AA);
         BuyAmount+=_value;
     }
     function buy(uint256 _value)public{
         bebTokenTransfer.transferFrom(msg.sender,address(this),_value);//×ªÈëUSDT
         BuyAmount-=_value;
     }
     function setBuy(uint256 _value)onlyOwner{
         uint256 AAA=_value*1000000;
         BuyAmount+=AAA;
     }
    function getbuy() public view returns(uint256){
         return BuyAmount;
    }
     function withdrawAmount(uint256 _usdt)onlyOwner{
       bebTokenTransfer.transfer(owner,_usdt);
    }
    function ()payable{
        
    }
}