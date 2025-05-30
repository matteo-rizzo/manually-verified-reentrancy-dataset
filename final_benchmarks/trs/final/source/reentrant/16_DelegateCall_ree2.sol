contract C {
    address public logic;
    mapping(address => uint256) public balances;
    bool private flag;

    modifier nonReentrant() {
        flag = true;
        _;
        flag = false;
    }

    constructor(address _logic) {
        logic = _logic;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() nonReentrant external {
        (bool success, ) = logic.delegatecall(abi.encodeWithSignature("withdraw(address)", msg.sender));
        require(success, "delegatecall failed");
    }

}
