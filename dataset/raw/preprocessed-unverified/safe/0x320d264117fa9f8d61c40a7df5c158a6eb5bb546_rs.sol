pragma solidity ^0.4.20;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title Token
 * @dev API interface for interacting with the Token contract 
 */


/**
 * @title AirDropAFTK5May Ver 1.0
 * @dev This contract can be used for Airdrop for AFTK Token
 *
 */
contract AirDropAFTK5May is Ownable {

  Token token;
  mapping(address => uint256) public redeemBalanceOf; 
  event BalanceSet(address indexed beneficiary, uint256 value);
  event Redeemed(address indexed beneficiary, uint256 value);
  event BalanceCleared(address indexed beneficiary, uint256 value);
  event TokenSendStart(address indexed beneficiary, uint256 value);
  event TransferredToken(address indexed to, uint256 value);
  event FailedTransfer(address indexed to, uint256 value);

  function AirDropAFTK5May() public {
      address _tokenAddr = 0x7fa2f70bd4c4120fdd539ebd55c04118ba336b9e;
      token = Token(_tokenAddr);
  }

 /**
  * @dev Send approved tokens to one address
  * @param dests -> address where you want to send tokens
  * @param quantity -> number of tokens to send
  */
 function sendTokensToOneAddress(address dests, uint256 quantity)  public payable onlyOwner returns (uint) {
	TokenSendStart(dests,quantity * 10**18);
	token.approve(dests, quantity * 10**18);
	require(token.transferFrom(owner , dests ,quantity * 10**18));
    return token.balanceOf(dests);
  }
  
 /**
  * @dev Send approved tokens to seven addresses
  * @param dests1 -> address where you want to send tokens
  * @param dests2 -> address where you want to send tokens
  * @param dests3 -> address where you want to send tokens
  * @param dests4 -> address where you want to send tokens
  * @param dests5 -> address where you want to send tokens
  * @param dests6 -> address where you want to send tokens
  * @param dests7 -> address where you want to send tokens
  * @param quantity -> number of tokens to send
  */
 function sendTokensToSevenAddresses(address dests1, address dests2, address dests3, address dests4, address dests5, 
 address dests6, address dests7,  uint256 quantity)  public payable onlyOwner returns (uint) {
	TokenSendStart(dests1,quantity * 10**18);
	token.approve(dests1, quantity * 10**18);
	require(token.transferFrom(owner , dests1 ,quantity * 10**18));
	TokenSendStart(dests2,quantity * 10**18);
	token.approve(dests2, quantity * 10**18);
	require(token.transferFrom(owner , dests2 ,quantity * 10**18));
	TokenSendStart(dests3,quantity * 10**18);
	token.approve(dests3, quantity * 10**18);
	require(token.transferFrom(owner , dests3 ,quantity * 10**18));
	TokenSendStart(dests4,quantity * 10**18);
	token.approve(dests4, quantity * 10**18);
	require(token.transferFrom(owner , dests4 ,quantity * 10**18));
	TokenSendStart(dests5,quantity * 10**18);
	token.approve(dests5, quantity * 10**18);
	require(token.transferFrom(owner , dests5 ,quantity * 10**18));
	TokenSendStart(dests6,quantity * 10**18);
	token.approve(dests6, quantity * 10**18);
	require(token.transferFrom(owner , dests6 ,quantity * 10**18));
	TokenSendStart(dests7,quantity * 10**18);
	token.approve(dests7, quantity * 10**18);
	require(token.transferFrom(owner , dests7 ,quantity * 10**18));
	return token.balanceOf(dests7);
  }
  
 
 /**
  * @dev admin can destroy this contract
  */
  function destroy() onlyOwner public { uint256 tokensAvailable = token.balanceOf(this); require (tokensAvailable > 0); token.transfer(owner, tokensAvailable);  selfdestruct(owner);  } 
}