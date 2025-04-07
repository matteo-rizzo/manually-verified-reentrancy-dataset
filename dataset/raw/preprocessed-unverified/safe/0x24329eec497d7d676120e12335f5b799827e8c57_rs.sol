/**
 *Submitted for verification at Etherscan.io on 2021-08-24
*/

// SPDX-License-Identifier: MIT


pragma solidity 0.8.2;










contract POLCBridgeTransfers is Ownable {

    address payable public bankVault;
    address public polcVault;
    address public polcTokenAddress;
    uint256 public bridgeFee;
    uint256 public gasFee;
    IERC20Token private polcToken;
    POLCProfits public profitsContract;

    uint256 public depositIndex;
    
    struct Deposit {
        address sender;
        uint256 amount;
        uint256 fee;
    } 
    
    mapping (uint256 => Deposit) public deposits;
    mapping (address => bool) public whitelisted;
    uint256 maxTXAmount = 25000 ether;
    
    constructor() {
        polcTokenAddress = 0xaA8330FB2B4D5D07ABFE7A72262752a8505C6B37;
        polcToken = IERC20Token(polcTokenAddress);
        bankVault = payable(0xf7A9F6001ff8b499149569C54852226d719f2D76);
        polcVault = 0xf7A9F6001ff8b499149569C54852226d719f2D76;
        bridgeFee = 1;
        gasFee = (1 gwei)*70000;
        whitelisted[0xf7A9F6001ff8b499149569C54852226d719f2D76] = true;
        whitelisted[0xeA50CE6EBb1a5E4A8F90Bfb35A2fb3c3F0C673ec] = true;
        profitsContract = POLCProfits(0xD7588254A4B16B3A0d4B544b0D0a13523115C140);
    }

    function bridgeSend(uint256 _amount) public payable {
        require((_amount>=(50 ether) && _amount<=(maxTXAmount)), "Invalid amount");
        require(msg.value >= gasFee, "Invalid gas fee");
        uint256 fee;
        if (bridgeFee > 0) {
            fee = (_amount * bridgeFee) /100;  // bridge transaction fee
            profitsContract.addBankEarnings((fee / 20)); //25% of the fees goes to bank hodlers, 5 banks = 5% each
        }
        Address.sendValue(bankVault, msg.value);
        require(polcToken.transferFrom(msg.sender, polcVault, _amount), "ERC20 transfer error");
        deposits[depositIndex].sender = msg.sender;
        deposits[depositIndex].amount = _amount;
        deposits[depositIndex].fee = fee;
        depositIndex += 1;
    }
    
    function platformTransfer(uint256 _amount) public {
        require(whitelisted[msg.sender] == true, "Not allowed");
        require(polcToken.transferFrom(msg.sender, polcVault, _amount), "ERC20 transfer error");
        deposits[depositIndex].sender = msg.sender;
        deposits[depositIndex].amount = _amount;
        deposits[depositIndex].fee = 0;
        depositIndex += 1;
    }
    
    function setBankVault(address _vault) public onlyOwner {
        bankVault = payable(_vault);
    }
    
    function setPOLCVault(address _vault) public onlyOwner {
        polcVault = _vault;
    }
    
    function setFee(uint256 _fee) public onlyOwner {
        bridgeFee = _fee;   
    }
    
    function setProfitsContract(address _contract) public onlyOwner {
        profitsContract = POLCProfits(_contract);
    }

    function setGasFee(uint256 _fee) public onlyOwner {
        gasFee = _fee;
    }
    
    function setMaxTXAmount(uint256 _amount) public onlyOwner {
        maxTXAmount = _amount;
    }
    
    function whitelistWallet(address _wallet, bool _whitelisted) public onlyOwner {
        whitelisted[_wallet] = _whitelisted;
    }

    
}