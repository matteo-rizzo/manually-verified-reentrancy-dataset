pragma solidity ^0.4.18;




contract SpyceToken{
  function sendCrowdsaleTokens(address, uint256)  public;
  function setCrowdsaleContract (address) public;
  function burnContributorTokens (address _address) public;
}

contract SpyceCrowdsale is Ownable{
  using SafeMath for uint;

  uint decimals = 18;

  // Token contract address
  SpyceToken public token;

  function SpyceCrowdsale(address _tokenAddress) public{
    token = SpyceToken(_tokenAddress);

    owner = msg.sender;
    token.setCrowdsaleContract(this);

    stageStruct memory buffer;

    buffer.startDate = 0; 
    
    //1522195199 is equivalent to 03/27/2018 @ 11:59pm (UTC)
    buffer.finishDate = 1522195199;
    buffer.tokenPrice = 0.00016 ether;
    buffer.minCap = 675000 ether;
    buffer.maxCap = 150000000 ether;

    stages.push(buffer);
  }

  /* Destribution addresses */
  //All ether will be send to this address: 0x003b43733592eFa879B7154eDE5A4Eea47585f30
  address distributionAddress = 0x003b43733592eFa879B7154eDE5A4Eea47585f30;

  function () public payable {
    require (buy(msg.sender, msg.value, now));
  }


  function buy (address _address, uint _value, uint _time) internal returns(bool) {

    uint currentStage = getCurrentStage(_time);
    
    require(currentStage != 1000);

    uint tokensToSend = _value.mul((uint)(10).pow(decimals))/stages[currentStage].tokenPrice;

    require (tokensToSend.add(stages[currentStage].tokensSold) <= stages[currentStage].maxCap);

    stages[currentStage].tokensSold = stages[currentStage].tokensSold.add(tokensToSend);

    stages[currentStage].ethContributors[_address] = stages[currentStage].ethContributors[_address].add(_value);

    stages[currentStage].ethCollected = stages[currentStage].ethCollected.add(_value);

    token.sendCrowdsaleTokens(_address, tokensToSend);

    autoDistribute(currentStage);

    return true;
  }

  function autoDistribute (uint currentStage) internal {
    if (stages[currentStage].minCap <= stages[currentStage].tokensSold){

      distributionAddress.transfer(stages[currentStage].ethCollected.sub(stages[currentStage].ethSended));

      stages[currentStage].ethSended = stages[currentStage].ethCollected;
    }
  }
  
  
function manualSendTokens (address _address, uint _value) public onlyOwner {

    uint currentStage = getCurrentStage(now);
    require(currentStage != 1000);

    stages[currentStage].tokensSold = stages[currentStage].tokensSold.add(_value.mul((uint)(10).pow(decimals)));

    token.sendCrowdsaleTokens(_address,_value.mul((uint)(10).pow(decimals)));

    autoDistribute(currentStage);
  }
  
  struct stageStruct {
    uint startDate;
    uint finishDate;
    uint tokenPrice;
    uint minCap;
    uint maxCap;
    uint tokensSold;

    uint ethCollected;
    uint ethSended;

    mapping (address => uint) ethContributors; 
  }

  stageStruct[] public stages;


  function addNewStage (uint _start, uint _finish, uint _price, uint _mincap, uint _maxcap) public onlyOwner {
    stageStruct memory buffer;

    buffer.startDate = _start;
    buffer.finishDate = _finish;
    buffer.tokenPrice = _price;
    buffer.minCap = _mincap.mul((uint)(10).pow(decimals));
    buffer.maxCap = _maxcap.mul((uint)(10).pow(decimals));

    stages.push(buffer);
  }
  
  function getCurrentStage (uint _time) public view returns (uint) {
    uint currentStage = 0;
    for (uint i = 0; i < stages.length; i++){
      if (stages[i].startDate < _time && _time <= stages[i].finishDate){
        currentStage = i;
        break;
      }
    }
    if (stages[currentStage].startDate < _time && _time <= stages[currentStage].finishDate){
      return currentStage;
    }else{
      return 1000; //NO ACTIVE STAGE
    }
  }
  
  
  function refund () public {
    uint currentStage = getCurrentStage(now);

    for (uint i = 0; i < currentStage; i++){
      if(stages[i].ethContributors[msg.sender] > 0 && stages[i].tokensSold < stages[i].minCap){
        msg.sender.transfer(stages[i].ethContributors[msg.sender]);
        stages[i].ethContributors[msg.sender] = 0;
      }
    }
  }

}