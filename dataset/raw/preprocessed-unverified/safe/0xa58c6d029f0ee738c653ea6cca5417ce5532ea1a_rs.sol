/**

 *Submitted for verification at Etherscan.io on 2018-08-30

*/



pragma solidity ^0.4.18;























contract DutchReserve {

  DutchExchange constant DUTCH_EXCHANGE = DutchExchange(0xaf1745c0f8117384Dfa5FFf40f824057c70F2ed3);

  WETH9 constant WETH = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

  KyberNetwork constant KYBER = KyberNetwork(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);

  ERC20 constant ETH = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);



  function DutchReserve() public {

    require(WETH.approve(DUTCH_EXCHANGE,2**255));

  }

  

  function enableToken(ERC20 token) public {

      require(token.approve(KYBER,2**255));

  }



  function buyToken(ERC20 token) payable public {

    uint auctionIndex = DUTCH_EXCHANGE.getAuctionIndex(token,WETH);

    WETH.deposit.value(msg.value)();

    DUTCH_EXCHANGE.deposit(WETH, msg.value);

    DUTCH_EXCHANGE.postBuyOrder(token,WETH,auctionIndex,msg.value);

    uint amount; uint first;

    (amount,first) = DUTCH_EXCHANGE.claimBuyerFunds(token,WETH,this,auctionIndex);

    DUTCH_EXCHANGE.withdraw(token,amount);

    require(KYBER.trade(token,amount,ETH,msg.sender,2**255,1,this) > 0) ;

    //token.transfer(msg.sender,amount);

  }



}