pragma solidity ^0.4.19;







contract TaxManFarmer {
    using SafeMath for uint256;
    
    bool private reentrancy_lock = false;
    
    address public shop = 0x4a1b1d67804D272ba616337A171a93e644f2f672;
    address public object = 0x95986d6fF6Edf1e24d4344D6a27aEA038bE72A7E;
    address public taxMan = 0x4b8C7951fa087B804d1DA7Bc69Dc492f44C4CBf6;
    
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