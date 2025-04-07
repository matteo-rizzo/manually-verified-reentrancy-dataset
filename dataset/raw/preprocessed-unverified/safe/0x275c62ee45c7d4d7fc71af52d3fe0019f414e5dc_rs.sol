/**

 *Submitted for verification at Etherscan.io on 2018-10-09

*/



pragma solidity ^0.4.24;



/**

* @title SafeMath

* @dev Math operations with safety checks that revert on error

*/

















contract TalaRCrowdsale is Ownable {

  using SafeMath for uint256;

  using SafeERC20 for IERC20;



  // The token being sold

  IERC20 private _token;



  // Address where funds are collected

  address private _wallet;



  // How many token units a buyer gets per wei.

  uint256 private _rate;



  // Same as _rate but in bonus time

  uint256 private _bonusRate;



  // bonus cap in wei

  uint256 private _bonusCap;



  // Amount of wei raised

  uint256 private _weiRaised;



  // Timestamps

  uint256 private _openingTime;

  uint256 private _bonusEndTime;

  uint256 private _closingTime;



  // Minimal contribution - 0.05 ETH

  uint256 private constant MINIMAL_CONTRIBUTION = 50000000000000000;



  event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);



  constructor(uint256 rate, uint256 bonusRate, uint256 bonusCap, uint256 openingTime, uint256 bonusEndTime, uint256 closingTime, address wallet, IERC20 token) public {

    require(rate > 0);

    require(bonusRate > 0);

    require(bonusCap > 0);

    require(openingTime >= block.timestamp);

    require(bonusEndTime >= openingTime);

    require(closingTime >= bonusEndTime);

    require(wallet != address(0));



    _rate = rate;

    _bonusRate = bonusRate;

    _bonusCap = bonusCap;

    _wallet = wallet;

    _token = token;

    _openingTime = openingTime;

    _closingTime = closingTime;

    _bonusEndTime = bonusEndTime;

  }



  function () external payable {

    buyTokens(msg.sender);

  }



  function token() public view returns(IERC20) {

    return _token;

  }



  function wallet() public view returns(address) {

    return _wallet;

  }



  function rate() public view returns(uint256) {

    return _rate;

  }



  function bonusRate() public view returns(uint256) {

    return _bonusRate;

  }



  function bonusCap() public view returns(uint256) {

    return _bonusCap;

  }



  function weiRaised() public view returns (uint256) {

    return _weiRaised;

  }



  function openingTime() public view returns(uint256) {

    return _openingTime;

  }



  function closingTime() public view returns(uint256) {

    return _closingTime;

  }



  function bonusEndTime() public view returns(uint256) {

    return _bonusEndTime;

  }



  function buyTokens(address beneficiary) public payable {

    uint256 weiAmount = msg.value;

    _preValidatePurchase(beneficiary, weiAmount);



    uint256 tokenAmount = _getTokenAmount(weiAmount);



    _weiRaised = _weiRaised.add(weiAmount);



    _token.safeTransfer(beneficiary, tokenAmount);

    emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokenAmount);



    _forwardFunds();

  }



  function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal {

    require(isOpen());

    require(beneficiary != address(0));

    require(weiAmount >= MINIMAL_CONTRIBUTION);

  }



  function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

    return weiAmount.mul(_getCurrentRate());

  }



  function _forwardFunds() internal {

    _wallet.transfer(msg.value);

  }



  function _getCurrentRate() internal view returns (uint256) {

    return isBonusTime() ? _bonusRate : _rate;

  }



  function isOpen() public view returns (bool) {

    return block.timestamp >= _openingTime && block.timestamp <= _closingTime;

  }



  function hasClosed() public view returns (bool) {

    return block.timestamp > _closingTime;

  }



  function isBonusTime() public view returns (bool) {

    return block.timestamp >= _openingTime && block.timestamp <= _bonusEndTime && _weiRaised <= _bonusCap;

  }



  // ETH balance is always expected to be 0.

  // but in case something went wrong, owner can extract ETH

  function emergencyETHDrain() external onlyOwner {

    _wallet.transfer(address(this).balance);

  }



  // owner can drain tokens that are sent here by mistake

  function emergencyERC20Drain(IERC20 tokenDrained, uint amount) external onlyOwner {

    tokenDrained.transfer(owner, amount);

  }



  // when sale is closed owner can drain any tokens left 

  function tokensLeftDrain(uint amount) external onlyOwner {

    require(hasClosed());

    _token.transfer(owner, amount);

  }

}