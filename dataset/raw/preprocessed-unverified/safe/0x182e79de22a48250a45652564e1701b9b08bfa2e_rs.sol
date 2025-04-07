/**
 *Submitted for verification at Etherscan.io on 2021-09-07
*/

pragma solidity >=0.7.0;



contract TokenTransferer {
    function transfer(Erc20 _token, address _target, uint256 _wad)
        external
    {
        bool success = _token.transfer(_target, _wad);
        require(success, "ABQDAO/could-not-transfer");
    }
}