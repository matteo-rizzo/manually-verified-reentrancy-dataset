pragma solidity ^0.4.21;


contract RealEstateCryptoFund {
  function transfer(address to, uint256 value) public returns (bool);
  function balanceOf(address who) public constant returns (uint256);
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



contract Bounty is Ownable {
  uint256 public BountyAmount;

  RealEstateCryptoFund public token;

  mapping(address=>bool) public participated;

  event TokenBounty(address indexed beneficiary, uint256 amount);

  event BountyAmountUpdate(uint256 BountyAmount);
  
  function Bounty(address _tokenAddress) public {
    token = RealEstateCryptoFund (_tokenAddress);
  }

  function () external payable {
    getTokens(msg.sender);
  }

  function setBountyAmount(uint256 _BountyAmount) public onlyOwner {
    require(_BountyAmount > 0);
    BountyAmount = _BountyAmount;
    emit BountyAmountUpdate(BountyAmount);
  }

  function getTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase(beneficiary));
    
    token.transfer(beneficiary, BountyAmount);

    emit TokenBounty(beneficiary, BountyAmount);

    participated[beneficiary] = true;
  }

  
  function validPurchase(address beneficiary) internal view returns (bool) {
    bool hasParticipated = participated[beneficiary];
    return !hasParticipated;
  }
}


contract RealEstateCryptoFundBounty is Bounty {
  function RealEstateCryptoFundBounty (address _tokenAddress) public
    Bounty(_tokenAddress)
  {

  }

  function drainRemainingTokens () public onlyOwner {
    token.transfer(owner, token.balanceOf(this));
  }
}