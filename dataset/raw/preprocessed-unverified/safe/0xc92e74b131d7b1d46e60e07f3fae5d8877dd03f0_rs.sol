/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity ^0.6.0;



















contract Minereum { 
string public name; 
string public symbol; 
uint8 public decimals; 

event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event LogStakeHolderSends(address indexed to, uint balance, uint amountToSend);
event LogFailedStakeHolderSends(address indexed to, uint balance, uint amountToSend);
event TokenCreation(address indexed from, address contractAdd);
event TokenCreationICO(address indexed from, address  contractAdd);
event StakeTransfer(address indexed from, address indexed to, uint256 value);

publicCalls public pc;
publicArrays public pa;
genesisCalls public gn;
normalAddress public na;
stakes public st;
stakeBuys public stb;
genesisBuys public gnb;
tokenService public tks;
baseTransfers public bst;

address public updaterAddress = 0x0000000000000000000000000000000000000000;
function setUpdater() public {if (updaterAddress == 0x0000000000000000000000000000000000000000) updaterAddress = msg.sender; else revert();}
address public payoutOwner = 0x0000000000000000000000000000000000000000;
bool public payoutBlocked = false;
address payable public secondaryPayoutAddress = 0x0000000000000000000000000000000000000000;

constructor(address _publicCallsAddress, address _publicArraysAddress, address _genesisCallsAddress, address _normalAddressAddress,
 address _stakesAddress, address _stakesBuysAddress,address _genesisBuysAddress, address _tokenServiceAddress, address _baseTransfersAddress) public {
name = "Minereum"; 
symbol = "MNE"; 
decimals = 8; 
setUpdater();
pc = publicCalls(_publicCallsAddress);
pc.setOwnerMain();
pa = publicArrays(_publicArraysAddress);
pa.setOwnerMain();
gn = genesisCalls(_genesisCallsAddress);
gn.setOwnerMain();
na = normalAddress(_normalAddressAddress);
na.setOwnerMain();
st = stakes(_stakesAddress);
st.setOwnerMain();
stb = stakeBuys(_stakesBuysAddress);
stb.setOwnerMain();
gnb = genesisBuys(_genesisBuysAddress);
gnb.setOwnerMain();
tks = tokenService(_tokenServiceAddress);
tks.setOwnerMain();
bst = baseTransfers(_baseTransfersAddress);
bst.setOwnerMain();
pc.initialBlockCountSet(block.number);
pc.overallSupplySet(0);
pc.genesisSalesCountSet(0);
pc.genesisSalesPriceCountSet(0);
pc.genesisTransfersCountSet(0);
pc.setupRunningSet(true);
pc.genesisCallerAddressSet(0x0000000000000000000000000000000000000000);
}

function reloadGenesis(address _address) public { if (msg.sender == updaterAddress)	{gn = genesisCalls(_address); gn.setOwnerMain(); } else revert();}
function reloadNormalAddress(address _address) public { if (msg.sender == updaterAddress)	{na = normalAddress(_address); na.setOwnerMain(); } else revert();}
function reloadStakes(address _address) public { if (msg.sender == updaterAddress)	{st = stakes(_address); st.setOwnerMain(); } else revert();}
function reloadStakeBuys(address _address) public { if (msg.sender == updaterAddress)	{stb = stakeBuys(_address); stb.setOwnerMain(); } else revert();}
function reloadGenesisBuys(address _address) public { if (msg.sender == updaterAddress)	{gnb = genesisBuys(_address); gnb.setOwnerMain(); } else revert();}
function reloadTokenService(address _address) public { if (msg.sender == updaterAddress)	{tks = tokenService(_address); tks.setOwnerMain(); } else revert();}
function reloadPublicCalls(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pc = publicCalls(_address); pc.setOwnerMain();} else revert();}
function reloadPublicArrays(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pa = publicArrays(_address); pa.setOwnerMain();} else revert();}

function setPayoutOwner() public
{
	if(payoutOwner == 0x0000000000000000000000000000000000000000)
		payoutOwner = msg.sender;
	else
		revert();
}

function setSecondaryPayoutAddress(address payable _address) public
{
	if(msg.sender == payoutOwner)
		secondaryPayoutAddress = _address;
	else
		revert();
}



