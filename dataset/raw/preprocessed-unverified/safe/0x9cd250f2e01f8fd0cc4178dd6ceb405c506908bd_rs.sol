/**

 *Submitted for verification at Etherscan.io on 2019-02-27

*/



pragma solidity ^0.5.4;



contract FrenchIco_Coprorate is Ownable {

    

    bool internal PauseAllContracts= false;

    uint public maxAmount;

    mapping(address => uint) internal role;

    

    event WhitelistedAddress(address addr, uint _role);



/** GENERAL STOPPABLE

  * All the Project are stoppable by the Company

  **/

 

    function GeneralPause() onlyOwner external {

        if (PauseAllContracts==false) {PauseAllContracts=true;}

        else {PauseAllContracts=false;}

    }

    

    function setupMaxAmount(uint _maxAmount) onlyOwner external {

        maxAmount = _maxAmount;

    }





/** ROLE ATTRIBUTION

     * @ Not registred = 0

     * @ STANDARD = 1

     * @ PREMIUM = 2

     * @ PREMIUM PRO = 3

      */   

   

    function RoleSetup(address addr, uint _role) onlyOwner public {

         role[addr]= _role;

         emit WhitelistedAddress(addr, _role);

      }

      

    function newMember() public payable {

         require (role[msg.sender]==0,"user has to be new");

         role[msg.sender]= 1;

         owner.transfer(msg.value);

         emit WhitelistedAddress(msg.sender, 1);

      }

      

/** USABLE BY EXTERNAL CONTRACT*/ 

	     

    function isGeneralPaused() external view returns (bool) {return PauseAllContracts;}

    function GetRole(address addr) external view returns (uint) {return role[addr];}

    function GetWallet_FRENCHICO() external view returns (address) {return owner;}

    function GetMaxAmount() external view returns (uint) {return maxAmount;}



}