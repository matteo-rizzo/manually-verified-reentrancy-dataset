pragma solidity ^0.4.18;

//credit given to original creator of the cornfarm contract and the original taxman contract
//to view how many of a specific token you have in the contract use the userInventory option in MEW.
//First address box copy paste in your eth address.  Second address box is the contract address of the Ethercraft item you want to check.    
//WorkDone = # of that token you have in the farm contract * 10^18.








contract FreeTaxManFarmer {
    using SafeMath for uint256;
    
    bool private reentrancy_lock = false;

    struct tokenInv {
      uint256 workDone;
    }
    
    mapping(address => mapping(address => tokenInv)) public userInventory;
    
    modifier nonReentrant() {
        require(!reentrancy_lock);
        reentrancy_lock = true;
        _;
        reentrancy_lock = false;
    }
    
    function pepFarm(address item_shop_address, address token_address, uint256 buy_amount) nonReentrant external {
        for (uint8 i = 0; i < buy_amount; i++) {
            CornFarm(item_shop_address).buyObject(this);
        }
        userInventory[msg.sender][token_address].workDone = userInventory[msg.sender][token_address].workDone.add(uint256(buy_amount * 10**18));
    }
    
    function reapFarm(address token_address) nonReentrant external {
        require(userInventory[msg.sender][token_address].workDone > 0);
        Corn(token_address).transfer(msg.sender, userInventory[msg.sender][token_address].workDone);
        userInventory[msg.sender][token_address].workDone = 0;
    }

}