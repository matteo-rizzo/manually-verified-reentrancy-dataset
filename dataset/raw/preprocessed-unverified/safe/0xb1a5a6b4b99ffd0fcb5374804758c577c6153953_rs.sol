/**
 *Submitted for verification at Etherscan.io on 2019-09-23
*/

pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;


























contract Requestable {
  using RequestHelper for Types.Request;

  mapping(address => uint) nonces;

  function validateRequest(Types.Request memory request) internal {
    require(request.target == address(this), "INVALID_TARGET");
    require(request.getSigner() == request.owner, "INVALID_SIGNATURE");
    require(nonces[request.owner] + 1 == request.nonce, "INVALID_NONCE");
    
    if (request.fee.feeAmount > 0) {
      require(balanceOf(request.owner, request.fee.feeToken) >= request.fee.feeAmount, "INSUFFICIENT_FEE_BALANCE");
    }

    nonces[request.owner] += 1;
  }

  function completeRequest(Types.Request memory request) internal {
    if (request.fee.feeAmount > 0) {
      _payRequestFee(request.owner, request.fee.feeToken, request.fee.feeRecipient, request.fee.feeAmount);
    }
  }

  function nonceOf(address owner) public view returns (uint) {
    return nonces[owner];
  }

  // Abtract functions
  function balanceOf(address owner, address token) public view returns (uint);
  function _payRequestFee(address owner, address feeToken, address feeRecipient, uint feeAmount) internal;
}


contract DepositContract {
  address public owner;
  address public parent;
  address public version;
    
  function setVersion(address newVersion) external;

  function perform(
    address addr, 
    string calldata signature, 
    bytes calldata encodedParams,
    uint value
  ) external returns (bytes memory);
}








/**
 * @title DolomiteDirectV1
 * @author Zack Rubenstein
 *
 * Interfaces with the DepositContractRegistry and individual 
 * DepositContracts to enable smart-wallet functionality as well
 * as spot and margin trading on Dolomite (through Loopring & Dy/dx)
 */
