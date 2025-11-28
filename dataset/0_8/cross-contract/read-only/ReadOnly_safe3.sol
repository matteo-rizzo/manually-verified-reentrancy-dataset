// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAdjuster {
    function adjust(uint256 inc) external returns (uint256);
}

contract ReadOnly_safe2 {
    ReadOnly_safe2_Oracle public o;
    bool private flag = false;

    constructor(address _o) {
        o = ReadOnly_safe2_Oracle(_o);
    }

    function withdraw() external {
        uint256 amt = o.getUserShare(msg.sender) / o.getTotal();

        (bool success, ) = payable(msg.sender).call{value: amt}("");
        require(success, "Failed to withdraw ETH");
    }

    receive() external payable {}
}

// THIS is the contract vulnerable to reentrancy
contract ReadOnly_safe2_Oracle {
    struct Data {
        uint256 amt;
        IAdjuster adj;
    }

    uint256 private total;
    mapping(address => Data) private userShares;
    address private owner;
    bool private flag;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    modifier nonReentrantView() {
        require(!flag, "Locked");
        _;
    }

    function register(address a) public nonReentrant {
        userShares[msg.sender] = Data(0, IAdjuster(a));
    }

    function updateUserShare(
        address user,
        uint inc
    ) external onlyOwner nonReentrant {
        userShares[user].amt += inc;
        uint256 a = userShares[user].adj.adjust(inc);
        // putting the side effect of the total AFTER the external call makes the division at line 17 diverge
        total += a + inc;
    }

    function getUserShare(
        address a
    ) external view nonReentrantView returns (uint256) {
        return userShares[a].amt;
    }

    function getTotal() external view nonReentrantView returns (uint256) {
        return total;
    }
}
