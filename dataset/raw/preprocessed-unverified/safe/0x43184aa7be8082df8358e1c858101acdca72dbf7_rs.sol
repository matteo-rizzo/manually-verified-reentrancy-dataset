/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity ^0.6.0;









contract Lists {

publicCalls public pc;
publicArrays public pa;
genesis public gn;

address public updaterAddress = 0x0000000000000000000000000000000000000000;
function setUpdater() public {if (updaterAddress == 0x0000000000000000000000000000000000000000) updaterAddress = msg.sender; else revert();}

constructor(address _publicCallsAddress, address _publicArraysAddress, address _genesisAddress) public {
setUpdater();
pc = publicCalls(_publicCallsAddress);
pa = publicArrays(_publicArraysAddress);
gn = genesis(_genesisAddress);
}

function reloadGenesis(address _address) public
{
	if (msg.sender == updaterAddress)
	{
		gn = genesis(_address);		
	}
	else revert();
}
function reloadPublicCalls(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pc = publicCalls(_address);} else revert();}
function reloadPublicArrays(address _address, uint code) public { if (!(code == 1234)) revert();  if (msg.sender == updaterAddress)	{pa = publicArrays(_address);} else revert();}


	
function ListNormalAddressesForSale(uint _startingIndex, uint _recordsLength) public view returns (address[] memory _normalAddress, uint[] memory _balance, uint[] memory _ETHPricePerMNE, uint[] memory _totalETHPrice){
if (_recordsLength > pa.normalAddressesForSaleLength())
       _recordsLength = pa.normalAddressesForSaleLength();
	
_normalAddress = new address[](_recordsLength);
_balance = new uint[](_recordsLength);
_ETHPricePerMNE = new uint[](_recordsLength);	
_totalETHPrice = new uint[](_recordsLength);

uint count = 0;
for(uint i = _startingIndex; i < (_startingIndex + _recordsLength) && i < pa.normalAddressesForSaleLength(); i++){
    address _add = pa.normalAddressesForSale(i);
	_normalAddress[count] = _add;
	_balance[count] = gn.balanceOf(_add);
	_ETHPricePerMNE[count] = pc.NormalAddressBuyPricePerMNE(_add) + (pc.NormalAddressBuyPricePerMNE(_add) * pc.ethPercentFeeNormalExchange() / 100);
	_totalETHPrice[count] = _ETHPricePerMNE[count] * _balance[count] / 100000000;
    count++;
}    
}


function ListGenesisForSaleLevel1(uint _startingIndex, uint _recordsLength) public view returns (address[] memory _genAddress, uint[] memory _balance, uint[] memory _ETHPrice){
	if (_recordsLength > pa.genesisAddressesForSaleLevel1Length())
       _recordsLength = pa.genesisAddressesForSaleLevel1Length();
    _genAddress = new address[](_recordsLength);
	_balance = new uint[](_recordsLength);
	_ETHPrice = new uint[](_recordsLength);	

	uint256 feesToPayToContract = pc.ethFeeToBuyLevel1();
	uint256 feesToPayToSeller = pc.ethFeeForSellerLevel1();
	uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentFeeGenesisExchange() / 100;
		
	uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;

    uint count = 0;
	for(uint i = _startingIndex; i < (_startingIndex + _recordsLength) && i < pa.genesisAddressesForSaleLevel1Length(); i++){
        address _add = pa.genesisAddressesForSaleLevel1(i);
		_genAddress[count] = _add;
		_balance[count] = gn.balanceOf(_add);   
		_ETHPrice[count] = totalToSend; 		
        count++;
    }    
}

