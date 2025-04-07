/**
 *Submitted for verification at Etherscan.io on 2020-12-02
*/

// File: contracts/lib/Ownable.sol

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

/**
 * @title Ownable
 * @author DODO Breeder
 *
 * @notice Ownership related functions
 */


// File: contracts/intf/IDODO.sol

/*

    Copyright 2020 DODO ZOO.

*/



// File: contracts/helper/CloneFactory.sol

/*

    Copyright 2020 DODO ZOO.

*/



// introduction of proxy mode design: https://docs.openzeppelin.com/upgrades/2.8/
// minimum implementation of transparent proxy: https://eips.ethereum.org/EIPS/eip-1167

contract CloneFactory is ICloneFactory {
    function clone(address prototype) external override returns (address proxy) {
        bytes20 targetBytes = bytes20(prototype);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            proxy := create(0, clone, 0x37)
        }
        return proxy;
    }
}

// File: contracts/DODOZoo.sol

/*

    Copyright 2020 DODO ZOO.

*/

/**
 * @title DODOZoo
 * @author DODO Breeder
 *
 * @notice Register of All DODO
 */
contract DODOZooEventTrigger is Ownable {
    
    // ============ Events ============

    event DODOBirth(address newBorn, address baseToken, address quoteToken);

    // ============ Admin Function ============

    function triggerBirth(address dodo) external onlyOwner {
        address baseToken = IDODO(dodo)._BASE_TOKEN_();
        address quoteToken = IDODO(dodo)._QUOTE_TOKEN_();
        emit DODOBirth(dodo, baseToken,quoteToken);
    }
}