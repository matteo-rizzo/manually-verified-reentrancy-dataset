pragma solidity ^0.5.16;









contract CompensationEscrow {
  using SafeERC20 for IERC20;
  
  address public constant arbitrator = address(0x5b97680e165B4DbF5C45f4ff4241e85F418c66C2); // kain.eth
  IERC20 public constant compensation = IERC20(0x8E14d03061705eB48fdA6BC6e244C5EABE5d322E); // CRON

  function payout(address _claimant, uint _payout) external {
      require(msg.sender == arbitrator, "!kain.eth");
      compensation.safeTransfer(_claimant, _payout);
  }
}