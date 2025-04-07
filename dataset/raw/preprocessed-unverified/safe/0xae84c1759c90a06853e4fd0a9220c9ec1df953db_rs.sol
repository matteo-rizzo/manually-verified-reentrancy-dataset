/**

 *Submitted for verification at Etherscan.io on 2018-10-09

*/



pragma solidity ^0.4.25;







contract FivePercent {

	using SafeMath for uint256;



	address public constant marketingAddress = 0xbacd82fd2a77128274f68983f82c8372e06a1472;



	mapping (address => uint256) deposited;

	mapping (address => uint256) withdrew;

	mapping (address => uint256) refearned;

	mapping (address => uint256) blocklock;



	uint256 public totalDepositedWei = 0;

	uint256 public totalWithdrewWei = 0;



	function() payable external

	{

		uint256 marketingPerc = msg.value.mul(5).div(100);



		marketingAddress.transfer(marketingPerc);

		

		if (deposited[msg.sender] != 0)

		{

			address investor = msg.sender;

			uint256 depositsPercents = deposited[msg.sender].mul(5).div(100).mul(block.number-blocklock[msg.sender]).div(5900);

			investor.transfer(depositsPercents);



			withdrew[msg.sender] += depositsPercents;

			totalWithdrewWei = totalWithdrewWei.add(depositsPercents);

		}



		address referrer = bytesToAddress(msg.data);

		uint256 refPerc = msg.value.mul(5).div(100);

		

		if (referrer > 0x0 && referrer != msg.sender)

		{

			referrer.transfer(refPerc);



			refearned[referrer] += refPerc;

		}



		blocklock[msg.sender] = block.number;

		deposited[msg.sender] += msg.value;



		totalDepositedWei = totalDepositedWei.add(msg.value);

	}



	function userDepositedWei(address _address) public view returns (uint256)

	{

		return deposited[_address];

    }



	function userWithdrewWei(address _address) public view returns (uint256)

	{

		return withdrew[_address];

    }



	function userDividendsWei(address _address) public view returns (uint256)

	{

		return deposited[_address].mul(5).div(100).mul(block.number-blocklock[_address]).div(5900);

    }



	function userReferralsWei(address _address) public view returns (uint256)

	{

		return refearned[_address];

    }



	function bytesToAddress(bytes bys) private pure returns (address addr)

	{

		assembly {

			addr := mload(add(bys, 20))

		}

	}

}