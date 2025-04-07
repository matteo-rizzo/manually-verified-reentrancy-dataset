/**
 *Submitted for verification at Etherscan.io on 2021-07-28
*/

pragma solidity ^0.8.0;









// NOTE: If this needs to be upgraded, we just deploy a new instance and remove the governance rights
// of the old instance and set rights for the new instance
contract ADXLoyaltyPoolIncentiveController {
	IChainlinkSimple public constant ADXUSDOracle = IChainlinkSimple(0x231e764B44b2C1b7Ca171fa8021A24ed520Cde10);
	IADXLoyaltyPoolToken public immutable loyaltyPool;
	constructor(IADXLoyaltyPoolToken lpt) {
		loyaltyPool = lpt;
	}

	function adjustIncentive() external {
		// Mint the current incurred incentive before changing the rate,
		// otherwise new rate would be applied for the entire period since the last mint
		loyaltyPool.mintIncentive();

		// At some point we might enable bonus periods:
		// if (block.timestamp < ...) { ... }
		// Or overinflation protection
		// if (loyaltyPool.ADXToken().totalSupply() > ...) { ... }

		// Reset the rate based on the price from the Chainlink oracle
		uint price = ADXUSDOracle.latestAnswer();
		require(price > 0, 'INVALID_ANSWER');
		if (price < 0.05*10**8) {
			loyaltyPool.setIncentive(uint(0.05*10**18));
		} else if (price < 0.10*10**8) {
			loyaltyPool.setIncentive(uint(0.10*10**18));
		} else if (price < 0.20*10**8) {
			loyaltyPool.setIncentive(uint(0.20*10**18));
		} else if (price < 0.35*10**8) {
			loyaltyPool.setIncentive(uint(0.25*10**18));
		} else if (price < 0.50*10**8) {
			loyaltyPool.setIncentive(uint(0.30*10**18));
		} else if (price < 1.00*10**8) {
			loyaltyPool.setIncentive(uint(0.35*10**18));
		} else if (price < 2.00*10**8) {
			loyaltyPool.setIncentive(uint(0.38*10**18));
		} else if (price < 2.50*10**8) {
			loyaltyPool.setIncentive(uint(0.40*10**18));
		} else {
			loyaltyPool.setIncentive(uint(0.45*10**18));
		}
	}
}