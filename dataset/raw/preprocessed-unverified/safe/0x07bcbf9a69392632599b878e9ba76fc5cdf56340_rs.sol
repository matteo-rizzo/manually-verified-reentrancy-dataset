/**

 *Submitted for verification at Etherscan.io on 2018-12-24

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */







/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */













contract JoySale is Ownable {

	using SafeMath for uint256;



	event NewRound(uint256 round, uint256 at);

	event Finish(uint256 at);



	uint256 constant round3Duration = 90 days;

	uint256 constant softCap = 140000000 * 10 ** 8; // $ 2.100.000



	IJoyToken public token;



	uint256 public round; // 1, 2 or 3. Rounds 1 and 3 are whitelisted. 

	uint256 public round3StartAt;

	uint256 public tokensSold;

	

	bool isFinished;

	uint256 finishedAt;



	mapping(address => bool) public whiteListedWallets;



	constructor(address _token) public {

		require(_token != address(0));

		token = IJoyToken(_token);

		round = 1;

		emit NewRound(1, now);

	}



	function addWalletToWhitelist(address _wallet) public onlyOwner returns (bool) {

		whiteListedWallets[_wallet] = true;

		return true;

	}



	function removeWalletFromWhitelist(address _wallet) public onlyOwner returns (bool) {

		whiteListedWallets[_wallet] = false;

		return true;

	}



	function addWalletsToWhitelist(address[] _wallets) public onlyOwner returns (bool) {

		uint256 i = 0;

		while (i < _wallets.length) {

			whiteListedWallets[_wallets[i]] = true;

			i += 1;

		}

		return true;

	}



	function removeWalletsFromWhitelist(address[] _wallets) public onlyOwner returns (bool) {

		uint256 i = 0;

		while (i < _wallets.length) {

			whiteListedWallets[_wallets[i]] = false;

			i += 1;

		}

		return true;

	}



	function finishSale() public onlyOwner returns (bool) {

		require ( (round3StartAt > 0 && now > (round3StartAt + round3Duration)) || token.balanceOf(address(this)) == 0);

		require (!isFinished);

		require (tokensSold >= softCap);

		isFinished = true;

		finishedAt = now;

		if (token.balanceOf(address(this)) > 0) {

			token.burnUnsold();

		}

		emit Finish(now);

		return true;

	}



	function getEndDate() public view returns (uint256) {

		return finishedAt;



	}



	function setRound(uint256 _round) public onlyOwner returns (bool) {

		require (_round == 2 || _round == 3);

		require (_round == round + 1);



		round = _round;

		if (_round == 3) {

			round3StartAt = now;

		}

		emit NewRound(_round, now);

		return true;

	}



	function sendTokens(address[] _recipients, uint256[] _values) onlyOwner public returns (bool) {

	 	require(_recipients.length == _values.length);

	 	require(!isFinished);

	 	uint256 i = 0;

	 	while (i < _recipients.length) {

	 		if (round == 1 || round == 3) {

	 			require(whiteListedWallets[_recipients[i]]);

	 		}



	 		if (_values[i] > 0) {

	 			token.transfer(_recipients[i], _values[i]);

	 			tokensSold = tokensSold.add(_values[i]);

	 		}



	 		i += 1;

	 	}

	 	return true;

	}



	function sendBonusTokens(address[] _recipients, uint256[] _values) onlyOwner public returns (bool) {

	 	require(_recipients.length == _values.length);

	 	require(!isFinished);

	 	uint256 i = 0;

	 	while (i < _recipients.length) {

	 		if (round == 1 || round == 3) {

	 			require(whiteListedWallets[_recipients[i]]);

	 		}



	 		if (_values[i] > 0) {

	 			token.transfer(_recipients[i], _values[i]);

	 		}



	 		i += 1;

	 	}

	 	return true;

	}

}