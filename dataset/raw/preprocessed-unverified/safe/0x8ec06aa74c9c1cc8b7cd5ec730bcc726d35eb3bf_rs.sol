pragma solidity ^0.4.18;


contract Dragon {
    
    function transfer(address receiver, uint amount)returns(bool ok);
    function balanceOf( address _address )returns(uint256);

    
}








contract DragonLock is Ownable {
    
    using SafeMath for uint;
   
    address public dataentryclerk;
    Dragon public tokenreward; 
    
    
    mapping ( address => uint ) public dragonBalance;
   
    
    uint public TimeLock;
 
    
    
    
     modifier onlyDataEntryClerk () {
        require ( msg.sender == dataentryclerk );
        _;
    }
    
    function DragonLock (){
        
        tokenreward = Dragon (  0x814f67fa286f7572b041d041b1d99b432c9155ee ); // dragon token address
        TimeLock = now + 90 days;
       
        owner = msg.sender;
        dataentryclerk = msg.sender;
        
    }
    
    
    //allows token holders to withdar their dragons after timelock expires
    function withdrawDragons(){
        
        require ( now > TimeLock );
        uint bal = dragonBalance [ msg.sender ];
        dragonBalance [ msg.sender ] = 0;
        tokenreward.transfer ( msg.sender , bal );
        
    }
    
    
    // manually enter dragon credit to dragon lock  - remember to add 8 extra zeros to compensate for 8 dragon decimals
    function creditDragon ( address tokenholder, uint amount ) onlyDataEntryClerk {
        
        require ( tokenholder != 0x00 );
        dragonBalance [ tokenholder ] = dragonBalance [ tokenholder ].add(amount);
        
    }
    
    //Used in case data entry clerk makes an error crediting address
    function resetDragonBalance ( address tokenholder, uint amount ) onlyOwner {
        
        require ( tokenholder != 0x00 );
        dragonBalance [ tokenholder ] = 0;
        
    }
   
    // transfer ownership of this contract
    function transferOwnership ( address _newowner ) onlyOwner {
        
        require ( _newowner != 0x00 );
        owner = _newowner;
        
    }
    
    
    function transferDataEntryClerk ( address _dataentryclerk ) onlyOwner {
        
        require ( _dataentryclerk != 0x00 );
        dataentryclerk = _dataentryclerk;
        
    }
    
   
}