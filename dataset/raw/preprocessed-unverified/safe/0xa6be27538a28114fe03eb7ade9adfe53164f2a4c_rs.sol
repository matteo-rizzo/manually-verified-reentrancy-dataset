/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity ^0.6.0;





contract GenesisAddresses
{
address public ownerMain = 0x0000000000000000000000000000000000000000;
address public ownerStakes = 0x0000000000000000000000000000000000000000;
address public ownerNormalAddress = 0x0000000000000000000000000000000000000000;
address public ownerGenesisBuys = 0x0000000000000000000000000000000000000000;
address public ownerStakeBuys = 0x0000000000000000000000000000000000000000;
address public ownerBaseTransfers = 0x0000000000000000000000000000000000000000;
address public external1 = 0x0000000000000000000000000000000000000000;

event GenesisAddressTransfer(address indexed from, address indexed to, uint256 supply);
event GenesisAddressSale(address indexed from, address indexed to, uint256 price, uint256 supply);
event GenesisBuyPriceHistory(address indexed from, uint256 price, uint8 genesisType);
event GenesisRemoveGenesisSaleHistory(address indexed from);
event AllowDestroyHistory(address indexed from, address indexed to);
event Level2UpgradeHistory(address indexed from);
event Level3UpgradeHistory(address indexed from);
event GenesisLevel1ForSaleHistory(address indexed from);
event GenesisRemoveSaleHistory(address indexed from);
event RemoveAllowDestroyHistory(address indexed from);
event ReceiveGenesisTransfersAllow(address indexed _address);
event RemoveReceiveGenesisTransfersAllow(address indexed _address);
event Burn(address indexed _owner, uint256 _value);

address public updaterAddress = 0x0000000000000000000000000000000000000000;
function setUpdater() public {if (updaterAddress == 0x0000000000000000000000000000000000000000) updaterAddress = msg.sender; else revert();}
function updaterSetOwnerMain(address _address) public {if (tx.origin == updaterAddress) ownerMain = _address; else revert();}
function updaterSetOwnerStakes(address _address) public {if (tx.origin == updaterAddress) ownerStakes = _address; else revert();}
function updaterSetOwnerNormalAddress(address _address) public {if (tx.origin == updaterAddress) ownerNormalAddress = _address; else revert();}
function updaterSetOwnerGenesisBuys(address _address) public {if (tx.origin == updaterAddress) ownerGenesisBuys = _address; else revert();}
function updaterSetOwnerStakeBuys(address _address) public {if (tx.origin == updaterAddress) ownerStakeBuys = _address; else revert();}
function updaterSetOwnerBaseTransfers(address _address) public {if (tx.origin == updaterAddress) ownerBaseTransfers = _address; else revert();}

function setOwnerBaseTransfers() public {
	if (tx.origin == updaterAddress)
		ownerBaseTransfers = msg.sender;
	else
		revert();
}

function setOwnerMain() public {
	if (tx.origin == updaterAddress)
		ownerMain = msg.sender;
	else
		revert();
}

function setOwnerStakes() public {
	if (tx.origin == updaterAddress)
		ownerStakes = msg.sender;
	else
		revert();
}

function setOwnerNormalAddress() public {
	if (tx.origin == updaterAddress)
		ownerNormalAddress = msg.sender;
	else
		revert();
}

function setOwnerGenesisBuys() public {
	if (tx.origin == updaterAddress)
		ownerGenesisBuys = msg.sender;
	else
		revert();
}

function setOwnerStakeBuys() public {
	if (tx.origin == updaterAddress)
		ownerStakeBuys = msg.sender;
	else
		revert();
}

function setOwnerExternal1() public {
	if (tx.origin == updaterAddress)
		external1 = msg.sender;
	else
		revert();
}

modifier onlyOwner(){
    require(msg.sender == ownerMain || msg.sender == ownerStakes || msg.sender == ownerNormalAddress || msg.sender == ownerGenesisBuys || msg.sender == ownerStakeBuys || msg.sender == ownerBaseTransfers || msg.sender == external1);
     _;
}


publicCalls public pc;
publicArrays public pa;

constructor(address _publicCallsAddress, address _publicArraysAddress) public {
setUpdater();
pc = publicCalls(_publicCallsAddress);
pc.setOwnerGenesis();
pa = publicArrays(_publicArraysAddress);
pa.setOwnerGenesis();
}

function reloadPublicCalls(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pc = publicCalls(_address); pc.setOwnerGenesis();} else revert();}
function reloadPublicArrays(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pa = publicArrays(_address); pa.setOwnerGenesis();} else revert();}

