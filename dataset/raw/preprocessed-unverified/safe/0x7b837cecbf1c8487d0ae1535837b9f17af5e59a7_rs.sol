pragma solidity 0.5.11;






contract MultiMintRaffle is Ownable {

    IRaffle public raffle ;
    constructor(IRaffle _raffle) public {
        raffle = IRaffle(_raffle);
    }


    function mint(address[] memory _users, uint256[] memory _amounts) public onlyOwner {
        require(_users.length == _amounts.length, "input length missmatch");
        for(uint i = 0; i < _users.length; i++) {
            raffle.mint(_users[i], _amounts[i]);
        }
        
    }

}