function ListGenesisForSaleLevel2(uint _startingIndex, uint _recordsLength) public view returns (address[] memory _genAddress, uint[] memory _balance, uint[] memory _availableBalance, uint[] memory _ETHPrice){
	if (_recordsLength > pa.genesisAddressesForSaleLevel2Length())
       _recordsLength = pa.genesisAddressesForSaleLevel2Length();
    _genAddress = new address[](_recordsLength);
	_balance = new uint[](_recordsLength);
	_availableBalance = new uint[](_recordsLength);
	_ETHPrice = new uint[](_recordsLength);	
	
	uint256 feesToPayToContract = pc.ethFeeToUpgradeToLevel3();
    
    uint count = 0;
	for(uint i = _startingIndex; i < (_startingIndex + _recordsLength) && i < pa.genesisAddressesForSaleLevel2Length(); i++){
        address _add = pa.genesisAddressesForSaleLevel2(i);
		_genAddress[count] = _add;
		_balance[count] = gn.balanceOf(_add);   
		_availableBalance[count] = gn.availableBalanceOf(_add);
		
		uint256 feesToPayToSeller = pc.genesisBuyPrice(_add);
        uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentFeeGenesisExchange() / 100;
	    uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
		
		_ETHPrice[count] = totalToSend; 		
        count++;
    }
}

function ListGenesisForSaleLevel3(uint _startingIndex, uint _recordsLength) public view returns (address[] memory _genAddress, uint[] memory _balance, uint[] memory _availableBalance, uint[] memory _ETHPrice){
	if (_recordsLength > pa.genesisAddressesForSaleLevel3Length())
       _recordsLength = pa.genesisAddressesForSaleLevel3Length();
    _genAddress = new address[](_recordsLength);
	_balance = new uint[](_recordsLength);
	_availableBalance = new uint[](_recordsLength);
	_ETHPrice = new uint[](_recordsLength);	

	uint256 feesToPayToContract = 0;
	
    uint count = 0;
	for(uint i = _startingIndex; i < (_startingIndex + _recordsLength) && i < pa.genesisAddressesForSaleLevel3Length(); i++){
        address _add = pa.genesisAddressesForSaleLevel3(i);
		_genAddress[count] = _add;
		_balance[count] = gn.balanceOf(_add);   
		_availableBalance[count] = gn.availableBalanceOf(_add);
		
		uint256 feesToPayToSeller = pc.genesisBuyPrice(_add);
	    uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentFeeGenesisExchange() / 100;
	    uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
		
		_ETHPrice[count] = totalToSend;
        count++;
    }    
}



function ListStakesForSale(uint _startingIndex, uint _recordsLength) public view returns (address[] memory _stakeholders, uint[] memory _balance, uint[] memory _ETHPrice, uint[] memory _MNEFee, uint[] memory _GenesisAddressFee){
	if (_recordsLength > pa.stakesForSaleLength())
       _recordsLength = pa.stakesForSaleLength();
    _stakeholders = new address[](_recordsLength);
	_balance = new uint[](_recordsLength);
	_ETHPrice = new uint[](_recordsLength);
	_MNEFee = new uint[](_recordsLength);
	_GenesisAddressFee = new uint[](_recordsLength);

	uint256 feesToPayToContract = 0;
	
    
    uint count = 0;
	for(uint i = _startingIndex; i < (_startingIndex + _recordsLength) && i < pa.stakesForSaleLength(); i++){
        address _add = pa.stakesForSale(i);
		_stakeholders[count] = _add;
		_balance[count] = pc.stakeBalances(_add);   
		
		uint256 feesToPayToSeller = pc.stakeBuyPrice(_add);
	    uint256 feesGeneralToPayToContract = (feesToPayToContract + feesToPayToSeller) * pc.ethPercentStakeExchange() / 100;
        uint256 totalToSend = feesToPayToContract + feesToPayToSeller + feesGeneralToPayToContract;
		
		uint256 mneFee = pc.amountOfMNEToBuyStakes()*pc.stakeBalances(_add) / pc.stakeDecimals();
		if (mneFee < pc.amountOfMNEToBuyStakes())
			mneFee = pc.amountOfMNEToBuyStakes();
		
		uint256 genesisAddressFee = pc.amountOfGenesisToBuyStakes()*pc.stakeBalances(_add) / pc.stakeDecimals();
		if (genesisAddressFee < pc.amountOfGenesisToBuyStakes())
			genesisAddressFee = pc.amountOfGenesisToBuyStakes();
		
		_ETHPrice[count] = totalToSend;
		_MNEFee[count] = mneFee;
		_GenesisAddressFee[count] = genesisAddressFee;
        count++;
    }    
}

