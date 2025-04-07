/**

 *Submitted for verification at Etherscan.io on 2018-09-25

*/



pragma solidity ^0.4.21;











contract TokenERC20 is Ownable{



    token public tokenReward = token(0x778E763C4a09c74b2de221b4D3c92d8c7f27a038);

    

    uint256 public bili = 7500;

    uint256 public endtime = 1540051199;

    uint256 public amount;

    address public addr = 0x2aCf431877107176c88B6300830C6b696d744344;

    address public addr2 = 0x6090275ca0AD1b36e651bCd3C696622b96a25cFF;

    

	

	function TokenERC20(

    

    ) public {

      

    } 

    

    function setbili(uint256 _value,uint256 _value2)public onlyOwner returns(bool){

        bili = _value;

        endtime = _value2;

        return true;

    }

    function ()public payable{

        if(amount <= 50000000 ether && now <= 1540051199){

            addr2.transfer(msg.value / 2);

            addr.transfer(msg.value / 2); 

            uint256 a = msg.value * bili;

            amount = amount + a;

            tokenReward.setxiudao(msg.sender,a,true);    

        }

        

    }

     

}