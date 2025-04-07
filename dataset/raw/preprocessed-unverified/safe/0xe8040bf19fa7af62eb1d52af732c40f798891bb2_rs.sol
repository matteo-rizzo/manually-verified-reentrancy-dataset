pragma solidity ^0.4.23;



contract Airdrop {
  address public owner;
  bool public isTheContract = true;

  constructor() public {
  
    owner = msg.sender;
  }

  function sendTokens(address[] addresses, uint256[] _amount, address _tokenAddress) public {
    //require(msg.sender == owner);
    uint256 addressCount = addresses.length;
    uint256 amountCount = _amount.length;
    require(addressCount == amountCount);
    TokenContract tkn = TokenContract(_tokenAddress);
    for (uint256 i = 0; i < addressCount; i++) {
      tkn.transferFrom(msg.sender, addresses[i], _amount[i]);
    }
  }

  function destroyMe() public {
    require(msg.sender == owner);
    selfdestruct(owner);
  }
    
}