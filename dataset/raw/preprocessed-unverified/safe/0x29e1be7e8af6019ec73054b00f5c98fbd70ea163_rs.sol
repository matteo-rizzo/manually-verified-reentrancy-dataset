pragma solidity 0.6.12; // optimization runs: 200, evm version: istanbul
pragma experimental ABIEncoderV2;





contract BasicTradeBotCommanderStaging {
  DharmaTradeBotV1Interface _TRADE_BOT = DharmaTradeBotV1Interface(
    0x0f36f2DA9F935a7802a4f1Af43A3740A73219A9e
  );
    
  function processLimitOrder(
    DharmaTradeBotV1Interface.LimitOrderArguments calldata args,
    DharmaTradeBotV1Interface.LimitOrderExecutionArguments calldata executionArgs
  ) external returns (uint256 amountReceived) {
    amountReceived = _TRADE_BOT.processLimitOrder(
      args, executionArgs
    );
  }
}