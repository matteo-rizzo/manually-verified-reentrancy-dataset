/**

 *Submitted for verification at Etherscan.io on 2018-10-11

*/



pragma solidity 0.4.24;







/**

 * @title ERC20Token Interface

 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

 */

contract ERC20Token {

  function name() public view returns (string);

  function symbol() public view returns (string);

  function decimals() public view returns (uint);

  function totalSupply() public view returns (uint);

  function balanceOf(address account) public view returns (uint);

  function transfer(address to, uint amount) public returns (bool);

  function transferFrom(address from, address to, uint amount) public returns (bool);

  function approve(address spender, uint amount) public returns (bool);

  function allowance(address owner, address spender) public view returns (uint);

}





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */







/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







/**

 * @title This contract handles the airdrop distribution

 */

contract INNBCAirdropDistribution is Ownable {

  address public tokenINNBCAddress;



  /**

   * @dev Sets the address of the INNBC token

   * @param tokenAddress The address of the INNBC token contract

   */

  function setINNBCTokenAddress(address tokenAddress) external onlyOwner() {

    require(tokenAddress != address(0), "Token address cannot be null");



    tokenINNBCAddress = tokenAddress;

  }



  /**

   * @dev Batch transfers tokens from the owner account to the recipients

   * @param recipients An array of the addresses of the recipients

   * @param amountPerRecipient An array of amounts of tokens to give to each recipient

   */

  function airdropTokens(address[] recipients, uint[] amountPerRecipient) external onlyOwner() {

    /* 100 recipients is the limit, otherwise we may reach the gas limit */

    require(recipients.length <= 100, "Recipients list is too long");



    /* Both arrays need to have the same length */

    require(recipients.length == amountPerRecipient.length, "Arrays do not have the same length");



    /* We check if the address of the token contract is set */

    require(tokenINNBCAddress != address(0), "INNBC token contract address cannot be null");



    ERC20Token tokenINNBC = ERC20Token(tokenINNBCAddress);



    /* We check if the owner has enough tokens for everyone */

    require(

      calculateSum(amountPerRecipient) <= tokenINNBC.balanceOf(msg.sender),

      "Sender does not have enough tokens"

    );



    /* We check if the contract is allowed to handle this amount */

    require(

      calculateSum(amountPerRecipient) <= tokenINNBC.allowance(msg.sender, address(this)),

      "This contract is not allowed to handle this amount"

    );



    /* If everything is okay, we can transfer the tokens */

    for (uint i = 0; i < recipients.length; i += 1) {

      tokenINNBC.transferFrom(msg.sender, recipients[i], amountPerRecipient[i]);

    }

  }



  /**

   * @dev Calculates the sum of an array of uints

   * @param a An array of uints

   * @return The sum as an uint

   */

  function calculateSum(uint[] a) private pure returns (uint) {

    uint sum;



    for (uint i = 0; i < a.length; i = SafeMath.add(i, 1)) {

      sum = SafeMath.add(sum, a[i]);

    }



    return sum;

  }

}