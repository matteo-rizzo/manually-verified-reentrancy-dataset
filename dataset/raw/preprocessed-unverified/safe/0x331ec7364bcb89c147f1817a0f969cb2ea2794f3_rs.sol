pragma solidity 0.4.16;














contract Nodes {
	address public owner;
	CommonLibrary.Data public vars;
	mapping (address => string) public confirmationNodes;
	uint confirmNodeId;
	uint40 changePercentId;
	uint40 pushNodeGroupId;
	uint40 deleteNodeGroupId;
	event NewNode(
		uint256 id, 
		string nodeName, 
		uint8 producersPercent, 
		address producer, 
		uint date
		);
	event OwnerNotation(uint256 id, uint date, string newNotation);
	event NewNodeGroup(uint16 id, string newNodeGroup);
	event AddNodeAddress(uint id, uint nodeID, address nodeAdress);
	event EditNode(
		uint nodeID,
		address nodeAdress, 
		address newProducer, 
		uint8 newProducersPercent,
		bool starmidConfirmed
		);
	event ConfirmNode(uint id, uint nodeID);
	event OutsourceConfirmNode(uint nodeID, address confirmationNode);
	event ChangePercent(uint id, uint nodeId, uint producersPercent);
	event PushNodeGroup(uint id, uint nodeId, uint newNodeGroup);
	event DeleteNodeGroup(uint id, uint nodeId, uint deleteNodeGroup);
	
	function Nodes() public {
		owner = msg.sender;
	}
	
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
	
	//-----------------------------------------------------Nodes---------------------------------------------------------------
	function changeOwner(string _changeOwnerPassword, address _newOwnerAddress) onlyOwner returns(bool) {
		//One-time tool for emergency owner change
		if (keccak256(_changeOwnerPassword) == 0xe17a112b6fc12fc80c9b241de72da0d27ce7e244100f3c4e9358162a11bed629) {
			owner = _newOwnerAddress;
			return true;
		}
		else 
			return false;
	}
	
	function addOwnerNotations(string _newNotation) onlyOwner {
		uint date = block.timestamp;
		vars.ownerNotationId += 1;
		OwnerNotation(vars.ownerNotationId, date, _newNotation);
	}
	
	function addConfirmationNode(string _newConfirmationNode) public returns(bool) {
		confirmationNodes[msg.sender] = _newConfirmationNode;
		return true;
	}
	
	function addNodeGroup(string _newNodeGroup) onlyOwner returns(uint16 _id) {
		bool result;
		(result, _id) = CommonLibrary.addNodeGroup(vars, _newNodeGroup);
		require(result);
		NewNodeGroup(_id, _newNodeGroup);
	}
	
	function addNode(string _newNode, uint8 _producersPercent) returns(bool) {
		bool result;
		uint _id;
		(result, _id) = CommonLibrary.addNode(vars, _newNode, _producersPercent);
		require(result);
		NewNode(_id, _newNode, _producersPercent, msg.sender, block.timestamp);
		return true;
	}
	
	function editNode(
		uint _nodeID, 
		address _nodeAddress, 
		bool _isNewProducer, 
		address _newProducer, 
		uint8 _newProducersPercent,
		bool _starmidConfirmed
		) onlyOwner returns(bool) {
		bool x = CommonLibrary.editNode(vars, _nodeID, _nodeAddress,_isNewProducer, _newProducer, _newProducersPercent, _starmidConfirmed);
		require(x);
		EditNode(_nodeID, _nodeAddress, _newProducer, _newProducersPercent, _starmidConfirmed);
		return true;
	}
	
	
	function addNodeAddress(uint _nodeID, address _nodeAddress) public returns(bool) {
		bool _result;
		uint _id;
		(_result, _id) = CommonLibrary.addNodeAddress(vars, _nodeID, _nodeAddress);
		require(_result);
		AddNodeAddress(_id, _nodeID, _nodeAddress);
		return true; 
	}
	
	function pushNodeGroup(uint _nodeID, uint16 _newNodeGroup) public returns(bool) {
		require(msg.sender == vars.nodes[_nodeID].node);
		vars.nodes[_nodeID].nodeGroup.push(_newNodeGroup);
		pushNodeGroupId += 1;
		PushNodeGroup(pushNodeGroupId, _nodeID, _newNodeGroup);
		return true;
	}
	
	function deleteNodeGroup(uint _nodeID, uint16 _deleteNodeGroup) public returns(bool) {
		require(msg.sender == vars.nodes[_nodeID].node);
		for(uint16 i = 0; i < vars.nodes[_nodeID].nodeGroup.length; i++) {
			if(_deleteNodeGroup == vars.nodes[_nodeID].nodeGroup[i]) {
				for(uint16 ii = i; ii < vars.nodes[_nodeID].nodeGroup.length - 1; ii++) 
					vars.nodes[_nodeID].nodeGroup[ii] = vars.nodes[_nodeID].nodeGroup[ii + 1];
		    	delete vars.nodes[_nodeID].nodeGroup[vars.nodes[_nodeID].nodeGroup.length - 1];
				vars.nodes[_nodeID].nodeGroup.length--;
				break;
		    }
	    }
		deleteNodeGroupId += 1;
		DeleteNodeGroup(deleteNodeGroupId, _nodeID, _deleteNodeGroup);
		return true;
    }
	
	function confirmNode(uint _nodeID) onlyOwner returns(bool) {
		vars.nodes[_nodeID].starmidConfirmed = true;
		confirmNodeId += 1;
		ConfirmNode(confirmNodeId, _nodeID);
		return true;
	}
	
	function outsourceConfirmNode(uint _nodeID) public returns(bool) {
		vars.nodes[_nodeID].outsourceConfirmed.push(msg.sender);
		OutsourceConfirmNode(_nodeID, msg.sender);
		return true;
	}
	
	function changePercent(uint _nodeId, uint8 _producersPercent) public returns(bool){
		if(msg.sender == vars.nodes[_nodeId].producer && vars.nodes[_nodeId].node == 0x0000000000000000000000000000000000000000) {
			vars.nodes[_nodeId].producersPercent = _producersPercent;
			changePercentId += 1;
			ChangePercent(changePercentId, _nodeId, _producersPercent);
			return true;
		}
	}
	
	function getNodeInfo(uint _nodeID) constant public returns(
		address _producer, 
		address _node, 
		uint _date, 
		bool _starmidConfirmed, 
		string _nodeName, 
		address[] _outsourceConfirmed, 
		uint16[] _nodeGroup, 
		uint _producersPercent
		) {
		_producer = vars.nodes[_nodeID].producer;
		_node = vars.nodes[_nodeID].node;
		_date = vars.nodes[_nodeID].date;
		_starmidConfirmed = vars.nodes[_nodeID].starmidConfirmed;
		_nodeName = vars.nodes[_nodeID].nodeName;
		_outsourceConfirmed = vars.nodes[_nodeID].outsourceConfirmed;
		_nodeGroup = vars.nodes[_nodeID].nodeGroup;
		_producersPercent = vars.nodes[_nodeID].producersPercent;
	}
}	


