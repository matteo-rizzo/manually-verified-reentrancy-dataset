/**
 *Submitted for verification at Etherscan.io on 2021-05-27
*/

//SPDX-License-Identifier: Apache-2.0;
pragma solidity ^0.7.6;






contract Barbecue {
    
    using SafeMath for uint256;
    uint256 constant EXCHANGE_RATE = 10;
    
    event Exchanged(address indexed from, uint256 ethValue, uint256 wurstValue);
    
    ERC20Interface public tokenContract = ERC20Interface(address(0x67e74603DF95cAbBEbC6795478c2402A01eA1517));
    address payable public fundingWallet = payable(0x67E0023d1E7176Cdaf65a9afA374D774484839e0);

    receive() external payable {
        address from = msg.sender;
        uint256 ethValue = msg.value;
        require(ethValue > 0, "sent eth has to be greater than 0");
        uint256 wurstValue = ethValue.div(EXCHANGE_RATE);
        require(wurstValue > 0, "exchanged wurstValue has to be greater than 0");
        
        require(tokenContract.transfer(from, wurstValue), "wurst transfer failed");
        emit Exchanged(from, ethValue, wurstValue);
    }
    
    function withdraw() external payable {
        require(msg.sender == fundingWallet, "only the funding wallet can issue a withdraw");
        fundingWallet.transfer(address(this).balance);
    }
}