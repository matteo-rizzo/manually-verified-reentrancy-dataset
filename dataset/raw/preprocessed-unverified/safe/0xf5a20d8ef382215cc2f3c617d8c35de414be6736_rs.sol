/**
 *Submitted for verification at Etherscan.io on 2019-10-31
*/

/**
 *Submitted for verification at Etherscan.io on 2019-10-28
*/

pragma solidity 0.5.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract Token{
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
}


/**
 * @title token token initial distribution
 *
 * @dev Distribute purchasers, airdrop, reserve, and founder tokens
 */
contract Airdrop { 
  using SafeMath for uint256;
  Token public token;
  
  event Airdropped(address _tokenContractAdd, address _recipient, uint256 _tokens);

  /**
    * @dev perform a transfer of allocations
    * @param _recipient is a list of recipients
    * @param _tokens is list of tokens to sent to recipients
    */
  function airdropTokens(address _tokenContractAdd, address[] memory _recipient, uint256[] memory _tokens) public {
    token = Token(_tokenContractAdd);
    for(uint256 i = 0; i< _recipient.length; i++)
    {
          require(token.transferFrom(msg.sender, _recipient[i], _tokens[i]));
          emit Airdropped(_tokenContractAdd, _recipient[i], _tokens[i]);
    }
  }
}