function ListStakeHolders(uint _startingIndex, uint _recordsLength) public view returns (address[] memory _stakeHolders, uint[] memory _stakeBalance){
	if (_recordsLength > pa.stakeHoldersListLength())
       _recordsLength = pa.stakeHoldersListLength();
    _stakeHolders = new address[](_recordsLength);
	_stakeBalance = new uint[](_recordsLength);
    uint count = 0;
	for(uint i = _startingIndex; i < (_startingIndex + _recordsLength) && i < pa.stakeHoldersListLength(); i++){
        address _add = pa.stakeHoldersList(i);
		_stakeHolders[count] = _add;
		_stakeBalance[count] = pc.stakeBalances(_add);        
        count++;
    }    
}

function ListHistoryNormalAddressSale(uint _startingIndex, uint _recordsLength) public view returns (address[] memory _seller,address[] memory _buyer,uint[] memory _amountMNE,uint[] memory _amountETH,uint[] memory _amountETHFee, uint[] memory _date){
	if (_recordsLength > pa.MNETradeHistorySellerLength())
       _recordsLength = pa.MNETradeHistorySellerLength();
	_seller = new address[](_recordsLength);
	_buyer = new address[](_recordsLength);
	_amountMNE = new uint[](_recordsLength);
	_amountETH = new uint[](_recordsLength);
	_amountETHFee = new uint[](_recordsLength);
	_date = new uint[](_recordsLength);
	
	uint count = 0;
	for(uint i = _startingIndex; i < (_startingIndex + _recordsLength) && i < pa.MNETradeHistorySellerLength(); i++){
        _seller[count] = pa.MNETradeHistorySeller(i);
		_buyer[count] = pa.MNETradeHistoryBuyer(i);
		_amountMNE[count] = pa.MNETradeHistoryAmountMNE(i);
		_amountETH[count] = pa.MNETradeHistoryAmountETH(i);
		_amountETHFee[count] = pa.MNETradeHistoryAmountETHFee(i);
		_date[count] = pa.MNETradeHistoryDate(i);
        count++;
    }    
}


function ListHistoryStakeSale(uint _startingIndex, uint _recordsLength) public view returns (address[] memory _seller, address[] memory _buyer, uint[] memory _stakeAmount, uint[] memory _ETHPrice, uint[] memory _ETHFee, uint[] memory _MNEGenesisBurned, uint[] memory _date){
	if (_recordsLength > pa.StakeTradeHistorySellerLength())
       _recordsLength = pa.StakeTradeHistorySellerLength();
	_seller = new address[](_recordsLength);
	_buyer = new address[](_recordsLength);
	_stakeAmount = new uint[](_recordsLength);
	_ETHPrice = new uint[](_recordsLength);
	_ETHFee = new uint[](_recordsLength);
	_MNEGenesisBurned = new uint[](_recordsLength);
	_date = new uint[](_recordsLength);

    uint count = 0;
	for(uint i = _startingIndex; i < (_startingIndex + _recordsLength) && i < pa.StakeTradeHistorySellerLength(); i++){
        _seller[count] = pa.StakeTradeHistorySeller(i);
		_buyer[count] = pa.StakeTradeHistoryBuyer(i);
		_stakeAmount[count] = pa.StakeTradeHistoryStakeAmount(i);
		_ETHPrice[count] = pa.StakeTradeHistoryETHPrice(i);
		_ETHFee[count] = pa.StakeTradeHistoryETHFee(i);
		_MNEGenesisBurned[count] = pa.StakeTradeHistoryMNEGenesisBurned(i);
		_date[count] = pa.StakeTradeHistoryDate(i);
        count++;
    }    
}