function SetBlockPayouts(bool toBlock) public
{
	if(msg.sender == payoutOwner)
	{
		payoutBlocked = toBlock;
	}
}


function currentEthBlock() public view returns (uint256 blockNumber) 
{
	return block.number;
}

function currentBlock() public view returns (uint256 blockNumber)
{
	return block.number - pc.initialBlockCount();
}

function availableBalanceOf(address _address) public view returns (uint256 Balance)
{
	return gn.availableBalanceOf(_address);
}

function totalSupply() public view returns (uint256 TotalSupply)
{	
	return bst.totalSupply();
}

function transfer(address _to, uint256 _value)  public { 
if (_to == address(this)) revert('if (_to == address(this))');
bst.transfer(msg.sender, _to, _value);
emit Transfer(msg.sender, _to, _value); 
}

function transferFrom(
        address _from,
        address _to,
        uint256 _amount
) public returns (bool success) {
		bool result = bst.transferFrom(msg.sender, _from, _to, _amount);
        emit Transfer(_from, _to, _amount);
        return result;    
}

function approve(address _spender, uint256 _amount) public returns (bool success) {
    pc.allowedSet(msg.sender,_spender, _amount);
    emit Approval(msg.sender, _spender, _amount);
    return true;
}

function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return pc.allowed(_owner,_spender);
}

function balanceOf(address _address) public view returns (uint256 balance) {
	return gn.balanceOf(_address);
}

function stakeBalanceOf(address _address) public view returns (uint256 balance) {
	return pc.stakeBalances(_address);
}

function TransferGenesis(address _to) public {
	if (_to == address(this)) revert('if (_to == address(this))');	
	gn.TransferGenesis(msg.sender, _to);
	emit Transfer(msg.sender, _to, balanceOf(_to));	
}

function SetGenesisForSale(uint256 weiPrice) public {	
	gn.SetGenesisForSale(msg.sender, weiPrice);
}

function AllowReceiveGenesisTransfers() public { 
	gn.AllowReceiveGenesisTransfers(msg.sender);
}

function RemoveAllowReceiveGenesisTransfers() public { 
	gn.RemoveAllowReceiveGenesisTransfers(msg.sender);
}

function RemoveGenesisAddressFromSale() public { 
	gn.RemoveGenesisAddressFromSale(msg.sender);
}

function AllowAddressToDestroyGenesis(address _address) public  { 
	gn.AllowAddressToDestroyGenesis(msg.sender, _address);
}

function RemoveAllowAddressToDestroyGenesis() public { 
	gn.RemoveAllowAddressToDestroyGenesis(msg.sender);
}

function UpgradeToLevel2FromLevel1() public payable {
	gn.UpgradeToLevel2FromLevel1(msg.sender, msg.value);
}

function UpgradeToLevel3FromLevel1() public payable {
	gn.UpgradeToLevel3FromLevel1(msg.sender, msg.value);
}

function UpgradeToLevel3FromLevel2() public payable {
	gn.UpgradeToLevel3FromLevel2(msg.sender, msg.value);
}

function UpgradeToLevel3FromDev() public {
	gn.UpgradeToLevel3FromDev(msg.sender);
}

function UpgradeOthersToLevel2FromLevel1(address[] memory _addresses) public payable {
	uint count = _addresses.length;
	if (msg.value != (pc.ethFeeToUpgradeToLevel2()*count)) revert('(msg.value != pc.ethFeeToUpgradeToLevel2()*count)');
	uint i = 0;
	while (i < count)
	{
		gn.UpgradeToLevel2FromLevel1(_addresses[i], pc.ethFeeToUpgradeToLevel2());
		i++;
	}
}

function UpgradeOthersToLevel3FromLevel1(address[] memory _addresses) public payable {
	uint count = _addresses.length;
	if (msg.value != ((pc.ethFeeToUpgradeToLevel2() + pc.ethFeeToUpgradeToLevel3())*count)) revert('(weiValue != ((msg.value + pc.ethFeeToUpgradeToLevel3())*count))');
	uint i = 0;
	while (i < count)
	{
		gn.UpgradeToLevel3FromLevel1(_addresses[i], (pc.ethFeeToUpgradeToLevel2() + pc.ethFeeToUpgradeToLevel3()));
		i++;
	}
}

