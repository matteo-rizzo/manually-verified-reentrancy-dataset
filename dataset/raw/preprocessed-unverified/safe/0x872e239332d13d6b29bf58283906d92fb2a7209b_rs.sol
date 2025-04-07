/**
 *Submitted for verification at Etherscan.io on 2021-04-07
*/

pragma solidity 0.8.1;



// NOTE: this interface lacks return values for transfer/transferFrom/approve on purpose,
// as we use the SafeERC20 library to check the return value







contract GaslessSweeper {
	function sweep(IStakingPool pool, address[] memory depositors) external {
		address token = pool.ADXToken();
		for (uint i = 0; i < depositors.length; i++) {
			new GaslessDepositor{ salt: bytes32(0) }(token, pool, depositors[i]);
		}
	}
}

contract GaslessDepositor {
	constructor(address token, IStakingPool pool, address depositor) {
		uint amount = IERC20(token).balanceOf(address(this));
		SafeERC20.approve(token, address(pool), amount);
		pool.enterTo(depositor, amount);
		assembly {
			selfdestruct(depositor)
		}
	}
}