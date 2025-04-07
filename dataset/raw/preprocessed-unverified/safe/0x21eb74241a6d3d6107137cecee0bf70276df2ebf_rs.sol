/**
 *Submitted for verification at Etherscan.io on 2021-06-18
*/

pragma solidity ^0.8.0;


/*

XAdspace - Dutch auction digital advertisement spaces 

  v0.15.4

*/
                                                                                 
  
 





  
  
/**
 * 
 * 
 *  Dutch auction digital advertisement spaces
 *
 * 
 */
contract XAdspace {

   mapping(bytes32 => AdProgram) public adPrograms;  

   mapping(address => uint256) public adProgramNonces;  
   

   //polygon network, 50000 blocks per day approx
   uint256 public adspaceAuctionTimeBlocks = 50000 * 7;
 
   struct AdProgram {

     address programOwner;
     string programName;
     address paymentDelegate; //address to recieve payment      
     address token;

     address renter;
     uint256 startPrice;
     uint256 rentStartBlock;
     string adURL; 

     bool newRentalsAllowed;
      
   }

   event BoughtAdspace(bytes32 programId, address programOwner, address token, uint256 tokens, string adURL, address renter);
   event CreatedAdProgram(bytes32 programId, address programOwner, address token, uint256 tokens, string adURL);


   
  constructor( uint256 _timeBlocks )   {  
    adspaceAuctionTimeBlocks = _timeBlocks;
  }

   
   

  function createAdProgram(address token, uint256 startPrice, string calldata programName, string calldata initialUrl ) public returns (bool) {
    
    address from = msg.sender; 
 
    bytes32 programId = keccak256(abi.encodePacked(from, adProgramNonces[from]++));

    require( !adspaceIsDefined(programId) );

    adPrograms[programId] = AdProgram( from, programName, from, token, address(0), startPrice, block.number, initialUrl, true);

    require( adspaceIsDefined(programId) );

    emit CreatedAdProgram(programId, from, token, startPrice, initialUrl);

    return true;
  }


  function buyAdspace(bytes32 programId, address token, uint256 tokens, string calldata adURL) public returns (bool) {
     

    address from = msg.sender;

    require(adspaceIsDefined(programId), 'That adspace does not exist');
    require(adPrograms[programId].newRentalsAllowed == true, 'New rentals disallowed');


    uint256 remainingAdspaceValue = getRemainingAdspaceValue(programId);
 
    if( remainingAdspaceValue > 0  ){  
      //need to pay off the previous owner to refund   for the rest of their time that remained 
       IERC20(adPrograms[programId].token).transferFrom(from, adPrograms[programId].renter, remainingAdspaceValue );
    }
 
    uint256 rentalPremium = getAdspaceRentalPremium(programId);

    if( rentalPremium > 0 ){ 
      //need to pay the adspace owner the rental premium 
      IERC20(adPrograms[programId].token).transferFrom(from, adPrograms[programId].paymentDelegate, rentalPremium );
    }

    adPrograms[programId].renter = from;
    adPrograms[programId].adURL = adURL;
    adPrograms[programId].startPrice = remainingAdspaceValue + rentalPremium;
    adPrograms[programId].rentStartBlock = block.number;

    //make sure the buyer explicity authorizes these values in the input parameters 
    require( token == adPrograms[programId].token );
    require( tokens >= remainingAdspaceValue + rentalPremium );

    emit BoughtAdspace(programId, adPrograms[programId].programOwner, token, remainingAdspaceValue + rentalPremium, adURL, from);


    return true;
   

  }


  function setPaymentDelegate( bytes32 programId, address delegate ) public returns (bool) {
     
      require(adPrograms[programId].programOwner == msg.sender);

      require(adspaceIsDefined(programId));
      
      adPrograms[programId].paymentDelegate = delegate;

      return true; 
  }

  function setNewRentalsAllowed(  bytes32 programId, bool allowed ) public returns (bool) {
     
      require(adPrograms[programId].programOwner == msg.sender);

      require(adspaceIsDefined(programId));
      
      adPrograms[programId].newRentalsAllowed = allowed;

      return true; 
  }


  //can always set price, but can never be lower than what the  current space owners's 
  function setPriceForAdspace(bytes32 programId, uint256 newPrice) public returns (bool) {
     
       
      require(adPrograms[programId].programOwner == msg.sender);

      require(adspaceIsDefined(programId));
     
      //must be expired, or must be no bounty to pay to the previous renter 
      require ( getRemainingAdspaceValue(programId) == 0);

      adPrograms[programId].startPrice = newPrice;

      return true; 
  }

  function setTokenForAdspace(bytes32 programId, address newToken) public returns (bool) {
 
      require(adPrograms[programId].programOwner == msg.sender);

      require(adspaceIsDefined(programId));
      
      //must be expired, or must be no bounty to pay to the previous renter 
      require ( getRemainingAdspaceValue(programId) == 0);

      adPrograms[programId].token = newToken;

      return true; 
  }


  function adspaceTimeRemaining( bytes32 programId ) public view returns (uint256){

      uint256 expirationBlock = adPrograms[programId].rentStartBlock + adspaceAuctionTimeBlocks;


       if(block.number <= expirationBlock){
         return expirationBlock - block.number; 
       }

       return 0;
     
  }
 
  function adspaceIsDefined( bytes32 programId ) public view returns (bool){
     
      return adPrograms[programId].token != address(0x0)  ;
  }

  
   
  function getRemainingAdspaceValue( bytes32 programId ) public view returns (uint256){
      if(adspaceIsDefined(programId) && adPrograms[programId].renter != address(0x0)){
  
        uint256 blocksRemaining = adspaceTimeRemaining(programId);
 
        return (2 * adPrograms[programId].startPrice * blocksRemaining / adspaceAuctionTimeBlocks);
         
      }

      return 0;
  }
 
  function getAdspaceRentalPremium( bytes32 programId ) public view returns (uint256){
      if(adspaceIsDefined(programId) && adPrograms[programId].renter != address(0x0)){

             uint256 blocksRemaining = adspaceTimeRemaining(programId);
  
        return (adPrograms[programId].startPrice /2) +  (adPrograms[programId].startPrice  )  * (  blocksRemaining / adspaceAuctionTimeBlocks);
         
      }

      return  adPrograms[programId].startPrice  ;
  }
 
    
   
     // ------------------------------------------------------------------------

    // Don't accept ETH

    // ------------------------------------------------------------------------
 
    fallback() external payable { revert(); }
    receive() external payable { revert(); }
   

}