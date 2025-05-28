contract ModifierEntrancy {
    mapping(address => uint) public tokenBalance;
    string constant name = "Nu Token";
    Bank bank;

    constructor() public {
        bank = new Bank();
    }

    function airDrop() public hasNoBalance supportsToken {
        tokenBalance[msg.sender] += 20;
    }

    modifier supportsToken() {
        require(
            keccak256(abi.encodePacked("Nu Token")) == bank.supportsToken()
        );
        _;
    }

    modifier hasNoBalance() {
        require(tokenBalance[msg.sender] == 0);
        _;
    }
}

contract Bank {
    function supportsToken() external returns (bytes32) {
        return keccak256(abi.encodePacked("Nu Token"));
    }
}
