
contract C {
    mapping (address => uint256) public balances;

    event Transfer(uint256 amt);

    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[msg.sender] -= amt;
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        emit Transfer(amt);
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}
