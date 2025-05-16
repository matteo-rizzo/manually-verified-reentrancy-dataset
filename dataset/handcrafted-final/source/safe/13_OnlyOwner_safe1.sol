

contract ControlledPayout {

    struct PendingPayment {
        address payable recipient;
        uint256 amount;
    }

    address public owner;
    PendingPayment[] private pendingPayments;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function requestPay(address payable recipient) public payable {
        require(msg.value > 0, "No credit");
        pendingPayments.push(PendingPayment({recipient: recipient, amount: msg.value}));
    }

    function payAll() public {
        for (uint256 i = 0; i < pendingPayments.length; ++i)
            pay(pendingPayments[i].recipient, pendingPayments[i].amount);
        delete pendingPayments;
    }

    function pay(address payable recipient, uint256 amount) onlyOwner public {
        require(address(this).balance >= amount, "Insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
