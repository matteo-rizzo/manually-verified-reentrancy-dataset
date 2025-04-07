/**

 *Submitted for verification at Etherscan.io on 2018-11-28

*/



pragma solidity ^0.4.24;















contract TokenTimelock {

  using SafeERC20 for IERC20;



  IERC20 private _token;

  address private _sender;

  address private _beneficiary;

  uint256 private _releaseTime;



  constructor(

    IERC20 token,

    address beneficiary,

    uint256 releaseTime

  )

    public

  {

    // solium-disable-next-line security/no-block-members

    require(releaseTime > block.timestamp);

    _token = token;

    _sender = msg.sender;

    _beneficiary = beneficiary;

    _releaseTime = releaseTime;

  }



  function token() public view returns(IERC20) {

    return _token;

  }

  function sender() public view returns(address) {

    return _sender;

  }

  function beneficiary() public view returns(address) {

    return _beneficiary;

  }

  function releaseTime() public view returns(uint256) {

    return _releaseTime;

  }



  function release() public {

    // solium-disable-next-line security/no-block-members

    require((msg.sender == _sender) || (msg.sender == _beneficiary), "thou shall not pass!");

    require(block.timestamp >= _releaseTime, "not yet.");



    uint256 amount = _token.balanceOf(address(this));

    require(amount > 0, "zero balance");



    _token.safeTransfer(_beneficiary, amount);

  }



  function cancel() public {

    require(msg.sender == _sender, "Only sender can do this");



    uint256 amount = _token.balanceOf(address(this));

    require(amount > 0, "zero balance");



    _token.safeTransfer(_sender, amount);

  }

}