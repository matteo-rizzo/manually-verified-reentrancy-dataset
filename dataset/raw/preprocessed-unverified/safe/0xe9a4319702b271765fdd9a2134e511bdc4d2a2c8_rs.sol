/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity ^0.6.0;







contract genesisBuys
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
pc.setOwnerGenesisBuys();
pa = publicArrays(_publicArraysAddress);
pa.setOwnerGenesisBuys();
gn = genesisCalls(_genesisAddress);
gn.setOwnerGenesisBuys();
}	

function reloadGenesis(address _address) public
{
	if (msg.sender == updaterAddress)
	{
		gn = genesisCalls(_address);
		gn.setOwnerGenesisBuys();
	}
	else revert();
}

function reloadPublicCalls(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pc = publicCalls(_address); pc.setOwnerGenesisBuys();} else revert();}
function reloadPublicArrays(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pa = publicArrays(_address); pa.setOwnerGenesisBuys();} else revert();}

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

function BuyGenesisLevel1FromNormal(address _from, address _address, uint256 _msgvalue) public onlyOwner returns (uint256 _totalToSend) {
	if (_msgvalue == 0) revert('(_msgvalue == 0)');
	
	if (!(_from != _address)) revert('(!(_from != _address))');
	
	if (!pc.isGenesisAddressForSale(_address)) revert('(!pc.isGenesisAddressForSale(_address))');
	
	if (pc.isGenesisAddressForSale(_from)) revert('pc.isGenesisAddressForSale(_from)');
	
	if (gn.isAnyGenesisAddress(_from)) revert('gn.isAnyGenesisAddress(_from)');

	if (!gn.isGenesisAddressLevel1(_address)) revert('(!gn.isGenesisAddressLevel1(_address))');
	
	if (gn.balanceOf(_address) == 0) revert('(gn.balanceOf(_address) == 0)');
	
	if (gn.balanceOf(_from) > 0) revert('(gn.balanceOf(_from) > 0)');
	
	uint256 feesToPayToContract = pc.ethFeeToBuyLevel1();
	uint256 feesToPayToSeller = pc.ethFeeForSellerLevel1();
	uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentFeeGenesisExchange() / 100;
		
	uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
	
	if  (totalToSend == 0) revert('totalSend == 0');
	if (!(_msgvalue == totalToSend)) revert('(!(_msgvalue == totalToSend))');
	
	gn.deleteAddressFromGenesisSaleList(_address);	
	pc.balancesSet(_from, pc.genesisSupplyPerAddress());
	pc.balancesSet(_address, 0);
	pc.initialBlockCountPerAddressSet(_from, block.number);
	pc.isGenesisAddressSet(_from, 3);
	pc.isGenesisAddressSet(_address, 0);
	pc.genesisBuyPriceSet(_from, 0);
	pc.genesisBuyPriceSet(_address, 0);
	pc.isGenesisAddressForSaleSet(_address, false);
	pc.isGenesisAddressForSaleSet(_from, false);
	pc.allowAddressToDestroyGenesisSet(_address, 0x0000000000000000000000000000000000000000);
	pc.allowAddressToDestroyGenesisSet(_from, 0x0000000000000000000000000000000000000000);
	pc.allowReceiveGenesisTransfersSet(_from, false);
	pc.allowReceiveGenesisTransfersSet(_address, false);		
	emit GenesisAddressSale(_address, _from, _msgvalue, pc.balances(_from));
	pc.genesisSalesCountSet(pc.genesisSalesCount() + 1);
	pc.genesisSalesPriceCountSet(pc.genesisSalesPriceCount() + _msgvalue);
	
	pa.Level1TradeHistorySellerSet(_address);
	pa.Level1TradeHistoryBuyerSet(_from);
	pa.Level1TradeHistoryAmountMNESet(gn.balanceOf(_from));
	pa.Level1TradeHistoryAmountETHSet(totalToSend);
	pa.Level1TradeHistoryAmountETHFeeSet(feesGeneralToPayToContract+feesToPayToContract);
	pa.Level1TradeHistoryDateSet(now);
	return feesToPayToSeller;
}