function UpgradeOthersToLevel3FromLevel2(address[] memory _addresses) public payable {
	uint count = _addresses.length;
	if (msg.value != (pc.ethFeeToUpgradeToLevel3()*count)) revert('(msg.value != (pc.ethFeeToUpgradeToLevel3()*count))');
	uint i = 0;
	while (i < count)
	{
		gn.UpgradeToLevel3FromLevel2(_addresses[i], pc.ethFeeToUpgradeToLevel3());
		i++;
	}
}

function UpgradeOthersToLevel3FromDev(address[] memory _addresses) public {
	uint count = _addresses.length;	
	uint i = 0;
	while (i < count)
	{
		gn.UpgradeToLevel3FromDev(_addresses[i]);
		i++;
	}
}

function BuyGenesisAddress(address payable _address) public payable
{
	if (gn.isGenesisAddressLevel1(_address))
		BuyGenesisLevel1FromNormal(_address);
	else if (gn.isGenesisAddressLevel2(_address))
		BuyGenesisLevel2FromNormal(_address);
	else if (gn.isGenesisAddressLevel3(_address))
		BuyGenesisLevel3FromNormal(_address);
	else
		revert('Address not for sale');
}

function SetNormalAddressForSale(uint256 weiPricePerMNE) public {	
	na.SetNormalAddressForSale(msg.sender, weiPricePerMNE);
}

function RemoveNormalAddressFromSale() public
{
	na.RemoveNormalAddressFromSale(msg.sender);
}

function BuyNormalAddress(address payable _address) public payable{
	uint256 feesToPayToSeller = na.BuyNormalAddress(msg.sender, address(_address), msg.value);				
	if(!_address.send(feesToPayToSeller)) revert('(!_address.send(feesToPayToSeller))');
	emit Transfer(_address, msg.sender, balanceOf(_address));	
}

function setBalanceNormalAddress(address _address, uint256 _balance) public
{
	na.setBalanceNormalAddress(msg.sender, _address, _balance);
	emit Transfer(address(this), _address, _balance); 
}

function ContractTransferAllFundsOut() public
{
	//in case of hack, funds can be transfered out to another addresses and transferred to the stake holders from there
	if (payoutBlocked)
		if(!secondaryPayoutAddress.send(address(this).balance)) revert();
}

function PayoutStakeHolders(uint minId, uint maxId) public {
	require(msg.sender == tx.origin); //For security reasons this line is to prevent smart contract calls
	if (payoutBlocked) revert('Payouts Blocked'); //In case of hack, payouts can be blocked
	uint contractBalance = address(this).balance;
	if (!(contractBalance > 0)) revert('(!(contractBalance > 0))');
	uint i;
	uint max;
	
	if (minId > 0 && maxId >0)
	{
		i = minId;
		max = maxId;
	}
	else
	{
		i = 0;
		max = pa.stakeHoldersListLength();
	}

	while (i < max)
	{
		address payable add = payable(pa.stakeHoldersList(i));
		uint balance = pc.stakeBalances(add);
		uint amountToSend = contractBalance * balance / pc.stakeDecimals();
		if (amountToSend > 0)
		{
			if (!add.send(amountToSend))
				emit LogFailedStakeHolderSends(add, balance, amountToSend);
			else
			{
				pc.totalPaidStakeHoldersSet(pc.totalPaidStakeHolders() + amountToSend);
				emit LogStakeHolderSends(add, balance, amountToSend);	
			}			
		}
		i++;
	}
}

function stopSetup() public returns (bool success)
{
	return bst.stopSetup(msg.sender);
}

function BurnTokens(uint256 mneToBurn) public returns (bool success) {	
	gn.BurnTokens(msg.sender, mneToBurn);
	emit Transfer(msg.sender, 0x0000000000000000000000000000000000000000, mneToBurn);
	return true;
}

function SetStakeForSale(uint256 priceInWei) public
{	
	st.SetStakeForSale(msg.sender, priceInWei);
}

function RemoveStakeFromSale() public {
	st.RemoveStakeFromSale(msg.sender);
}

function StakeTransferMNE(address _to, uint256 _value) public {
	if (_to == address(this)) revert('if (_to == address(this))');
	BurnTokens(st.StakeTransferMNE(msg.sender, _to, _value));
	emit StakeTransfer(msg.sender, _to, _value); 
}

