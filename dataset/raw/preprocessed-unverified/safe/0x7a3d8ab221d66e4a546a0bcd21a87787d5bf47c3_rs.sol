pragma solidity ^0.4.18;





contract PepFarmer {

    address public shop = 0x5f277da6734Cb32e182C8252467dF39D6EC424B4;
    address public object = 0x12105bd41f403e33d444049884B000CC8D438AcB;
    address public farmer;
    
    function PepFarmer(){
        farmer = msg.sender;
    }

    function pepFarm() external {
        for (uint8 i = 0; i < 100; i++) {
            CornFarm(shop).buyObject(this);
        }
    }
    
    function reapFarm() external {
        Corn(object).transfer(farmer, Corn(object).balanceOf(this));
    }
    
    function set(address _shop, address _object){
        if(msg.sender == farmer){
            shop = _shop;
            object = _object;
        }
    }
}