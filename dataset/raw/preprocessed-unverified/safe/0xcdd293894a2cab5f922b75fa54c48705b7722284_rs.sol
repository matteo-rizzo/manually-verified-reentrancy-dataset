/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;









abstract contract IWETH {
    function allowance(address, address) public virtual returns (uint256);

    function balanceOf(address) public virtual returns (uint256);

    function approve(address, uint256) public virtual;

    function transfer(address, uint256) public virtual returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) public virtual returns (bool);

    function deposit() public payable virtual;

    function withdraw(uint256) public virtual;
}





/// @title Helper contract where we can retreive the 2 wei Dydx fee
contract FLFeeFaucet {
    address public constant WETH_ADDR = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @notice Sends 2 wei to msg.sender
    function my2Wei() public {
        IWETH(WETH_ADDR).transfer(msg.sender, 2);
    }
}