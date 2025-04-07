/**
 *Submitted for verification at Etherscan.io on 2019-11-16
*/

pragma solidity ^0.5.12;







 //--BTCGW BatchTransfer--Carstyle--
contract BatchTransfer is Ownable{
    using SafeMath for uint256;
    
    IERC20 BTCGW = IERC20(0x305F8157C1f841fBD378f636aBF390c5b4C0e330); //contract address of BTCGW

    
    function batchTransferBoth(address payable[] memory accounts, uint256 etherValue, uint256 btcgwValue) public payable {
        uint256 __etherBalance = address(this).balance;
        uint256 __btcgwAllowance = BTCGW.allowance(msg.sender, address(this));

        require(__etherBalance >= etherValue.mul(accounts.length));
        require(__btcgwAllowance >= btcgwValue.mul(accounts.length));

        for (uint256 i = 0; i < accounts.length; i++) {
            accounts[i].transfer(etherValue);
            assert(BTCGW.transferFrom(msg.sender, accounts[i], btcgwValue));
        }
    }

    function batchTransferEther(address payable[] memory accounts, uint256 etherValue) public payable {
        uint256 __etherBalance = address(this).balance;

        require(__etherBalance >= etherValue.mul(accounts.length));

        for (uint256 i = 0; i < accounts.length; i++) {
            accounts[i].transfer(etherValue);
        }
    }

   
    function batchTransferBTCGW(address[] memory accounts, uint256 btcgwValue) public {
        uint256 __btcgwAllowance = BTCGW.allowance(msg.sender, address(this));

        require(__btcgwAllowance >= btcgwValue.mul(accounts.length));

        for (uint256 i = 0; i < accounts.length; i++) {
            assert(BTCGW.transferFrom(msg.sender, accounts[i], btcgwValue));
        }
    }
}