pragma solidity ^0.4.19;





contract PrivateSaleMacau {

  using Math for uint256;

  struct Info {
    uint256 weiPaid;
    uint256 fstVested;
  }

  event BuyFST(address indexed user, uint256 fstValue, uint256 weiValue, uint256 timestamp);
  event Release(address indexed user, uint256 value);
  event Refund(address indexed user, uint256 value);
  event Collect(uint256 weiAmount, uint256 fstAmount);

  // 330M FST
  uint256 public constant fstTotalSupply = 330000000 * (10 ** 18);

  // 5%
  uint256 public constant fstPrivateSalePortionNumerator   = 5;
  uint256 public constant fstPrivateSalePortionDenominator = 100;

  // 1 ETH = 3600 FST in private sale
  uint256 public constant fstUnitPriceNumerator   = 1;
  uint256 public constant fstUnitPriceDenominator = 3600;

  // 5% of 330M FST
  uint256 public constant saleCap =
    fstTotalSupply * fstPrivateSalePortionNumerator / fstPrivateSalePortionDenominator;

  // minimum wei value = 10 ether
  uint256 public constant minWeiValue = 10 ether;

  // start time, end time
  uint256 public constant startTime = 1515837600; // Saturday, January 13, 2018 6:00:00 PM GMT+08:00
  uint256 public constant endTime   = 1516269600; // Thursday, January 18, 2018 6:00:00 PM GMT+08:00

  // private sale progress
  uint256 public fstSold     = 0;
  uint256 public weiReceived = 0;
  uint256 public weiLiquid   = 0;
  uint256 public weiRefund   = 0;

  mapping (address => Info) public users;

  // Funder Smart Token
  ERC20 public token;

  // manager
  address public manager;

  function PrivateSaleMacau (ERC20 _token) public {
    token   = _token;
    manager = msg.sender;
  }

  function buy () payable public returns (bool) {
    require(
      minWeiValue     <= msg.value &&
      fstSold         <  saleCap   &&
      block.timestamp >= startTime &&
      block.timestamp <  endTime
    );

    uint256 eth = msg.value;
    uint256 fst = eth.mul(fstUnitPriceDenominator).div(fstUnitPriceNumerator);

    uint256 fstAvailable = saleCap - fstSold;
    if (fst > fstAvailable) {
      uint256 refund = (fst - fstAvailable).mul(fstUnitPriceNumerator).div(fstUnitPriceDenominator);
      msg.sender.transfer(refund); // 2300 gas only
      eth -= refund;
      fst = fstAvailable;
    }

    Info storage user = users[msg.sender];
    user.weiPaid += eth;
    user.fstVested += fst;
    weiReceived += eth;
    fstSold += fst;

    BuyFST(msg.sender, fst, eth, block.timestamp);
    return true;
  }

  function () payable public {
    require(buy());
  }

  function transferOwnership (address _to) public returns (bool) {
    require(msg.sender == manager);
    manager = _to;
    return true;
  }

  // on kyc result
  function processPurchase(uint256[] results) public {
    require(msg.sender == manager);

    for (uint256 i = 0; i < results.length; i++) {
      address userAddress = address(results[i] >> 96);
      Info storage user = users[userAddress];
      require(user.weiPaid > 0);

      // kyc success
      if ((results[i] & 0x1) == 1) {
        weiLiquid += user.weiPaid;
        token.transfer(userAddress, user.fstVested);
        Release(msg.sender, user.fstVested);
      } else {
        fstSold -= user.fstVested;
        weiRefund += user.weiPaid;
        userAddress.transfer(user.weiPaid);
        Refund(msg.sender, user.weiPaid);
      }

      delete users[userAddress];
    }
  }

  function finalize() public {
    require(msg.sender == manager && block.timestamp >= endTime);

    uint256 weiVested = weiReceived - weiLiquid - weiRefund;
    uint256 weiAvailable = this.balance - weiVested;
    if (weiAvailable > 0) {
      msg.sender.transfer(weiAvailable);
    }

    uint256 tokenAvailable = token.balanceOf(this);
    if (tokenAvailable > 0) {
      token.transfer(msg.sender, tokenAvailable);      
    }
    
    Collect(weiAvailable, tokenAvailable);
  }
}