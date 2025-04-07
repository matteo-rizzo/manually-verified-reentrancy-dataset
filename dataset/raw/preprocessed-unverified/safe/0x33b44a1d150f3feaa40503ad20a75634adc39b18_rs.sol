pragma solidity ^0.4.17;



contract TimeCapsule is Ownable {
    address public Owner;
    mapping (address=>uint) public deposits;
    uint public openDate;
    
    function initCapsule(uint open) {
        Owner = msg.sender;
        openDate = open;
    }

    function() payable { deposit(); }
    
    function deposit() {
        if( msg.value >= 0.5 ether )
            deposits[msg.sender] += msg.value;
        else throw;
    }
    
    function withdraw(uint amount) {
        if( isOwner() && now >= openDate ) {
            uint max = deposits[msg.sender];
            if( amount <= max && max > 0 )
                msg.sender.send( amount );
        }
    }

    function kill() {
        if( isOwner() && this.balance == 0 )
            suicide( msg.sender );
	}
}