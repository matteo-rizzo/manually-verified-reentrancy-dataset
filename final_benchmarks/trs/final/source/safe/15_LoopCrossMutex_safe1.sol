contract C {
    mapping (address => uint256) public balances;

    bool private flag;

    function transfer(address to, uint256 amt) public {
        require(!flag, "Locked");
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[to] += amt;
        balances[msg.sender] -= amt;
    }

    function payAll(address[] memory recipients, uint256 amt) public {
        require(!flag, "Locked");
        flag = true;

        for (uint i = 0; i < recipients.length; ++i) {
            address r = recipients[i];
            require(balances[r] >= amt, "Insufficient funds");
            balances[r] -= amt;
            (bool success, ) = r.call{value:amt}("");
            require(success, "Call failed");
        }

        flag = false;
    }

    function deposit() public payable {
        require(!flag, "Locked");
        balances[msg.sender] += msg.value;       
    }

}
