/**
 *Submitted for verification at Etherscan.io on 2020-04-19
*/

pragma solidity ^0.6.0;







contract GetStakefees
{

publicCalls public pc;
	
constructor(address _publicCallsAddress) public {
pc = publicCalls(_publicCallsAddress);
}	

function getStakeMNEFeeBuy(address _add) public view returns (uint256 price)
{
	uint256 mneFee = pc.amountOfMNEToBuyStakes()*pc.stakeBalances(_add) * 100 / pc.stakeDecimals();
	if (mneFee < pc.amountOfMNEToBuyStakes())
		mneFee = pc.amountOfMNEToBuyStakes();
	return mneFee;
}

function getStakeGenesisFeeBuy(address _add) public view returns (uint256 price)
{
	uint256 genesisAddressFee = pc.amountOfGenesisToBuyStakes()*pc.stakeBalances(_add) * 100 / pc.stakeDecimals();
	if (genesisAddressFee < pc.amountOfGenesisToBuyStakes())
	genesisAddressFee = pc.amountOfGenesisToBuyStakes();
	return genesisAddressFee;
}
}