function isAnyGenesisAddress(address _address) public view returns (bool success) {
	if (pc.isGenesisAddress(_address) > 0)
		return true;
	else
		return false;
}

function isGenesisAddressLevel1(address _address) public view returns (bool success) {
	if (pc.isGenesisAddress(_address) == 1)
		return true;
	else
		return false;
}

function isGenesisAddressLevel2(address _address) public view returns (bool success) {
	if (pc.isGenesisAddress(_address) == 2)
		return true;
	else
		return false;
}

function isGenesisAddressLevel3(address _address) public view returns (bool success) {
	if (pc.isGenesisAddress(_address) == 3)
		return true;
	else
		return false;
}

function isGenesisAddressLevel2Or3(address _address) public view returns (bool success) {
	if (pc.isGenesisAddress(_address) == 2 || pc.isGenesisAddress(_address) == 3)
		return true;
	else
		return false;
}

function TransferGenesis(address _from, address _to) public onlyOwner { 
	if (!isGenesisAddressLevel2Or3(_from)) revert('(!isGenesisAddressLevel2Or3(_from))');
	
	if (!(_from != _to)) revert('(!(_from != _address))');
	
	if (!pc.allowReceiveGenesisTransfers(_to)) revert('(!pc.allowReceiveGenesisTransfers(_to))');
	
	if (pc.isGenesisAddressForSale(_from)) revert('(pc.isGenesisAddressForSale(_from))');
	
	if (balanceOf(_to) > 0) revert('(balanceOf(_to) > 0)');
	
	if (isAnyGenesisAddress(_to)) revert('(isAnyGenesisAddress(_to))');	
		
	pc.balancesSet(_to, pc.balances(_from)); 
	pc.balancesSet(_from, 0);
	pc.initialBlockCountPerAddressSet(_to, pc.initialBlockCountPerAddress(_from));
	pc.initialBlockCountPerAddressSet(_from, 0);
	pc.isGenesisAddressSet(_to, pc.isGenesisAddress(_from));
	pc.isGenesisAddressSet(_from, 0);
	pc.genesisBuyPriceSet(_from, 0);
	pc.isGenesisAddressForSaleSet(_from, false);	
	pc.allowAddressToDestroyGenesisSet(_to, 0x0000000000000000000000000000000000000000);
	pc.allowAddressToDestroyGenesisSet(_from, 0x0000000000000000000000000000000000000000);
	pc.allowReceiveGenesisTransfersSet(_from, false);
	pc.allowReceiveGenesisTransfersSet(_to, false);
	pc.genesisTransfersCountSet(pc.genesisTransfersCount() + 1);
	emit GenesisAddressTransfer(_from, _to, pc.balances(_to));
}

