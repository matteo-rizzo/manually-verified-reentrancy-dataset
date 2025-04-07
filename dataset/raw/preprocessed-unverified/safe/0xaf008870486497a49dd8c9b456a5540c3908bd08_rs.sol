/**
 *Submitted for verification at Etherscan.io on 2021-09-01
*/

pragma solidity ^0.7.0;



contract TokenApprover
{
    function approve(Erc20 _token, address _to, uint256 _wad)
        external
    {
        bool success = _token.approve(_to, _wad);
        require(success, "ABQDAO/could-not-approve");
    }
}