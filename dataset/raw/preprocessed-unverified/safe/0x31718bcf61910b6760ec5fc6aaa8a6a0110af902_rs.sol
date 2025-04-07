pragma solidity ^0.4.18;







contract PepFarmer {
    using SafeMath for uint256;
 
    address public shop = 0x5f277da6734Cb32e182C8252467dF39D6EC424B4;
    address public object = 0x12105bd41f403e33d444049884B000CC8D438AcB;

    mapping(address => uint256) public workDone;
    
    function pepFarm() external {
        for (uint8 i = 0; i < 100; i++) {
            CornFarm(shop).buyObject(this);
        }
        
        workDone[msg.sender] = workDone[msg.sender].add(uint256(100 ether));
    }
    
    function reapFarm() external {
        require(workDone[msg.sender] > 0);
        Corn(object).transfer(msg.sender, workDone[msg.sender]);
        workDone[msg.sender] = 0;
    }
}