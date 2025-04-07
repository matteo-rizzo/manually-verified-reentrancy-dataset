/**
 *Submitted for verification at Etherscan.io on 2020-10-04
*/

// File: contracts/intf/IDODO.sol

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;





// File: contracts/intf/IERC20.sol

// This is a file copied from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */



// File: contracts/lib/SafeMath.sol

/*

    Copyright 2020 DODO ZOO.

*/

/**
 * @title SafeMath
 * @author DODO Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */



// File: contracts/token/DODOMineReader.sol

/*

    Copyright 2020 DODO ZOO.

*/




contract DODOMineReader {
    using SafeMath for uint256;

    function getUserStakedBalance(
        address _dodoMine,
        address _dodo,
        address _user
    ) external view returns (uint256 baseBalance, uint256 quoteBalance) {
        address baseLpToken = IDODO(_dodo)._BASE_CAPITAL_TOKEN_();
        address quoteLpToken = IDODO(_dodo)._QUOTE_CAPITAL_TOKEN_();

        uint256 baseLpBalance = IDODOMine(_dodoMine).getUserLpBalance(baseLpToken, _user);
        uint256 quoteLpBalance = IDODOMine(_dodoMine).getUserLpBalance(quoteLpToken, _user);

        uint256 baseLpTotalSupply = IERC20(baseLpToken).totalSupply();
        uint256 quoteLpTotalSupply = IERC20(quoteLpToken).totalSupply();

        (uint256 baseTarget, uint256 quoteTarget) = IDODO(_dodo).getExpectedTarget();
        baseBalance = baseTarget.mul(baseLpBalance).div(baseLpTotalSupply);
        quoteBalance = quoteTarget.mul(quoteLpBalance).div(quoteLpTotalSupply);

        return (baseBalance, quoteBalance);
    }
}