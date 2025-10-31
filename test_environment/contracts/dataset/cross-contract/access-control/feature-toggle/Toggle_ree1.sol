// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ToggleRee1 {
    Vault public immutable vault;
    bool private locked = false;

    modifier nonReentrant() {
        require(!locked, "Locked");
        locked = true;
        _;
        locked = false;
    }

    constructor(address _vault) { vault = Vault(_vault); }

    // the following function is vulnerable to a cross-contract reentrancy attack
    function redeem(address payable to) external nonReentrant {
        vault.setEnabled(true); 

        uint256 amt = vault.takeAll(to);

        // here an attacker can enter the Vault contract and call its functions that requires the enabled flag
        (bool success, ) = to.call{value: amt}(""); 
        require(success, "Refund failed");

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

    function takeAll(address a) external returns (uint256) {
        require(enabled, "Vault disabled");
        uint256 r = balances[a];
        balances[a] = 0;
        return r;
    }
}