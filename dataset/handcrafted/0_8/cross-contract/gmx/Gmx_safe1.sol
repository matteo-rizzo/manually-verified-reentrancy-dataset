// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

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

    function balanceOf(address a) external view returns (uint256) {
        require(enabled, "Vault disabled");
        return balances[a];
    }

    function reset(address a) external {
        require(enabled, "Vault disabled");
        balances[a] = 0;
    }
}

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

    function redeem(address payable to) external payable nonReentrant {
        vault.setEnabled(true); 

        uint256 amt = vault.balanceOf(to);

        (bool success, ) = to.call{value: amt}("");
        require(success, "Refund failed");

        vault.reset(to);    // zeroing the balance AFTER the call does not allow the attacked to corrupt the vault balance

        vault.setEnabled(false);
    }

    receive() external payable {}
}

contract Attacker {
    Vault public immutable vault;
    C public immutable c;

    constructor(address _vault, address payable _c) {
        vault = Vault(_vault);
        c = C(_c);
    }

    function attack() public {
        c.redeem(payable(msg.sender));
        c.redeem(payable(msg.sender));  // the second redeem() will not pay
    }

    receive() external payable {
        vault.increase(msg.sender, 1000);
    }

}

contract Deployer {
    function deploy() public {
        Vault v = new Vault();
        C c = new C(address(v));
        v.setAdmin(address(c));
    }
}