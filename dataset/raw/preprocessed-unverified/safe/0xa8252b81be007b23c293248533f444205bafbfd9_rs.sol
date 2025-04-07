/**
 *Submitted for verification at Etherscan.io on 2020-07-10
*/

pragma solidity 0.5.11;

contract MultiSendETH {
  using SafeMath for uint256;

  function multiSendEth(address payable[] memory addresses, uint256[] memory amounts) public payable {
    require(getTotal(addresses,amounts) <= msg.value, "invalid amount");
    for(uint i = 0; i < addresses.length; i++) {
        require(addresses[i] != address(0x0), "invalid address");
        addresses[i].transfer(amounts[i]);
    }
    msg.sender.transfer(address(this).balance);
  }
  
   function getTotal(address payable[] memory addresses, uint256[] memory amounts)  public pure returns (uint256) {
    require(addresses.length == amounts.length, "list missmatch input");
    uint256 total;
    for(uint i = 0; i < amounts.length; i++) {
      total = total.add(amounts[i]);
    }
    return total;
  }
    
}


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
