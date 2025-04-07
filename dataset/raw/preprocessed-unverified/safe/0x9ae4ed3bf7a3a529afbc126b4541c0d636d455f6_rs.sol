pragma solidity 0.4.19;

/*

  Copyright 2018 EasyTrade.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

contract Token {
    
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint balance) {}
    
    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint _value) public returns (bool success) {}

    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint _value) public returns (bool success) {}
    
    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint remaining) {}
}



contract EtherToken is Token {

    /// @dev Buys tokens with Ether, exchanging them 1:1.
    function deposit()
        public
        payable
    {}

    /// @dev Sells tokens in exchange for Ether, exchanging them 1:1.
    /// @param amount Number of tokens to sell.
    function withdraw(uint amount)
        public
    {}
}

contract Exchange {

    /// @dev Fills the input order.
    /// @param orderAddresses Array of order&#39;s maker, taker, makerToken, takerToken, and feeRecipient.
    /// @param orderValues Array of order&#39;s makerTokenAmount, takerTokenAmount, makerFee, takerFee, expirationTimestampInSec, and salt.
    /// @param fillTakerTokenAmount Desired amount of takerToken to fill.
    /// @param shouldThrowOnInsufficientBalanceOrAllowance Test if transfer will fail before attempting.
    /// @param v ECDSA signature parameter v.
    /// @param r ECDSA signature parameters r.
    /// @param s ECDSA signature parameters s.
    /// @return Total amount of takerToken filled in trade.
    function fillOrder(
          address[5] orderAddresses,
          uint[6] orderValues,
          uint fillTakerTokenAmount,
          bool shouldThrowOnInsufficientBalanceOrAllowance,
          uint8 v,
          bytes32 r,
          bytes32 s)
          public
          returns (uint filledTakerTokenAmount)
    {}

    /*
    * Constant public functions
    */
    
    /// @dev Calculates Keccak-256 hash of order with specified parameters.
    /// @param orderAddresses Array of order&#39;s maker, taker, makerToken, takerToken, and feeRecipient.
    /// @param orderValues Array of order&#39;s makerTokenAmount, takerTokenAmount, makerFee, takerFee, expirationTimestampInSec, and salt.
    /// @return Keccak-256 hash of order.
    function getOrderHash(address[5] orderAddresses, uint[6] orderValues)
        public
        constant
        returns (bytes32)
    {}
    
     
    /// @dev Calculates the sum of values already filled and cancelled for a given order.
    /// @param orderHash The Keccak-256 hash of the given order.
    /// @return Sum of values already filled and cancelled.
    function getUnavailableTakerTokenAmount(bytes32 orderHash)
        public
        constant
        returns (uint)
    {}
}

contract EtherDelta {
  address public feeAccount; //the account that will receive fees
  uint public feeTake; //percentage times (1 ether)
  
  function deposit() public payable {}

  function withdraw(uint amount) public {}

  function depositToken(address token, uint amount) public {}

  function withdrawToken(address token, uint amount) public {}

  function trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) public {}

  function availableVolume(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) constant returns(uint) {}
}





