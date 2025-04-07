/**
 *Submitted for verification at Etherscan.io on 2021-09-13
*/

// SPDX-License-Identifier: NONE

pragma solidity 0.8.3;



// Part: ERC20



// Part: L1GatewayRouter



// File: Arbitrum.sol

contract ArbitrumBridgeTester {

    L1GatewayRouter constant gateway = L1GatewayRouter(0x72Ce9c846789fdB6fC1f34aC4AD25Dd9ef7031ef);
    ERC20 constant crv = ERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);

    constructor() {
        crv.approve(0xa3A7B6F88361F48403514059F1F16C8E78d60EeC, type(uint256).max);
    }


    function bridgeCRV(
        uint _amount
    ) external payable {
        require(msg.value == 500000000000000); // 0.0005 ether
        crv.transferFrom(msg.sender, address(this), _amount);
        gateway.outboundTransfer{value: msg.value}(
            address(crv),
            address(this),
            _amount,
            500000,
            1000000,
            abi.encode(10000000000000, bytes(""))
        );
    }
}