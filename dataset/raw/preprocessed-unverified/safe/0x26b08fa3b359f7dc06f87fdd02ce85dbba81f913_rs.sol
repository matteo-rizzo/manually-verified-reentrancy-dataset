/**
 *Submitted for verification at Etherscan.io on 2020-11-13
*/

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// File: @openzeppelin/contracts/math/SafeMath.sol

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


// File: contracts/uniswapv2/interfaces/IUniswapV2Pair.sol





contract NoStepOnSmolProxy {
    using SafeMath for uint256;

    IERC20 public token;
    IUniswapV2Pair public lpToken;
    SmolTingPot public smolTingPot;

    constructor(address _tokenAddr, address _lpAddr, SmolTingPot _smolTingPot) public {
        token = IERC20(_tokenAddr);
        lpToken = IUniswapV2Pair(_lpAddr);
        smolTingPot = _smolTingPot;
    }

    function decimals() external pure returns (uint8) {
        return uint8(18);
    }

    function name() external pure returns (string memory) {
        return "$NOSTEPONSMOL";
    }

    function symbol() external pure returns (string memory) {
        return "$NOSTEPONSMOL";
    }

    function totalSupply() external view returns (uint256) {
        return token.totalSupply();
    }

    function balanceOf(address _voter) external view returns (uint256) {
        uint256 _votes = 0;

        uint256 lpSupply = lpToken.totalSupply();
        uint256 smolInPool = token.balanceOf(address(lpToken));

        // Get total LP balance of address (whats on the address + whats stake into SmolTingPot)
        uint256 lpBalance = lpToken.balanceOf(_voter);
        lpBalance = lpBalance.add(smolTingPot.userInfo(1, address(_voter)).amount);

        // Count the smol in uniswap liquidity pool provided by address
        _votes = _votes.add(lpBalance.mul(smolInPool)).div(lpSupply);

        // Count smol held by address
        _votes = _votes.add(token.balanceOf(address(_voter)));

        // Count smol staked in SmolTingPot
        _votes = _votes.add(smolTingPot.userInfo(0, address(_voter)).amount);

        return _votes;
    }
}