function BurnGenesisAddresses(address[] memory _genesisAddressesToBurn) public
{
	gn.BurnGenesisAddresses(msg.sender, _genesisAddressesToBurn);
	uint i = 0;	
	while(i < _genesisAddressesToBurn.length)
	{
		emit Transfer(_genesisAddressesToBurn[i], 0x0000000000000000000000000000000000000000, balanceOf(_genesisAddressesToBurn[i]));
		i++;
	}
}

function StakeTransferGenesis(address _to, uint256 _value, address[] memory _genesisAddressesToBurn) public {
	if (_to == address(this)) revert('if (_to == address(this))');
	uint i = 0;	
	while(i < _genesisAddressesToBurn.length)
	{
		emit Transfer(_genesisAddressesToBurn[i], 0x0000000000000000000000000000000000000000, balanceOf(_genesisAddressesToBurn[i]));
		i++;
	}
	st.StakeTransferGenesis(msg.sender, _to, _value, _genesisAddressesToBurn);	
	emit StakeTransfer(msg.sender, _to, _value); 
}

function setBalanceStakes(address _address, uint256 balance) public {
	st.setBalanceStakes(msg.sender, _address, balance);
}

function BuyGenesisLevel1FromNormal(address payable _address) public payable {
	uint256 feesToPayToSeller = gnb.BuyGenesisLevel1FromNormal(msg.sender, address(_address), msg.value);
	if(!_address.send(feesToPayToSeller)) revert('(!_address.send(feesToPayToSeller))');	
	emit Transfer(_address, msg.sender, balanceOf(msg.sender));		
}

function BuyGenesisLevel2FromNormal(address payable _address) public payable{
	uint256 feesToPayToSeller = gnb.BuyGenesisLevel2FromNormal(msg.sender, address(_address), msg.value);	
	if(!_address.send(feesToPayToSeller)) revert('(!_address.send(feesToPayToSeller))');
	emit Transfer(_address, msg.sender, balanceOf(msg.sender));
}

function BuyGenesisLevel3FromNormal(address payable _address) public payable{
	uint256 feesToPayToSeller = gnb.BuyGenesisLevel3FromNormal(msg.sender, address(_address), msg.value);	
	if(!_address.send(feesToPayToSeller)) revert('(!_address.send(feesToPayToSeller))');	
	emit Transfer(_address, msg.sender, balanceOf(msg.sender));
}

function BuyStakeMNE(address payable _address) public payable {
	uint256 balanceToSend = pc.stakeBalances(_address);
	(uint256 mneToBurn, uint256 feesToPayToSeller) = stb.BuyStakeMNE(msg.sender, address(_address), msg.value);
	BurnTokens(mneToBurn);
	if(!_address.send(feesToPayToSeller)) revert('(!_address.send(feesToPayToSeller))');	
	emit StakeTransfer(_address, msg.sender, balanceToSend); 
}

function BuyStakeGenesis(address payable _address, address[] memory _genesisAddressesToBurn) public payable {
	uint256 balanceToSend = pc.stakeBalances(_address);
	uint i = 0;
	while(i < _genesisAddressesToBurn.length)
	{
		emit Transfer(_genesisAddressesToBurn[i], 0x0000000000000000000000000000000000000000, balanceOf(_genesisAddressesToBurn[i]));
		i++;
	}
	uint256 feesToPayToSeller = stb.BuyStakeGenesis(msg.sender, address(_address), _genesisAddressesToBurn, msg.value);
	if(!_address.send(feesToPayToSeller)) revert();		
	emit StakeTransfer(_address, msg.sender, balanceToSend); 
}

function CreateToken() public payable {
	(uint256 _mneToBurn, address tokenAdderss) = tks.CreateToken(msg.sender, msg.value);
	BurnTokens(_mneToBurn);
	emit TokenCreation(msg.sender, tokenAdderss);
}

function CreateTokenICO() public payable {
	(uint256 _mneToBurn, address tokenAdderss) = tks.CreateTokenICO(msg.sender, msg.value);
	BurnTokens(_mneToBurn);
	emit TokenCreationICO(msg.sender, tokenAdderss);
}