function SetGenesisForSale(address _from, uint256 weiPrice) public onlyOwner {
	
	if (weiPrice < 10 && isGenesisAddressLevel2Or3(msg.sender)) revert('weiPrice < 10 && isGenesisAddressLevel2Or3(msg.sender)');
	
	if (!isAnyGenesisAddress(_from)) revert('(!isAnyGenesisAddress(_from))');
	
	if (pc.isGenesisAddressForSale(_from)) revert('(pc.isGenesisAddressForSale(_from))');
	
	if (balanceOf(_from) == 0) revert('(balanceOf(_from) == 0)');
	
	if (isGenesisAddressLevel2Or3(_from)) 
	{
		if (weiPrice > 0)
		{
			pc.genesisBuyPriceSet(_from, weiPrice);	
			if (isGenesisAddressLevel3(_from))
			{
				pa.genesisAddressesForSaleLevel3Set(_from);
				pc.genesisAddressesForSaleLevel3IndexSet(_from, pa.genesisAddressesForSaleLevel3Length() - 1);	
			}
			else
			{
				pa.genesisAddressesForSaleLevel2Set(_from);
				pc.genesisAddressesForSaleLevel2IndexSet(_from, pa.genesisAddressesForSaleLevel2Length() - 1);	
			}	
			emit GenesisBuyPriceHistory(_from, weiPrice, pc.isGenesisAddress(_from));			
		}
		else
			revert('Price cannot be 0');
	}	
	else if (isGenesisAddressLevel1(_from))
	{
		pa.genesisAddressesForSaleLevel1Set(_from);
		pc.genesisAddressesForSaleLevel1IndexSet(_from, pa.genesisAddressesForSaleLevel1Length() - 1);			
		emit GenesisLevel1ForSaleHistory(_from);
	}
	
	pc.isGenesisAddressForSaleSet(_from, true);

}

function deleteAddressFromGenesisSaleList(address _address) public onlyOwner {
		if (isGenesisAddressLevel1(_address))
		{
			uint lastIndex = pa.genesisAddressesForSaleLevel1Length() - 1;
			if (lastIndex > 0)
			{
				address lastIndexAddress = pa.genesisAddressesForSaleLevel1(lastIndex);
				pc.genesisAddressesForSaleLevel1IndexSet(lastIndexAddress, pc.genesisAddressesForSaleLevel1Index(_address));
				pa.genesisAddressesForSaleLevel1SetAt(pc.genesisAddressesForSaleLevel1Index(_address), lastIndexAddress);				
			}
			pc.genesisAddressesForSaleLevel1IndexSet(_address, 0);
			pa.deleteGenesisAddressesForSaleLevel1();
		}
		else if (isGenesisAddressLevel2(_address))
		{
			uint lastIndex = pa.genesisAddressesForSaleLevel2Length() - 1;
			if (lastIndex > 0)
			{
				address lastIndexAddress = pa.genesisAddressesForSaleLevel2(lastIndex);
				pc.genesisAddressesForSaleLevel2IndexSet(lastIndexAddress, pc.genesisAddressesForSaleLevel2Index(_address));
				pa.genesisAddressesForSaleLevel2SetAt(pc.genesisAddressesForSaleLevel2Index(_address),lastIndexAddress);				
			}
			pc.genesisAddressesForSaleLevel2IndexSet(_address, 0);
			pa.deleteGenesisAddressesForSaleLevel2();
		}
		else if (isGenesisAddressLevel3(_address))
		{
			uint lastIndex = pa.genesisAddressesForSaleLevel3Length() - 1;
			if (lastIndex > 0)
			{
				address lastIndexAddress = pa.genesisAddressesForSaleLevel3(lastIndex);
				pc.genesisAddressesForSaleLevel3IndexSet(lastIndexAddress, pc.genesisAddressesForSaleLevel3Index(_address));
				pa.genesisAddressesForSaleLevel3SetAt(pc.genesisAddressesForSaleLevel3Index(_address), lastIndexAddress);				
			}
			pc.genesisAddressesForSaleLevel3IndexSet(_address, 0);
			pa.deleteGenesisAddressesForSaleLevel3();
		}		
}

function AllowReceiveGenesisTransfers(address _from) public onlyOwner { 
	if (isAnyGenesisAddress(_from)) revert('if (isAnyGenesisAddress(_from))');
	if (pc.allowReceiveGenesisTransfers(_from)) revert('pc.allowReceiveGenesisTransfers(_from)');
	pc.allowReceiveGenesisTransfersSet(_from, true);
	emit ReceiveGenesisTransfersAllow(_from);
}

