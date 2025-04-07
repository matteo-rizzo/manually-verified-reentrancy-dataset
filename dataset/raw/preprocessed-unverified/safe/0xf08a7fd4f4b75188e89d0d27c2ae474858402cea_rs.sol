pragma solidity ^0.4.11;

/**
 * @title SafeMath
    * @dev Math operations with safety checks that throw on error
       */


/**
 * @title Ownable
    * @dev The Ownable contract has an owner address, and provides basic authorization control 
       * functions, this simplifies the implementation of "user permissions". 
          */


/**
 * @title Token
   * @dev interface for interacting with droneshowcoin token
             */


contract DroneShowCoinICOContract is Ownable {
    
    using SafeMath for uint256;
    
    Token token;
    
    uint256 public constant RATE = 650; //tokens per ether
    uint256 public constant CAP = 15000; //cap in ether
    uint256 public constant START = 1510754400; //GMT: Wednesday, November 15, 2017 2:00:00 PM
    uint256 public constant DAYS = 30; //
    
    bool public initialized = false;
    uint256 public raisedAmount = 0;
    uint256 public bonusesGiven = 0;
    uint256 public numberOfTransactions = 0;
    
    event BoughtTokens(address indexed to, uint256 value);
    
    modifier whenSaleIsActive() {
        assert (isActive());
        _;
    }
    
    function DroneShowCoinICOContract(address _tokenAddr) public {
        require(_tokenAddr != 0);
        token = Token(_tokenAddr);
    }
    
    function initialize(uint256 numTokens) public onlyOwner {
        require (initialized == false);
        require (tokensAvailable() == numTokens);
        initialized = true;
    }
    
    function isActive() public constant returns (bool) {
        return (
            initialized == true &&  //check if initialized
            now >= START && //check if after start date
            now <= START.add(DAYS * 1 days) && //check if before end date
            goalReached() == false //check if goal was not reached
        ); // if all of the above are true we are active, else we are not
    }
    
    function goalReached() public constant returns (bool) {
        return (raisedAmount >= CAP * 1 ether);
    }
    
    function () public payable {
        buyTokens();
    }
    
    function buyTokens() public payable whenSaleIsActive {
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount.mul(RATE);
        
        uint256 secondspassed = now - START;
        uint256 dayspassed = secondspassed/(60*60*24);
        uint256 bonusPrcnt = 0;
        if (dayspassed < 7) {
            //first 7 days 20% bonus
            bonusPrcnt = 20;
        } else if (dayspassed < 14) {
            //second week 10% bonus
            bonusPrcnt = 10;
        } else {
            //no bonus
            bonusPrcnt = 0;
        }
        uint256 bonusAmount = (tokens * bonusPrcnt) / 100;
        tokens = tokens.add(bonusAmount);
        BoughtTokens(msg.sender, tokens);
        
        raisedAmount = raisedAmount.add(msg.value);
        bonusesGiven = bonusesGiven.add(bonusAmount);
        numberOfTransactions = numberOfTransactions.add(1);
        token.transfer(msg.sender, tokens);
        
        owner.transfer(msg.value);
        
    }
    
    function tokensAvailable() public constant returns (uint256) {
        return token.balanceOf(this);
    }
    
    function destroy() public onlyOwner {
        uint256 balance = token.balanceOf(this);
        assert (balance > 0);
        token.transfer(owner,balance);
        selfdestruct(owner);
        
    }
}