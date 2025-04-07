pragma solidity 0.4.24;








contract ETHCDISTRIBUTION is Owned{
    address public ETCHaddress;
    token public  rewardToken;
    //uint public ContractTokenBalance = rewardToken.balanceOf(this);
    
    
    constructor() public{
    ETCHaddress = 0x673F2F89840b93D2b2b0100f9E35e5CE371Faf54;
    rewardToken = token(ETCHaddress);
    
    }
    
    function() public payable{
        uint tokensToBeSent = msg.value * 2000;
        require(rewardToken.balanceOf(this)>= tokensToBeSent);
        rewardToken.transfer(msg.sender, tokensToBeSent);
        uint amount = address(this).balance;
        owner.transfer(amount);
        
    }
    
}