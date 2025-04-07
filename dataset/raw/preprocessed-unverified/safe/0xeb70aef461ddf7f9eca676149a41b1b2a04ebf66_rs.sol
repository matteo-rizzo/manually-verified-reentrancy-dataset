/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity ^0.6.0;








contract stakes
{

address public ownerMain = 0x0000000000000000000000000000000000000000;
address public updaterAddress = 0x0000000000000000000000000000000000000000;
function setUpdater() public {if (updaterAddress == 0x0000000000000000000000000000000000000000) updaterAddress = msg.sender; else revert();}
function updaterSetOwnerMain(address _address) public {if (tx.origin == updaterAddress) ownerMain = _address; else revert();}

function setOwnerMain() public {
	if (tx.origin == updaterAddress)
		ownerMain = msg.sender;
	else
		revert();
}

modifier onlyOwner(){
    require(msg.sender == ownerMain);
     _;
}

publicCalls public pc;
publicArrays public pa;
genesisCalls public gn;
	
constructor(address _publicCallsAddress, address _publicArraysAddress, address _genesisAddress) public {
setUpdater();
pc = publicCalls(_publicCallsAddress);
pc.setOwnerStakes();
pa = publicArrays(_publicArraysAddress);
pa.setOwnerStakes();
gn = genesisCalls(_genesisAddress);
gn.setOwnerStakes();
}

function reloadGenesis(address _address) public
{
	if (msg.sender == updaterAddress)
	{
		gn = genesisCalls(_address);
		gn.setOwnerStakes();
	}
	else revert();
}

function reloadPublicCalls(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pc = publicCalls(_address); pc.setOwnerStakes();} else revert();}
function reloadPublicArrays(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pa = publicArrays(_address); pa.setOwnerStakes();} else revert();}
	
event Transfer(address indexed from, address indexed to, uint256 value);
event StakeTransfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event GenesisAddressTransfer(address indexed from, address indexed to, uint256 supply);
event GenesisAddressSale(address indexed from, address indexed to, uint256 price, uint256 supply);
event GenesisBuyPriceHistory(address indexed from, uint256 price, uint8 genesisType);
event GenesisRemoveGenesisSaleHistory(address indexed from);
event AllowDestroyHistory(address indexed from, address indexed to);
event Level2UpgradeHistory(address indexed from);
event Level3UpgradeHistory(address indexed from);
event GenesisLevel1ForSaleHistory(address indexed from);
event NormalAddressForSaleHistory(address indexed from, uint price);
event NormalAddressRemoveSaleHistory(address indexed from);	
event NormalAddressSale(address indexed from, address indexed to, uint price, uint balance);
event RemoveStakeSale(address indexed from);
event StakeGenesisTransfer(address indexed from, address indexed to, uint value, uint amountGenesisToBurn);
event TransferStake(address indexed from, address indexed to, uint value); 
event LogStakeHolderSends(address indexed to, uint balance, uint amountToSend);
event LogFailedStakeHolderSends(address indexed to, uint balance, uint amountToSend);
event StakeGenesisSale(address indexed to, address indexed from, uint balance, uint amountGenesisToBurn, uint totalToSend);
event GenesisRemoveSaleHistory(address indexed from);
event RemoveAllowDestroyHistory(address indexed from);
event StakeMNETransfer(address indexed from, address indexed to, uint256 value, uint256 mneToBurn);
event StakeMNESale(address indexed to, address indexed from, uint256 value, uint256 mneToBurn, uint256 totalToSend);
event CreateTokenHistory(address indexed _owner, address indexed _address);
event CreateTokenICOHistory(address indexed _owner, address indexed _address);
event SetStakeForSaleHistory(address indexed _owner, uint256 priceInWei);
event Burn(address indexed _owner, uint256 _value);	
	
function SetStakeForSale(address _from, uint256 priceInWei) public onlyOwner {
	if (priceInWei < 10) revert('(priceInWei < 10)');
	if (pc.stakeBalances(_from) == 0 || pc.stakeBuyPrice(_from) > 0) revert('pc.stakeBalances(_from) == 0 || pc.stakeBuyPrice(_from) > 0');
	pc.stakeBuyPriceSet(_from, priceInWei);	
	pa.stakesForSaleSet(_from);
	pc.stakesForSaleIndexSet(_from, pa.stakesForSaleLength() -1);
	emit SetStakeForSaleHistory(_from, priceInWei);
}

function deleteStakeFromSaleList(address _address) private {
		uint lastIndex = pa.stakesForSaleLength() - 1;
		if (lastIndex > 0)
		{
			address lastIndexAddress = pa.stakesForSale(lastIndex);
			pc.stakesForSaleIndexSet(lastIndexAddress, pc.stakesForSaleIndex(_address));
			pa.stakesForSaleSetAt(pc.stakesForSaleIndex(_address), lastIndexAddress);
		}
		pc.stakesForSaleIndexSet(_address, 0);
		pa.deleteStakesForSale();
}

function addStakeHolder(address _address) private {
        pa.stakeHoldersListSet(_address);
		pc.stakeHoldersListIndexSet(_address, pa.stakeHoldersListLength() - 1);					
}

function deleteStakeHolder(address _address) private {
		uint lastIndex = pa.stakeHoldersListLength() - 1;
		if (lastIndex > 0)
		{
			address lastIndexAddress = pa.stakeHoldersList(lastIndex);
			pc.stakeHoldersListIndexSet(lastIndexAddress, pc.stakeHoldersListIndex(_address));
			pa.stakeHoldersListAt(pc.stakeHoldersListIndex(_address), lastIndexAddress);
		}
		pc.stakeHoldersListIndexSet(_address, 0);
		pa.deleteStakeHoldersList();
}

