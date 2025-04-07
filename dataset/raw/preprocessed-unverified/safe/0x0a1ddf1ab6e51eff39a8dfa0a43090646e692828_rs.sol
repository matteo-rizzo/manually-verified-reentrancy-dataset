/**
 *Submitted for verification at Etherscan.io on 2021-02-17
*/

pragma solidity 0.6.7;







abstract contract LinenWalletActions {

    function cEther() internal pure virtual returns (CEther);

    function approveAndMint(CToken cToken, uint mintAmount) external returns (bool) {
        
        if (address(cToken) == address(cEther())){
            cEther().mint{value: mintAmount}();
        } else {
            cToken.underlying().approve(address(cToken), mintAmount);
            require(cToken.mint(mintAmount) == 0, "Mint was not successful");
        }
        return true;
    }

    function redeemUnderlyingAndTransfer(CToken cToken, address payable to, uint redeemAmount) external returns (bool) {
        if (address(cToken) == address(cEther())){
            require(cEther().redeemUnderlying(redeemAmount) == 0, "Redeem Underlying was not successful");
            (bool success, ) = to.call{value: redeemAmount}("");
            require(success, "Transfer was not successful");
        } else {
            require(cToken.redeemUnderlying(redeemAmount) == 0, "Redeem Underlying was not successful");
            cToken.underlying().transfer(to, redeemAmount);
        }

        return true;
    }

    function redeemUnderlyingAndTransfer(CToken cToken, address payable to, uint redeemAmount, uint feeAmount) external returns (bool) {
        require(redeemAmount >= feeAmount, "subtraction overflow");
        
        if (address(cToken) == address(cEther())){
            require(cEther().redeemUnderlying(redeemAmount) == 0, "Redeem Underlying was not successful");
            (bool success, ) = to.call{value: redeemAmount - feeAmount}("");
            require(success, "Transfer was not successful");
        } else {
            require(cToken.redeemUnderlying(redeemAmount) == 0, "Redeem Underlying was not successful");
            cToken.underlying().transfer(to, redeemAmount - feeAmount);
        }

        return true;
    }
}

contract LinenWalletActionsMainnet is LinenWalletActions {
    function cEther() internal pure override returns (CEther){
        return CEther(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);
    }
}