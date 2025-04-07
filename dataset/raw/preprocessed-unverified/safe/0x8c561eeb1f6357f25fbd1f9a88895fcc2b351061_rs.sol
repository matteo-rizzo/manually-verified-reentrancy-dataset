/**
 *Submitted for verification at Etherscan.io on 2020-11-25
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;



contract ToolMasterchef {
    address public constant _masterchef = 0xe550Bfdb3F4De5a19f85D56f40394803e70b3e69;

    function massUpdatePool() external {
        IMasterchef masterchef = IMasterchef(_masterchef);

        uint _poolLength = masterchef.poolLength();
        for (uint i = 0; i < _poolLength; i++) {
            masterchef.deposit(i, 0, address(0));
        }
    }
}