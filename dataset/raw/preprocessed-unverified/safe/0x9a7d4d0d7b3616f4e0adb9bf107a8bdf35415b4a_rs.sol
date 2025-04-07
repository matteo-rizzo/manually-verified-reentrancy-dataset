/**
 *Submitted for verification at Etherscan.io on 2021-04-24
*/

pragma solidity 0.6.12;

contract burner {
    function removeLiquidity(
        unipair pair,
        address to,
        uint256 amount
    ) external {
        pair.transferFrom(msg.sender, address(pair), amount); // send `amount` to pair
        pair.burn(to); // burn against `pair` to redeem liquidity
    }
}