/**
 *Submitted for verification at Etherscan.io on 2019-09-23
*/

/*
 * Copyright 2019 Dolomite
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;








/// @title Utility Functions for bytes
/// @author Daniel Wang - <daniel@loopring.org>















contract DydxProtocol {
  
  struct OperatorArg {
      address operator;
      bool trusted;
  }

  function operate(
      DydxPosition.Info[] calldata accounts,
      DydxActions.ActionArgs[] calldata actions
  ) external;

  function getMarketTokenAddress(uint256 marketId)
      external
      view
      returns (address);

  function setOperators(OperatorArg[] calldata args) external;
}








contract LoopringProtocol {
  address public lrcTokenAddress;
  address public delegateAddress;
  function submitRings(bytes calldata data) external;
}


contract ITradeDelegate {
  function batchTransfer(bytes32[] calldata batch) external;
}




















contract Globals {
  using MiscHelper for *;

  string constant public ORDER_SIGNATURE = "dolomiteMarginOrder(version 1.0.0)";
  bytes4 constant public ORDER_SELECTOR = bytes4(keccak256(bytes(ORDER_SIGNATURE)));

  address internal LRC_TOKEN_ADDRESS;
  LoopringProtocol internal LOOPRING_PROTOCOL;
  ITradeDelegate internal TRADE_DELEGATE;
  DydxProtocol internal DYDX_PROTOCOL;
  address internal DYDX_EXPIRATION_CONTRACT;

  constructor(
    address payable loopringRingSubmitterAddress, 
    address dydxProtocolAddress,
    address dydxExpirationContractAddress
  ) public {

    LOOPRING_PROTOCOL = LoopringProtocol(loopringRingSubmitterAddress);
    LRC_TOKEN_ADDRESS = LOOPRING_PROTOCOL.lrcTokenAddress();

    address payable tradeDelegateAddress = LOOPRING_PROTOCOL.delegateAddress().toPayable();
    TRADE_DELEGATE = ITradeDelegate(tradeDelegateAddress);
    
    DYDX_PROTOCOL = DydxProtocol(dydxProtocolAddress);
    DYDX_EXPIRATION_CONTRACT = dydxExpirationContractAddress;
  }
}


/**
 * @title MarginRingSubmitterWrapper
 * @author Zack Rubenstein
 *
 * Entry point for margin trading though Dydx and Loopring. Dolomite
 * relay calls `submitRingsWithMarginOrder` passing the same ringData 
 * that would be passed to Loopring's `submitRings` plus some additional
 * info about the margin order being filled in the rings.
 */
