/**
 *Submitted for verification at Etherscan.io on 2020-06-10
*/

pragma solidity ^0.5.10;



contract Staking_NAEN is Ownable {
    event Received(address payable[] addresses, uint256[] values);

    //function () payable external {}

    function StakingHolderNAEN(address payable[] calldata _to, uint256[] calldata _values) payable external onlyOwnerOrDistributor {
        require(_to.length == _values.length);
        for (uint256 i = 0; i < _to.length; i++) {
            address(_to[i]).transfer(_values[i]);
        }
        emit Received(_to, _values);
    }
}