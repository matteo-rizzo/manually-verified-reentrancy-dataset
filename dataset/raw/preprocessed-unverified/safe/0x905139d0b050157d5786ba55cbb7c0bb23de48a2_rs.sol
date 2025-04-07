/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity ^0.6.0;







contract NormalAddresses
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
pc.setOwnerNormalAddress();
pa = publicArrays(_publicArraysAddress);
pa.setOwnerNormalAddress();
gn = genesisCalls(_genesisAddress);
gn.setOwnerNormalAddress();
}

function reloadGenesis(address _address) public
{
	if (msg.sender == updaterAddress)
	{
		gn = genesisCalls(_address);
		gn.setOwnerNormalAddress();
	}
	else revert();
}

function reloadPublicCalls(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pc = publicCalls(_address); pc.setOwnerNormalAddress();} else revert();}
function reloadPublicArrays(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pa = publicArrays(_address); pa.setOwnerNormalAddress();} else revert();}



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

function SetNormalAddressForSale(address _from, uint256 weiPricePerMNE) public onlyOwner{
	
	if (weiPricePerMNE < 10) revert('(weiPricePerMNE < 10)');
	
	if (gn.isAnyGenesisAddress(_from)) revert('gn.isAnyGenesisAddress(_from)');
	
	if (gn.balanceOf(_from) == 0) revert('gn.balanceOf(_from) == 0');
	
	if (pc.NormalAddressBuyPricePerMNE(_from) > 0) revert('pc.NormalAddressBuyPricePerMNE(_from) > 0');
	
	if (pc.isNormalAddressForSale(_from)) revert('pc.isNormalAddressForSale(_from)');
	
	uint totalPrice = weiPricePerMNE * gn.balanceOf(_from) / 100000000;
	
	if (totalPrice == 0) revert('if (totalPrice == 0)');
	
	pc.NormalAddressBuyPricePerMNESet(_from, weiPricePerMNE);	
	
	pa.normalAddressesForSaleSet(_from);
	
	pc.normalAddressesForSaleIndexSet(_from, pa.normalAddressesForSaleLength() - 1);	
	
	pc.isNormalAddressForSaleSet(_from, true);	
	
	emit NormalAddressForSaleHistory(_from, weiPricePerMNE);
}

function deleteAddressFromNormalSaleList(address _address) private {
		uint lastIndex = pa.normalAddressesForSaleLength() - 1;
		if (lastIndex > 0)
		{
			address lastIndexAddress = pa.normalAddressesForSale(lastIndex);
			pc.normalAddressesForSaleIndexSet(lastIndexAddress, pc.normalAddressesForSaleIndex(_address));
			pa.normalAddressesForSaleSetAt(pc.normalAddressesForSaleIndex(_address), lastIndexAddress);
		}
		pc.normalAddressesForSaleIndexSet(_address, 0);
		pa.deleteNormalAddressesForSale();
}

function RemoveNormalAddressFromSale(address _address) public onlyOwner { 
	if (gn.isAnyGenesisAddress(_address)) revert('(gn.isAnyGenesisAddress(_address))');
	if (!pc.isNormalAddressForSale(_address)) revert('(!pc.isNormalAddressForSale(_address))');
	pc.isNormalAddressForSaleSet(_address, false);
	pc.NormalAddressBuyPricePerMNESet(_address, 0);
	deleteAddressFromNormalSaleList(_address);
	emit NormalAddressRemoveSaleHistory(_address);	
}

function setBalanceNormalAddress(address _from, address _address, uint256 balance) public onlyOwner
{
	if (pc.setupRunning() && _from == pc.genesisCallerAddress())
	{
		if (pc.isGenesisAddress(_address) > 0)
		{
			pc.isGenesisAddressSet(_address, 0);
			pc.genesisAddressCountSet(pc.genesisAddressCount()-1);
		}
		pc.balancesSet(_address, balance);
		pc.NormalBalanceImportedSet(pc.NormalBalanceImported()+1);
		pc.NormalImportedAmountCountSet(pc.NormalImportedAmountCount() + balance);
	}
	else
	{
		revert();
	}
}

function BuyNormalAddress(address _from, address _address, uint256 _msgvalue) public onlyOwner returns (uint256 _totalToSend){
	if (_msgvalue == 0) revert('_msgvalue == 0');
	
	if (!(_from != _address)) revert('(!(_from != _address))');
	
	if (!pc.isNormalAddressForSale(_address)) revert('(!pc.isNormalAddressForSale(_address))');
	
	if (pc.isNormalAddressForSale(_from)) revert('(pc.isNormalAddressForSale(_from))');
	
	if (gn.isAnyGenesisAddress(_from)) revert('(gn.isAnyGenesisAddress(_from))');
	
	if (gn.isAnyGenesisAddress(_address)) revert('(gn.isAnyGenesisAddress(_address))');

	if (gn.balanceOf(_address) == 0) revert('(gn.balanceOf(_address) == 0)');
	
	uint256 feesToPayToContract = 0;
	uint256 feesToPayToSeller = gn.balanceOf(_address) * pc.NormalAddressBuyPricePerMNE(_address) / 100000000;
	uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentFeeNormalExchange() / 100;
		
	uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
	
	if  (totalToSend == 0) revert('(totalToSend == 0)');
	if (!(_msgvalue == totalToSend)) revert('(!(_msgvalue == totalToSend))');
	
	uint256 soldBalance = gn.balanceOf(_address);
	
	deleteAddressFromNormalSaleList(_address);	
	pc.balancesSet(_from, pc.balances(_from) + gn.balanceOf(_address));
	pc.balancesSet(_address, 0);
	pc.NormalAddressBuyPricePerMNESet(_address, 0);
	pc.isNormalAddressForSaleSet(_address, false);
	pc.NormalAddressBuyPricePerMNESet(_from, 0);
	pc.isNormalAddressForSaleSet(_from, false);	
	emit NormalAddressSale(_address, _from, _msgvalue, soldBalance);
	pc.NormalAddressSalesCountSet(pc.NormalAddressSalesCount() + 1);
	pc.NormalAddressSalesPriceCountSet(pc.NormalAddressSalesPriceCount() + _msgvalue);	
	pc.NormalAddressSalesMNECountSet(pc.NormalAddressSalesMNECount() + soldBalance);	
	pc.NormalAddressFeeCountSet(pc.NormalAddressFeeCount() + feesGeneralToPayToContract);
	
	pa.MNETradeHistorySellerSet(_address);
	pa.MNETradeHistoryBuyerSet(_from);
	pa.MNETradeHistoryAmountMNESet(soldBalance);
	pa.MNETradeHistoryAmountETHSet(_msgvalue);
	pa.MNETradeHistoryAmountETHFeeSet(feesGeneralToPayToContract);
	pa.MNETradeHistoryDateSet(now);
	
	return feesToPayToSeller;
}
}