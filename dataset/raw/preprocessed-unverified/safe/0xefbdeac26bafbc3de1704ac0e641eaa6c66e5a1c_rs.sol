/**

 *Submitted for verification at Etherscan.io on 2019-03-01

*/



pragma solidity 0.4.25;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------





contract Token{

    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    function balanceOf(address tokenOwner) public view returns (uint balance);

}





/**

 * @title token token initial distribution

 *

 * @dev Distribute purchasers, airdrop, reserve, and founder tokens

 */

contract Airdrop is Owned {

  using SafeMath for uint256;

  Token public token;

  uint256 private constant decimalFactor = 10**uint256(18);

  // Keeps track of whether or not a token airdrop has been made to a particular address

  mapping (address => bool) public airdrops;

  

  /**

    * @dev Constructor function - Set the token token address

  */

  constructor(address _tokenContractAdd, address _owner) public {

    // takes an address of the existing token contract as parameter

    token = Token(_tokenContractAdd);

    owner = _owner;

  }

  

  /**

    * @dev perform a transfer of allocations

    * @param _recipient is a list of recipients

    */

  function airdropTokens(address[] _recipient, uint256[] _tokens) external onlyOwner{

    for(uint256 i = 0; i< _recipient.length; i++)

    {

        uint256 tokens = token.balanceOf(_recipient[i]);

        if ((!airdrops[_recipient[i]]) && ( tokens == 0)) {

          airdrops[_recipient[i]] = true;

          require(token.transferFrom(msg.sender, _recipient[i], _tokens[i] * decimalFactor));

        }

    }

  }

}