interface IAlpha {
    function totalETHView() external view returns (uint256);
    function totalSupplyView() external view returns (uint256);
    function work(address strategy) external payable;
}

interface IStrategy {
    function execute() external;
}

interface IRari {
    function withdraw() external returns (uint256);
}

contract A is IRari {
    IAlpha public alpha;

    constructor(address _alpha) {
        alpha = IAlpha(_alpha);
    }

    function withdraw() external returns (uint256) {
        uint256 rate = alpha.totalETHView() * 1e18 / alpha.totalSupplyView();
        uint256 amountETH = rate * 1000 / 1e18;

        (bool success, ) = payable(msg.sender).call{value: amountETH}("");
        require (success, "Failed to withdraw ETH");

        return amountETH;
    }

    receive() external payable {}
}

contract B is IAlpha {
    uint256 public totalETH;
    uint256 public totalSupply;

    function work(address strategy) external payable {
        totalETH += msg.value;
        totalSupply += msg.value;
        IStrategy(strategy).execute();
    }

    function totalETHView() external view returns (uint256) {
        return totalETH;
    }
    function totalSupplyView() external view returns (uint256) {
        return totalSupply;
    }
}
