/**

 *Submitted for verification at Etherscan.io on 2018-12-19

*/



pragma solidity ^0.4.24;







contract Airdrop is Ownable {



    function () payable public {}



    function airdrop(address[] _to, uint256[] _values) external onlyOwnerOrDistributor {

        require(_to.length == _values.length);

        for (uint256 i = 0; i < _to.length; i++) {

            _to[i].transfer(_values[i]);

        }

    }

}