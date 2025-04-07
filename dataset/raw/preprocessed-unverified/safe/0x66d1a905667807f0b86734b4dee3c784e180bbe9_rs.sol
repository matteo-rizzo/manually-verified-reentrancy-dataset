/**

 *Submitted for verification at Etherscan.io on 2019-03-01

*/



pragma solidity ^0.4.24;



// File: contracts/identity/KeyHolderLibrary.sol



/**

 * @title Library for KeyHolder.

 * @notice Fork of Origin Protocol's implementation at

 * https://github.com/OriginProtocol/origin/blob/master/origin-contracts/contracts/identity/KeyHolderLibrary.sol

 * We want to add purpose to already existing key.

 * We do not want to have purpose J if you have purpose I and I < J

 * Exception: we want a key of purpose 1 to have all purposes.

 * @author Talao, Polynomial.

 */

