/**
 *Submitted for verification at Etherscan.io on 2021-02-01
*/

pragma solidity ^0.6.12;


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


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract Distributor {
    using SafeMath for uint256;

    address constant public address0 = address(0x6Ec1f0e5d98cD11f6987F0e97A4fB5A966E268Ed);
    address constant public address1  = address(0x68039Bcf3b10e75beC7485889050807E60F72C79);

    constructor() public {
    }

    function transfer(address token) public {
        uint256 bal = IERC20(token).balanceOf(address(this));
        uint256 bal0 = bal.div(4);
        uint256 bal1 = bal.sub(bal0);
        IERC20(token).transfer(address0, bal0);
        IERC20(token).transfer(address1, bal1);
    }
}