contract Starmid {
	address public owner;
	Nodes public nodesVars;
	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public totalSupply;
	StarCoinLibrary.Data public sCVars;
	
	event Transfer(address indexed from, address indexed to, uint256 value);
	event BuyOrder(address indexed from, uint orderId, uint buyPrice);
	event SellOrder(address indexed from, uint orderId, uint sellPrice);
	event CancelBuyOrder(address indexed from, uint indexed orderId, uint price);
	event CancelSellOrder(address indexed from, uint indexed orderId, uint price);
	event TradeHistory(uint date, address buyer, address seller, uint price, uint amount, uint orderId);
    //----------------------------------------------------Starmid exchange
	event StockTransfer(address indexed from, address indexed to, uint indexed node, uint256 value);
	event StockBuyOrder(uint node, uint buyPrice);
	event StockSellOrder(uint node, uint sellPrice);
	event StockCancelBuyOrder(uint node, uint price);
	event StockCancelSellOrder(uint node, uint price);
	event StockTradeHistory(uint node, uint date, address buyer, address seller, uint price, uint amount, uint orderId);
	
	function Starmid(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) public {
		owner = 0x378B9eea7ab9C15d9818EAdDe1156A079Cd02ba8;
		totalSupply = initialSupply;  
		sCVars.balanceOf[msg.sender] = 5000000000;
		sCVars.balanceOf[0x378B9eea7ab9C15d9818EAdDe1156A079Cd02ba8] = initialSupply - 5000000000;                
		name = tokenName;                                   
		symbol = tokenSymbol;                               
		decimals = decimalUnits; 
		sCVars.lastMint = block.timestamp;
		sCVars.emissionLimits[1] = 500000; sCVars.emissionLimits[2] = 500000; sCVars.emissionLimits[3] = 500000;
		sCVars.emissionLimits[4] = 500000; sCVars.emissionLimits[5] = 500000; sCVars.emissionLimits[6] = 500000;
	}
	
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
	//-----------------------------------------------------StarCoin Exchange------------------------------------------------------
	function getWithdrawal() constant public returns(uint _amount) {
        _amount = sCVars.pendingWithdrawals[msg.sender];
    }
	
	function withdraw() public returns(bool _result, uint _amount) {
        _amount = sCVars.pendingWithdrawals[msg.sender];
        sCVars.pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(_amount);
		_result = true;
    }
	
	function changeOwner(string _changeOwnerPassword, address _newOwnerAddress) onlyOwner returns(bool) {
		//One-time tool for emergency owner change
		if (keccak256(_changeOwnerPassword) == 0xe17a112b6fc12fc80c9b241de72da0d27ce7e244100f3c4e9358162a11bed629) {
			owner = _newOwnerAddress;
			return true;
		}
		else 
			return false;
	}
	
	function setNodesVars(address _addr) public {
	    require(msg.sender == 0xfCbA69eF1D63b0A4CcD9ceCeA429157bA48d6a9c);
		nodesVars = Nodes(_addr);
	}
	
	function balanceOf(address _address) constant public returns(uint _balance) {
		_balance = sCVars.balanceOf[_address];
	}
	
	function getBuyOrderPrices() constant public returns(uint[] _prices) {
		_prices = sCVars.buyOrderPrices;
	}
	
	function getSellOrderPrices() constant public returns(uint[] _prices) {
		_prices = sCVars.sellOrderPrices;
	}
	
	function getOrderInfo(bool _isBuyOrder, uint _price, uint _number) constant public returns(address _address, uint _amount, uint _orderId) {
		if(_isBuyOrder == true) {
			_address = sCVars.buyOrders[_price][_number].client;
			_amount = sCVars.buyOrders[_price][_number].amount;
			_orderId = sCVars.buyOrders[_price][_number].orderId;
		}
		else {
			_address = sCVars.sellOrders[_price][_number].client;
			_amount = sCVars.sellOrders[_price][_number].amount;
			_orderId = sCVars.sellOrders[_price][_number].orderId;
		}
	}
	
	function transfer(address _to, uint256 _value) public returns (bool _result) {
		_transfer(msg.sender, _to, _value);
		_result = true;
	}
	
	function mint() public onlyOwner returns(uint _mintedAmount) {
		//Minted amount does not exceed 8,5% per annum. Thus, minting does not greatly increase the total supply 
		//and does not cause significant inflation and depreciation of the starcoin.
		_mintedAmount = (block.timestamp - sCVars.lastMint)*totalSupply/(12*31536000);//31536000 seconds in year
		sCVars.balanceOf[msg.sender] += _mintedAmount;
		totalSupply += _mintedAmount;
		sCVars.lastMint = block.timestamp;
		Transfer(0, this, _mintedAmount);
		Transfer(this, msg.sender, _mintedAmount);
	}
	
	function buyOrder(uint256 _buyPrice) payable public returns (uint[4] _results) {
		require(_buyPrice > 0 && msg.value > 0);
		_results = StarCoinLibrary.buyOrder(sCVars, _buyPrice);
		require(_results[3] == 1);
		BuyOrder(msg.sender, _results[2], _buyPrice);
	}
	
	function sellOrder(uint256 _sellPrice, uint _amount) public returns (uint[4] _results) {
		require(_sellPrice > 0 && _amount > 0);
		_results = StarCoinLibrary.sellOrder(sCVars, _sellPrice, _amount);
		require(_results[3] == 1);
		SellOrder(msg.sender, _results[2], _sellPrice);
	}
	
	function cancelBuyOrder(uint _thisOrderID, uint _price) public {
		require(StarCoinLibrary.cancelBuyOrder(sCVars, _thisOrderID, _price));
		CancelBuyOrder(msg.sender, _thisOrderID, _price);
	}
	
	function cancelSellOrder(uint _thisOrderID, uint _price) public {
		require(StarCoinLibrary.cancelSellOrder(sCVars, _thisOrderID, _price));
		CancelSellOrder(msg.sender, _thisOrderID, _price);
	}
	
	function _transfer(address _from, address _to, uint _value) internal {
		require(_to != 0x0);
        require(sCVars.balanceOf[_from] >= _value && sCVars.balanceOf[_to] + _value > sCVars.balanceOf[_to]);
        sCVars.balanceOf[_from] -= _value;
        sCVars.balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
	}
	
	function buyCertainOrder(uint _price, uint _thisOrderID) payable public returns (bool _results) {
		_results = StarmidLibraryExtra.buyCertainOrder(sCVars, _price, _thisOrderID);
		require(_results && msg.value > 0);
		BuyOrder(msg.sender, _thisOrderID, _price);
	}
	
	function sellCertainOrder(uint _amount, uint _price, uint _thisOrderID) public returns (bool _results) {
		_results = StarmidLibraryExtra.sellCertainOrder(sCVars, _amount, _price, _thisOrderID);
		require(_results && _amount > 0);
		SellOrder(msg.sender, _thisOrderID, _price);
	}
	//------------------------------------------------------Starmid exchange----------------------------------------------------------
	function stockTransfer(address _to, uint _node, uint _value) public {
		require(_to != 0x0);
        require(sCVars.stockBalanceOf[msg.sender][_node] >= _value && sCVars.stockBalanceOf[_to][_node] + _value > sCVars.stockBalanceOf[_to][_node]);
		var (x,y,) = nodesVars.getNodeInfo(_node);
		require(msg.sender != y);//nodeOwner cannot transfer his stocks, only sell
		sCVars.stockBalanceOf[msg.sender][_node] -= _value;
        sCVars.stockBalanceOf[_to][_node] += _value;
        StockTransfer(msg.sender, _to, _node, _value);
	}
	
	function getEmission(uint _node) constant public returns(uint _emissionNumber, uint _emissionDate, uint _emissionAmount) {
		_emissionNumber = sCVars.emissions[_node].emissionNumber;
		_emissionDate = sCVars.emissions[_node].date;
		_emissionAmount = sCVars.emissionLimits[_emissionNumber];
	}
	
	function emission(uint _node) public returns(bool _result, uint _emissionNumber, uint _emissionAmount, uint _producersPercent) {
		var (x,y,,,,,,z,) = nodesVars.getNodeInfo(_node);
		address _nodeOwner = y;
		address _nodeProducer = x;
		_producersPercent = z;
		require(msg.sender == _nodeOwner || msg.sender == _nodeProducer);
		uint allStocks;
		for (uint i = 1; i <= sCVars.emissions[_node].emissionNumber; i++) {
			allStocks += sCVars.emissionLimits[i];
		}
		if (_nodeOwner !=0x0000000000000000000000000000000000000000 && block.timestamp > sCVars.emissions[_node].date + 5184000 && 
		sCVars.stockBalanceOf[_nodeOwner][_node] <= allStocks/2 ) {
			_emissionNumber = sCVars.emissions[_node].emissionNumber + 1;
			sCVars.stockBalanceOf[_nodeOwner][_node] += sCVars.emissionLimits[_emissionNumber]*(100 - _producersPercent)/100;
			//save stockOwnerInfo for _nodeOwner
			uint thisNode = 0;
			for (i = 0; i < sCVars.stockOwnerInfo[_nodeOwner].nodes.length; i++) {
				if (sCVars.stockOwnerInfo[_nodeOwner].nodes[i] == _node) thisNode = 1;
			}
			if (thisNode == 0) sCVars.stockOwnerInfo[_nodeOwner].nodes.push(_node);
			sCVars.stockBalanceOf[_nodeProducer][_node] += sCVars.emissionLimits[_emissionNumber]*_producersPercent/100;
			//save stockOwnerInfo for _nodeProducer
			thisNode = 0;
			for (i = 0; i < sCVars.stockOwnerInfo[_nodeProducer].nodes.length; i++) {
				if (sCVars.stockOwnerInfo[_nodeProducer].nodes[i] == _node) thisNode = 1;
			}
			if (thisNode == 0) sCVars.stockOwnerInfo[_nodeProducer].nodes.push(_node);
			sCVars.emissions[_node].date = block.timestamp;
			sCVars.emissions[_node].emissionNumber = _emissionNumber;
			_emissionAmount = sCVars.emissionLimits[_emissionNumber];
			_result = true;
		}
		else _result = false;
	}
	
	function getStockOwnerInfo(address _address) constant public returns(uint[] _nodes) {
		_nodes = sCVars.stockOwnerInfo[_address].nodes;
	}
	
	function getStockBalance(address _address, uint _node) constant public returns(uint _balance) {
		_balance = sCVars.stockBalanceOf[_address][_node];
	}
	
	function getWithFrozenStockBalance(address _address, uint _node) constant public returns(uint _balance) {
		_balance = sCVars.stockBalanceOf[_address][_node] + sCVars.stockFrozen[_address][_node];
	}
	
	function getStockOrderInfo(bool _isBuyOrder, uint _node, uint _price, uint _number) constant public returns(address _address, uint _amount, uint _orderId) {
		if(_isBuyOrder == true) {
			_address = sCVars.stockBuyOrders[_node][_price][_number].client;
			_amount = sCVars.stockBuyOrders[_node][_price][_number].amount;
			_orderId = sCVars.stockBuyOrders[_node][_price][_number].orderId;
		}
		else {
			_address = sCVars.stockSellOrders[_node][_price][_number].client;
			_amount = sCVars.stockSellOrders[_node][_price][_number].amount;
			_orderId = sCVars.stockSellOrders[_node][_price][_number].orderId;
		}
	}
	
	function getStockBuyOrderPrices(uint _node) constant public returns(uint[] _prices) {
		_prices = sCVars.stockBuyOrderPrices[_node];
	}
	
	function getStockSellOrderPrices(uint _node) constant public returns(uint[] _prices) {
		_prices = sCVars.stockSellOrderPrices[_node];
	}
	
	function stockBuyOrder(uint _node, uint256 _buyPrice, uint _amount) public returns (uint[4] _results) {
		require(_node > 0 && _buyPrice > 0 && _amount > 0);
		_results = StarmidLibrary.stockBuyOrder(sCVars, _node, _buyPrice, _amount);
		require(_results[3] == 1);
		StockBuyOrder(_node, _buyPrice);
	}
	
	function stockSellOrder(uint _node, uint256 _sellPrice, uint _amount) public returns (uint[4] _results) {
		require(_node > 0 && _sellPrice > 0 && _amount > 0);
		_results = StarmidLibrary.stockSellOrder(sCVars, _node, _sellPrice, _amount);
		require(_results[3] == 1);
		StockSellOrder(_node, _sellPrice);
	}
	
	function stockCancelBuyOrder(uint _node, uint _thisOrderID, uint _price) public {
		require(StarmidLibrary.stockCancelBuyOrder(sCVars, _node, _thisOrderID, _price));
		StockCancelBuyOrder(_node, _price);
	}
	
	function stockCancelSellOrder(uint _node, uint _thisOrderID, uint _price) public {
		require(StarmidLibrary.stockCancelSellOrder(sCVars, _node, _thisOrderID, _price));
		StockCancelSellOrder(_node, _price);
	}
	
	function getLastDividends(uint _node) public constant returns (uint _lastDividents, uint _dividends) {
		uint stockAmount = sCVars.StockOwnersBuyPrice[msg.sender][_node].sumAmount;
		uint sumAmount = sCVars.StockOwnersBuyPrice[msg.sender][_node].sumAmount;
		if(sumAmount > 0) {
			uint stockAverageBuyPrice = sCVars.StockOwnersBuyPrice[msg.sender][_node].sumPriceAmount/sumAmount;
			uint dividendsBase = stockAmount*stockAverageBuyPrice;
			_lastDividents = sCVars.StockOwnersBuyPrice[msg.sender][_node].sumDateAmount/sumAmount;
			if(_lastDividents > 0)_dividends = (block.timestamp - _lastDividents)*dividendsBase/(10*31536000);
			else _dividends = 0;
		}
	}
	
	//--------------------------------Dividends (10% to stock owner, 2,5% to node owner per annum)------------------------------------
	function dividends(uint _node) public returns (bool _result, uint _dividends) {
		var (x,y,) = nodesVars.getNodeInfo(_node);
		uint _stockAmount = sCVars.StockOwnersBuyPrice[msg.sender][_node].sumAmount;
		uint _sumAmount = sCVars.StockOwnersBuyPrice[msg.sender][_node].sumAmount;
		if(_sumAmount > 0) {
			uint _stockAverageBuyPrice = sCVars.StockOwnersBuyPrice[msg.sender][_node].sumPriceAmount/_sumAmount;
			uint _dividendsBase = _stockAmount*_stockAverageBuyPrice;
			uint _averageDate = sCVars.StockOwnersBuyPrice[msg.sender][_node].sumDateAmount/_sumAmount;
			//Stock owner`s dividends
			uint _div = (block.timestamp - _averageDate)*_dividendsBase/(10*31536000);//31536000 seconds in year
			sCVars.balanceOf[msg.sender] += _div;
			//Node owner`s dividends
			uint _nodeDividends = (block.timestamp - _averageDate)*_dividendsBase/(40*31536000);//31536000 seconds in year
			sCVars.balanceOf[y] += _nodeDividends;
			sCVars.StockOwnersBuyPrice[msg.sender][_node].sumDateAmount = block.timestamp*_stockAmount;//set new average dividends date
			totalSupply += _div + _div/4;
			_dividends =  _div + _div/4;
			Transfer(this, msg.sender, _div);	
			Transfer(this, y, _div/4);	
			_result = true;
		}
	}
	
	function stockBuyCertainOrder(uint _node, uint _price, uint _amount, uint _thisOrderID) payable public returns (bool _results) {
		_results = StarmidLibraryExtra.stockBuyCertainOrder(sCVars, _node, _price, _amount, _thisOrderID);
		require(_results && _node > 0 && _amount > 0);
		StockBuyOrder(_node, _price);
	}
	
	function stockSellCertainOrder(uint _node, uint _price, uint _amount, uint _thisOrderID) public returns (bool _results) {
		_results = StarmidLibraryExtra.stockSellCertainOrder(sCVars, _node, _price, _amount, _thisOrderID);
		require(_results && _node > 0 && _amount > 0);
		StockSellOrder(_node, _price);
	}
}