contract MarginRingSubmitterWrapper is Globals {
  using MiscHelper for *;
  using DecodeHelper for bytes;
  using MarginOrderHelper for LoopringTypes.Order;
  using OrderDataHelper for Types.OrderData;

  event OpenPosition(address indexed trader, uint indexed id);
  event ClosePosition(address indexed trader, uint indexed id);

  /*
   * TODO: make this the default way to use this contract
   */
  function structuredSubmitRingsWithMarginOrder(Types.MarginRingSubmission calldata submissionData) external {
    this.submitRingsWithMarginOrder(
      submissionData.ringData,
      abi.encode(
        submissionData.positionId,
        submissionData.marginOrderIndex,
        submissionData.marketIdS,
        submissionData.marketIdB,
        submissionData.fillAmountS,
        submissionData.fillAmountB
      )
    );
  }

  /**
   * Loopring protocol middleman that opens/closes a margin position with Dy/dx using
   * Loopring as the medium of exchange
   */
  function submitRingsWithMarginOrder(
    bytes calldata ringData, 
    bytes calldata relayData
  ) external {

    (
      Types.RelayerInfo memory relayerInfo,
      LoopringTypes.Order memory order,
      Types.MarginOrderDetails memory marginDetails
    ) = decodeParams(ringData, relayData);

    // ----------------------
    // Construct order data

    Types.OrderData memory orderData;

    if (order.broker == address(0x0)) {
      orderData.trader = order.owner;
    } else {
      orderData.trader = IDolomiteMarginTradingBroker(order.broker).brokerMarginGetTrader(
        order.owner, 
        order.transferDataS
      );
    }

    if (marginDetails.isOpen && marginDetails.isLong) {
      // Open Long
      orderData.side = Types.OrderDataSide.BUY;
      orderData.fillAmountS = order.calculateActualAmount(relayerInfo.fillAmountS, order.tokenS);
      orderData.fillAmountB = order.getAmountB();

    } else if (marginDetails.isOpen && !marginDetails.isLong) {
      // Open Short
      orderData.side = Types.OrderDataSide.SELL;
      orderData.fillAmountS = order.getAmountS();
      orderData.fillAmountB = order.calculateActualAmount(relayerInfo.fillAmountB, order.tokenB);

    } else if (!marginDetails.isOpen && marginDetails.isLong) {
      // Close Long
      orderData.side = Types.OrderDataSide.BUY;
      orderData.fillAmountS = order.getAmountS();
      orderData.fillAmountB = order.calculateActualAmount(relayerInfo.fillAmountB, order.tokenB);
      orderData.bringToZero = true;

    } else if (!marginDetails.isOpen && !marginDetails.isLong) {
      // Close Short
      orderData.side = Types.OrderDataSide.BUY;
      orderData.fillAmountS = order.calculateActualAmount(relayerInfo.fillAmountS, order.tokenS);
      orderData.fillAmountB = order.getAmountB();
      orderData.bringToZero = true;
    }

    bytes memory encodedOrderData = orderData.encodeWithRingData(ringData);

    // ----------------------
    // Construct dydx actions

    DydxActions.ActionArgs[] memory actions;
    DydxPosition.Info[] memory positions = new DydxPosition.Info[](1);
    
    // Add dydx position (account) that actions will operate on
    positions[0] = DydxPosition.Info({
      owner: orderData.trader,
      number: marginDetails.isOpen ? generatePositionId(ringData, relayData) : relayerInfo.positionId
    });

    // Construct exchange action (buy or sell)
    DydxActions.ActionArgs memory exchangeAction;
    exchangeAction.otherAddress = address(this);
    exchangeAction.data = encodedOrderData;

    if (orderData.side == Types.OrderDataSide.BUY) {
      // Buy Order
      exchangeAction.actionType = DydxActions.ActionType.Buy;
      exchangeAction.primaryMarketId = relayerInfo.marketIdB;
      exchangeAction.secondaryMarketId = relayerInfo.marketIdS;

      if (orderData.bringToZero) {
        // Buy enough to repay the loan (end balance will be 0)
        exchangeAction.amount = DydxTypes.AssetAmount({
          sign: true,
          denomination: DydxTypes.AssetDenomination.Wei,
          ref: DydxTypes.AssetReference.Target,
          value: 0
        });

      } else {
        exchangeAction.amount = DydxTypes.AssetAmount({
          sign: true,
          denomination: DydxTypes.AssetDenomination.Wei,
          ref: DydxTypes.AssetReference.Delta,
          value: orderData.fillAmountB
        });
      }
      
    } else if (orderData.side == Types.OrderDataSide.SELL) {
      // Sell Order
      exchangeAction.actionType = DydxActions.ActionType.Sell;
      exchangeAction.primaryMarketId = relayerInfo.marketIdS;
      exchangeAction.secondaryMarketId = relayerInfo.marketIdB;
      exchangeAction.amount = DydxTypes.AssetAmount({
        sign: false,
        denomination: DydxTypes.AssetDenomination.Wei,
        ref: DydxTypes.AssetReference.Delta,
        value: orderData.fillAmountS
      });
    }

    if (marginDetails.isOpen) {
      
      if (order.broker == address(0x0)) {
        // Pull deposit funds from owner to this contract
        TRADE_DELEGATE.transferTokenFrom(
          marginDetails.depositToken, 
          marginDetails.owner,
          address(this), 
          marginDetails.depositAmount
        );
      } else {

        // Request approval for deposit funds from the broker
        IDolomiteMarginTradingBroker(order.broker).brokerMarginRequestApproval(
          marginDetails.owner, 
          marginDetails.depositToken, 
          marginDetails.depositAmount
        );

        // Pull deposit funds from the broker into this contract
        IERC20(marginDetails.depositToken).transferFrom(
          order.broker,
          address(this),
          marginDetails.depositAmount
        );
      }

      // Set allowance for dydx contract
      IERC20(marginDetails.depositToken).approve(
        address(DYDX_PROTOCOL), 
        marginDetails.depositAmount
      );

      // Construct action to deposit funds from this contract into a dydx position
      DydxActions.ActionArgs memory depositAction;
      depositAction.actionType = DydxActions.ActionType.Deposit;
      depositAction.primaryMarketId = marginDetails.depositMarketId;
      depositAction.otherAddress = address(this);
      depositAction.amount = DydxTypes.AssetAmount({
        sign: true,
        denomination: DydxTypes.AssetDenomination.Wei,
        ref: DydxTypes.AssetReference.Delta,
        value: marginDetails.depositAmount
      });

      if (marginDetails.expiration == 0) {
        actions = new DydxActions.ActionArgs[](2);
      } else {
        // Construct action to set the expiration of the dydx position
        DydxActions.ActionArgs memory expirationAction;
        expirationAction.actionType = DydxActions.ActionType.Call;
        expirationAction.otherAddress = DYDX_EXPIRATION_CONTRACT;
        expirationAction.data = encodeExpiration(relayerInfo.marketIdS, marginDetails.expiration);

        actions = new DydxActions.ActionArgs[](3);
        actions[2] = expirationAction;
      }

      // Build deposit and exchange actions in correct order
      actions[0] = depositAction;
      actions[1] = exchangeAction;
      
    } else {
      // Construct action to withdraw funds to order owner or order broker trader (orderData.trader)
      DydxActions.ActionArgs memory withdrawAction;
      withdrawAction.actionType = DydxActions.ActionType.Withdraw;
      withdrawAction.primaryMarketId = marginDetails.withdrawalMarketId;
      withdrawAction.otherAddress = orderData.trader;
      withdrawAction.amount = DydxTypes.AssetAmount({
        sign: true,
        denomination: DydxTypes.AssetDenomination.Wei,
        ref: DydxTypes.AssetReference.Target,
        value: 0
      });

      // Build actions in correct order
      actions = new DydxActions.ActionArgs[](2);
      actions[0] = exchangeAction;
      actions[1] = withdrawAction;
    }

    // ----------------------
    // Perform operation with dydx

    DYDX_PROTOCOL.operate(positions, actions);

    // ----------------------
    // Finalize margin order 

    if (marginDetails.isOpen) emit OpenPosition(positions[0].owner, positions[0].number);
    else emit ClosePosition(positions[0].owner, positions[0].number);
  }

  // ============================================
  // Helpers

  function decodeParams(bytes memory ringData, bytes memory relayData)
    private
    view
    returns (
      Types.RelayerInfo memory relayerInfo,
      LoopringTypes.Order memory order,
      Types.MarginOrderDetails memory marginDetails
    ) 
  {
    relayerInfo = relayData.decodeRelayerInfo();
    order = ringData.decodeMinimalOrderAtIndex(
      relayerInfo.marginOrderIndex, 
      LRC_TOKEN_ADDRESS
    );
    marginDetails = order.getMarginOrderDetails(ORDER_SELECTOR);
    order.checkValidity(relayerInfo, marginDetails, DYDX_PROTOCOL);
  }

  function encodeExpiration(uint marketId, uint expiration) private pure returns (bytes memory) {
    return abi.encode(marketId, expiration);
  }

  function generatePositionId(bytes memory ringData, bytes memory relayData)
    private
    pure
    returns (uint)
  {
    return uint(keccak256(abi.encode(ringData, relayData)));
  }
}