function ListHistoryGenesisSaleLevel1(uint _startingIndex, uint _recordsLength) public view returns (address[] memory _seller, address[] memory _buyer, uint[] memory _amountMNE, uint[] memory _amountETH, uint[] memory _amountETHFee, uint[] memory _date){
	if (_recordsLength > pa.Level1TradeHistorySellerLength())
       _recordsLength = pa.Level1TradeHistorySellerLength();
    _seller = new address[](_recordsLength);
	_buyer = new address[](_recordsLength);
	_amountMNE = new uint[](_recordsLength);
	_amountETH = new uint[](_recordsLength);
	_amountETHFee = new uint[](_recordsLength);
	_date = new uint[](_recordsLength);
	
    uint count = 0;
	for(uint i = _startingIndex; i < (_startingIndex + _recordsLength) && i < pa.Level1TradeHistorySellerLength(); i++){
        _seller[count] = pa.Level1TradeHistorySeller(i);
		_buyer[count] = pa.Level1TradeHistoryBuyer(i);
		_amountMNE[count] = pa.Level1TradeHistoryAmountMNE(i);
		_amountETH[count] = pa.Level1TradeHistoryAmountETH(i);
		_amountETHFee[count] = pa.Level1TradeHistoryAmountETHFee(i);
		_date[count] = pa.Level1TradeHistoryDate(i);
        count++;
    }    
}

function ListHistoryGenesisSaleLevel2(uint _startingIndex, uint _recordsLength) public view returns (address[] memory _seller, address[] memory _buyer, uint[] memory _amountMNE, uint[] memory _availableBalance,uint[] memory _amountETH, uint[] memory _amountETHFee, uint[] memory _date){
	if (_recordsLength > pa.Level2TradeHistorySellerLength())
       _recordsLength = pa.Level2TradeHistorySellerLength();
    _seller = new address[](_recordsLength);
	_buyer = new address[](_recordsLength);
	_amountMNE = new uint[](_recordsLength);
	_availableBalance = new uint[](_recordsLength);
	_amountETH = new uint[](_recordsLength);
	_amountETHFee = new uint[](_recordsLength);
	_date = new uint[](_recordsLength);
	
    uint count = 0;
	for(uint i = _startingIndex; i < (_startingIndex + _recordsLength) && i < pa.Level2TradeHistorySellerLength(); i++){
        _seller[count] = pa.Level2TradeHistorySeller(i);
		_buyer[count] = pa.Level2TradeHistoryBuyer(i);
		_amountMNE[count] = pa.Level2TradeHistoryAmountMNE(i);
		_availableBalance[count] = pa.Level2TradeHistoryAvailableAmountMNE(i);
		_amountETH[count] = pa.Level2TradeHistoryAmountETH(i);
		_amountETHFee[count] = pa.Level2TradeHistoryAmountETHFee(i);
		_date[count] = pa.Level2TradeHistoryDate(i);
        count++;
    }    
}

function ListHistoryGenesisSaleLevel3(uint _startingIndex, uint _recordsLength) public view returns (address[] memory _seller, address[] memory _buyer, uint[] memory _amountMNE, uint[] memory _availableBalance, uint[] memory _amountETH, uint[] memory _amountETHFee, uint[] memory _date){
	if (_recordsLength > pa.Level3TradeHistorySellerLength())
       _recordsLength = pa.Level3TradeHistorySellerLength();
    _seller = new address[](_recordsLength);
	_buyer = new address[](_recordsLength);
	_amountMNE = new uint[](_recordsLength);
	_availableBalance =  new uint[](_recordsLength);
	_amountETH = new uint[](_recordsLength);
	_amountETHFee = new uint[](_recordsLength);
	_date = new uint[](_recordsLength);
	
    uint count = 0;
	for(uint i = _startingIndex; i < (_startingIndex + _recordsLength) && i < pa.Level3TradeHistorySellerLength(); i++){
        _seller[count] = pa.Level3TradeHistorySeller(i);
		_buyer[count] = pa.Level3TradeHistoryBuyer(i);
		_amountMNE[count] = pa.Level3TradeHistoryAmountMNE(i);
		_availableBalance[count] = pa.Level3TradeHistoryAvailableAmountMNE(i);
		_amountETH[count] = pa.Level3TradeHistoryAmountETH(i);
		_amountETHFee[count] = pa.Level3TradeHistoryAmountETHFee(i);
		_date[count] = pa.Level3TradeHistoryDate(i);
        count++;
    }
}


function ListTokenCreationHistory(address _address) public view returns (address[] memory _contracts){
	return pc.tokenCreatedGet(_address);
}

function ListTokenICOCreationHistory(address _address) public view returns (address[] memory _contracts){
	return pc.tokenICOCreatedGet(_address);
}
}