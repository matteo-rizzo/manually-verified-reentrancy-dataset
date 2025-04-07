pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



contract EtherMemes {
  //ETHEREUM SOLIDITY VERSION 4.19
  //CRYPTOCOLLECTED LTD
  
  //INITIALIZATION VALUES
  address ceoAddress = 0xc10A6AedE9564efcDC5E842772313f0669D79497;
  struct Sergey {
    address memeHolder;
    uint256 currentValue;
   
  }
  Sergey[32] data;
  
  //No-Arg Constructor initializes basic low-end values.
  function EtherMemes() public {
    for (uint i = 0; i < 32; i++) {
     
      data[i].currentValue = 15000000000000000;
      data[i].memeHolder = msg.sender;
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
  // Function that handles logic for setting prices and assigning collectibles to addresses.
  // Doubles instance value  on purchase.
  // Verify  correct amount of ethereum has been received
  function purchaseCollectible(uint uniqueCollectibleID) public payable returns (uint, uint) {
    require(uniqueCollectibleID >= 0 && uniqueCollectibleID <= 31);
    // Set initial price to .02 (ETH)
    if ( data[uniqueCollectibleID].currentValue == 15000000000000000 ) {
      data[uniqueCollectibleID].currentValue = 30000000000000000;
    } else {
      // Double price
      data[uniqueCollectibleID].currentValue = data[uniqueCollectibleID].currentValue * 2;
    }
    
    require(msg.value >= data[uniqueCollectibleID].currentValue * uint256(1));
    // Call payPreviousOwner() after purchase.
    payPreviousOwner(data[uniqueCollectibleID].memeHolder,  (data[uniqueCollectibleID].currentValue / 10) * (8)); 
    transactionFee(ceoAddress, (data[uniqueCollectibleID].currentValue / 10) * (2));
    // Assign owner.
    data[uniqueCollectibleID].memeHolder = msg.sender;
    // Return values for web3js display.
    return (uniqueCollectibleID, data[uniqueCollectibleID].currentValue);

  }
  // Gets the current list of heroes, their owners, and prices. 
  function getMemeHolders() external view returns (address[], uint256[]) {
    address[] memory memeHolders = new address[](32);
    uint256[] memory currentValues =  new uint256[](32);
    for (uint i=0; i<32; i++) {
      memeHolders[i] = (data[i].memeHolder);
      currentValues[i] = (data[i].currentValue);
    }
    return (memeHolders,currentValues);
  }
  
}