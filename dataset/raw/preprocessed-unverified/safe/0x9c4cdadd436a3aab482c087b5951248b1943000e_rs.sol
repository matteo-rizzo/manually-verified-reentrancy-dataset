/**

 *Submitted for verification at Etherscan.io on 2018-12-18

*/



/* ===============================================

* Flattened with Solidifier by Coinage

* 

* https://solidifier.coina.ge

* ===============================================

*/





////////////////// SafeMath.sol //////////////////



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */







////////////////// SafeDecimalMath.sol //////////////////



/*



-----------------------------------------------------------------

FILE INFORMATION

-----------------------------------------------------------------



file:       SafeDecimalMath.sol

version:    2.0

author:     Kevin Brown

            Gavin Conway

date:       2018-10-18



-----------------------------------------------------------------

MODULE DESCRIPTION

-----------------------------------------------------------------



A library providing safe mathematical operations for division and

multiplication with the capability to round or truncate the results

to the nearest increment. Operations can return a standard precision

or high precision decimal. High precision decimals are useful for

example when attempting to calculate percentages or fractions

accurately.



-----------------------------------------------------------------

*/





/**

 * @title Safely manipulate unsigned fixed-point decimals at a given precision level.

 * @dev Functions accepting uints in this contract and derived contracts

 * are taken to be such fixed point decimals of a specified precision (either standard

 * or high).

 */

