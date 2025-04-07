pragma solidity ^0.4.18;







contract TaxManFarmer {
    using SafeMath for uint256;
    
    bool private reentrancy_lock = false;
    
    address public shop = 0x2dadfF9Fc12bcd339B68692622C3438A5B46EA53;
    address public object = 0xB3EfD0FA677822203BB69623F3DB2Cdc3377d5f2;
    address public taxMan = 0xB503Ec22A950288415F04da3B30f6964dC07a34a;
    
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