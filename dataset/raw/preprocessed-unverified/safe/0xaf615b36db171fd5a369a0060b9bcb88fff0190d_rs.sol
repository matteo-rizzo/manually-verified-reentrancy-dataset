pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;







contract Stores {

  /**
   * @dev Return ethereum address
   */
  function getEthAddr() internal pure returns (address) {
    return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // ETH Address
  }

  /**
   * @dev Return memory variable address
   */
  function getMemoryAddr() internal pure returns (address) {
    return 0x8a5419CfC711B2343c17a6ABf4B2bAFaBb06957F; // InstaMemory Address
  }

  /**
   * @dev Return InstaEvent Address.
   */
  function getEventAddr() internal pure returns (address) {
    return 0x2af7ea6Cb911035f3eb1ED895Cb6692C39ecbA97; // InstaEvent Address
  }

  /**
   * @dev Get Uint value from InstaMemory Contract.
   */
  function getUint(uint getId, uint val) internal returns (uint returnVal) {
    returnVal = getId == 0 ? val : MemoryInterface(getMemoryAddr()).getUint(getId);
  }

  /**
  * @dev Set Uint value in InstaMemory Contract.
  */
  function setUint(uint setId, uint val) virtual internal {
    if (setId != 0) MemoryInterface(getMemoryAddr()).setUint(setId, val);
  }

  /**
  * @dev emit event on event contract
  */
  function emitEvent(bytes32 eventCode, bytes memory eventData) virtual internal {
    (uint model, uint id) = connectorID();
    EventInterface(getEventAddr()).emitEvent(model, id, eventCode, eventData);
  }

  /**
  * @dev Connector Details.
  */
  function connectorID() public view returns(uint model, uint id) {
    (model, id) = (1, 41);
  }

}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


contract DSMath {
  uint constant WAD = 10 ** 18;
  uint constant RAY = 10 ** 27;

  function add(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(x, y);
  }

  function sub(uint x, uint y) internal virtual pure returns (uint z) {
    z = SafeMath.sub(x, y);
  }

  function mul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.mul(x, y);
  }

  function div(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.div(x, y);
  }

  function wmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), WAD / 2) / WAD;
  }

  function wdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, WAD), y / 2) / y;
  }

  function rdiv(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, RAY), y / 2) / y;
  }

  function rmul(uint x, uint y) internal pure returns (uint z) {
    z = SafeMath.add(SafeMath.mul(x, y), RAY / 2) / RAY;
  }

}







contract GaugeHelper is DSMath, Stores{

  function getCurveGaugeMappingAddr() internal virtual view returns (address){
    return 0x1C800eF1bBfE3b458969226A96c56B92a069Cc92;
  }

  function getCurveMintorAddr() internal virtual view returns (address){
    return 0xd061D61a4d941c39E5453435B6345Dc261C2fcE0;
  }

  /**
   * @dev Convert String to bytes32.
   */
  function stringToBytes32(string memory str) internal pure returns (bytes32 result) {
    require(bytes(str).length != 0, "string-empty");
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      result := mload(add(str, 32))
    }
  }
}

contract CurveGaugeEvent is GaugeHelper {
  event LogDeposit(
    string indexed gaugePoolName,
    uint amount,
    uint getId,
    uint setId
  );

  event LogWithdraw(
    string indexed gaugePoolName,
    uint amount,
    uint getId,
    uint setId
  );

  event LogClaimedReward(
    string indexed gaugePoolName,
    uint amount,
    uint rewardAmt,
    uint setId,
    uint setIdReward
  );

  function emitLogWithdraw(string memory gaugePoolName, uint _amt, uint getId, uint setId) internal {
    emit LogWithdraw(gaugePoolName, _amt, getId, setId);
    bytes32 _eventCodeWithdraw = keccak256("LogWithdraw(string,uint256,uint256,uint256)");
    bytes memory _eventParamWithdraw = abi.encode(gaugePoolName, _amt, getId, setId);
    emitEvent(_eventCodeWithdraw, _eventParamWithdraw);
  }

  function emitLogClaimedReward(string memory gaugePoolName, uint crvAmt, uint rewardAmt, uint setIdCrv, uint setIdReward) internal {
    emit LogClaimedReward(gaugePoolName, crvAmt, rewardAmt, setIdCrv, setIdReward);
    bytes32 _eventCode = keccak256("LogClaimedReward(string,uint256,uint256,uint256,uint256)");
    bytes memory _eventParam = abi.encode(gaugePoolName, crvAmt, rewardAmt, setIdCrv, setIdReward);
    emitEvent(_eventCode, _eventParam);
  }
}

