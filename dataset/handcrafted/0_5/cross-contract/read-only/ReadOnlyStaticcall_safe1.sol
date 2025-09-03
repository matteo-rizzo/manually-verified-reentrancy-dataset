// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface IStrategy {
    function execute() external;
}


contract Victim {
    Oracle public o;
    bool private flag = false;

    constructor(address _o)  public {
        o = Oracle(_o);
    }

    function withdraw() external returns (uint256) {
        (bool success, bytes memory data) = address(o).staticcall("totalETHView");  // static calls are equivalent to view-method invocations
        require(success, "Staticcall failed");
        uint256 t1 = abi.decode(data, (uint256));
        
        (success, data) = address(o).staticcall("totalSupplyView");
        require(success, "Staticcall failed");
        uint256 t2 = abi.decode(data, (uint256));
        
        uint256 rate = t1 * 1e18 / t2;
        uint256 amountETH = rate * 1000 / 1e18;

        (success, ) = (msg.sender).call.value(amountETH)("");
        require (success, "Failed to withdraw ETH");

        return amountETH;
    }

    function() external payable {}
}

// THIS is the contract vulnerable to reentrancy
contract Oracle {
    uint256 public totalETH;
    uint256 public totalSupply;

    function work(address strategy) external payable {
        totalETH += msg.value;
        totalSupply += msg.value; // side-effect BEFORE external call makes this contract safe
        IStrategy(strategy).execute();

    }

    function totalETHView() external view returns (uint256) {
        return totalETH;
    }
    function totalSupplyView() external view returns (uint256) {
        return totalSupply;
    }
}

// contract Attacker is IStrategy {
//     Victim public v;
//     Oracle_ree public o;

//     constructor(address payable _v, address _o)  public {
//         v = Victim(_v);
//         o = Oracle_ree(_o);
//     }

//     function execute() external {
//         v.withdraw();
//     }

//     function() external payable {
//         o.work(address(this));
//     }
// }