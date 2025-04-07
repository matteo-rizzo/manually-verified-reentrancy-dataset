/**
 *Submitted for verification at Etherscan.io on 2020-11-30
*/

pragma solidity ^0.6.0;







contract external1
{

publicCalls public pc;
publicArrays public pa;
genesisCalls public gn;
address public stakingAddress;
address public bondsAddress;
address public extraAddress;
address public ownershipTransferContract;
	
function reloadGenesis(address _address) public { if (msg.sender == updaterAddress)	{gn = genesisCalls(_address); gn.setOwnerExternal1(); } else revert();}
function reloadPublicCalls(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pc = publicCalls(_address); pc.setOwnerExternal1();} else revert();}
function reloadPublicArrays(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pa = publicArrays(_address); pa.setOwnerExternal1();} else revert();}	
function setStakingOwner() public { if (tx.origin == updaterAddress)	{ stakingAddress = msg.sender; } else revert();}
function setBondsOwner() public { if (tx.origin == updaterAddress)	{ bondsAddress = msg.sender; } else revert();}
function setExtraAddressOwner() public { if (tx.origin == updaterAddress)	{ extraAddress = msg.sender; } else revert();}
function setOwnershipTransferContract() public { if (tx.origin == updaterAddress)	{ ownershipTransferContract = msg.sender; } else revert();}

function reloadStakingAddress(address _address) public { if (msg.sender == updaterAddress)	{stakingAddress = _address; } else revert();}
function reloadbondsAddress(address _address) public { if (msg.sender == updaterAddress)	{bondsAddress = _address; } else revert();}
function reloadextraAddress(address _address) public { if (msg.sender == updaterAddress)	{extraAddress = _address; } else revert();}
function reloadOwnershipTransferContract(address _address) public { if (msg.sender == updaterAddress)	{ownershipTransferContract = _address; } else revert();}


address public updaterAddress = 0x0000000000000000000000000000000000000000;
function setUpdater() public {if (updaterAddress == 0x0000000000000000000000000000000000000000) updaterAddress = msg.sender; else revert();}

modifier onlyOwner(){
    require(msg.sender == ownershipTransferContract);
     _;
}

constructor(address _publicCallsAddress, address _publicArraysAddress, address _genesisAddress) public {
setUpdater();
pc = publicCalls(_publicCallsAddress);
pc.setOwnerExternal1();
pa = publicArrays(_publicArraysAddress);
pa.setOwnerExternal1();
gn = genesisCalls(_genesisAddress);
gn.setOwnerExternal1();
}	

function mintNewCoins(uint256 _amount) public
{
	if (msg.sender == stakingAddress || msg.sender == bondsAddress || msg.sender == extraAddress)
	{
		pc.balancesSet(msg.sender, pc.balances(msg.sender) + _amount);
	}
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

function TransferGenesis(address _from, address _to) public onlyOwner { 
	if (!gn.isGenesisAddressLevel1(_from)) revert('Seller Not Level1');
	
	if (!(_from != _to)) revert('(!(_from != _address))');
	
	if (pc.isGenesisAddressForSale(_from)) revert('For Seller: Remove Address from DEX Sale First');
	
	if (gn.balanceOf(_to) > 0) revert('For Buyer: Balance must be 0');
	
	if (gn.isAnyGenesisAddress(_to)) revert('(isAnyGenesisAddress(_to))');	
		
	pc.isGenesisAddressSet(_to, 1);
	pc.isGenesisAddressSet(_from, 0);
}
}