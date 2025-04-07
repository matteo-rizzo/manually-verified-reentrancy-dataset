/**
 *Submitted for verification at Etherscan.io on 2021-05-25
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



contract bridge{

    IERC20 token;
    bool pause;
    address connector;
    address owner;
    constructor(address _token, address _bridge) {
        token = IERC20(_token);
        pause = false;
        connector = _bridge;
        owner = msg.sender;
    }

    event bridged(address recv, uint256 amount);

    function move(uint256 amount) public payable{
        require(amount <= token.allowance(msg.sender, address(this)), "approve the contract");
        require(!pause, "bridge is paused");
        require(msg.value > 0, "gas fee not set");
        payable(connector).transfer(msg.value);
        token.transferFrom(msg.sender, connector, amount);

        emit bridged(msg.sender, amount);
    }

    function stop() public {
        require(msg.sender == owner, "only Owner");
        pause = !pause;
    }
}