// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface IAdjuster {
    function adjust(uint256 inc) external returns (uint256);
}

contract Victim {
    Oracle_ree public o;
    bool private flag = false;

    constructor(address _o)  public {
        o = Oracle_ree(_o);
    }

    function withdraw() external {
        uint256 amt = o.getUserShare(msg.sender) / o.total();

        (bool success, ) = (msg.sender).call.value(amt)("");
        require (success, "Failed to withdraw ETH");
    }

    function() external payable {}
}

// THIS is the contract vulnerable to reentrancy
contract Oracle_ree {

    struct Data {
        uint256 amt;
        IAdjuster adj;
    }

    uint256 public total;
    mapping (address => Data) private userShares;
    address private owner;

    constructor(address _owner)  public {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function register(address a) public {
        userShares[msg.sender] = Data (0, IAdjuster(a));
    }

    function updateUserShare(address user, uint inc) onlyOwner external {
        userShares[user].amt += inc;
        uint256 a = userShares[user].adj.adjust(inc);
        // putting the side effect of the total AFTER the external call makes the division at line 17 diverge
        total += a + inc;
    }

    function getUserShare(address a) external view returns (uint256) {
        return userShares[a].amt;
    }

}

// contract Attacker is IAdjuster {
//     Victim public v;
//     Oracle_ree public o;

//     constructor(address payable _v, address _o)  public {
//         v = Victim(_v);
//         o = Oracle_ree(_o);
//     }

//     function attack() public {
//         o.register(address(this));
//     }

//     function adjust(uint256 inc) external  returns (uint256) {
//         v.withdraw();
//         return inc;
//     }

//     function() external payable {}
// }