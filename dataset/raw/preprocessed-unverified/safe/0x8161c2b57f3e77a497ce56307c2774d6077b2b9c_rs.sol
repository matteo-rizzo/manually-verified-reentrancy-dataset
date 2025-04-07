/**
 *Submitted for verification at Etherscan.io on 2020-12-19
*/

/**
 * SPDX-License-Identifier: UNLICENSED
*/

pragma solidity 0.6.8;





contract rfiSantaSale {
  using SafeMath for uint256;

  uint256 public totalSold;
  ERC20 public rfiSantaToken;
  address payable public owner;
  uint256 public collectedETH;
  uint256 public startDate;
  bool public softCapMet;
  bool private presaleClosed = false;
  uint256 private ethWithdrawals = 0;
  uint256 private lastWithdrawal;

  mapping(address => uint256) internal _contributions;
  mapping(address => uint256) internal _averagePurchaseRate;
  mapping(address => uint256) internal _numberOfContributions;

  constructor(address _wallet) public {
    owner = msg.sender;
    rfiSantaToken = ERC20(_wallet);
  }

  uint256 amount;
  uint256 ratepereth = 25;
 
  receive () external payable {
    require(startDate > 0 && now.sub(startDate) <= 2 days);
    require(rfiSantaToken.balanceOf(address(this)) > 0);
    require(msg.value >= 0.1 ether && msg.value <= 3 ether);
    require(!presaleClosed);
     
    if (now.sub(startDate) <= 1 days) {
       amount = msg.value.mul(25);
       _averagePurchaseRate[msg.sender] = _averagePurchaseRate[msg.sender].add(ratepereth.mul(10));
    } else if(now.sub(startDate) > 1 days && now.sub(startDate) <= 2 days) {
       amount = msg.value.mul(25);
       _averagePurchaseRate[msg.sender] = _averagePurchaseRate[msg.sender].add(ratepereth.mul(10));
    }
    
    require(amount <= rfiSantaToken.balanceOf(address(this)));
    totalSold = totalSold.add(amount);
    collectedETH = collectedETH.add(msg.value);
    _contributions[msg.sender] = _contributions[msg.sender].add(amount);
    _numberOfContributions[msg.sender] = _numberOfContributions[msg.sender].add(1);
    rfiSantaToken.transfer(msg.sender, amount);
    if (!softCapMet && collectedETH >= 1 ether) {
      softCapMet = true;
    }
  }

  function contribute() external payable {
    require(startDate > 0 && now.sub(startDate) <= 2 days);
    require(rfiSantaToken.balanceOf(address(this)) > 0);
    require(msg.value >= 0.1 ether && msg.value <= 3 ether);
    require(!presaleClosed);

    if (now.sub(startDate) <= 1 days) {
       amount = msg.value.mul(25);
       _averagePurchaseRate[msg.sender] = _averagePurchaseRate[msg.sender].add(ratepereth.mul(10));
    } else if(now.sub(startDate) > 1 days && now.sub(startDate) <= 2 days) {
       amount = msg.value.mul(25);
       _averagePurchaseRate[msg.sender] = _averagePurchaseRate[msg.sender].add(ratepereth.mul(10));
    }
        
    require(amount <= rfiSantaToken.balanceOf(address(this)));
    totalSold = totalSold.add(amount);
    collectedETH = collectedETH.add(msg.value);
    _contributions[msg.sender] = _contributions[msg.sender].add(amount);
    _numberOfContributions[msg.sender] = _numberOfContributions[msg.sender].add(1);
    rfiSantaToken.transfer(msg.sender, amount);
    if (!softCapMet && collectedETH >= 1 ether) {
      softCapMet = true;
    }
  }

  function numberOfContributions(address from) public view returns(uint256) {
    return _numberOfContributions[address(from)]; 
  }

  function contributions(address from) public view returns(uint256) {
    return _contributions[address(from)];
  }

  function averagePurchaseRate(address from) public view returns(uint256) {
    return _averagePurchaseRate[address(from)];
  }

  function buyBackETH(address payable from) public {
    require(now.sub(startDate) > 3 days && !softCapMet);
    require(_contributions[from] > 0);
    uint256 exchangeRate = _averagePurchaseRate[from].div(10).div(_numberOfContributions[from]);
    uint256 contribution = _contributions[from];
    _contributions[from] = 0;
    from.transfer(contribution.div(exchangeRate));
  }

  function withdrawETH() public {
    require(msg.sender == owner && address(this).balance > 0);
    require(softCapMet == true && presaleClosed == true);
    uint256 withdrawAmount;
    if (ethWithdrawals == 0) {
      if (collectedETH <= 25 ether) {
        withdrawAmount = collectedETH;
      } else {
        withdrawAmount = 25 ether;
      }
    } else {
      uint256 currDate = now;
      require(currDate.sub(lastWithdrawal) >= 1 days);
      if (collectedETH <= 25 ether) {
        withdrawAmount = collectedETH;
      } else {
        withdrawAmount = 25 ether;
      }
    }
    lastWithdrawal = now;
    ethWithdrawals = ethWithdrawals.add(1);
    collectedETH = collectedETH.sub(withdrawAmount);
    owner.transfer(withdrawAmount);
  }

  function endPresale() public {
    require(msg.sender == owner);
    presaleClosed = true;
  }

  function burnrfiSanta() public {
    require(msg.sender == owner && rfiSantaToken.balanceOf(address(this)) > 0 && now.sub(startDate) > 1 days);
    rfiSantaToken.transfer(address(0), rfiSantaToken.balanceOf(address(this)));
  }
  
  function startSale() public {
    require(msg.sender == owner && startDate==0);
    startDate=now;
  }
  
  function availablerfiSanta() public view returns(uint256) {
    return rfiSantaToken.balanceOf(address(this));
  }
}