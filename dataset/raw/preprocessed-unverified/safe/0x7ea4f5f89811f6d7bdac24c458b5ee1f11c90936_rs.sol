/**
 *Submitted for verification at Etherscan.io on 2020-11-24
*/

pragma solidity ^0.6.12;














contract BancorPoolParser {
  using SafeMath for uint256;
  IGetBancorData public GetBancorData;
  IExchangePortal public ExchangePortal;

  constructor(address _GetBancorData, address _ExchangePortal) public {
    GetBancorData = IGetBancorData(_GetBancorData);
    ExchangePortal = IExchangePortal(_ExchangePortal);
  }

  // Works for new Bancor pools
  // parse total value of pool conenctors
  function parseConnectorsByPool(address _from, address _to, uint256 poolAmount)
    external
    view
    returns(uint256)
  {
     // get common data
     address converter = ISmartToken(address(_from)).owner();
     uint16 connectorTokenCount = IBancorConverter(converter).connectorTokenCount();
     uint256 poolTotalSupply = ISmartToken(address(_from)).totalSupply();
     uint32 reserveRatio =  IBancorConverter(converter).reserveRatio();

     IBancorFormula bancorFormula = IBancorFormula(
       GetBancorData.getBancorContractAddresByName("BancorFormula")
     );

     return calculateTotalSum(
       converter,
       poolTotalSupply,
       reserveRatio,
       connectorTokenCount,
       bancorFormula,
       _to,
       poolAmount
       );
  }


  // internal helper
  function calculateTotalSum(
    address converter,
    uint256 poolTotalSupply,
    uint32 reserveRatio,
    uint16 connectorTokenCount,
    IBancorFormula bancorFormula,
    address _to,
    uint256 poolAmount
    )
    internal
    view
    returns(uint256 totalValue)
  {
    for(uint16 i = 0; i < connectorTokenCount; i++){
      // get amount of token in pool by pool input
      address connectorToken = IBancorConverter(converter).connectorTokens(i);
      uint256 connectorBalance = IBancorConverter(converter).getConnectorBalance(address(connectorToken));
      uint256 amountByShare = bancorFormula.fundCost(poolTotalSupply, connectorBalance, reserveRatio, poolAmount);

      // get ratio of pool token
      totalValue = totalValue.add(ExchangePortal.getValueViaDEXsAgregators(connectorToken, _to, amountByShare));
    }
  }
}