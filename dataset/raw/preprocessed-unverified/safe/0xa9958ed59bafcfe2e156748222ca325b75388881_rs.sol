pragma solidity ^0.4.21;

/**

 * Changes by https://www.docademic.com/

 */



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * Changes by https://www.docademic.com/

 */



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */





contract Destroyable is Ownable {

	/**

	 * @notice Allows to destroy the contract and return the tokens to the owner.

	 */

	function destroy() public onlyOwner {

		selfdestruct(owner);

	}

}







contract TokenPool is Ownable, Destroyable {

	using SafeMath for uint256;

	

	Token public token;

	address public spender;

	

	event AllowanceChanged(uint256 _previousAllowance, uint256 _allowed);

	event SpenderChanged(address _previousSpender, address _spender);

	

	

	/**

	 * @dev Constructor.

	 * @param _token The token address

	 * @param _spender The spender address

	 */

	function TokenPool(address _token, address _spender) public{

		require(_token != address(0) && _spender != address(0));

		token = Token(_token);

		spender = _spender;

	}

	

	/**

	 * @dev Get the token balance of the contract.

	 * @return _balance The token balance of this contract in wei

	 */

	function Balance() view public returns (uint256 _balance) {

		return token.balanceOf(address(this));

	}

	

	/**

	 * @dev Get the token allowance of the contract to the spender.

	 * @return _balance The token allowed to the spender in wei

	 */

	function Allowance() view public returns (uint256 _balance) {

		return token.allowance(address(this), spender);

	}

	

	/**

	 * @dev Allows the owner to set up the allowance to the spender.

	 */

	function setUpAllowance() public onlyOwner {

		emit AllowanceChanged(token.allowance(address(this), spender), token.balanceOf(address(this)));

		token.approve(spender, token.balanceOf(address(this)));

	}

	

	/**

	 * @dev Allows the owner to update the allowance of the spender.

	 */

	function updateAllowance() public onlyOwner {

		uint256 balance = token.balanceOf(address(this));

		uint256 allowance = token.allowance(address(this), spender);

		uint256 difference = balance.sub(allowance);

		token.increaseApproval(spender, difference);

		emit AllowanceChanged(allowance, allowance.add(difference));

	}

	

	/**

	 * @dev Allows the owner to destroy the contract and return the tokens to the owner.

	 */

	function destroy() public onlyOwner {

		token.transfer(owner, token.balanceOf(address(this)));

		selfdestruct(owner);

	}

	

	/**

	 * @dev Allows the owner to change the spender.

	 * @param _spender The new spender address

	 */

	function changeSpender(address _spender) public onlyOwner {

		require(_spender != address(0));

		emit SpenderChanged(spender, _spender);

		token.approve(spender, 0);

		spender = _spender;

		setUpAllowance();

	}

	

}