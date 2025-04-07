/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity ^0.6.0;







contract stakesBuys
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
pc.setOwnerStakeBuys();
pa = publicArrays(_publicArraysAddress);
pa.setOwnerStakeBuys();
gn = genesisCalls(_genesisAddress);
gn.setOwnerStakeBuys();
}

function reloadGenesis(address _address) public
{
	if (msg.sender == updaterAddress)
	{
		gn = genesisCalls(_address);
		gn.setOwnerStakeBuys();
	}
	else revert();
}	

function reloadPublicCalls(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pc = publicCalls(_address); pc.setOwnerStakeBuys();} else revert();}
function reloadPublicArrays(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pa = publicArrays(_address); pa.setOwnerStakeBuys();} else revert();}

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

function BuyStakeMNE(address _from, address _address, uint256 _msgvalue) public onlyOwner returns (uint256 _mneToBurn, uint256 _feesToPayToSeller){
	if (pc.stakeBuyPrice(_from) > 0) revert('(pc.stakeBuyPrice(_from) > 0)');
	if (!(_from != _address)) revert('(!(_from != _address))');
	if (!(pc.stakeBuyPrice(_address) > 0)) revert('(!(pc.stakeBuyPrice(_address) > 0))');
	if (!(pc.stakeBalances(_address) > 0)) revert('(!(pc.stakeBalances(_address) > 0))');
	
	if (pc.isGenesisAddressForSale(_from)) revert('(pc.isGenesisAddressForSale(_from))');
	
	if (pc.isNormalAddressForSale(_from)) revert('(pc.isNormalAddressForSale(_from))');
	
	uint256 mneToBurn = pc.amountOfMNEToBuyStakes() * pc.stakeBalances(_address) / pc.stakeDecimals();
	if (mneToBurn < pc.amountOfMNEToBuyStakes())
		mneToBurn = pc.amountOfMNEToBuyStakes();	
	if (!(gn.availableBalanceOf(_from) >= mneToBurn)) revert('(!(gn.availableBalanceOf(_from) >= mneToBurn))');	
	
	uint256 feesToPayToContract = 0;
	uint256 feesToPayToSeller = pc.stakeBuyPrice(_address);
	uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentStakeExchange() / 100;
		
	uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
	
	if  (totalToSend == 0) revert('(totalToSend == 0)');
	if (!(_msgvalue == totalToSend)) revert('(!(_msgvalue == totalToSend))');
	
	deleteStakeFromSaleList(_address);
	uint256 _value = pc.stakeBalances(_address);
	uint256 _valueFrom = pc.stakeBalances(_from);
	pc.stakeBalancesSet(_from, _valueFrom + _value); 
	pc.stakeBalancesSet(_address, 0); 
	emit TransferStake(_address, _from, _value); 	
	pc.stakeBuyPriceSet(_address, 0);
	pc.stakeMneBurnCountSet(pc.stakeMneBurnCount() + mneToBurn);
	pc.buyStakeMNECountSet(pc.buyStakeMNECount() + 1);	

    if (pc.stakeBalances(_address) == 0)
		deleteStakeHolder(_address);	
	
	if (pc.stakeHoldersListIndex(_from) == 0)
		addStakeHolder(_from);
	
	emit StakeMNESale(_from, _address, _value, mneToBurn, totalToSend);
	
	pa.StakeTradeHistorySellerSet(_address);
	pa.StakeTradeHistoryBuyerSet(_from);
	pa.StakeTradeHistoryStakeAmountSet(_value);
	pa.StakeTradeHistoryETHPriceSet(totalToSend);
	pa.StakeTradeHistoryETHFeeSet(feesGeneralToPayToContract);
	pa.StakeTradeHistoryMNEGenesisBurnedSet(mneToBurn);
	pa.StakeTradeHistoryDateSet(now);
	
	return (mneToBurn, feesToPayToSeller);
}

function BuyStakeGenesis(address _from, address payable _address, address[] memory _genesisAddressesToBurn, uint256 _msgvalue) public onlyOwner returns (uint256 _feesToPayToSeller){
	if (pc.stakeBuyPrice(_from) > 0) revert('(pc.stakeBuyPrice(_from) > 0)');
	if (!(_from != _address)) revert('(!(_from != _address))');
	if (!(pc.stakeBuyPrice(_address) > 0)) revert('(!(pc.stakeBuyPrice(_address) > 0))');
	if (!(pc.stakeBalances(_address) > 0)) revert('(!(pc.stakeBalances(_address) > 0))');	
	uint256 _amountGenesisToBurn = pc.amountOfGenesisToBuyStakes() * pc.stakeBalances(_address);
	if (_amountGenesisToBurn < pc.amountOfGenesisToBuyStakes())
		_amountGenesisToBurn = pc.amountOfGenesisToBuyStakes();
	if (_genesisAddressesToBurn.length < _amountGenesisToBurn) revert('(_genesisAddressesToBurn.length < _amountGenesisToBurn)');
	
	uint256 feesToPayToContract = 0;
	uint256 feesToPayToSeller = pc.stakeBuyPrice(_address);
	uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentStakeExchange() / 100;
		
	uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
	
	if  (totalToSend == 0) revert('(totalToSend == 0)');
	if (!(_msgvalue == totalToSend)) revert('(!(_msgvalue == totalToSend))');
	
	gn.BurnGenesisAddresses(_from, _genesisAddressesToBurn);
	
	uint256 _value = pc.stakeBalances(_address);
	uint256 _valueFrom = pc.stakeBalances(_from);
	pc.stakeBalancesSet(_from, _valueFrom + _value); 
	pc.stakeBalancesSet(_address, 0); 
	emit TransferStake(_address, _from, _value); 	
	pc.stakeBuyPriceSet(_address, 0);
	pc.buyStakeGenesisCountSet(pc.buyStakeGenesisCount() + 1);
	deleteStakeFromSaleList(_address);
	
	if (pc.stakeBalances(_address) == 0)
		deleteStakeHolder(_address);	
	
	if (pc.stakeHoldersListIndex(_from) == 0)
		addStakeHolder(_from);
	
	emit StakeGenesisSale(_from, _address, _value, _amountGenesisToBurn, totalToSend);
	
	pa.StakeTradeHistorySellerSet(_address);
	pa.StakeTradeHistoryBuyerSet(_from);
	pa.StakeTradeHistoryStakeAmountSet(_value);
	pa.StakeTradeHistoryETHPriceSet(totalToSend);
	pa.StakeTradeHistoryETHFeeSet(feesGeneralToPayToContract);
	pa.StakeTradeHistoryMNEGenesisBurnedSet(_amountGenesisToBurn);
	pa.StakeTradeHistoryDateSet(now);
	
	return feesToPayToSeller;
}
}