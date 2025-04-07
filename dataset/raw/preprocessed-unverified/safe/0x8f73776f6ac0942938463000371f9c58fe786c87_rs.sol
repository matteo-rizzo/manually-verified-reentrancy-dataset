/**
 *Submitted for verification at Etherscan.io on 2021-07-18
*/

// SPDX-License-Identifier: Unlicense

pragma solidity 0.8.4;



// Part: Create2

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */


// File: Create.sol

contract Create {

    function deploy(uint256 amount, bytes32 salt, bytes memory bytecode) public returns (address){
        return Create2.deploy(amount, salt, bytecode);
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) public view returns (address){
        return Create2.computeAddress(salt, bytecodeHash);
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash, address deployer) public pure returns (address){
        return Create2.computeAddress(salt, bytecodeHash, deployer);
    }
}