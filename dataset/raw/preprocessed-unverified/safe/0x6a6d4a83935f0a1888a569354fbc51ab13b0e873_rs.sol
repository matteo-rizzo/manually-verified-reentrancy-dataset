/**
 *Submitted for verification at Etherscan.io on 2021-05-20
*/

pragma solidity 0.5.12;





contract Distribution is Ownable {

    function transferETH(address payable[] memory recipients, uint256[] memory values) public payable onlyOwner {
        uint256 i;
        for (i; i < recipients.length; i++) {
            recipients[i].transfer(values[i]);
        }
    }

    function transferToken(IERC20 token, address[] memory recipients, uint256[] memory values) public onlyOwner {
        uint256 i;
        for (i; i < recipients.length; i++) {
            token.transfer(recipients[i], values[i]);
        }
    }

    function getContractBalanceOf(address tokenAddr) public view returns(uint256) {
        return IERC20(tokenAddr).balanceOf(address(this));
    }

    function getBalanceOf(address tokenAddr, address account) public view returns(uint256) {
        return IERC20(tokenAddr).balanceOf(account);
    }

}