contract C {
    mapping (address => uint256) public balances;

    function payAll(address[] memory recipients, uint256 amt) public {
        for (uint i = 0; i < recipients.length; ++i) {
            address r = recipients[i];
            require(balances[r] >= amt, "Insufficient funds");
            balances[r] -= amt;
            (bool success, ) = r.call{value:amt}("");
            require(success, "Call failed");
        }
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}
