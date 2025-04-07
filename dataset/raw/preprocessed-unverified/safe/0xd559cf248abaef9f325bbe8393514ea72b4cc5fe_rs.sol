/**
 *Submitted for verification at Etherscan.io on 2021-07-20
*/

pragma solidity 0.8.4;








contract BalanceProxy is BalanceProxyInterface {
    function balance(address account) external view override returns (uint256 balance) {
        balance = account.balance;
    }

    function balanceOf(ERC20Interface token, address account) external view override returns (uint256 balance) {
        balance = token.balanceOf(account);
    }
}