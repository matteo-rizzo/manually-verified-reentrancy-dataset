
contract C {
    mapping (address => uint256) public balances;

    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        unchecked {
            balances[msg.sender] -= amt;
        }
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}