contract CurveGauge is CurveGaugeEvent {
  struct Balances{
    uint intialCRVBal;
    uint intialRewardBal;
    uint finalCRVBal;
    uint finalRewardBal;
    uint crvRewardAmt;
    uint rewardAmt;
  }

  /**
  * @dev Deposit Cruve LP Token.
    * @param gaugePoolName Curve gauge pool name.
    * @param amt deposit amount.
    * @param getId Get token amount at this ID from `InstaMemory` Contract.
    * @param setId Set token amount at this ID in `InstaMemory` Contract.
  */
  function deposit(
    string calldata gaugePoolName,
    uint amt,
    uint getId,
    uint setId
  ) external payable {
    uint _amt = getUint(getId, amt);
    ICurveGaugeMapping curveGaugeMapping = ICurveGaugeMapping(getCurveGaugeMappingAddr());
    ICurveGaugeMapping.GaugeData memory curveGaugeData = curveGaugeMapping.gaugeMapping(
        bytes32(stringToBytes32(gaugePoolName)
    ));
    require(curveGaugeData.gaugeAddress != address(0), "wrong-gauge-pool-name");
    IGauge gauge = IGauge(curveGaugeData.gaugeAddress);
    TokenInterface lp_token = TokenInterface(address(gauge.lp_token()));

    _amt = _amt == uint(-1) ? lp_token.balanceOf(address(this)) : _amt;
    lp_token.approve(address(curveGaugeData.gaugeAddress), _amt);

    gauge.deposit(_amt);

    setUint(setId, _amt);

    emit LogDeposit(gaugePoolName, _amt, getId, setId);
    bytes32 _eventCode = keccak256("LogDeposit(string,uint256,uint256,uint256)");
    bytes memory _eventParam = abi.encode(gaugePoolName, _amt, getId, setId);
    emitEvent(_eventCode, _eventParam);
  }

  /**
  * @dev Withdraw LP Token and claim both CRV and Reward token.
    * @param gaugePoolName gauge pool name.
    * @param amt LP token amount.
    * @param getId Get LP token amount at this ID from `InstaMemory` Contract.
    * @param setId Set LP token amount at this ID in `InstaMemory` Contract.
    * @param setIdCrv Set CRV token reward amount at this ID in `InstaMemory` Contract.
    * @param setIdReward Set reward amount at this ID in `InstaMemory` Contract.
  */
  function withdraw(
    string calldata gaugePoolName,
    uint amt,
    uint getId,
    uint setId,
    uint setIdCrv,
    uint setIdReward
  ) external payable {
    uint _amt = getUint(getId, amt);
    ICurveGaugeMapping curveGaugeMapping = ICurveGaugeMapping(getCurveGaugeMappingAddr());
    ICurveGaugeMapping.GaugeData memory curveGaugeData = curveGaugeMapping.gaugeMapping(
      bytes32(stringToBytes32(gaugePoolName))
    );
    require(curveGaugeData.gaugeAddress != address(0), "wrong-gauge-pool-name");
    IGauge gauge = IGauge(curveGaugeData.gaugeAddress);
    TokenInterface crv_token = TokenInterface(address(gauge.crv_token()));
    TokenInterface rewarded_token;
    Balances memory balances;

    _amt = _amt == uint(-1) ? gauge.balanceOf(address(this)) : _amt;
    balances.intialCRVBal = crv_token.balanceOf(address(this));

    if (curveGaugeData.rewardToken) {
      rewarded_token = TokenInterface(address(gauge.rewarded_token()));
      balances.intialRewardBal = rewarded_token.balanceOf(address(this));
    }

    IMintor(getCurveMintorAddr()).mint(curveGaugeData.gaugeAddress);
    gauge.withdraw(_amt);

    balances.finalCRVBal = crv_token.balanceOf(address(this));
    balances.crvRewardAmt = sub(balances.finalCRVBal, balances.intialCRVBal);

    setUint(setId, _amt);
    setUint(setIdCrv, balances.crvRewardAmt);

    if (curveGaugeData.rewardToken) {
      balances.finalRewardBal = rewarded_token.balanceOf(address(this));
      balances.rewardAmt = sub(balances.finalRewardBal, balances.intialRewardBal);
      setUint(setIdReward, balances.rewardAmt);
    }

    emitLogWithdraw(gaugePoolName, _amt, getId, setId);
    emitLogClaimedReward(gaugePoolName, balances.crvRewardAmt, balances.rewardAmt, setIdCrv, setIdReward);
  }

  /**
  * @dev Claim CRV Reward with Staked Reward token
    * @param gaugePoolName gauge pool name.
    * @param setId Set CRV reward amount at this ID in `InstaMemory` Contract.
    * @param setIdReward Set token reward amount at this ID in `InstaMemory` Contract.
  */
  function claimReward(
    string calldata gaugePoolName,
    uint setId,
    uint setIdReward
  ) external payable {
    ICurveGaugeMapping curveGaugeMapping = ICurveGaugeMapping(getCurveGaugeMappingAddr());
    ICurveGaugeMapping.GaugeData memory curveGaugeData = curveGaugeMapping.gaugeMapping(
      bytes32(stringToBytes32(gaugePoolName))
    );
    require(curveGaugeData.gaugeAddress != address(0), "wrong-gauge-pool-name");
    IMintor mintor = IMintor(getCurveMintorAddr());
    IGauge gauge = IGauge(curveGaugeData.gaugeAddress);
    TokenInterface crv_token = TokenInterface(address(gauge.crv_token()));
    TokenInterface rewarded_token;
    Balances memory balances;

    if (curveGaugeData.rewardToken) {
      rewarded_token = TokenInterface(address(gauge.rewarded_token()));
      balances.intialRewardBal = rewarded_token.balanceOf(address(this));
    }

    balances.intialCRVBal = crv_token.balanceOf(address(this));

    mintor.mint(curveGaugeData.gaugeAddress);

    balances.finalCRVBal = crv_token.balanceOf(address(this));
    balances.crvRewardAmt = sub(balances.finalCRVBal, balances.intialCRVBal);

    setUint(setId, balances.crvRewardAmt);

    if(curveGaugeData.rewardToken){
      balances.finalRewardBal = rewarded_token.balanceOf(address(this));
      balances.rewardAmt = sub(balances.finalRewardBal, balances.intialRewardBal);
      setUint(setIdReward, balances.rewardAmt);
    }

    emitLogClaimedReward(gaugePoolName, balances.crvRewardAmt, balances.rewardAmt, setId, setIdReward);
  }
}

contract ConnectCurveGauge is CurveGauge {
  string public name = "Curve-Gauge-v1.0";
}