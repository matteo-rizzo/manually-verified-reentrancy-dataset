// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract C {
    Vault public immutable vault;
    bool private locked = false;

    modifier nonReentrant() {
        require(!locked, "Locked");
        locked = true;
        _;
        locked = false;
    }

    constructor(address _vault) { vault = Vault(_vault); }

    function redeem(address payable to) external nonReentrant {
        vault.setEnabled(true); 

        // this function has been fixed by changing the logic in Vault.
        // Instead of using the takeAll function, we now use the combination of balanceOf and reset.
        uint256 amt = vault.balanceOf(to);

        (bool success, ) = to.call{value: amt}("");
        require(success, "Refund failed");

        vault.reset(to);    // zeroing the balance AFTER the call does not prevent an attacker to steal money through a multi-contract attacking scheme

        vault.setEnabled(false);
    }

    receive() external payable {
        vault.setEnabled(true); 
        vault.increase(msg.sender, msg.value);
        vault.setEnabled(false);
    }
}

contract Vault {
    mapping(address => uint256) private balances; 
    address private admin;
    bool private enabled;

    modifier onlyAdmin() { require(msg.sender == admin, "Only admin can enable vault"); _; }

    function setAdmin(address a) external {
        require(admin == address(0), "Invalid address");
        admin = a;
    }

    function setEnabled(bool b) external onlyAdmin { enabled = b; }

    function increase(address a, uint256 amt) external {
        require(enabled, "Vault disabled");
        balances[a] += amt;
    }

    // Here the takeAll function has been replaced with balanceOf and reset
    function balanceOf(address a) external view returns (uint256) {
        require(enabled, "Vault disabled");
        return balances[a];
    }

    function reset(address a) external {
        require(enabled, "Vault disabled");
        balances[a] = 0;
    }
}

// contract Attacker1 {
//     C c;
//     address att2;
//     Vault v;
//     function attacker() public {
//         c.redeem(payable(address(this)));
//         Attacker2(att2).redeem();
//     }
//     receive() external payable {
//         v.increase(att2, 1000);
//     }
// }

// contract Attacker2 {
//     C c;
//     Vault v;
//     function redeem() external {
//         c.redeem(payable(address(this)));
//     }
// }