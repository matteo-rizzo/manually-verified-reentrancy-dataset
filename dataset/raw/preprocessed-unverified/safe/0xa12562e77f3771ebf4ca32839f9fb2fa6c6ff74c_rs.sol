/**
 *Submitted for verification at Etherscan.io on 2019-06-30
*/

/**
 *Submitted for verification at Etherscan.io on 2019-05-09
*/

pragma solidity ^0.4.21;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */


contract Airdrop {

    event AirdropEvent(address indexed tokencontract, address[] destinations,uint[] indexed amounts);

    function doAirDrop(address erc20TokenAddr, uint[] amounts, address[] addresses) public {
        
        IERC20 erc20Token = IERC20(erc20TokenAddr);
        uint allowance = erc20Token.allowance(msg.sender, address(this));

        for (uint i = 0; i < addresses.length; i++) {
          if (addresses[i] != address(0) && amounts[i] != 0) {
            if (allowance >= amounts[i]) {
              if (erc20Token.transferFrom(msg.sender, addresses[i], amounts[i])) {
                allowance -= amounts[i];
              }
            }
          }
        }

        emit AirdropEvent(erc20TokenAddr, addresses, amounts);
    }
}