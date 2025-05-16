
contract C {
    mapping (address => uint256) public balances;
    mapping (address => bool) private done;

    function withdrawOnlyOnce(uint256 amt) public {
        require(!done[msg.sender], "Not allowed!");
        require(balances[msg.sender] >= amt, "Insufficient funds");
        done[msg.sender] = true;
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] -= amt;    
        done[msg.sender] = success;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}
