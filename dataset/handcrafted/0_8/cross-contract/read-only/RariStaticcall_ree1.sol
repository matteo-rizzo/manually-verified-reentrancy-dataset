// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAlpha {
    function totalETHView() external returns (uint256);
    function totalSupplyView() external returns (uint256);
    function work(address strategy) external payable;
}

interface IStrategy {
    function execute() external;
}

interface IRari {
    function withdraw() external returns (uint256);
}


// CONTROL FLOW: A.execute() -> LOOP { V.withdraw() -> A.receive() -> O.work() -> A.execute() -> V.withdraw() ... }

contract A is IRari {
    IAlpha public alpha;
    bool private flag;

    constructor(address _alpha) {
        alpha = IAlpha(_alpha);
    }

    modifier mod() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    function withdraw() mod external returns (uint256) {
        (bool success, bytes memory data) = address(alpha).staticcall("totalETHView");
        require(success, "Staticcall failed");
        uint256 t1 = abi.decode(data, (uint256));
        
        (success, data) = address(alpha).staticcall("totalSupplyView");
        require(success, "Staticcall failed");
        uint256 t2 = abi.decode(data, (uint256));
        
        uint256 rate = t1 * 1e18 / t2;
        uint256 amountETH = rate * 1000 / 1e18;

        (success, ) = payable(msg.sender).call{value: amountETH}("");
        require (success, "Failed to withdraw ETH");

        return amountETH;
    }

    receive() external payable {}
}

// this is the VULNERABLE CONTRACT
contract B is IAlpha {
    uint256 public totalETH;
    uint256 public totalSupply;

    function work(address strategy) external payable {
        totalETH += msg.value;
        IStrategy(strategy).execute();
        totalSupply += msg.value;
    }

    function totalETHView() external view returns (uint256) {
        return totalETH;
    }
    function totalSupplyView() external view returns (uint256) {
        return totalSupply;
    }
}

/*
contract C is IStrategy {
    IRari public rari;
    IAlpha public alpha;

    constructor(address _rari, address _alpha) {
        rari = IRari(_rari);
        alpha = IAlpha(_alpha);
    }

    function execute() external {
        rari.withdraw();
    }

    receive() external payable {
        alpha.work(address(this));
    }
}*/