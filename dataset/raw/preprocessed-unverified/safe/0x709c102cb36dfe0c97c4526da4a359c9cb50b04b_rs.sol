/**
 *Submitted for verification at Etherscan.io on 2020-01-15
*/

pragma solidity 0.5.10;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */



// @author Ben Scholtz @ Linum Labs
// @title Bonding curve functions

contract CurveFunctions {
	using SafeMath for uint256;

	// Description of function (function ID)
	string constant public curveFunction = "linear: (1/20000)*x + 0.5	curve integral: (0.000025*x + 0.5)*x	inverse curve integral: -10000 + 200*sqrt(x + 2500)";
	// Decimal place precision
	uint256 constant public DECIMALS = 18;

	/**
      * @dev    Calculates the definite integral of the curve.
	  * @notice	Various symboles are used within this function (i.e a, b). This
	  *			is done to represent the variables within the curve integral 
	  *			equation.
      * @param  _x : Token value for upper limit of definite integral
      */
	function curveIntegral(uint256 _x) public pure returns (uint256) {
		// Ensuring that after scaling the number will not be too large
		require(_x <= 10**40, 'Input argument too large');

		// Calculate equation arguments
		uint256 a = 25*10**(DECIMALS - 6);
		// hatch price
		uint256 b = 5*10**(DECIMALS - 1);

		// curve integral: (0.000025*x + 0.5)*x
		return (a.mul(_x).div(10**DECIMALS).add(b)).mul(_x).div(10**DECIMALS);
	}

	/**
	  * @dev    Calculates the definite inverse integral of the curve
	  * @notice	Various symbols are used within this function (i.e a, b). This
	  *			is done to represent the variables within the inverse curve 
	  *			integral equation.
		* @param  _x : collateral value for upper limit of definite integral
		*/
	function inverseCurveIntegral(uint256 _x) public pure returns(uint256) {
		// Ensuring that after scaling the number will not be too large
		require(_x <= 10**40, 'Input argument too large');

		// Use 36 decimal places for square root precision
		uint256 DECIMALS_36 = 36;

		// Calculate equation arguments
		uint256 x = _x*10**DECIMALS;
		uint256 prefix = 200*10**DECIMALS_36;
		uint256 a = prefix
			.mul(sqrt(x + 2500*10**DECIMALS_36))
			.div(sqrt(10**DECIMALS_36));

		// inverse curve integral: -10000 + 200*sqrt(x + 2500)
		return uint256(
				-10000*int256(10**DECIMALS_36) + int256(a)
			).div(10**DECIMALS);
	}

	/**
	  * @notice	Square root function.
	  *	@param	_x : Vaule getting square rooted.
	  */
	function sqrt(uint256 _x) public pure returns (uint256) {
		if (_x == 0) return 0;
		else if (_x <= 3) return 1;
		uint256 z = (_x + 1) / 2;
		uint256 y = _x;
		
		while (z < y) {
			y = z;
			z = (_x / z + z) / 2;
		}

		return y;
	}
}