contract EasyTrade {
    
  string constant public VERSION = "1.0.0";
  address constant public ZRX_TOKEN_ADDR = 0xe41d2489571d322189246dafa5ebde1f4699f498;
  
  address public admin; // Admin address
  address public feeAccount; // Account that will receive the fee
  uint public serviceFee; // Percentage times (1 ether)
  uint public collectedFee = 0; // Total of fees accumulated
 
  event FillSellOrder(address account, address token, uint tokens, uint ethers, uint tokensSold, uint ethersObtained, uint tokensRefunded);
  event FillBuyOrder(address account, address token, uint tokens, uint ethers, uint tokensObtained, uint ethersSpent, uint ethersRefunded);
  
  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }
  
  modifier onlyFeeAccount() {
    require(msg.sender == feeAccount);
    _;
  }
 
  function EasyTrade(
    address admin_,
    address feeAccount_,
    uint serviceFee_) 
  {
    admin = admin_;
    feeAccount = feeAccount_;
    serviceFee = serviceFee_;
  } 
    
  /// @dev For exchange contracts that send ethers back.
  function() public payable { 
      //Only accepts payments from 0x Wrapped Ether or EtherDelta
      require(msg.sender == ZrxTrader.getWethAddress() || msg.sender == EtherDeltaTrader.getEtherDeltaAddresss());
  }

  /// @dev Set the new admin. Only admin can set the new admin.
  /// @param admin_ Address of the new admin.
  function changeAdmin(address admin_) public onlyAdmin {
    admin = admin_;
  }
  
  /// @dev Set the new fee account. Only admin can set the new fee account.
  /// @param feeAccount_ Address of the new fee account.
  function changeFeeAccount(address feeAccount_) public onlyAdmin {
    feeAccount = feeAccount_;
  }

  /// @dev Set the service fee. Only admin can set the new fee. Service fee can only be reduced, never increased
  /// @param serviceFee_ Percentage times (1 ether).
  function changeFeePercentage(uint serviceFee_) public onlyAdmin {
    require(serviceFee_ < serviceFee);
    serviceFee = serviceFee_;
  }
  
  /// @dev Creates an order to sell a token. 
  /// @notice Needs first to call Token(tokend_address).approve(this, tokens_) so the contract can trade the tokens.
  /// @param token Address of the token to sell.
  /// @param tokensTotal Amount of the token to sell.
  /// @param ethersTotal Amount of ethers to get.
  /// @param exchanges Exchanges of each order (0: EtherDelta 1: 0x).
  /// @param ethersTotal Amount of ethers to get.
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param exchangeFees Array of exchange fees to fill in orders.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  function createSellOrder(
    address token, 
    uint tokensTotal, 
    uint ethersTotal,
    uint8[] exchanges,
    address[5][] orderAddresses,
    uint[6][] orderValues,
    uint[] exchangeFees,
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  ) public
  {
    
    //Transfer tokens to contract so it can sell them.
    require(Token(token).transferFrom(msg.sender, this, tokensTotal));
    
    uint ethersObtained;
    uint tokensSold;
    uint tokensRefunded = tokensTotal;
    
    (ethersObtained, tokensSold) = fillOrdersForSellRequest(
      tokensTotal,
      exchanges,
      orderAddresses,
      orderValues,
      exchangeFees,
      v,
      r,
      s
    );
    
    //We make sure that at least one order had some amount filled
    require(ethersObtained > 0 && tokensSold >0);
    
    //Check that the price of what was sold is not smaller than the min agreed
    require(SafeMath.safeDiv(ethersTotal, tokensTotal) <= SafeMath.safeDiv(ethersObtained, tokensSold));
    
    //Substracts the tokens sold
    tokensRefunded = SafeMath.safeSub(tokensTotal, tokensSold);
    
    //Return tokens not sold 
    if(tokensRefunded > 0) 
     require(Token(token).transfer(msg.sender, tokensRefunded));
    
    //Send the ethersObtained
    transfer(msg.sender, ethersObtained);
    
    FillSellOrder(msg.sender, token, tokensTotal, ethersTotal, tokensSold, ethersObtained, tokensRefunded);
  }
  
  /// @dev Fills a sell order by synchronously executing exchange buy orders.
  /// @param tokensTotal Total amount of tokens to sell.
  /// @param exchanges Exchanges of each order (0: EtherDelta 1: 0x).
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param exchangeFees Array of exchange fees to fill in orders.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  /// @return Total amount of ethers obtained and total amount of tokens sold.
  function fillOrdersForSellRequest(
    uint tokensTotal,
    uint8[] exchanges,
    address[5][] orderAddresses,
    uint[6][] orderValues,
    uint[] exchangeFees,
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  ) internal returns(uint, uint)
  {
    uint totalEthersObtained = 0;
    uint tokensRemaining = tokensTotal;
    
    for (uint i = 0; i < orderAddresses.length; i++) {
   
      (totalEthersObtained, tokensRemaining) = fillOrderForSellRequest(
         totalEthersObtained,
         tokensRemaining,
         exchanges[i],
         orderAddresses[i],
         orderValues[i],
         exchangeFees[i],
         v[i],
         r[i],
         s[i]
      );

    }
    
    //Substracts service fee
    if(totalEthersObtained > 0) {
      uint fee =  SafeMath.safeMul(totalEthersObtained, serviceFee) / (1 ether);
      totalEthersObtained = collectServiceFee(SafeMath.min256(fee, totalEthersObtained), totalEthersObtained);
    }
    
    //Returns ethers obtained
    return (totalEthersObtained, SafeMath.safeSub(tokensTotal, tokensRemaining));
  }
  
  /// @dev Fills a sell order with a buy order.
  /// @param totalEthersObtained Total amount of ethers obtained so far.
  /// @param initialTokensRemaining Total amount of tokens remaining to sell.
  /// @param exchange 0: EtherDelta 1: 0x.
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param exchangeFee Exchange fees to fill the order.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  /// @return Total amount of ethers obtained and total amount of tokens remainint to sell.
  function fillOrderForSellRequest(
    uint totalEthersObtained,
    uint initialTokensRemaining,
    uint8 exchange,
    address[5] orderAddresses,
    uint[6] orderValues,
    uint exchangeFee,
    uint8 v,
    bytes32 r,
    bytes32 s
    ) internal returns(uint, uint)
  {
    uint ethersObtained = 0;
    uint tokensRemaining = initialTokensRemaining;
    
    //Exchange fees should not be higher than 1% (in Wei)
    require(exchangeFee < 10000000000000000);
    
    //Checks that there is enoughh amount to execute the trade
    uint fillAmount = getFillAmount(
      tokensRemaining,
      exchange,
      orderAddresses,
      orderValues,
      exchangeFee,
      v,
      r,
      s
    );
    
    if(fillAmount > 0) {
          
      //Substracts the amount to execute
      tokensRemaining = SafeMath.safeSub(tokensRemaining, fillAmount);
    
      if(exchange == 0) {
        //Executes EtherDelta buy order and returns the amount of ethers obtained, fullfill all or returns zero
        ethersObtained = EtherDeltaTrader.fillBuyOrder(
          orderAddresses,
          orderValues,
          exchangeFee,
          fillAmount,
          v,
          r,
          s
        );    
      } 
      else {
        //Executes 0x buy order and returns the amount of ethers obtained, fullfill all or returns zero
        ethersObtained = ZrxTrader.fillBuyOrder(
          orderAddresses,
          orderValues,
          fillAmount,
          v,
          r,
          s
        );
        
        //If 0x, exchangeFee is collected by the contract to buy externally ZrxTrader
        uint fee = SafeMath.safeMul(ethersObtained, exchangeFee) / (1 ether);
        ethersObtained = collectServiceFee(fee, ethersObtained);
    
      }
    }
         
    //Adds the amount of ethers obtained and tokens remaining
    return (SafeMath.safeAdd(totalEthersObtained, ethersObtained), ethersObtained==0? initialTokensRemaining: tokensRemaining);
   
  }
  
  /// @dev Creates an order to buy a token. 
  /// @param token Address of the token to sell.
  /// @param tokensTotal Amount of the token to sell.
  /// @param exchanges Exchanges of each order (0: EtherDelta 1: 0x).
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param exchangeFees Array of exchange fees to fill in orders.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  function createBuyOrder(
    address token, 
    uint tokensTotal,
    uint8[] exchanges,
    address[5][] orderAddresses,
    uint[6][] orderValues,
    uint[] exchangeFees,
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  ) public payable 
  {
    
    
    uint ethersTotal = msg.value;
    uint tokensObtained;
    uint ethersSpent;
    uint ethersRefunded = ethersTotal;
     
    require(tokensTotal > 0 && msg.value > 0);
    
    (tokensObtained, ethersSpent) = fillOrdersForBuyRequest(
      ethersTotal,
      exchanges,
      orderAddresses,
      orderValues,
      exchangeFees,
      v,
      r,
      s
    );
    
    //We make sure that at least one order had some amount filled
    require(ethersSpent > 0 && tokensObtained >0);
    
    //Check that the price of what was bought is not greater than the max agreed
    require(SafeMath.safeDiv(ethersTotal, tokensTotal) >= SafeMath.safeDiv(ethersSpent, tokensObtained));

    //Substracts the ethers spent
    ethersRefunded = SafeMath.safeSub(ethersTotal, ethersSpent);
    
    //Return ethers not spent 
    if(ethersRefunded > 0)
     require(msg.sender.call.value(ethersRefunded)());
   
    //Send the tokens
    transferToken(token, msg.sender, tokensObtained);
    
    FillBuyOrder(msg.sender, token, tokensTotal, ethersTotal, tokensObtained, ethersSpent, ethersRefunded);
  }
  
  /// @dev Fills a buy order by synchronously executing exchange sell orders.
  /// @param ethersTotal Total amount of ethers to spend.
  /// @param exchanges Exchanges of each order (0: EtherDelta 1: 0x).
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param exchangeFees Array of exchange fees to fill in orders.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  /// @return Total of tokens obtained.
  /// @return Total amount of tokens obtained and total amount of ethers spent.
  function fillOrdersForBuyRequest(
    uint ethersTotal,
    uint8[] exchanges,
    address[5][] orderAddresses,
    uint[6][] orderValues,
    uint[] exchangeFees,
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  ) internal returns(uint, uint)
  {
    uint totalTokensObtained = 0;
    uint ethersRemaining = ethersTotal;
    
    for (uint i = 0; i < orderAddresses.length; i++) {
    
      if(ethersRemaining > 0) {
        (totalTokensObtained, ethersRemaining) = fillOrderForBuyRequest(
          totalTokensObtained,
          ethersRemaining,
          exchanges[i],
          orderAddresses[i],
          orderValues[i],
          exchangeFees[i],
          v[i],
          r[i],
          s[i]
        );
      }
    
    }
    
    //Returns total of tokens obtained
    return (totalTokensObtained, SafeMath.safeSub(ethersTotal, ethersRemaining));
  }
  
  /// @dev Fills a buy order wtih a sell order.
  /// @param totalTokensObtained Total amount of tokens obtained so far.
  /// @param initialEthersRemaining Total amount of ethers remainint to spend.
  /// @param exchange 0: EtherDelta 1: 0x.
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param exchangeFee Exchange fees to fill the order.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  /// @return Total of tokens obtained.
  /// @return Total amount of tokens obtained and total amount of ethers remainint to spend.
  function fillOrderForBuyRequest(
    uint totalTokensObtained,
    uint initialEthersRemaining,
    uint8 exchange,
    address[5] orderAddresses,
    uint[6] orderValues,
    uint exchangeFee,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal returns(uint, uint)
  {
    uint tokensObtained = 0;
    uint ethersRemaining = initialEthersRemaining;
       
    //Exchange fees should not be higher than 1% (in Wei)
    require(exchangeFee < 10000000000000000);
     
    //Checks that there is enoughh amount to execute the trade
    uint fillAmount = getFillAmount(
      ethersRemaining,
      exchange,
      orderAddresses,
      orderValues,
      exchangeFee,
      v,
      r,
      s
    );
   
    if(fillAmount > 0) {
     
      //Substracts the amount to execute
      ethersRemaining = SafeMath.safeSub(ethersRemaining, fillAmount);
      
      //Substract service fee
      (fillAmount, ethersRemaining) = substractFee(serviceFee, fillAmount, ethersRemaining);
         
      if(exchange == 0) {
        //Executes EtherDelta order, fee is paid directly to EtherDelta, fullfill all or returns zero
        tokensObtained = EtherDeltaTrader.fillSellOrder(
          orderAddresses,
          orderValues,
          exchangeFee,
          fillAmount,
          v,
          r,
          s
        );
      
      } 
      else {
          
        //If 0x, exchangeFee is collected by the contract to buy externally ZrxTrader, fullfill all or returns zero
        (fillAmount, ethersRemaining) = substractFee(exchangeFee, fillAmount, ethersRemaining);
        
        //Executes 0x order
        tokensObtained = ZrxTrader.fillSellOrder(
          orderAddresses,
          orderValues,
          fillAmount,
          v,
          r,
          s
        );
      }
    }
        
    //Returns total of tokens obtained and ethers remaining
    return (SafeMath.safeAdd(totalTokensObtained, tokensObtained), tokensObtained==0? initialEthersRemaining: ethersRemaining);
  }
  
  
  /// @dev Get the amount to fill in the order.
  /// @param amount Remaining amount of the order.
  /// @param exchange 0: EtherDelta 1: 0x.
  /// @param orderAddresses Array of address arrays containing individual order addresses.
  /// @param orderValues Array of uint arrays containing individual order values.
  /// @param v Array ECDSA signature v parameters.
  /// @param r Array of ECDSA signature r parameters.
  /// @param s Array of ECDSA signature s parameters.
  /// @return Min amount between the remaining and the order available.
  function getFillAmount(
    uint amount,
    uint8 exchange,
    address[5] orderAddresses,
    uint[6] orderValues,
    uint exchangeFee,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal returns(uint) 
  {
    uint availableAmount;
    if(exchange == 0) {
      availableAmount = EtherDeltaTrader.getAvailableAmount(
        orderAddresses,
        orderValues,
        exchangeFee,
        v,
        r,
        s
      );    
    } 
    else {
      availableAmount = ZrxTrader.getAvailableAmount(
        orderAddresses,
        orderValues,
        v,
        r,
        s
      );
    }
     
    return SafeMath.min256(amount, availableAmount);
  }
  
  /// @dev Substracts the service from the remaining amount if enough, if not from the amount to fill the order.
  /// @param feePercentage Fee Percentage
  /// @param fillAmount Amount to fill the order
  /// @param ethersRemaining Remaining amount of ethers for other orders
  /// @return Amount to fill the order and remaining amount
  function substractFee(
    uint feePercentage,
    uint fillAmount,
    uint ethersRemaining
  ) internal returns(uint, uint) 
  {       
      uint fee = SafeMath.safeMul(fillAmount, feePercentage) / (1 ether);
      //If there is enough remaining to pay fee, it substracts the fee from the remaining
      if(ethersRemaining >= fee)
         ethersRemaining = collectServiceFee(fee, ethersRemaining);
      else {
         fillAmount = collectServiceFee(fee, SafeMath.safeAdd(fillAmount, ethersRemaining));
         ethersRemaining = 0;
      }
      return (fillAmount, ethersRemaining);
  }
  
  /// @dev Substracts the service fee in ethers.
  /// @param fee Service fee in ethers
  /// @param amount Amount to substract service fee
  /// @return Amount minus service fee.
  function collectServiceFee(uint fee, uint amount) internal returns(uint) {
    collectedFee = SafeMath.safeAdd(collectedFee, fee);
    return SafeMath.safeSub(amount, fee);
  }
  
  /// @dev Transfer ethers to user account.
  /// @param account User address where to send ethers.
  /// @param amount Amount of ethers to send.
  function transfer(address account, uint amount) internal {
    require(account.send(amount));
  }
    
  /// @dev Transfer token to user account.
  /// @param token Address of token to transfer.
  /// @param account User address where to transfer tokens.
  /// @param amount Amount of tokens to transfer.
  function transferToken(address token, address account, uint amount) internal {
    require(Token(token).transfer(account, amount));
  }
   
  /// @dev Withdraw collected service fees. Only by fee account.
  /// @param amount Amount to withdraw
  function withdrawFees(uint amount) public onlyFeeAccount {
    require(collectedFee >= amount);
    collectedFee = SafeMath.safeSub(collectedFee, amount);
    require(feeAccount.send(amount));
  }
  
   
  /// @dev Withdraw contract ZRX in case new version is deployed. Only by admin.
  /// @param amount Amount to withdraw
  function withdrawZRX(uint amount) public onlyAdmin {
    require(Token(ZRX_TOKEN_ADDR).transfer(admin, amount));
  }
}