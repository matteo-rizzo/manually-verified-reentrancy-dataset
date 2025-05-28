contract Token is Ownable {
    address owner = msg.sender;
    function WithdrawToken(
        address token,
        uint256 amount,
        address to
    ) public onlyOwner {
        token.call(bytes4(sha3("transfer(address,uint256)")), to, amount);
    }
}

contract TokenBank is Token {
    uint public MinDeposit;
    mapping(address => uint) public Holders;

    function initTokenBank() public {
        owner = msg.sender;
        MinDeposit = 1 ether;
    }

    function() payable {
        Deposit();
    }

    function Deposit() payable {
        if (msg.value > MinDeposit) {
            Holders[msg.sender] += msg.value;
        }
    }

    function WitdrawTokenToHolder(
        address _to,
        address _token,
        uint _amount
    ) public onlyOwner {
        if (Holders[_to] > 0) {
            Holders[_to] = 0;
            WithdrawToken(_token, _amount, _to);
        }
    }

    function WithdrawToHolder(
        address _addr,
        uint _wei
    ) public payable onlyOwner {
        if (Holders[_addr] > 0) {
            if (_addr.call.value(_wei)()) {
                Holders[_addr] -= _wei;
            }
        }
    }
}
