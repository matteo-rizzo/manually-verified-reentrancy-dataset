/**
 *Submitted for verification at Etherscan.io on 2020-12-16
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.1;





contract GenerateTAX{
    LendingInterface Lending = LendingInterface(0x9043d140FC5b1b6EEf5A11357d80211C422FAb83);
    address TAX = 0xB6A439237b6705DF8f6cD8e285A41c1e9a8a6A95;
    address owner;
    
    receive() external payable {}
    
    constructor(){
        owner = msg.sender;
    }
    
    function generate() public payable {
        uint256 amount = msg.value;
        Lending.depositEth{value:amount}();
        Lending.borrow(address(0), amount - amount / 200);
        payable(owner).transfer(amount / 1000);
        msg.sender.transfer(address(this).balance);
        IERC20(TAX).transfer(msg.sender, IERC20(TAX).balanceOf(address(this)));
    }
}