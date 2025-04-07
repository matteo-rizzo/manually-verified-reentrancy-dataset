/**

 *Submitted for verification at Etherscan.io on 2018-08-16

*/



pragma solidity ^0.4.24;







contract TimeLockedWallet is Ownable {

	uint256 public unlockTime;



	constructor(uint256 _unlockTime) 

		public

	{

		unlockTime = _unlockTime;

	}



	function()

		public

		payable

	{

	}



	function locked()

		public

		view

		returns (bool)

	{

		return now <= unlockTime;

	}



	function claim()

		external

		onlyOwner

	{

		require(!locked());

		selfdestruct(owner);

	}	

}