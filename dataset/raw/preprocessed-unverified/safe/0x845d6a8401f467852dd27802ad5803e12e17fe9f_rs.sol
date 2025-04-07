/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

pragma solidity >= 0.6.4;





contract glare is Owned {
  using SafeMath for uint;

  constructor() public {
    buyMinimum = 10**16;
    sellMinimum = 10**16;
    buyTax = 10 * 10**2;
    referRate = 25 * 10**2;
    referRateMasternode = 50 * 10**2;

    earlyPenalty = 90 * 10**2;
    cdGLXMin = 10**17;
    cdDurrationMax = 365;

    scalefactor = 10**12;
  }

  struct accountCDStruct {
    uint256 tokenAmount;
    uint256 created;
    uint256 contractDurration;
    bool closed;
  }

  IERC20 public glaretoken; //GLX token interface

  //BASE BUY AND SELL VARIABLES
  uint256 public scalefactor;         //Price scalar
  uint256 public buyMinimum;          //minimum buy value in ETH
  uint256 public sellMinimum;         //minimum sell value in ETH
  uint256 public buyTax;              //buy tax in 100x tax %
  uint256 public referRate;           //ref rate in 100x ref %
  uint256 public referRateMasternode; //masternode ref rate in 100x ref %

  mapping(address => bool) public masternode; //is a refer address a masternode?
  mapping(address => address) public referBook; //refer book address --> refer address

  //CD VARIABLES
  uint256 public tokenTime; //Total number of GLX days
  uint256 public cdGLXMin;
  uint256 public cdDurrationMax;
  uint256 public earlyPenalty; //penalty for closing contract early in 100x 100% - penalty %
  mapping(address => accountCDStruct[]) public accountCD; //account --> id --> contract data



  function buyTokens(address inputrefer) public payable {
    require(msg.value >= buyMinimum, "Does not meet buy minimum");
    uint256 tokens = getTokenBuyResult();
    uint256 taxedTokens = tokens.mul(buyTax).div(10**4);
    uint256 userTokens = tokens.sub(taxedTokens);


    //REF CHECK
    address refer = referBook[msg.sender];
    if(refer == address(0)) {
      refer = inputrefer;
    }
    if(refer != msg.sender) {
      if(refer != address(0)) {
        if(referBook[msg.sender] == address(0)) {
          referBook[msg.sender] = refer;
        }
      }
    }
    //IF REFER PAY THEM
    if(referBook[msg.sender] != address(0)) {
      if(masternode[refer] == true){
        uint256 refamt = referRateMasternode.mul(taxedTokens).div(10**4);
        mintGlareToken(refer, refamt);
        mintGlareToken(address(this), taxedTokens.sub(refamt));
      }
      else {
        uint256 refamt = referRate.mul(taxedTokens).div(10**4);
        mintGlareToken(refer, refamt);
        mintGlareToken(address(this), taxedTokens.sub(refamt));
      }
    }
    else {
      mintGlareToken(address(this), taxedTokens);
    }

    mintGlareToken(msg.sender, userTokens);
  }

  function sellTokens(uint256 amount) public {
    uint256 eth = getTokenSellResult(amount);
    address payable account = msg.sender;
    require(eth >= sellMinimum, "Does not meet sell minimum");
    require(glaretoken.balanceOf(msg.sender) >= amount, "Sell amount exceeds balance");
    burnGlareToken(account, amount);
    account.transfer(eth);
  }

  function openCD(uint256 amount, uint256 durration) public {
    require(amount >= cdGLXMin, "Token amount less than minimum");
    require(durration > 0, "CD durration must be at least 1 day");
    require(durration <= cdDurrationMax, "CD durration longer than maximum");
    require(glaretoken.balanceOf(msg.sender) >= amount, "Lock amount exceeds balance");
    require(glaretoken.transferFrom(msg.sender, address(this), amount));
    tokenTime = amount.mul(durration).div(10**13).add(tokenTime);

    accountCDStruct memory newcd;
    newcd.tokenAmount = amount;
    newcd.contractDurration = durration;
    newcd.created = now;

    accountCD[msg.sender].push(newcd);
  }

  function closeCD(uint256 index) public {
    require(accountCD[msg.sender][index].tokenAmount != 0);
    require(accountCD[msg.sender][index].closed == false);

    uint256 contractTokenTime = accountCD[msg.sender][index].contractDurration.mul(accountCD[msg.sender][index].tokenAmount).div(10**13);
    uint256 tokensdue = contractTokenTime.mul(glaretoken.balanceOf(address(this))).div(tokenTime);

    if(accountCD[msg.sender][index].created.add(accountCD[msg.sender][index].contractDurration.mul(1 days)) > now) {
      tokensdue = earlyPenalty.mul(accountCD[msg.sender][index].tokenAmount).div(10**4);
    }

    tokenTime = tokenTime.sub(contractTokenTime);

    accountCD[msg.sender][index].closed = true;
    glaretoken.transfer(msg.sender, tokensdue);
  }

  //VIEW FUNCTIONS
  //returns the spot price in terms of eth / token
  function spotprice() public view returns(uint256) {
    if(glaretoken.totalSupply() == 0) {
      return(0);
    }
    else {
      return(address(this).balance.mul(2 * 10**18).div(glaretoken.totalSupply()));
    }
  }
  function getTokenBuyResult() public view returns(uint256) {
    uint256 _sold = glaretoken.totalSupply();
    uint256 _ethnew = address(this).balance;
    uint256 _snew = sqrt(_ethnew.mul(2 * 10**18).div(scalefactor)).mul(10**9);
    uint256 _sout = _snew - _sold;
    return(_sout);
  }
  function getTokenSellResult(uint256 amount) public view returns(uint256) {
    uint256 _ethold = address(this).balance;
    uint256 _sold = glaretoken.totalSupply();
    uint256 _snew = _sold.sub(amount);
    uint256 _ethnew = scalefactor.mul(_snew**2).div(2*10**36);
    uint256 _ethout = _ethold - _ethnew;
    return(_ethout);
  }

  function getAccountCDLength(address account) public view returns(uint256) {
    return(accountCD[account].length);
  }

  //INTERNAL FUNCTIONS
  function mintGlareToken(address account, uint256 amount) internal {
    glaretoken.mint(account, amount);
  }
  function burnGlareToken(address account, uint256 amount) internal {
    glaretoken.burn(account, amount);
  }

  //ADMIN FUNCTIONS
  function setBuyMinimum(uint256 eth) public onlyOwner() {
    buyMinimum = eth;
  }
  function setSellMinimum(uint256 eth) public onlyOwner() {
    sellMinimum = eth;
  }
  function setMasternode(address account, bool status) public onlyOwner() {
    masternode[account] = status;
  }
  function setGlareToken(IERC20 _glaretoken) public onlyOwner() {
    glaretoken = _glaretoken;
  }
  function setCdGLXMin(uint256 amount) public onlyOwner() {
    cdGLXMin = amount;
  }
  function setCdDurrationMax(uint256 durration) public onlyOwner() {
    cdDurrationMax = durration;
  }

  //Additional needed math functions not part of safemath
  function sqrt(uint x) internal pure returns (uint y) {
    uint z = (x + 1) / 2;
    y = x;
    while (z < y) {
        y = z;
        z = (x / z + z) / 2;
    }
}

  fallback() external payable{
    revert();
  }
    receive() external payable {
    revert();
  }

}

