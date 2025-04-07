pragma solidity ^0.5.16;

/**
  * @title Artem Token Pool
  * @notice Derived from Compound's Reservoir
  *         https://github.com/compound-finance/compound-protocol/tree/master/contracts
  */
/**
 * @title ERC 20 Token Standard Interface
 *  https://eips.ethereum.org/EIPS/eip-20
 */



contract ArtemPool {

  /// @notice The block number when the Reservoir started (immutable)
  uint public dripStart;

  /// @notice Tokens per block that to drip to target (immutable)
  uint public dripRate;

  /// @notice Reference to token to drip (immutable)
  EIP20Interface public token;

  /// @notice Target to receive dripped tokens (immutable)
  address public target;

  /// @notice Amount that has already been dripped
  uint public dripped;

  constructor(uint dripRate_, EIP20Interface token_, address target_) public {
    dripStart = block.number;
    dripRate = dripRate_;
    token = token_;
    target = target_;
    dripped = 0;
  }


  function drip() public returns (uint) {

    EIP20Interface token_ = token;
    uint reservoirBalance_ = token_.balanceOf(address(this)); 
    uint dripRate_ = dripRate;
    uint dripStart_ = dripStart;
    uint dripped_ = dripped;
    address target_ = target;
    uint blockNumber_ = block.number;

    // Calculate intermediate values
    uint dripTotal_ = mul(dripRate_, blockNumber_ - dripStart_, "dripTotal overflow");
    uint deltaDrip_ = sub(dripTotal_, dripped_, "deltaDrip underflow");
    uint toDrip_ = min(reservoirBalance_, deltaDrip_);
    uint drippedNext_ = add(dripped_, toDrip_, "tautological");

    dripped = drippedNext_;
    token_.transfer(target_, toDrip_);

    return toDrip_;
  }

  // SafeMath

  function add(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a, errorMessage);
    return c;
  }

  function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
    require(b <= a, errorMessage);
    uint c = a - b;
    return c;
  }

  function mul(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    require(c / a == b, errorMessage);
    return c;
  }

  function min(uint a, uint b) internal pure returns (uint) {
    if (a <= b) {
      return a;
    } else {
      return b;
    }
  }
}