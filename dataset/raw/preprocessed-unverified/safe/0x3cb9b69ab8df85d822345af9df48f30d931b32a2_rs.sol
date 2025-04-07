/**
 *Submitted for verification at Etherscan.io on 2020-05-14
*/

pragma solidity ^0.6.0;







contract external1
{

publicCalls public pc;
publicArrays public pa;
genesisCalls public gn;
	
function reloadGenesis(address _address) public { if (msg.sender == updaterAddress)	{gn = genesisCalls(_address); gn.setOwnerExternal1(); } else revert();}
function reloadPublicCalls(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pc = publicCalls(_address); pc.setOwnerExternal1();} else revert();}
function reloadPublicArrays(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pa = publicArrays(_address); pa.setOwnerExternal1();} else revert();}	

address public updaterAddress = 0x0000000000000000000000000000000000000000;
function setUpdater() public {if (updaterAddress == 0x0000000000000000000000000000000000000000) updaterAddress = msg.sender; else revert();}

constructor(address _publicCallsAddress, address _publicArraysAddress, address _genesisAddress) public {
setUpdater();
pc = publicCalls(_publicCallsAddress);
pc.setOwnerExternal1();
pa = publicArrays(_publicArraysAddress);
pa.setOwnerExternal1();
gn = genesisCalls(_genesisAddress);
gn.setOwnerExternal1();
}	

function DestroyGenesisAddressLevel1() public {
	if (gn.isGenesisAddressLevel1(msg.sender))
	{
		if (pc.isGenesisAddressForSale(msg.sender)) revert('Remove Your Address From Sale First');		
		pc.isGenesisAddressSet(msg.sender, 0);
		uint256 _balanceToDestroy = gn.balanceOf(msg.sender);
		pc.balancesSet(msg.sender, 0);
		pc.initialBlockCountPerAddressSet(msg.sender, 0);
		pc.isGenesisAddressForSaleSet(msg.sender, false);
		pc.genesisBuyPriceSet(msg.sender, 0);		
		pc.allowAddressToDestroyGenesisSet(msg.sender, 0x0000000000000000000000000000000000000000);
		pc.GenesisDestroyCountStakeSet(pc.GenesisDestroyCountStake() + 1);
		pc.GenesisDestroyedSet(pc.GenesisDestroyed() + 1);
		pc.GenesisDestroyAmountCountSet(pc.GenesisDestroyAmountCount() + _balanceToDestroy);
	}
	else
	{
		revert('Address not Genesis');
	}
}
}