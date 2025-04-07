/**

 *Submitted for verification at Etherscan.io on 2018-09-17

*/



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

 * @title RedeemAFTKTokenCampaign Ver 1.0 - Sept 17, 2018

 * @dev This contract can be used for AFTK token redumption. 

 *       Admin will setBalance for users who can redeem tokens.

 */

contract RedeemAFTKTokenCampaign is Ownable {



  Token token;

  mapping(address => uint256) public redeemBalanceOf;

  event BalanceSet(address indexed beneficiary, uint256 value);

  event Redeemed(address indexed beneficiary, uint256 value);

  event BalanceCleared(address indexed beneficiary, uint256 value);



  function RedeemAFTKTokenCampaign() public {

      address _tokenAddr = 0x7Fa2F70bD4C4120fDD539EBd55c04118ba336b9E;

      token = Token(_tokenAddr);

  }



function setBalances(address[] dests, uint256[] values) onlyOwner public {

    uint256 i = 0; 

    while (i < dests.length){

        if(dests[i] != address(0)) 

        {

            uint256 toSend = values[i] * 10**18;

            redeemBalanceOf[dests[i]] += toSend;

            BalanceSet(dests[i],values[i]);

        }

        i++;

    }

  }



  function redeem(uint256 quantity) public {

      uint256 baseUnits = quantity * 10**18;

      uint256 senderEligibility = redeemBalanceOf[msg.sender];

      uint256 tokensAvailable = token.balanceOf(this);

      require(senderEligibility >= baseUnits);

      require( tokensAvailable >= baseUnits);

      if(token.transfer(msg.sender,baseUnits)){

        redeemBalanceOf[msg.sender] -= baseUnits;

        Redeemed(msg.sender,quantity);

      }

  }



  function removeBalances(address[] dests, uint256[] values) onlyOwner public {

    uint256 i = 0; 

    while (i < dests.length){

        if(dests[i] != address(0)) 

        {

            uint256 toRevoke = values[i] * 10**18;

            if(redeemBalanceOf[dests[i]]>=toRevoke)

            {

                redeemBalanceOf[dests[i]] -= toRevoke;

                BalanceCleared(dests[i],values[i]);

            }

        }

        i++;

    }



  }

  

  function getAvailableTokenCount() public view returns (uint256 balance)  {return token.balanceOf(this);} 

  /**

  * @dev admin can destroy this contract

  */

  function destroy() onlyOwner public { uint256 tokensAvailable = token.balanceOf(this); require (tokensAvailable > 0); token.transfer(owner, tokensAvailable);  selfdestruct(owner);  } 



}