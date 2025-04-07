/**
 *Submitted for verification at Etherscan.io on 2019-06-23
*/

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */








contract Approved {

    using SafeERC20Detailed for address;

    function allowances(
        address source,
        address[] calldata tokens,
        address[] calldata spenders
    )
        external
        returns(
            uint256[] memory results,
            uint256[] memory decimals,
            bytes32[] memory symbols
        )
    {
        require(tokens.length == spenders.length, "Invalid argument array lengths");

        results = new uint256[](tokens.length);
        decimals = new uint256[](tokens.length);
        symbols = new bytes32[](tokens.length);

        for (uint i = 0; i < tokens.length; i++) {

            results[i] = IERC20(tokens[i]).allowance(source, spenders[i]);
            decimals[i] = tokens[i].safeDecimals();
            symbols[i] = tokens[i].safeSymbol();
        }
    }
}