function RemoveAllowReceiveGenesisTransfers(address _from) public onlyOwner { 
	pc.allowReceiveGenesisTransfersSet(_from,false);
	emit RemoveReceiveGenesisTransfersAllow(_from);
}

function RemoveGenesisAddressFromSale(address _from) public onlyOwner{ 
	if (!isAnyGenesisAddress(_from)) revert('(!isAnyGenesisAddress(_from))');
	if (!pc.isGenesisAddressForSale(_from)) revert('!pc.isGenesisAddressForSale(_from))');
	pc.genesisBuyPriceSet(_from, 0);
	pc.isGenesisAddressForSaleSet(_from, false);	
	deleteAddressFromGenesisSaleList(_from);	
	emit GenesisRemoveSaleHistory(_from);	
}

function AllowAddressToDestroyGenesis(address _from, address _address) public onlyOwner { 
	if (!isGenesisAddressLevel3(_from)) revert('(!isGenesisAddressLevel3(_from))');
	if (pc.isGenesisAddressForSale(_from)) revert('(pc.isGenesisAddressForSale(_from))');	
	pc.allowAddressToDestroyGenesisSet(_from, _address);
	emit AllowDestroyHistory(_from, _address);	
}

function RemoveAllowAddressToDestroyGenesis(address _from) public onlyOwner { 
	pc.allowAddressToDestroyGenesisSet(_from, 0x0000000000000000000000000000000000000000);
	emit RemoveAllowDestroyHistory(_from);			
}

function UpgradeToLevel2FromLevel1(address _address, uint256 weiValue) public onlyOwner {
	if (isGenesisAddressLevel1(_address) && !pc.isGenesisAddressForSale(_address))
	{
		if (weiValue != pc.ethFeeToUpgradeToLevel2()) revert('(weiValue != pc.ethFeeToUpgradeToLevel2())');
		pc.initialBlockCountPerAddressSet(_address, block.number);
		pc.isGenesisAddressSet(_address, 2);	
		pc.balancesSet(_address, pc.genesisSupplyPerAddress());
		pc.level2ActivationsFromLevel1CountSet(pc.level2ActivationsFromLevel1Count()+1);
		emit Level2UpgradeHistory(_address);
	}
	else
	{
		revert();
	}
}

function UpgradeToLevel3FromLevel1(address _address, uint256 weiValue) public onlyOwner {
	if (isGenesisAddressLevel1(_address) && !pc.isGenesisAddressForSale(_address))
	{
		uint256 totalFee = (pc.ethFeeToUpgradeToLevel2() + pc.ethFeeToUpgradeToLevel3());
		if (weiValue != totalFee) revert('(weiValue != totalFee)');
		pc.initialBlockCountPerAddressSet(_address, block.number);
		pc.isGenesisAddressSet(_address, 3);	
		pc.balancesSet(_address, pc.genesisSupplyPerAddress());
		pc.level3ActivationsFromLevel1CountSet(pc.level3ActivationsFromLevel1Count()+1);		
		emit Level3UpgradeHistory(_address);
	}
	else
	{
		revert();
	}
}

function UpgradeToLevel3FromLevel2(address _address, uint256 weiValue) public onlyOwner {
	if (isGenesisAddressLevel2(_address) && !pc.isGenesisAddressForSale(_address))
	{
		if (weiValue != pc.ethFeeToUpgradeToLevel3()) revert('(weiValue != pc.ethFeeToUpgradeToLevel3())');
		pc.isGenesisAddressSet(_address, 3);	
		pc.level3ActivationsFromLevel2CountSet(pc.level3ActivationsFromLevel2Count()+1);
		emit Level3UpgradeHistory(_address);
	}
	else
	{
		revert();
	}
}

