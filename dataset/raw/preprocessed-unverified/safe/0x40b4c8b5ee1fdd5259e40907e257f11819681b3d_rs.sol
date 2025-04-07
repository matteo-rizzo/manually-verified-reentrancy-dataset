/**
 *Submitted for verification at Etherscan.io on 2020-04-03
*/

pragma solidity 0.5.16;




contract DedgeGeneralManager {
    function () external payable {}

    constructor() public {}

    function transferETH(address recipient, uint amount) public {
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "gen-mgr-transfer-eth-failed");
    }

    function transferERC20(address recipient, address erc20Address, uint amount) public {
        require(
            IERC20(erc20Address).transfer(recipient, amount),
            "gen-mgr-transferperc20-failed"
        );
    }
}