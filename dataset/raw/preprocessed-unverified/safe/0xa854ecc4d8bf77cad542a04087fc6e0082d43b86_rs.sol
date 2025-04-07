pragma solidity 0.6.12;

pragma experimental ABIEncoderV2;

// File: interfaces/IERC20.sol

// Interface declarations

/* solhint-disable func-order */



// File: interfaces/IConfigurableRightsPool.sol

// Interface declarations

// Introduce to avoid circularity (otherwise, the CRP and SmartPoolManager include each other)
// Removing circularity allows flattener tools to work, which enables Etherscan verification


// File: contracts/IBFactory.sol





// File: libraries/BalancerConstants.sol

/**
 * @author Balancer Labs
 * @title Put all the constants in one place
 */



// File: libraries/BalancerSafeMath.sol


// Imports


/**
 * @author Balancer Labs
 * @title SafeMath - wrap Solidity operators to prevent underflow/overflow
 * @dev badd and bsub are basically identical to OpenZeppelin SafeMath; mul/div have extra checks
 */


// File: libraries/SafeApprove.sol

// Imports


// Libraries

/**
 * @author PieDAO (ported to Balancer Labs)
 * @title SafeApprove - set approval for tokens that require 0 prior approval
 * @dev Perhaps to address the known ERC20 race condition issue
 *      See https://github.com/crytic/not-so-smart-contracts/tree/master/race_condition
 *      Some tokens - notably KNC - only allow approvals to be increased from 0
 */


// File: libraries/SmartPoolManager.sol


// Imports


/**
 * @author Balancer Labs
 * @title Factor out the weight updates
 */
