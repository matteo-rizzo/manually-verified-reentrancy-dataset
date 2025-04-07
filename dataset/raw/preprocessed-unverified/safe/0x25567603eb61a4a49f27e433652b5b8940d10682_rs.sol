/**
 *Submitted for verification at Etherscan.io on 2021-02-23
*/

pragma solidity 0.6.12;











contract proxy  {
	address payable owner;

	uint256 handlerID;

	string tokenName;

	uint256 constant unifiedPoint = 10 ** 18;

	uint256 unifiedTokenDecimal = 10 ** 18;

	uint256 underlyingTokenDecimal;

	marketManagerInterface marketManager;

	interestModelInterface interestModelInstance;

	marketHandlerDataStorageInterface handlerDataStorage;

	marketSIHandlerDataStorageInterface SIHandlerDataStorage;

	IERC20 erc20Instance;

	address public handler;

	address public SI;

	string DEPOSIT = "deposit(uint256,bool)";

	string REDEEM = "withdraw(uint256,bool)";

	string BORROW = "borrow(uint256,bool)";

	string REPAY = "repay(uint256,bool)";

	modifier onlyOwner {
		require(msg.sender == owner, "Ownable: caller is not the owner");
		_;
	}

	modifier onlyMarketManager {
		address msgSender = msg.sender;
		require((msgSender == address(marketManager)) || (msgSender == owner), "onlyMarketManager function");
		_;
	}

	constructor () public 
	{
		owner = msg.sender;
	}

	function ownershipTransfer(address _owner) onlyOwner external returns (bool)
	{
		owner = address(uint160(_owner));
		return true;
	}

	function initialize(uint256 _handlerID, address handlerAddr, address marketManagerAddr, address interestModelAddr, address marketDataStorageAddr, address erc20Addr, string memory _tokenName, address siHandlerAddr, address SIHandlerDataStorageAddr) onlyOwner public returns (bool)
	{
		handlerID = _handlerID;
		handler = handlerAddr;
		marketManager = marketManagerInterface(marketManagerAddr);
		interestModelInstance = interestModelInterface(interestModelAddr);
		handlerDataStorage = marketHandlerDataStorageInterface(marketDataStorageAddr);
		erc20Instance = IERC20(erc20Addr);
		tokenName = _tokenName;
		SI = siHandlerAddr;
		SIHandlerDataStorage = marketSIHandlerDataStorageInterface(SIHandlerDataStorageAddr);
	}

	function setHandlerID(uint256 _handlerID) onlyOwner public returns (bool)
	{
		handlerID = _handlerID;
		return true;
	}

	function setHandlerAddr(address handlerAddr) onlyOwner public returns (bool)
	{
		handler = handlerAddr;
		return true;
	}

	function setSiHandlerAddr(address siHandlerAddr) onlyOwner public returns (bool)
	{
		SI = siHandlerAddr;
		return true;
	}

	function getHandlerID() public view returns (uint256)
	{
		return handlerID;
	}

	function getHandlerAddr() public view returns (address)
	{
		return handler;
	}

	function getSiHandlerAddr() public view returns (address)
	{
		return SI;
	}

	function migration(address target) onlyOwner public returns (bool)
	{
		uint256 balance = erc20Instance.balanceOf(address(this));
		erc20Instance.transfer(target, balance);
	}

	function deposit(uint256 unifiedTokenAmount, bool flag) public payable returns (bool)
	{
		bool result;
		bytes memory returnData;
		bytes memory data = abi.encodeWithSignature(DEPOSIT, unifiedTokenAmount, flag);
		(result, returnData) = handler.delegatecall(data);
		require(result, string(returnData));
		return result;
	}

	function withdraw(uint256 unifiedTokenAmount, bool flag) public returns (bool)
	{
		bool result;
		bytes memory returnData;
		bytes memory data = abi.encodeWithSignature(REDEEM, unifiedTokenAmount, flag);
		(result, returnData) = handler.delegatecall(data);
		require(result, string(returnData));
		return result;
	}

	function borrow(uint256 unifiedTokenAmount, bool flag) public returns (bool)
	{
		bool result;
		bytes memory returnData;
		bytes memory data = abi.encodeWithSignature(BORROW, unifiedTokenAmount, flag);
		(result, returnData) = handler.delegatecall(data);
		require(result, string(returnData));
		return result;
	}

	function repay(uint256 unifiedTokenAmount, bool flag) public payable returns (bool)
	{
		bool result;
		bytes memory returnData;
		bytes memory data = abi.encodeWithSignature(REPAY, unifiedTokenAmount, flag);
		(result, returnData) = handler.delegatecall(data);
		require(result, string(returnData));
		return result;
	}

	function handlerProxy(bytes memory data) onlyMarketManager external returns (bool, bytes memory)
	{
		bool result;
		bytes memory returnData;
		(result, returnData) = handler.delegatecall(data);
		require(result, string(returnData));
		return (result, returnData);
	}

	function handlerViewProxy(bytes memory data) external returns (bool, bytes memory)
	{
		bool result;
		bytes memory returnData;
		(result, returnData) = handler.delegatecall(data);
		require(result, string(returnData));
		return (result, returnData);
	}

	function siProxy(bytes memory data) onlyMarketManager external returns (bool, bytes memory)
	{
		bool result;
		bytes memory returnData;
		(result, returnData) = SI.delegatecall(data);
		require(result, string(returnData));
		return (result, returnData);
	}

	function siViewProxy(bytes memory data) external returns (bool, bytes memory)
	{
		bool result;
		bytes memory returnData;
		(result, returnData) = SI.delegatecall(data);
		require(result, string(returnData));
		return (result, returnData);
	}
}

contract LinkHandlerProxy is proxy {
    constructor()
    proxy() public {}
}