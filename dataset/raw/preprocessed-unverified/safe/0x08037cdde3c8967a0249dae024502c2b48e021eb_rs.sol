/**
 *Submitted for verification at Etherscan.io on 2019-07-24
*/

pragma solidity ^0.5.10;



contract Airdrop is Ownable {
    event Received(address payable[] addresses, uint256[] values);

    //function () payable external {}

    function airdrop(address payable[] calldata _to, uint256[] calldata _values) payable external onlyOwnerOrDistributor {
        require(_to.length == _values.length);
        for (uint256 i = 0; i < _to.length; i++) {
            address(_to[i]).transfer(_values[i]);
        }
        emit Received(_to, _values);
    }
}