function RemoveStakeFromSale(address _from) public onlyOwner {
	if (pc.stakeBuyPrice(_from) > 0)
	{
		pc.stakeBuyPriceSet(_from, 0);
		deleteStakeFromSaleList(_from);
		emit RemoveStakeSale(_from);
	}
	else
		revert();
}

function StakeTransferMNE(address _from, address _to, uint256 _value) public onlyOwner returns (uint256 _mneToBurn) {
	if (pc.stakeBuyPrice(_to) > 0) revert('(pc.stakeBuyPrice(_to) > 0)');
	
	if (pc.stakeBuyPrice(_from) > 0) revert('(pc.stakeBuyPrice(_from) > 0)');
	
	if (!(_from != _to)) revert('(!(_from != _address))');

	if (pc.stakeBalances(_from) < _value) revert('(pc.stakeBalances(_from) < _value)'); 

	if (pc.stakeBalances(_to) + _value < pc.stakeBalances(_to)) revert('(pc.stakeBalances(_to) + _value < pc.stakeBalances(_to))'); 

	if (_value > pc.stakeBalances(_from)) revert('(_value > pc.stakeBalances(_from))');
	
	if (pc.isGenesisAddressForSale(_from)) revert('(pc.isGenesisAddressForSale(_from))');
	
	if (pc.isNormalAddressForSale(_from)) revert('(pc.isNormalAddressForSale(_from))');
	
	uint256 mneToBurn = pc.amountOfMNEToTransferStakes() * _value / pc.stakeDecimals();
	if (mneToBurn < pc.amountOfMNEToTransferStakes())
		mneToBurn = pc.amountOfMNEToTransferStakes();	
	if (!(gn.availableBalanceOf(_from) >= mneToBurn)) revert('(!(gn.availableBalanceOf(_from) >= mneToBurn))');	
	
	pc.stakeMneTransferBurnCountSet(pc.stakeMneTransferBurnCount() + mneToBurn);
	pc.transferStakeMNECountSet(pc.transferStakeMNECount() + 1);
	emit StakeMNETransfer(_from, _to, _value, mneToBurn);
	pc.stakeBalancesSet(_from, pc.stakeBalances(_from) - _value); 
	pc.stakeBalancesSet(_to, pc.stakeBalances(_to) + _value); 
	
	if (pc.stakeBalances(_from) == 0)
		deleteStakeHolder(_from);	
	
	if (pc.stakeHoldersListIndex(_to) == 0)
		addStakeHolder(_to);
	
	emit TransferStake(_from, _to, _value); 
	return mneToBurn;
}

function StakeTransferGenesis(address _from, address _to, uint256 _value, address[] memory _genesisAddressesToBurn) public onlyOwner {
	if (pc.stakeBuyPrice(_to) > 0) revert('(pc.stakeBuyPrice(_to) > 0)');
	if (pc.stakeBuyPrice(_from) > 0) revert('(pc.stakeBuyPrice(_from) > 0)');
	
	if (!(_from != _to)) revert('(!(_from != _address))');

	if (pc.stakeBalances(_from) < _value) revert('(pc.stakeBalances(_from) < _value)'); 

	if (pc.stakeBalances(_to) + _value < pc.stakeBalances(_to)) revert('(pc.stakeBalances(_to) + _value < pc.stakeBalances(_to))'); 

	if (_value > pc.stakeBalances(_from)) revert('(_value > pc.stakeBalances(_from))');
	
	uint256 _amountGenesisToBurn = pc.amountOfGenesisToTransferStakes() * _value / pc.stakeDecimals();
	if (_amountGenesisToBurn < pc.amountOfGenesisToTransferStakes())
		_amountGenesisToBurn = pc.amountOfGenesisToTransferStakes();
	if (_genesisAddressesToBurn.length < pc.amountOfGenesisToTransferStakes()) revert('(_genesisAddressesToBurn.length < pc.amountOfGenesisToTransferStakes())');
	
	gn.BurnGenesisAddresses(_from, _genesisAddressesToBurn);
	
	pc.transferStakeGenesisCountSet(pc.transferStakeGenesisCount() + 1);
	emit StakeGenesisTransfer(_from, _to, _value, _amountGenesisToBurn);
	pc.stakeBalancesSet(_from, pc.stakeBalances(_from) - _value); 
	pc.stakeBalancesSet(_to, pc.stakeBalances(_to) + _value); 
	
	if (pc.stakeBalances(_from) == 0)
		deleteStakeHolder(_from);	
	
	if (pc.stakeHoldersListIndex(_to) == 0)
		addStakeHolder(_to);
	
	emit TransferStake(_from, _to, _value); 	
}

function setBalanceStakes(address _from, address _address, uint256 balance) public onlyOwner
{
	if (pc.setupRunning() && _from == pc.genesisCallerAddress())
	{
		pc.stakeBalancesSet(_address, balance);	
		pa.stakeHoldersListSet(_from);
		pc.stakeHoldersListIndexSet(_from, pa.stakeHoldersListLength() - 1);			
		pc.stakeBalancesSet(_address, balance);
		pc.stakeHoldersImportedSet(pc.stakeHoldersImported()+1);
	}
	else
	{
		revert();
	}
}
}