contract DolomiteDirectV1 is Requestable, IVersionable, IBrokerDelegate, IDolomiteMarginTradingBroker {
  using DepositContractHelper for DepositContract;
  using SafeMath for uint;

  IDepositContractRegistry public registry;
  address public loopringProtocolAddress;
  address public dolomiteMarginProtocolAddress;
  address public dydxProtocolAddress;
  address public wethTokenAddress;

  constructor(
    address _depositContractRegistry,
    address _loopringRingSubmitter,
    address _dolomiteMarginProtocol,
    address _dydxProtocolAddress,
    address _wethTokenAddress
  ) public {
    registry = IDepositContractRegistry(_depositContractRegistry);
    loopringProtocolAddress = _loopringRingSubmitter;
    dolomiteMarginProtocolAddress = _dolomiteMarginProtocol;
    dydxProtocolAddress = _dydxProtocolAddress;
    wethTokenAddress = _wethTokenAddress;
  }

  /*
   * Returns the available balance for an owner that this contract manages.
   * If the token is WETH, it returns the sum of the ETH and WETH balance,
   * as ETH is automatically wrapped upon transfers (unless the unwrap option is
   * set to true in the transfer request)
   */
  function balanceOf(address owner, address token) public view returns (uint) {
    address depositAddress = registry.depositAddressOf(owner);
    uint tokenBalance = IERC20(token).balanceOf(depositAddress);
    if (token == wethTokenAddress) tokenBalance = tokenBalance.add(depositAddress.balance);
    return tokenBalance;
  }

  /*
   * Send up a signed transfer request and the given amount tokens
   * is transfered to the specified recipient.
   */
  function transfer(Types.Request memory request) public {
    validateRequest(request);
    
    Types.TransferRequest memory transferRequest = request.decodeTransferRequest();
    address payable depositAddress = registry.depositAddressOf(request.owner);

    _transfer(
      transferRequest.token, 
      depositAddress, 
      transferRequest.recipient, 
      transferRequest.amount, 
      transferRequest.unwrap
    );

    completeRequest(request);
  }

  // =============================

  function _transfer(address token, address payable depositAddress, address recipient, uint amount, bool unwrap) internal {
    DepositContract depositContract = DepositContract(depositAddress);
    
    if (token == wethTokenAddress && unwrap) {
      if (depositAddress.balance < amount) {
        depositContract.unwrapWeth(wethTokenAddress, amount.sub(depositAddress.balance));
      }

      depositContract.transferEth(recipient, amount);
      return;
    }

    depositContract.wrapAndTransferToken(token, recipient, amount, wethTokenAddress);
  }

  // -----------------------------
  // Loopring Broker Delegate

  function brokerRequestAllowance(LoopringTypes.BrokerApprovalRequest memory request) public returns (bool) {
    require(msg.sender == loopringProtocolAddress);

    LoopringTypes.BrokerOrder[] memory mergedOrders = new LoopringTypes.BrokerOrder[](request.orders.length);
    uint numMergedOrders = 1;

    mergedOrders[0] = request.orders[0];
    
    if (request.orders.length > 1) {
      for (uint i = 1; i < request.orders.length; i++) {
        bool isDuplicate = false;

        for (uint b = 0; b < numMergedOrders; b++) {
          if (request.orders[i].owner == mergedOrders[b].owner) {
            mergedOrders[b].requestedAmountS += request.orders[i].requestedAmountS;
            mergedOrders[b].requestedFeeAmount += request.orders[i].requestedFeeAmount;
            isDuplicate = true;
            break;
          }
        }

        if (!isDuplicate) {
          mergedOrders[numMergedOrders] = request.orders[i];
          numMergedOrders += 1;
        }
      }
    }

    for (uint j = 0; j < numMergedOrders; j++) {
      LoopringTypes.BrokerOrder memory order = mergedOrders[j];
      address payable depositAddress = registry.depositAddressOf(order.owner);
      
      _transfer(request.tokenS, depositAddress, address(this), order.requestedAmountS, false);
      if (order.requestedFeeAmount > 0) _transfer(request.feeToken, depositAddress, address(this), order.requestedFeeAmount, false);
    }

    return false; // Does not use onOrderFillReport
  }

  function onOrderFillReport(LoopringTypes.BrokerInterceptorReport memory fillReport) public {
    // Do nothing
  }

  function brokerBalanceOf(address owner, address tokenAddress) public view returns (uint) {
    return balanceOf(owner, tokenAddress);
  }

  // ----------------------------
  // Dolomite Margin Trading Broker

  function brokerMarginRequestApproval(address owner, address token, uint amount) public {
    require(msg.sender == dolomiteMarginProtocolAddress);

    address payable depositAddress = registry.depositAddressOf(owner);
    _transfer(token, depositAddress, address(this), amount, false);
  }

  function brokerMarginGetTrader(address owner, bytes memory orderData) public returns (address) {
    return registry.depositAddressOf(owner);
  }

  // -----------------------------
  // Requestable

  function _payRequestFee(address owner, address feeToken, address feeRecipient, uint feeAmount) internal {
    _transfer(feeToken, registry.depositAddressOf(owner), feeRecipient, feeAmount, false);
  }

  // -----------------------------
  // Versionable

  function versionBeginUsage(
    address owner, 
    address payable depositAddress, 
    address oldVersion, 
    bytes calldata additionalData
  ) external { 
    // Approve the DolomiteMarginProtocol as an operator for the deposit contract's dydx account
    DepositContract(depositAddress).setDydxOperator(dydxProtocolAddress, dolomiteMarginProtocolAddress);
  }

  function versionEndUsage(
    address owner,
    address payable depositAddress,
    address newVersion,
    bytes calldata additionalData
  ) external { /* do nothing */ }


  // =============================
  // Administrative

  /*
   * Tokens are held in individual deposit contracts, the only time a trader's
   * funds are held by this contract is when Loopring or Dy/dx requests a trader's
   * tokens, and immediatly upon this contract moving funds into itself, Loopring
   * or Dy/dx will move the funds out and into themselves. Thus, we can open this 
   * function up for anyone to call to set or reset the approval for Loopring and
   * Dy/dx for a given token. The reason these approvals are set globally and not
   * on an as-needed (per fill) basis is to reduce gas costs.
   */
  function enableTrading(address token) external {
    IERC20(token).approve(loopringProtocolAddress, 10**70);
    IERC20(token).approve(dolomiteMarginProtocolAddress, 10**70);
  }
}