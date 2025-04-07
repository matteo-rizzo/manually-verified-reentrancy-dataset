pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


// Allows users to "heart" (like) a DAPP by dapp id
// 1 Like = XXXXX eth will be set on front end of site
// 50% of each transaction gets sent to the last liker

contract dappVolumeHearts {

	using SafeMath for uint256;

	// set contract owner
	address public contractOwner;
	// set last address transacted
	address public lastAddress;

	// only contract owner
	modifier onlyContractOwner {
		require(msg.sender == contractOwner);
		_;
	}

	// set constructor
	constructor() public {
		contractOwner = msg.sender;
	}

	// withdraw funds to contract creator
	function withdraw() public onlyContractOwner {
		contractOwner.transfer(address(this).balance);
	}

	// map dapp ids with heart totals
	mapping(uint256 => uint256) public totals;

	// update heart count
	function update(uint256 dapp_id) public payable {
		require(msg.value > 1900000000000000);
		totals[dapp_id] = totals[dapp_id] + msg.value;
		// send 50% of the money to the last person
		lastAddress.transfer(msg.value.div(2));
		lastAddress = msg.sender;
	}

	// get total hearts by id
	function getTotalHeartsByDappId(uint256 dapp_id) public view returns(uint256) {
		return totals[dapp_id];
	}

	// get contract balance
	function getBalance() public view returns(uint256){
		return address(this).balance;
	}

}