function BuyGenesisLevel2FromNormal(address _from, address _address, uint256 _msgvalue) public onlyOwner returns (uint256 _totalToSend) {
	if (_msgvalue == 0) revert('_msgvalue == 0');
	
	if (!(_from != _address)) revert('(!(_from != _address))');
	
	if (!pc.isGenesisAddressForSale(_address)) revert('(!pc.isGenesisAddressForSale(_address))');
	
	if (pc.isGenesisAddressForSale(_from)) revert('pc.isGenesisAddressForSale(_from)');
	
	if (gn.isAnyGenesisAddress(_from)) revert('gn.isAnyGenesisAddress(_from)');

	if (!gn.isGenesisAddressLevel2(_address)) revert('(!gn.isGenesisAddressLevel2(_address))');
	
	if (gn.balanceOf(_address) == 0) revert('gn.balanceOf(_address) == 0');
	
	if (gn.balanceOf(_from) > 0) revert('gn.balanceOf(_from) > 0');
	
	uint256 feesToPayToContract = pc.ethFeeToUpgradeToLevel3();
	uint256 feesToPayToSeller = pc.genesisBuyPrice(_address);
	uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentFeeGenesisExchange() / 100;
		
	uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
	
	if  (totalToSend == 0) revert('totalToSend == 0');
	if (!(_msgvalue == totalToSend)) revert('(!(_msgvalue == totalToSend))');
	
	gn.deleteAddressFromGenesisSaleList(_address);	
	pc.balancesSet(_from, pc.balances(_address));
	pc.balancesSet(_address, 0);
	pc.initialBlockCountPerAddressSet(_from, pc.initialBlockCountPerAddress(_address));
	pc.initialBlockCountPerAddressSet(_address, 0);
	pc.isGenesisAddressSet(_from, 3);
	pc.isGenesisAddressSet(_address, 0);
	pc.genesisBuyPriceSet(_from, 0);
	pc.genesisBuyPriceSet(_address, 0);
	pc.isGenesisAddressForSaleSet(_address, false);
	pc.isGenesisAddressForSaleSet(_from, false);
	pc.allowAddressToDestroyGenesisSet(_address, 0x0000000000000000000000000000000000000000);
	pc.allowAddressToDestroyGenesisSet(_from, 0x0000000000000000000000000000000000000000);
	pc.allowReceiveGenesisTransfersSet(_from, false);
	pc.allowReceiveGenesisTransfersSet(_address, false);
	emit GenesisAddressSale(_address, _from, _msgvalue, pc.balances(_from));
	pc.genesisSalesCountSet(pc.genesisSalesCount() + 1);
	pc.genesisSalesPriceCountSet(pc.genesisSalesPriceCount() + _msgvalue);
	pa.Level2TradeHistorySellerSet(_address);
	pa.Level2TradeHistoryBuyerSet(_from);
	pa.Level2TradeHistoryAmountMNESet(gn.balanceOf(_from));
	pa.Level2TradeHistoryAvailableAmountMNESet(gn.availableBalanceOf(_from));
	pa.Level2TradeHistoryAmountETHSet(totalToSend);
	pa.Level2TradeHistoryAmountETHFeeSet(feesGeneralToPayToContract + feesToPayToContract);
	pa.Level2TradeHistoryDateSet(now);
	return feesToPayToSeller;
}

function BuyGenesisLevel3FromNormal(address _from, address _address, uint256 _msgvalue) public onlyOwner returns (uint256 _totalToSend){
	if (_msgvalue == 0) revert('_msgvalue == 0');
	
	if (!(_from != _address)) revert('(!(_from != _address))');
	
	if (!pc.isGenesisAddressForSale(_address)) revert('(!pc.isGenesisAddressForSale(_address))');
	
	if (pc.isGenesisAddressForSale(_from)) revert('pc.isGenesisAddressForSale(_from)');
	
	if (gn.isAnyGenesisAddress(_from)) revert('gn.isAnyGenesisAddress(_from)');

	if (!gn.isGenesisAddressLevel3(_address)) revert('(!gn.isGenesisAddressLevel3(_address))');
	
	if (gn.balanceOf(_address) == 0) revert('gn.balanceOf(_address) == 0');
	
	if (gn.balanceOf(_from) > 0) revert('gn.balanceOf(_from) > 0');
	
	uint256 feesToPayToContract = 0;
	uint256 feesToPayToSeller = pc.genesisBuyPrice(_address);
	uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentFeeGenesisExchange() / 100;
		
	uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
	
	if  (totalToSend == 0) revert('totalToSend == 0');
	if (!(_msgvalue == totalToSend)) revert('(!(_msgvalue == totalToSend))');
	
	gn.deleteAddressFromGenesisSaleList(_address);			
	pc.balancesSet(_from, pc.balances(_address));
	pc.balancesSet(_address, 0);
	pc.initialBlockCountPerAddressSet(_from, pc.initialBlockCountPerAddress(_address));
	pc.initialBlockCountPerAddressSet(_address, 0);
	pc.isGenesisAddressSet(_from, 3);
	pc.isGenesisAddressSet(_address, 0);
	pc.genesisBuyPriceSet(_from, 0);
	pc.genesisBuyPriceSet(_address, 0);
	pc.isGenesisAddressForSaleSet(_address, false);
	pc.isGenesisAddressForSaleSet(_from, false);
	pc.allowAddressToDestroyGenesisSet(_address, 0x0000000000000000000000000000000000000000);
	pc.allowAddressToDestroyGenesisSet(_from, 0x0000000000000000000000000000000000000000);
	pc.allowReceiveGenesisTransfersSet(_from, false);
	pc.allowReceiveGenesisTransfersSet(_address, false);
	emit GenesisAddressSale(_address, _from, _msgvalue, pc.balances(_from));
	pc.genesisSalesCountSet(pc.genesisSalesCount() + 1);
	pc.genesisSalesPriceCountSet(pc.genesisSalesPriceCount() + _msgvalue);
	pa.Level3TradeHistorySellerSet(_address);
	pa.Level3TradeHistoryBuyerSet(_from);
	pa.Level3TradeHistoryAmountMNESet(gn.balanceOf(_from));
	pa.Level3TradeHistoryAvailableAmountMNESet(gn.availableBalanceOf(_from));
	pa.Level3TradeHistoryAmountETHSet(totalToSend);
	pa.Level3TradeHistoryAmountETHFeeSet(feesGeneralToPayToContract);
	pa.Level3TradeHistoryDateSet(now);
	return feesToPayToSeller;
}
}