/**
 * @title LoopringV2ExchangeWrapper
 * @author Zack Rubenstein
 *
 * Dydx compatible `ExchangeWrapper` implementation to enable
 * Loopring ring settlement to be performed through Dydx to settle
 * trades for performing margin trading with Dydx and Loopring
 */
contract LoopringV2ExchangeWrapper is IDydxExchangeWrapper, Globals {
  using MiscHelper for *;
  using DecodeHelper for bytes;
  using SafeMath for uint;

  address constant ZERO_ADDRESS = address(0x0);

  string constant INVALID_MSG_SENDER = "The msg.sender must be Dydx protocol";
  string constant INVALID_RECEIVER = "Bought token receiver must be Dydx protocol";
  string constant INVALID_TOKEN_RECIPIENT = "Invalid tokenRecipient in Loopring order";
  string constant INVALID_TRADE_ORIGINATOR = "Loopring order owner must be originator";
  string constant INCORRECT_FILL_AMOUNT = "Amount received must be exactly equal to expected amountB (either provided by relayer or order)";
  string constant NOTHING_RECEIVED = "Amount received is zero. Ring submission most likely failed";

  /**
   * Exchange some amount of takerToken for makerToken.
   *
   * @param  tradeOriginator      Address of the initiator of the trade (however, this value
   *                              cannot always be trusted as it is set at the discretion of the
   *                              msg.sender)
   * @param  receiver             Address to set allowance on once the trade has completed
   * @param  makerToken           Address of makerToken, the token to receive
   * @param  takerToken           Address of takerToken, the token to pay
   * @param  requestedFillAmount  Amount of takerToken being paid
   * @param  orderData            Arbitrary bytes data for any information to pass to the exchange
   * @return                      The amount of makerToken received
   */
  function exchange(
    address tradeOriginator,
    address receiver,
    address makerToken,
    address takerToken,
    uint256 requestedFillAmount,
    bytes calldata orderData
  ) external returns (uint256) {
    require(msg.sender == address(DYDX_PROTOCOL), INVALID_MSG_SENDER);
    require(receiver == address(DYDX_PROTOCOL), INVALID_RECEIVER);

    Types.OrderData memory orderInfo = orderData.decodeOrderData();
    LoopringTypes.Order memory order = orderInfo.ringData.decodeMinimalOrderAtIndex(
      orderInfo.marginOrderIndex,
      ZERO_ADDRESS
    );

    require(order.tokenRecipient == address(this), INVALID_TOKEN_RECIPIENT);
    require(order.broker == address(0x0)
      ? tradeOriginator == order.owner
      : tradeOriginator == orderInfo.trader
    , INVALID_TRADE_ORIGINATOR);

    // Transfer sell tokens to order owner
    IERC20(takerToken).safeTransfer(orderInfo.trader, requestedFillAmount);

    // Record balance of buy tokens prior to ring submission
    uint balanceBeforeSubmission = IERC20(makerToken).balanceOf(address(this));

    // Submit & settle rings
    LOOPRING_PROTOCOL.submitRings(orderInfo.ringData);

    // Get actual amount of tokens received
    uint amountReceived = IERC20(makerToken).balanceOf(address(this)).sub(balanceBeforeSubmission);
    require(amountReceived > 0, NOTHING_RECEIVED);
    require(amountReceived == orderInfo.fillAmountB, INCORRECT_FILL_AMOUNT);

    // Allow Dy/dx to pull received tokens from this contract
    IERC20(makerToken).approve(receiver, amountReceived);

    return amountReceived;
  }

  /**
   * Get amount of takerToken required to buy a certain amount of makerToken for a given trade.
   * Should match the takerToken amount used in exchangeForAmount. If the order cannot provide
   * exactly desiredMakerToken, then it must return the price to buy the minimum amount greater
   * than desiredMakerToken
   *
   * @param  makerToken         Address of makerToken, the token to receive
   * @param  takerToken         Address of takerToken, the token to pay
   * @param  desiredMakerToken  Amount of makerToken requested
   * @param  orderData          Arbitrary bytes data for any information to pass to the exchange
   * @return                    Amount of takerToken the needed to complete the exchange
   */
  function getExchangeCost(
    address makerToken,
    address takerToken,
    uint256 desiredMakerToken,
    bytes calldata orderData
  ) external view returns (uint256) {
    return orderData.decodeOrderData().fillAmountS;
  }
}


/**
 * @title DolomiteMarginTrading
 * @author Zack Rubenstein
 *
 * Combines `MarginRingSubmitterWrapper` and `LoopringV2ExchangeWrapper` into one
 * contract. Takes in the address to Loopring's `RingSubmitter` contract and
 * Dy/Dx's `SoloMargin` contract to intialize the wrappers that integrate the two.
 */
contract DolomiteMarginTrading is Globals, MarginRingSubmitterWrapper, LoopringV2ExchangeWrapper {

  constructor(
    address payable loopringRingSubmitterAddress, 
    address dydxProtocolAddress,
    address dydxExpirationContractAddress
  ) 
    public 
    Globals(loopringRingSubmitterAddress, dydxProtocolAddress, dydxExpirationContractAddress) { }

}