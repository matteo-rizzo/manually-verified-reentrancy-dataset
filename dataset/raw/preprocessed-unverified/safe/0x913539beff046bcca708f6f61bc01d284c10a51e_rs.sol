/**
 *Submitted for verification at Etherscan.io on 2019-12-21
*/

pragma solidity 0.5.11;






contract Common {
    /**
     * @dev get MakerDAO MCD Address contract
     */
    function getMcdAddresses() public pure returns (address mcd) {
        mcd = 0xF23196DF1C440345DE07feFbe556a5eF0dcD29F0;
    }

}


contract InstaMcdGive is Common {
    function transferOwner(uint vault) public {
        address manager = InstaMcdAddress(getMcdAddresses()).manager();
        ManagerLike(manager).give(vault, msg.sender);
    }
}