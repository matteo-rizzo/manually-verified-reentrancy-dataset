
contract C {
    mapping (address => uint256) public balances;

    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[msg.sender] -= amt;
        payable(msg.sender).transfer(amt);
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}
