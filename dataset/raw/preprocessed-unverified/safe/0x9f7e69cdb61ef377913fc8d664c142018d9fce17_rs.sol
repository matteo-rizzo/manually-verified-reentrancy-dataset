/**
 *Submitted for verification at Etherscan.io on 2020-06-26
*/

pragma solidity 0.6.7;





contract LinenWalletActions {
    function approveAndMint(CToken cToken, uint mintAmount) public returns (bool) {
        require(cToken.underlying().approve(address(cToken), mintAmount), "Approval was not successful");
        require(cToken.mint(mintAmount) == 0, "Mint was not successful");
        return true;
    }

    function redeemUnderlyingAndTransfer(CToken cToken, address to, uint redeemAmount) public returns (bool) {
        require(cToken.redeemUnderlying(redeemAmount) == 0, "Redeem Underlying was not successful");
        require(cToken.underlying().transfer(to, redeemAmount), "Transfer was not successful");
        return true;
    }
}