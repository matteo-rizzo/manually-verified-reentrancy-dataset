// v7



/**

 * Affiliate.sol

 */



pragma solidity ^0.4.23;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





/**

 * @title TokenContract

 * @dev Token contract interface with transfer and balanceOf functions which need to be implemented

 */





/**

 * @title Affiliate

 * @dev Affiliate contract collects and stores all affiliates and token earnings for each affiliate

 */

contract Affiliate is Ownable {



  TokenContract public tkn;

  mapping (address => uint256) affiliates;



  /**

   * @dev Add affiliates in affiliate mapping

   * @param _affiliates List of all affiliates

   * @param _amount Amount earned

   */

  function addAffiliates(address[] _affiliates, uint256[] _amount) onlyOwner public {

    require(_affiliates.length > 0);

    require(_affiliates.length == _amount.length);

    for (uint256 i = 0; i < _affiliates.length; i++) {

      affiliates[_affiliates[i]] = _amount[i];

    }

  }



  /**

   * @dev Claim reward collected through your affiliates

   */

  function claimReward() public {

    if (affiliates[msg.sender] > 0) {

      require(tkn.transfer(msg.sender, affiliates[msg.sender]));

      affiliates[msg.sender] = 0;

    }

  }



  /**

   * @dev Terminate the Affiliate contract and destroy it

   */

  function terminateContract() onlyOwner public {

    uint256 amount = tkn.balanceOf(address(this));

    require(tkn.transfer(owner, amount));

    selfdestruct(owner);

  }

}