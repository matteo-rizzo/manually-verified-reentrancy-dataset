/**

 *Submitted for verification at Etherscan.io on 2018-08-10

*/



pragma solidity ^0.4.24;



















contract BitSongCrowdsale is Ownable{

  using SafeMath for uint256;

  using SafeERC20 for ERC20;



  ERC20 public token;

  address public wallet;

  uint256 public rate;

  uint256 public weiRaised;

  address public kycAdmin;

  uint256 public hardCap;

  uint256 public tokensAllocated;

  uint256 public openingTime;

  uint256 public closingTime;

  uint256 public duration;



  mapping(address => bool) public approvals;

  mapping(address => uint256) public balances;



  event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

  event KycApproved(address indexed beneficiary, address indexed admin, bool status);

  event KycRefused(address indexed beneficiary, address indexed admin, bool status);



  modifier onlyKycAdmin() { require(msg.sender == kycAdmin); _; }

  modifier onlyWhileOpen { require(block.timestamp >= openingTime && block.timestamp <= closingTime); _; }



  constructor(uint256 _rate, address _wallet, uint256 _duration, uint256 _hardCap, ERC20 _tokenAddress) public {

    require(_rate > 0);

    require(_wallet != address(0));

    require(_tokenAddress != address(0));



    rate = _rate;

    wallet = _wallet;

    token = _tokenAddress;

    hardCap = _hardCap * 10**18;

    duration = _duration * 1 days;

  }



  function () external payable {

    buyTokens();

  }



  function buyTokens() public onlyWhileOpen() payable {

    require(msg.value > 0);

    require(approvals[msg.sender] == true);

    uint256 weiAmount = msg.value;

    uint256 tokenAmount = weiAmount.mul(rate);

    tokensAllocated = tokensAllocated.add(tokenAmount);

    assert(tokensAllocated <= hardCap);

    weiRaised = weiRaised.add(weiAmount);

    balances[msg.sender] = balances[msg.sender].add(tokenAmount);

    emit TokenPurchase(msg.sender, weiAmount, tokenAmount);

    wallet.transfer(msg.value);

  }



  function withdrawTokens() external {

    require(hasClosed());

    uint256 amount = balances[msg.sender];

    require(amount > 0);

    balances[msg.sender] = 0;

    token.safeTransferFrom(wallet, msg.sender, amount);

  }



  function withdrawTokensFor(address _beneficiary) external {

    require(hasClosed());

    uint256 amount = balances[_beneficiary];

    require(amount > 0);

    balances[_beneficiary] = 0;

    token.safeTransferFrom(wallet, _beneficiary, amount);

  }



  function hasClosed() public view returns (bool) {

    return block.timestamp > closingTime;

  }



  function approveAddress(address _beneficiary) external onlyKycAdmin() {

    approvals[_beneficiary] = true;

    emit KycApproved(_beneficiary, kycAdmin, true);

  }



  function refuseAddress(address _beneficiary) external onlyKycAdmin() {

    approvals[_beneficiary] = false;

    emit KycRefused(_beneficiary, kycAdmin, false);

  }



  function rewardManual(address _beneficiary, uint256 _amount) external onlyOwner() {

    require(_amount > 0);

    require(_beneficiary != address(0));

    tokensAllocated = tokensAllocated.add(_amount);

    assert(tokensAllocated <= hardCap);

    balances[_beneficiary] = balances[_beneficiary].add(_amount);

  }



  function transfer(address _beneficiary, uint256 _amount) external onlyOwner() {

    require(_amount > 0);

    require(_beneficiary != address(0));

    token.safeTransfer(_beneficiary, _amount);

  }



  function setKycAdmin(address _newAdmin) external onlyOwner() {

    kycAdmin = _newAdmin;

  }



  function startDistribution() external onlyOwner() {

    require(openingTime == 0);

    openingTime = block.timestamp;

    closingTime = openingTime.add(duration);

  }



  function setRate(uint256 _newRate) external onlyOwner() {

    rate = _newRate;

  }



  function setClosingTime(uint256 _newTime) external onlyOwner() {

    closingTime = _newTime;

  }

}