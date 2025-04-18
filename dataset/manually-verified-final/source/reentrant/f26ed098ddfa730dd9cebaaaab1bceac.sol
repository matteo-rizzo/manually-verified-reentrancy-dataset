contract Reentrance {
    mapping(address => uint256) userBalance;

    function getBalance(address u) public view returns (uint) {
        return userBalance[u];
    }

    function addToBalance() public payable {
        userBalance[msg.sender] += msg.value;
    }

    function withdrawBalance() public {
        bool flag;
        bytes memory data;

        (flag, data) = msg.sender.call.value(userBalance[msg.sender])("");
        if (!flag) {
            revert();
        }
        userBalance[msg.sender] = 0;
    }
}
