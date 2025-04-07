/**
 *Submitted for verification at Etherscan.io on 2020-12-21
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.6.11;







contract Autoexec {

    Chainlog constant  cl = Chainlog(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    IlkReg   immutable ir;
    AutoLine immutable al;

    constructor() public {
        ir = IlkReg(cl.getAddress("ILK_REGISTRY"));
        al = AutoLine(cl.getAddress("MCD_IAM_AUTO_LINE"));
    }

    function bat() public {
        bytes32[] memory _ilks = ir.list();
        for (uint256 i = 0; i < _ilks.length; i++) {
            al.exec(_ilks[i]);
        }
    }
}