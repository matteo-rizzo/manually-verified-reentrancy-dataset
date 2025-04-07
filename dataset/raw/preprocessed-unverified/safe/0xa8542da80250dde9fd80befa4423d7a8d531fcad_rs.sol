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



contract Airdrop is Ownable {
  uint256 public airdropAmount;

  RealEstateCryptoFund public token;

  mapping(address=>bool) public participated;

  event TokenAirdrop(address indexed beneficiary, uint256 amount);

  event AirdropAmountUpdate(uint256 airdropAmount);
  
  function Airdrop(address _tokenAddress) public {
    token = RealEstateCryptoFund (_tokenAddress);
  }

  function () external payable {
    getTokens(msg.sender);
  }

  function setAirdropAmount(uint256 _airdropAmount) public onlyOwner {
    require(_airdropAmount > 0);
    airdropAmount = _airdropAmount;
    emit AirdropAmountUpdate(airdropAmount);
  }

  function getTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase(beneficiary));
    
    token.transfer(beneficiary, airdropAmount);

    emit TokenAirdrop(beneficiary, airdropAmount);

    participated[beneficiary] = true;
  }

  
  function validPurchase(address beneficiary) internal view returns (bool) {
    bool hasParticipated = participated[beneficiary];
    return !hasParticipated;
  }
}


contract RealEstateCryptoFundAirdrop is Airdrop {
  function RealEstateCryptoFundAirdrop (address _tokenAddress) public
    Airdrop(_tokenAddress)
  {

  }

  function drainRemainingTokens () public onlyOwner {
    token.transfer(owner, token.balanceOf(this));
  }
}