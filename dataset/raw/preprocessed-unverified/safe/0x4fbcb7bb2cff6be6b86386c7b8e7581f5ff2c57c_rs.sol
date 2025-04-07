/**

 *Submitted for verification at Etherscan.io on 2019-03-15

*/



pragma solidity ^0.4.19;













contract Airdrop is Owned {

  /**

   * @dev daAirdrop to address

   * @param _tokenAddr address the erc20 token address

   * @param dests address[] addresses to airdrop

   * @param values uint256[] value(in ether) to airdrop

   */

  function doAirdrop(address _tokenAddr, address[] dests, uint256[] values) onlyOwner public returns (uint256) {

    uint256 i = 0;

    while (i < dests.length) {

      token(_tokenAddr).transferFrom(msg.sender, dests[i], values[i] * (10 ** 18));

      i += 1;

    }

    return(i);

  }

}