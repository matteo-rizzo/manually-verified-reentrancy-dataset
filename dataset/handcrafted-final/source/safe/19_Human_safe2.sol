contract C {
    mapping (address => uint256) public balances;

    modifier isHuman() {
        require(tx.origin != msg.sender, "Not EOA");
        _;
    }

    function transfer(address to, uint256 amt) isHuman() public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[msg.sender] -= amt;
        (bool success, ) = to.call{value:amt}("");
        require(success, "Call failed");
    }

    function deposit() isHuman() public payable {
        balances[msg.sender] += msg.value;       
    }

}
