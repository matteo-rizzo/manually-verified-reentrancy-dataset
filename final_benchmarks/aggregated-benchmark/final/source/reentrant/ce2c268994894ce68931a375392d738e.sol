contract SimpleDAO {
    mapping(address => uint) public credit;

    function donate(address to) public payable {
        credit[to] += msg.value;
    }

    function withdraw(uint amount) public {
        if (credit[msg.sender] >= amount) {
            require(msg.sender.call.value(amount)());
            credit[msg.sender] -= amount;
        }
    }

    function queryCredit(address to) public view returns (uint) {
        return credit[to];
    }
}
