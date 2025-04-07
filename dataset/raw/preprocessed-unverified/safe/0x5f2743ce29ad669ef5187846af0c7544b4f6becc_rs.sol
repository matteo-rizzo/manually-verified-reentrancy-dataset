pragma solidity ^0.4.21;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract ERC20Basic {
	function totalSupply() public view returns (uint256);

	function balanceOf(address who) public view returns (uint256);

	function transfer(address to, uint256 value) public returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) public view returns (uint256);

	function transferFrom(address from, address to, uint256 value) public returns (bool);

	function approve(address spender, uint256 value) public returns (bool);

	event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Airdrop Controller
 * @dev Controlls ERC20 token airdrop
 * @notice Token Contract Must send enough tokens to this contract to be distributed before aidrop
 */
contract AirdropController is Ownable {
	using SafeMath for uint;

	uint public totalClaimed;

	bool public airdropAllowed;

	ERC20 public token;

	mapping(address => bool) public tokenReceived;

	modifier isAllowed() {
		require(airdropAllowed == true);
		_;
	}

	function AirdropController() public {
		airdropAllowed = true;
	}

	function airdrop(address[] _recipients, uint[] _amounts) public onlyOwner isAllowed {
		for (uint i = 0; i < _recipients.length; i++) {
			require(_recipients[i] != address(0));
			require(tokenReceived[_recipients[i]] == false);
			require(token.transfer(_recipients[i], _amounts[i]));
			tokenReceived[_recipients[i]] = true;
			totalClaimed = totalClaimed.add(_amounts[i]);
		}
	}

	function airdropManually(address _holder, uint _amount) public onlyOwner isAllowed {
		require(_holder != address(0));
		require(tokenReceived[_holder] == false);
		if (!token.transfer(_holder, _amount)) revert();
		tokenReceived[_holder] = true;
		totalClaimed = totalClaimed.add(_amount);
	}

	function setTokenAddress(address _token) public onlyOwner {
		require(_token != address(0));
		token = ERC20(_token);
	}

	function remainingTokenAmount() public view returns (uint) {
		return token.balanceOf(this);
	}

	function setAirdropEnabled(bool _allowed) public onlyOwner {
		airdropAllowed = _allowed;
	}
}