function UpgradeToLevel3FromDev(address _address) public onlyOwner {
	if (pc.isGenesisAddress(_address) == 4 && !pc.isGenesisAddressForSale(_address))
	{
		pc.initialBlockCountPerAddressSet(_address, block.number);
		pc.isGenesisAddressSet(_address, 3);	
		pc.balancesSet(_address, pc.genesisSupplyPerAddress());
		pc.level3ActivationsFromDevCountSet(pc.level3ActivationsFromDevCount()+1);		
		emit Level3UpgradeHistory(_address);
	}
	else
	{
		revert();
	}
}

function availableBalanceOf(address _address) public view returns (uint256 Balance)
{
	if (isGenesisAddressLevel2Or3(_address))
	{
		uint minedBlocks = block.number - pc.initialBlockCountPerAddress(_address);
		
		if (minedBlocks >= pc.maxBlocks()) return pc.balances(_address);
				
		return pc.balances(_address) - (pc.genesisSupplyPerAddress() - (pc.genesisRewardPerBlock()*minedBlocks));
	}
	else if (isGenesisAddressLevel1(_address) || pc.isGenesisAddress(_address) == 4)
		return 0;
	else
		return pc.balances(_address);
}

function balanceOf(address _address) public view returns (uint256 balance) {
	if (isGenesisAddressLevel1(_address) || pc.isGenesisAddress(_address) == 4)
		return pc.genesisSupplyPerAddress();
	else
		return pc.balances(_address);
}

function BurnTokens(address _from, uint256 mneToBurn) public onlyOwner returns (bool success)
{
	if (pc.isGenesisAddressForSale(_from)) revert('(pc.isGenesisAddressForSale(_from))');
	
	if (pc.isNormalAddressForSale(_from)) revert('(pc.isNormalAddressForSale(_from))');
	
	if (availableBalanceOf(_from) >= mneToBurn)
	{
		pc.balancesSet(_from, pc.balances(_from) - mneToBurn);
		pc.mneBurnedSet(pc.mneBurned() + mneToBurn);
		emit Burn(_from, mneToBurn);			
	}
	else
	{
		revert();
	}
	return true;
}

function BurnGenesisAddresses(address _from, address[] memory _genesisAddressesToBurn) public onlyOwner {
	uint8 i = 0;	
	while(i < _genesisAddressesToBurn.length)
	{
		if (pc.allowAddressToDestroyGenesis(_genesisAddressesToBurn[i]) != _from) revert('(pc.allowAddressToDestroyGenesis(_genesisAddressesToBurn[i]) != _from)');
		if (pc.isGenesisAddressForSale(_genesisAddressesToBurn[i])) revert('(pc.isGenesisAddressForSale(_genesisAddressesToBurn[i]))');
		if (!isGenesisAddressLevel3(_genesisAddressesToBurn[i])) revert('(!isGenesisAddressLevel3(_genesisAddressesToBurn[i]))');
		pc.isGenesisAddressSet(_genesisAddressesToBurn[i], 0);
		uint256 _balanceToDestroy = pc.balances(_genesisAddressesToBurn[i]);
		pc.balancesSet(_genesisAddressesToBurn[i], 0);
		pc.initialBlockCountPerAddressSet(_genesisAddressesToBurn[i], 0);
		pc.isGenesisAddressForSaleSet(_genesisAddressesToBurn[i], false);
		pc.genesisBuyPriceSet(_genesisAddressesToBurn[i], 0);		
		pc.allowAddressToDestroyGenesisSet(_genesisAddressesToBurn[i], 0x0000000000000000000000000000000000000000);
		pc.GenesisDestroyCountStakeSet(pc.GenesisDestroyCountStake() + 1);
		pc.GenesisDestroyedSet(pc.GenesisDestroyed() + 1);
		pc.GenesisDestroyAmountCountSet(pc.GenesisDestroyAmountCount() + _balanceToDestroy);
		i++;
	}
}
}