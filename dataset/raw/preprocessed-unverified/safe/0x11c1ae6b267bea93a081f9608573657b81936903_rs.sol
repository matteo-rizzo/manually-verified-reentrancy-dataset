/**

 *Submitted for verification at Etherscan.io on 2018-08-22

*/



pragma solidity ^0.4.24;







contract ETHPublish is Ownable {

	event Publication(bytes32 indexed hash, string content);



	mapping(bytes32 => string) public publications;

	mapping(bytes32 => bool) published;



	function()

		public

		payable

	{

		revert();

	}



	function publish(string content)

		public

		onlyOwner

		returns (bytes32)

	{

		bytes32 hash = keccak256(bytes(content));

		

		require(!published[hash]);



		publications[hash] = content;

		published[hash] = true;

		emit Publication(hash, content);



		return hash;

	}

}