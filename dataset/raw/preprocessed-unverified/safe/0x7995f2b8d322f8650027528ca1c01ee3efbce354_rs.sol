/**
 *Submitted for verification at Etherscan.io on 2020-02-19
*/

pragma solidity 0.5.13;

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


// Beta program for ERC20 token swap deals. Use at own risk!
contract tokenSwap {
    using SafeMath for uint256;
    
    event Swapped(address indexed caller, address indexed counterparty, string indexed details);
    
    function Swap( 
    	uint256 partyAswap,
    	IERC20 partyAtkn,
    	address partyB,
    	uint256 partyBswap,
    	IERC20 partyBtkn,
        string memory details) public {
        
        partyAtkn.transferFrom(msg.sender, partyB, partyAswap);
        partyBtkn.transferFrom(partyB, msg.sender, partyBswap);
        	 
        emit Swapped(msg.sender, partyB, details); 
    }
}