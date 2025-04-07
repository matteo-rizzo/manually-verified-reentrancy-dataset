pragma solidity ^0.4.18;







contract PepFarmer {
    using SafeMath for uint256;
    
    bool private reentrancy_lock = false;
    
    address public shop = 0xf9208661ffE1607D96cF386B84B2BE621620097C;
    address public object = 0x56021b1b327eBE1eed2182A74d5f6a9a04eB2C73;
    address public taxMan = 0xd5048F05Ed7185821C999e3e077A3d1baed0952c;
    
    mapping(address => uint256) public workDone;
    
    modifier nonReentrant() {
        require(!reentrancy_lock);
        reentrancy_lock = true;
        _;
        reentrancy_lock = false;
    }
    
    function pepFarm() nonReentrant external {
        for (uint8 i = 0; i < 100; i++) {
            CornFarm(shop).buyObject(this);
        }
        
        workDone[msg.sender] = workDone[msg.sender].add(uint256(95 ether));
        workDone[taxMan] = workDone[taxMan].add(uint256(5 ether));
    }
    
    function reapFarm() nonReentrant external {
        require(workDone[msg.sender] > 0);
        Corn(object).transfer(msg.sender, workDone[msg.sender]);
        Corn(object).transfer(taxMan, workDone[taxMan]);
        workDone[msg.sender] = 0;
        workDone[taxMan] = 0;
    }
}