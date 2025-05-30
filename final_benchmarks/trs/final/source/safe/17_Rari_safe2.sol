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
    bool private flag;

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    function work(address strategy) nonReentrant external payable {
        totalETH += msg.value;
        IStrategy(strategy).execute();
        totalSupply += msg.value;
    }

    function totalETHView() nonReentrant external returns (uint256) {
        return totalETH;
    }
    function totalSupplyView() nonReentrant external returns (uint256) {
        return totalSupply;
    }
}
