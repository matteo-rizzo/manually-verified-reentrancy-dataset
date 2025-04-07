/**
 *Submitted for verification at Etherscan.io on 2019-10-08
*/

pragma solidity ^0.5.6;





contract IOperationalWallet2 {
    function setTrustedToggler(address _trustedToggler) external;
    function toggleTrustedWithdrawer(address _withdrawer, bool isEnabled) external;
    function withdrawCoin(address coin, address to, uint256 amount) external returns (bool);
}


contract OperationalWallet2 is Ownable, IOperationalWallet2 {
    address private trustedToggler;
    mapping(address => bool) private trustedWithdrawers;

    function setTrustedToggler(address _trustedToggler) public onlyOwner {
        trustedToggler = _trustedToggler; // this should be a booking factory
    }

    function toggleTrustedWithdrawer(address _withdrawer, bool isEnabled) external {
        require(isOwner() || msg.sender == trustedToggler);
        trustedWithdrawers[_withdrawer] = isEnabled;
    }

    function withdrawCoin(address coin, address to, uint256 amount) external returns (bool) {
        require(isOwner() || trustedWithdrawers[msg.sender]);
        return IERC20(coin).transfer(to, amount);
    }
}