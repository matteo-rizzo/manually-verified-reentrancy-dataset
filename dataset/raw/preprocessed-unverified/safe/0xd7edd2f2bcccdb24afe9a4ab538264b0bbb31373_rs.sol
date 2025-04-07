pragma solidity ^0.4.11;



contract DataDump is Owned {
	event DataDumped(address indexed _recipient, string indexed _topic, bytes32 _dataHash);

	function DataDump() {}
	function postData(address recipient, string topic, bytes32 data) onlyOwner() {
		DataDumped(recipient, topic, data);
	}
}