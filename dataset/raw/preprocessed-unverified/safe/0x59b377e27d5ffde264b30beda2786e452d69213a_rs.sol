pragma solidity ^0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */




contract B0xPresale is Ownable {
	using SafeMath for uint;

	mapping (address => Investment[]) public received;  // mapping of investor address to Investment struct arrays
	address[] public investors;                     	// array of investors who have already send Ether

	address public receiver1;
	address public receiver2;
	address public receiver3;

	struct Investment {
		uint amount;
		uint blockNumber;
		uint blockTimestamp;
	}

	function() 
		public
		payable
	{
		require(msg.value > 0);
		received[msg.sender].push(Investment({
			amount: msg.value,
			blockNumber: block.number,
			blockTimestamp: block.timestamp
		}));
		investors.push(msg.sender);
	}

	function B0xPresale(
		address _receiver1,
		address _receiver2,
		address _receiver3)
		public
	{
		receiver1 = _receiver1;
		receiver2 = _receiver2;
		receiver3 = _receiver3;
	}

	function withdraw()
		public
	{
		require(msg.sender == owner 
			|| msg.sender == receiver1 
			|| msg.sender == receiver2 
			|| msg.sender == receiver3);

		var toSend = this.balance.mul(3).div(7);
		require(receiver1.send(toSend));
		require(receiver2.send(toSend));
		require(receiver3.send(this.balance)); // remaining balance goes to 3rd receiver
	}

	function ownerWithdraw(
		address _receiver,
		uint amount
	)
		public
		onlyOwner
	{
		require(_receiver.send(amount));
	}

	function setReceiver1(
		address _receiver
	)
		public
		onlyOwner
	{
		require(_receiver != address(0) && _receiver != receiver1);
		receiver1 = _receiver;
	}

	function setReceiver2(
		address _receiver
	)
		public
		onlyOwner
	{
		require(_receiver != address(0) && _receiver != receiver2);
		receiver2 = _receiver;
	}

	function setReceiver3(
		address _receiver
	)
		public
		onlyOwner
	{
		require(_receiver != address(0) && _receiver != receiver3);
		receiver3 = _receiver;
	}

	function getInvestorsAddresses()
		public
		view
		returns (address[])
	{
		return investors;
	}

	function getBalance()
		public
		view
		returns (uint)
	{
		return this.balance;
	}
}