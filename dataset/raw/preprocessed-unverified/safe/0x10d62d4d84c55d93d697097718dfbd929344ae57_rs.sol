/**
 *Submitted for verification at Etherscan.io on 2020-01-10
*/

pragma solidity ^0.5.0;

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
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


contract chaiBatch {
    using SafeMath for uint256;
    
    address public constant chaiContract = 0x06AF07097C9Eeb7fD685c692751D5C66dB49c215;
    IERC20 chai = IERC20(chaiContract);
    
    function distributeChai(address sender, address[] memory recipients, uint256 chaiSum) public {
        for (uint256 i = 0; i < recipients.length; i++) {
		    chai.transferFrom(sender, recipients[i], chaiSum);
        }
    }
}