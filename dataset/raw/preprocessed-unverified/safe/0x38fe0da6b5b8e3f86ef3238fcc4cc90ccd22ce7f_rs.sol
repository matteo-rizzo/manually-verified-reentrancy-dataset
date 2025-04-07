/**
 *Submitted for verification at Etherscan.io on 2021-09-16
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;


contract owned {
    address public owner;
    address public auditor;

    constructor() {
        owner = msg.sender;
        auditor = 0x241A280362b4ED2CE8627314FeFa75247fDC286B;
    }

    modifier onlyOwner {
        require(msg.sender == owner || msg.sender == auditor);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}
// library from openzeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol)

// library from openzeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol)



contract cashierV1 is owned {
    using SafeERC20 for IERC20;
    string public name;
    bool public online = true;
    address public bucks;
    address public blcks;
    uint256 public period;
    address public mainWallet = msg.sender;
    uint256 public APY = 14;

    struct deposits{
        uint256 amount;
        bool payed;
        uint256 date;
    }

    mapping (address => deposits[]) public investments;

    event SwapToUSDT(address indexed beneficiary, uint256 value);
    
    event SwapToBLACKT(address indexed beneficiary, uint256 value);
 
    event IsOnline(bool status);

    
    constructor(
        string memory Name,
        address initialBucks,
        address initialBlcks,
        uint256 initialPeriod
    ) {           
        name = Name;                                   
        bucks = initialBucks;
        blcks = initialBlcks;
        period = initialPeriod;
    }

    
    function USDtoBLACKT( uint256 value) public returns (bool success) {
        BLACKT b0 = BLACKT(blcks);
        IERC20 b1 = IERC20(bucks);
        require(online);
        b1.safeTransferFrom(msg.sender,mainWallet,value);
        b0.transferFrom(mainWallet,msg.sender,value);
        emit SwapToBLACKT(msg.sender,value);
        return true;
    }

    function BLACKTtoUSD(uint256 value) public returns (bool success) {
        BLACKT b0 = BLACKT(blcks);
        IERC20 b1 = IERC20(bucks);
        require(online);
        b0.transferFrom(msg.sender,mainWallet,value);
        b1.safeTransferFrom(mainWallet,msg.sender,value);
        emit SwapToUSDT(msg.sender,value);
        
        return true;
    }

    function AutoInvestUSD(uint256 investment) public returns (bool success) {
        BLACKT b0 = BLACKT(blcks);
        IERC20 b1 = IERC20(bucks);
        require(online);
        b1.safeTransferFrom(msg.sender,mainWallet,investment);
        b0.lockLiquidity(msg.sender, investment);   
        investments[msg.sender].push(deposits(investment,false,block.timestamp));
        return true;
    }

    function AutoUnlock() public returns (bool success) {
        require(online);
        BLACKT b = BLACKT(blcks);
        for (uint256 j=0; j < investments[msg.sender].length; j++){
            if (block.timestamp-investments[msg.sender][j].date>period && !investments[msg.sender][j].payed) {
                if (b.unlockLiquidity(msg.sender, investments[msg.sender][j].amount)) {
                    b.transferFrom(mainWallet,msg.sender,investments[msg.sender][j].amount*APY/100);
                    investments[msg.sender][j].payed = true;
                }
            }
        }
        return true;
    }

    function zChangeAPY(uint256 newAPY) onlyOwner public returns (bool success) {
        APY = newAPY;
        return true;
    }

    function zChangePeriod(uint256 newPeriod) onlyOwner public returns (bool success) {
        period = newPeriod;
        return true;
    }

    function zChangeBucks(address newBucks) onlyOwner public returns (bool success) {
        bucks = newBucks;
        return true;
    }

    function zChangeBlcks(address newBlcks) onlyOwner public returns (bool success) {
        blcks = newBlcks;
        return true;
    }

    function zChangeOnlineState(bool state) onlyOwner public returns (bool success) {
        online = state;
        return true;
    }

    function zChangeMainWallet(address newWallet) onlyOwner public returns (bool success) {
        mainWallet = newWallet;
        return true;
    }
}



