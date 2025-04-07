pragma solidity ^0.4.18;





contract Satoshi {

  using strings for *;

  enum MoodState {happy, sad, angry, thinking, stoked}

  string public whatSatoshiSays;

  string public name;

  MoodState public satoshiMood;

  uint public currentPrice;

  address public currentOwner;

  address private devAddress;  

  



  function Satoshi() public {

    whatSatoshiSays = "My name is Satoshi Nakamoto, creator of Bitcoin!";    

    name = "Satoshi Nakamoto";

    satoshiMood = MoodState.happy;

    currentPrice = 1000000000000000; // includes the fee 

    currentOwner = msg.sender;

    devAddress = msg.sender;

  }

  

  function changeWhatSatoshiSays(string _whatSatoshiSays, MoodState _satoshiMood, string _name) payable public {

    require(msg.value >= currentPrice && _name.toSlice().len() <= 25 && _whatSatoshiSays.toSlice().len() <= 180);

    uint sentAmount = msg.value;

    uint devFee = (sentAmount * 1) / 100; // 1 % fee sent to devs

    uint amountToSendToCurrentOwner = sentAmount - devFee;

    devAddress.transfer(devFee);

    currentOwner.transfer(amountToSendToCurrentOwner);

    currentPrice = (currentPrice * 105) / 100;

    currentOwner = msg.sender;

    whatSatoshiSays = _whatSatoshiSays;    

    satoshiMood = _satoshiMood;

    name = _name;    

  }



  function fetchCurrentSatoshiState() public view returns (string, string, MoodState, address, uint) {

    return (whatSatoshiSays, name, satoshiMood, currentOwner, currentPrice);

  }  

}