pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



contract EtherHeroes {
  //ETHEREUM SOLIDITY VERSION 4.19
  //CRYPTOCOLLECTED LTD
  
  //INITIALIZATION VALUES
  address ceoAddress = 0xC0c8Dc6C1485060a72FCb629560371fE09666500;
  struct Hero {
    address currentHeroOwner;
    uint256 currentValue;
   
  }
  Hero[16] data;
  
  //No-Arg Constructor initializes basic low-end values.
  function EtherHeroes() public {
    for (uint i = 0; i < 16; i++) {
     
      data[i].currentValue = 10000000000000000;
      data[i].currentHeroOwner = msg.sender;
    }
  }

  // Function to pay the previous owner.
  //     Neccesary for contract integrity
  function payPreviousOwner(address previousHeroOwner, uint256 currentValue) private {
    previousHeroOwner.transfer(currentValue);
  }
  //Sister function to payPreviousOwner():
  //   Addresses wallet-to-wallet payment totality
  function transactionFee(address, uint256 currentValue) private {
    ceoAddress.transfer(currentValue);
  }
  // Function that handles logic for setting prices and assigning heroes to addresses.
  // Doubles instance value  on purchase.
  // Verify  correct amount of ethereum has been received
  function purchaseHeroForEth(uint uniqueHeroID) public payable returns (uint, uint) {
    require(uniqueHeroID >= 0 && uniqueHeroID <= 15);
    // Set initial price to .02 (ETH)
    if ( data[uniqueHeroID].currentValue == 10000000000000000 ) {
      data[uniqueHeroID].currentValue = 20000000000000000;
    } else {
      // Double price
      data[uniqueHeroID].currentValue = data[uniqueHeroID].currentValue * 2;
    }
    
    require(msg.value >= data[uniqueHeroID].currentValue * uint256(1));
    // Call payPreviousOwner() after purchase.
    payPreviousOwner(data[uniqueHeroID].currentHeroOwner,  (data[uniqueHeroID].currentValue / 10) * (9)); 
    transactionFee(ceoAddress, (data[uniqueHeroID].currentValue / 10) * (1));
    // Assign owner.
    data[uniqueHeroID].currentHeroOwner = msg.sender;
    // Return values for web3js display.
    return (uniqueHeroID, data[uniqueHeroID].currentValue);

  }
  // Gets the current list of heroes, their owners, and prices. 
  function getCurrentHeroOwners() external view returns (address[], uint256[]) {
    address[] memory currentHeroOwners = new address[](16);
    uint256[] memory currentValues =  new uint256[](16);
    for (uint i=0; i<16; i++) {
      currentHeroOwners[i] = (data[i].currentHeroOwner);
      currentValues[i] = (data[i].currentValue);
    }
    return (currentHeroOwners,currentValues);
  }
  
}