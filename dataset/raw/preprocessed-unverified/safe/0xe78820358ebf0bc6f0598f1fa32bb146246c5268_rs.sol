/**
 *Submitted for verification at Etherscan.io on 2020-12-06
*/

pragma solidity ^0.6.0;







contract BaseTransfers
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
pc.setOwnerBaseTransfers();
pa = publicArrays(_publicArraysAddress);
pa.setOwnerBaseTransfers();
gn = genesisCalls(_genesisAddress);
gn.setOwnerBaseTransfers();
}	

function reloadGenesis(address _address) public
{
	if (msg.sender == updaterAddress)
	{
		gn = genesisCalls(_address);
		gn.setOwnerBaseTransfers();
	}
	else revert();
}

function reloadPublicCalls(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pc = publicCalls(_address); pc.setOwnerBaseTransfers();} else revert();}
function reloadPublicArrays(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pa = publicArrays(_address); pa.setOwnerBaseTransfers();} else revert();}

function transfer(address _from, address _to, uint256 _value) onlyOwner public { 
if (gn.isAnyGenesisAddress(_to)) revert('gn.isAnyGenesisAddress(_to)');

if (gn.isGenesisAddressLevel1(_from) || gn.isGenesisAddressLevel2(_from)) revert('ERROR You must first upgrade to Level 3 to allow transfers. Visit https://minereum.com for more info');

if (pc.isNormalAddressForSale(_from)) revert('pc.isNormalAddressForSale(_from)');

if (pc.isGenesisAddressForSale(_from)) revert('pc.isGenesisAddressForSale(_from)');

if (pc.isNormalAddressForSale(_to)) revert('pc.isNormalAddressForSale(_to)');

if (pc.isGenesisAddressForSale(_to)) revert('pc.isGenesisAddressForSale(_to)');

if (pc.balances(_from) < _value) revert('pc.isGenesisAddressForSale(_to)'); 

if (pc.balances(_to) + _value < pc.balances(_to)) revert('(pc.balances(_to) + _value < pc.balances(_to))'); 

if (_value > gn.availableBalanceOf(_from)) revert('(_value > gn.availableBalanceOf(_from))');

pc.balancesSet(_from, pc.balances(_from) - _value);
pc.balancesSet(_to, pc.balances(_to) + _value); 
}

function transferFrom (
		address _sender,
        address _from,
        address _to,
        uint256 _amount
) public onlyOwner returns (bool success) {
	if (gn.isAnyGenesisAddress(_to))
		revert('(gn.isAnyGenesisAddress(_to))');
	
	if (gn.isGenesisAddressLevel1(_from) || gn.isGenesisAddressLevel2(_from))
		revert('gn.isGenesisAddressLevel1(_from) || gn.isGenesisAddressLevel2(_from)');
	
	if (pc.isGenesisAddressForSale(_sender)) revert('pc.isGenesisAddressForSale(_sender)');
	
	if (pc.isNormalAddressForSale(_to) || pc.isNormalAddressForSale(_from))
		revert('pc.isNormalAddressForSale(_to) || pc.isNormalAddressForSale(_from)');
	
    if (gn.availableBalanceOf(_from) >= _amount
        && pc.allowed(_from,_sender) >= _amount
        && _amount > 0
        && pc.balances(_to) + _amount > pc.balances(_to)) {
        pc.balancesSet(_from, pc.balances(_from) - _amount);
        pc.allowedSet(_from, _sender, pc.allowed(_from,_sender) - _amount);
        pc.balancesSet(_to, pc.balances(_to) + _amount);        
        return true;
    } else {
		revert();
        return false;
    }
}
function getPriceLevel1() public view returns (uint256 price)
{
	uint256 feesToPayToContract = pc.ethFeeToBuyLevel1();
	uint256 feesToPayToSeller = pc.ethFeeForSellerLevel1();
	uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentFeeGenesisExchange() / 100;
		
	uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
	return totalToSend;
}

function getPriceLevel2(address _add) public view returns (uint256 price)
{
	uint256 feesToPayToContract = pc.ethFeeToUpgradeToLevel3();
	uint256 feesToPayToSeller = pc.genesisBuyPrice(_add);
	uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentFeeGenesisExchange() / 100;
		
	uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
	return totalToSend;
}

function getPriceLevel3(address _add) public view returns (uint256 price)
{
	uint256 feesToPayToContract = 0;
	uint256 feesToPayToSeller = pc.genesisBuyPrice(_add);
	uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentFeeGenesisExchange() / 100;
	uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
	return totalToSend;
}

function getPriceNormalAddress(address _add) public view returns (uint256 price)
{
	uint256 _ETHPricePerMNE = pc.NormalAddressBuyPricePerMNE(_add) + (pc.NormalAddressBuyPricePerMNE(_add) * pc.ethPercentFeeNormalExchange() / 100);
	uint256 _totalETHPrice = _ETHPricePerMNE * gn.balanceOf(_add) / 100000000;
	return _totalETHPrice;
}

function getStakePrice(address _add) public view returns (uint256 price)
{
	uint256 feesToPayToContract = 0;
	uint256 feesToPayToSeller = pc.stakeBuyPrice(_add);
	uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentStakeExchange() / 100;
    uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
	return totalToSend;
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

function getStakeMNEFeeTransfer(uint256 _value) public view returns (uint256 price)
{
	uint256 mneFee = pc.amountOfMNEToTransferStakes()*_value * 100 / pc.stakeDecimals();
	if (mneFee < pc.amountOfMNEToTransferStakes())
		mneFee = pc.amountOfMNEToTransferStakes();
	return mneFee;
}

function getStakeGenesisFeeTransfer(uint256 _value) public view returns (uint256 price)
{
	uint256 genesisAddressFee = pc.amountOfGenesisToTransferStakes()*_value * 100 / pc.stakeDecimals();
	if (genesisAddressFee < pc.amountOfGenesisToTransferStakes())
	genesisAddressFee = pc.amountOfGenesisToTransferStakes();
	return genesisAddressFee;
}

function stopSetup(address _from) public onlyOwner returns (bool success)
{
	if (_from == pc.genesisCallerAddress())
	{
		pc.setupRunningSet(false);
	}
	return true;
}

function totalSupply() public view returns (uint256 TotalSupply)
{	
	return ((pc.genesisAddressCount() * pc.genesisSupplyPerAddress()) + pc.NormalImportedAmountCount() - pc.mneBurned() - pc.GenesisDestroyAmountCount());
}
}