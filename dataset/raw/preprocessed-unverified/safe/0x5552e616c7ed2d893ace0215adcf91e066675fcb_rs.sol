/**

 *Submitted for verification at Etherscan.io on 2018-09-17

*/



pragma solidity ^0.4.24;











contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}







contract Distribution {



	using SafeMath for uint256;

	using SafeERC20 for ERC20;



	struct distributionInfo {

		ERC20 token;

		uint256 tokenDecimal;

	}



	mapping (address => distributionInfo) wallets;



	function() public payable {

		revert();

	}



	function updateDistributionInfo(ERC20 _token, uint256 _tokenDecimal) public {

		require(_token != address(0));

		require(_tokenDecimal > 0);



		distributionInfo storage wallet = wallets[msg.sender];

		wallet.token = _token;

		wallet.tokenDecimal = _tokenDecimal;

	} 



	function distribute(address[] _addresses, uint256[] _amounts) public {

		require(wallets[msg.sender].token != address(0));

		require(_addresses.length == _amounts.length);



	    for(uint256 i = 0; i < _addresses.length; i++){

	    	require(wallets[msg.sender].token.balanceOf(msg.sender) >= _amounts[i]);

	    	require(wallets[msg.sender].token.allowance(msg.sender,this) >= _amounts[i]);

	    	wallets[msg.sender].token.safeTransferFrom(msg.sender, _addresses[i], _amounts[i]);

	    }

	}



	function getDistributionInfo(address _address) view public returns (ERC20, uint256) {

        return (wallets[_address].token, wallets[_address].tokenDecimal);

    }



}