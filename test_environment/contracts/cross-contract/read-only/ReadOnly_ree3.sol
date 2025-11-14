// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAdjuster {
    function adjust(uint256 inc) external returns (uint256);
}

contract ReadOnly_ree3 {
    ReadOnly_ree3_Oracle public o;
    bool private flag = false;

    event Deposited(address indexed user, uint256 amount);

    constructor(address _o) {
        o = ReadOnly_ree3_Oracle(_o);
    }

    function withdraw() external {
        uint256 amt = getWithdrawableAmount();

        (bool success, ) = payable(msg.sender).call{value: amt}("");
        require(success, "Failed to withdraw ETH");
    }

    function getWithdrawableAmount() public view returns (uint256) {
        return
            o.getUserShare(msg.sender) +
            ((o.getUserShare(msg.sender) * 0.01 ether) / o.total());
    }

    receive() external payable {
        emit Deposited(msg.sender, msg.value);
    }
}

// THIS is the contract vulnerable to reentrancy
contract ReadOnly_ree3_Oracle {
    struct Data {
        uint256 amt;
        IAdjuster adj;
    }

    uint256 public total;
    mapping(address => Data) private userShares;
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function register(address a) public {
        userShares[msg.sender] = Data(0, IAdjuster(a));
    }

    function updateUserShare(address user, uint increment) external onlyOwner {
        userShares[user].amt += increment;
        uint256 a = userShares[user].adj.adjust(increment);
        // putting the side effect of the total AFTER the external call makes the division at line 17 diverge
        total += a + increment;
    }

    function getUserShare(address a) external view returns (uint256) {
        return userShares[a].amt;
    }
}

contract ReadOnly_ree3_DummyAdjuster is IAdjuster {
    uint256 private counter = 1;

    function adjust(uint256 inc) external pure override returns (uint256) {
        return inc * 0;
    }
}
