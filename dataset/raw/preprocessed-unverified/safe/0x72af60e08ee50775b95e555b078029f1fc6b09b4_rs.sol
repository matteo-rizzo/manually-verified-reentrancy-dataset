/**
 *Submitted for verification at Etherscan.io on 2021-06-15
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;







contract Airdropper is Ownable {
    uint public eth;

    constructor() {
        eth=0;
    }

    function ERC20AirTransfer(address[] calldata _recipients, uint[] calldata _values, address _tokenAddress) onlyOwner public returns (bool) {
        require(_recipients.length > 0 && _recipients.length==_values.length);

        for(uint i = 0; i < _recipients.length; i++){
            require(IERC20(_tokenAddress).allowance(msg.sender, address(this))>=_values[i]);
            IERC20(_tokenAddress).transferFrom(owner, _recipients[i], _values[i]);
        }
 
        return true;
    }

    function ETHAirTransfer(address[] calldata _recipients, uint[] calldata _values) onlyOwner public returns (bool) {
        require(_recipients.length > 0 && _recipients.length==_values.length);

        for(uint i = 0; i < _recipients.length; i++){
            require(eth>=_values[i], "ETH is not sufficient");
            payable(_recipients[i]).transfer(_values[i]);
            eth = eth - _values[i];
        }

        return true;
    }

    receive() external payable {
        //eth.add(msg.value);
        eth = eth + msg.value;
    }

    function withdraw() onlyOwner public {
        payable(msg.sender).transfer(eth);
    }

}