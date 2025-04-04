pragma solidity ^0.4.4;



contract FaucetI {
	function giveMe() 
		returns (bool success);

	function giveTo(address who)
		returns (bool success);
}

contract BasicFaucet is Owned, FaucetI {
	uint public giveAway;

	event OnGiveAwayChanged(uint indexed giveAway);
	event OnPaid(address indexed who, uint indexed giveAway);

	function BasicFaucet(uint _giveAway) {
		giveAway = _giveAway;
	}

	function setGiveAway(uint _giveAway) fromOwner {
		giveAway = _giveAway;
		OnGiveAwayChanged(giveAway);
	}

	function giveMe() 
		returns (bool success) {
		return giveTo(msg.sender);
	}

	function giveForce(address who)
		fromOwner 
		returns (bool success)  {
		return give(who);
	}

	function give(address who)
		internal
		returns (bool success);
}

contract ThrottledFaucet is BasicFaucet {
	uint public delay;
	uint public nextTimestamp;
	bytes32 constant public name = "B9LabFaucet";

	function ThrottledFaucet(uint _giveAway, uint _delay) 
		BasicFaucet(_giveAway) {
		delay = _delay;
		nextTimestamp = now;
	}

	function giveTo(address who)
		returns (bool success) {
		return give(who);
	}

	function give(address who)
		internal
		returns (bool success) {
		if (nextTimestamp <= now) {
			// Protect from re-entrance
			nextTimestamp = now + delay;
			if (who.call.value(giveAway)()) {
				OnPaid(who, giveAway);
				return true;
			}
			nextTimestamp = now;
		}
		return false;
	}
}