function isAnyGenesisAddress(address _address) public view returns (bool success) {
	return gn.isAnyGenesisAddress(_address);
}

function isGenesisAddressLevel1(address _address) public view returns (bool success) {
	return gn.isGenesisAddressLevel1(_address);
}

function isGenesisAddressLevel2(address _address) public view returns (bool success) {
	return gn.isGenesisAddressLevel2(_address);
}

function isGenesisAddressLevel3(address _address) public view returns (bool success) {
	return gn.isGenesisAddressLevel3(_address);
}

function isGenesisAddressLevel2Or3(address _address) public view returns (bool success) {
	return gn.isGenesisAddressLevel2Or3(_address);
}

function registerGenesisAddresses(address[] memory _addressList) public {
	uint i = 0;
	if (pc.setupRunning() && msg.sender == pc.genesisCallerAddress())
	{
		while(i < _addressList.length)
		{
			emit Transfer(address(this), _addressList[i], pc.genesisSupplyPerAddress());
			i++;
		}
	}
	else 
	{
		revert();
	}
}

function ethFeeToUpgradeToLevel2Set(uint256 _ethFeeToUpgradeToLevel2) public {pc.ethFeeToUpgradeToLevel2Set(msg.sender, _ethFeeToUpgradeToLevel2);}
function ethFeeToUpgradeToLevel3Set(uint256 _ethFeeToUpgradeToLevel3) public {pc.ethFeeToUpgradeToLevel3Set(msg.sender, _ethFeeToUpgradeToLevel3);}
function ethFeeToBuyLevel1Set(uint256 _ethFeeToBuyLevel1) public {pc.ethFeeToBuyLevel1Set(msg.sender, _ethFeeToBuyLevel1);}
function ethFeeForSellerLevel1Set(uint256 _ethFeeForSellerLevel1) public {pc.ethFeeForSellerLevel1Set(msg.sender, _ethFeeForSellerLevel1);}
function ethFeeForTokenSet(uint256 _ethFeeForToken) public {pc.ethFeeForTokenSet(msg.sender, _ethFeeForToken);}
function ethFeeForTokenICOSet(uint256 _ethFeeForTokenICO) public {pc.ethFeeForTokenICOSet(msg.sender, _ethFeeForTokenICO);}
function ethPercentFeeGenesisExchangeSet(uint256 _ethPercentFeeGenesisExchange) public {pc.ethPercentFeeGenesisExchangeSet(msg.sender, _ethPercentFeeGenesisExchange);}
function ethPercentFeeNormalExchangeSet(uint256 _ethPercentFeeNormalExchange) public {pc.ethPercentFeeNormalExchangeSet(msg.sender, _ethPercentFeeNormalExchange);}
function ethPercentStakeExchangeSet(uint256 _ethPercentStakeExchange) public {pc.ethPercentStakeExchangeSet(msg.sender, _ethPercentStakeExchange);}
function amountOfGenesisToBuyStakesSet(uint256 _amountOfGenesisToBuyStakes) public {pc.amountOfGenesisToBuyStakesSet(msg.sender, _amountOfGenesisToBuyStakes);}
function amountOfMNEToBuyStakesSet(uint256 _amountOfMNEToBuyStakes) public {pc.amountOfMNEToBuyStakesSet(msg.sender, _amountOfMNEToBuyStakes);}
function amountOfMNEForTokenSet(uint256 _amountOfMNEForToken) public {pc.amountOfMNEForTokenSet(msg.sender, _amountOfMNEForToken);}
function amountOfMNEForTokenICOSet(uint256 _amountOfMNEForTokenICO) public {pc.amountOfMNEForTokenICOSet(msg.sender, _amountOfMNEForTokenICO);}
function amountOfMNEToTransferStakesSet(uint256 _amountOfMNEToTransferStakes) public {pc.amountOfMNEToTransferStakesSet(msg.sender, _amountOfMNEToTransferStakes);}
function amountOfGenesisToTransferStakesSet(uint256 _amountOfGenesisToTransferStakes) public {pc.amountOfGenesisToTransferStakesSet(msg.sender, _amountOfGenesisToTransferStakes);}
function stakeDecimalsSet(uint256 _stakeDecimals) public {pc.stakeDecimalsSet(msg.sender, _stakeDecimals);}
}