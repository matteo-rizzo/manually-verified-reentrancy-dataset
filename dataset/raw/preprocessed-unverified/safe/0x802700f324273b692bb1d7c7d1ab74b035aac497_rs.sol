/**
 *Submitted for verification at Etherscan.io on 2021-03-08
*/

//SPDX-License-Identifier: GNU GPLv3
pragma solidity ^0.7.0;







contract SwapContract is Ownable {
    using SafeMath for uint256;

    IERC20 public OldToken;
    IERC20 public NewToken;
    uint256 public Decimals;

    uint BasisPoints = 10**9;

    constructor(address OldTokenAddress, address NewTokenAddress ) public{
         OldToken = IERC20(OldTokenAddress);
        NewToken = IERC20(NewTokenAddress);
        Decimals = 9;
    }

    function withdraw(IERC20 token) public onlyOwner {
        token.transfer(address(owner()), token.balanceOf(address(this)));
    }

    function swapTokens() hasApprovedTransfer public {

        uint tokenBalance = OldToken.balanceOf(msg.sender);
        uint totalSupply = OldToken.totalSupply();
        uint supplyPercentage = tokenBalance.mul(BasisPoints).div(totalSupply);
        require(supplyPercentage > 0, "Must have larger balance to swap");

        uint approvedTokenAmount = OldToken.allowance(msg.sender, address(this));
        require(approvedTokenAmount >= tokenBalance, "Insufficient Tokens approved for transfer");

        uint newTokenSupply = NewToken.totalSupply();
        uint supplyTokenBasis = newTokenSupply.div(BasisPoints);
        uint tokensToTransfer = supplyTokenBasis * supplyPercentage;

        uint newTokenBalance = NewToken.balanceOf(address(this));
        require(tokensToTransfer <= newTokenBalance, "Insufficient Tokens tokens on contract to swap");

        require(OldToken.transferFrom(msg.sender, address(this), tokenBalance));
        NewToken.transfer(msg.sender, tokensToTransfer);
    }

    modifier hasApprovedTransfer() {
        require(OldToken.allowance(msg.sender, address(this)) > 0, "Tokens not approved for transfer");
        _;
    }
}