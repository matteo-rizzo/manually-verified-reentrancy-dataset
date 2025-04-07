/**
 *Submitted for verification at Etherscan.io on 2020-10-28
*/

pragma solidity ^0.5.17;















contract StrategyStakingWING {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address constant public want = address(0xcB3df3108635932D912632ef7132d03EcFC39080);
    
    uint256 public constant DURATION = 30 days;

    uint256 public lastUpdateTime;

    uint256 public amountLocked = 0;
    uint256 public rewards = 0;

    uint public withdrawalFee = 50;
    uint constant public withdrawalMax = 10000;

    uint public rewardRate = 35;
    uint constant public rewardRateMax = 10000;
    
    address public governance;
    address public controller;
    address public strategist;
    address public rewardsPool = address(0xB6eCc90cC20959Fcf0083bF353977c52e48De2c4);
    
    modifier updateReward() {
        rewards = earned();
        lastUpdateTime = currentTime();
        _;
    }

    constructor(address _controller) public {
        governance = msg.sender;
        controller = _controller;
    }
    
    function getName() external pure returns (string memory) {
        return "StrategyStakingWING";
    }

    function currentTime() public view returns (uint256) {
        return block.timestamp;
    }

    function earned() public view returns (uint256) {
        return
            amountLocked
                .mul(currentTime() - lastUpdateTime)
                .div(DURATION)
                .mul(rewardRate).div(rewardRateMax)
                .add(rewards);
    }

    function deposit() public updateReward {
        amountLocked = IERC20(want).balanceOf(address(this));
    }
    
    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint _amount) external updateReward {
        require(msg.sender == controller, "!controller");

        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        
        uint _rewardToUser = _amount.mul(earned()).div(balanceOfWant());
        rewards = rewards - _rewardToUser;
        
        StakingRewardsPool(rewardsPool).withdrawToken(want, _rewardToUser);

        uint _fee = _rewardToUser.mul(withdrawalFee).div(withdrawalMax);
        
        IERC20(want).safeTransfer(Controller(controller).rewards(), _fee);
        
        IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
        
        amountLocked = balanceOfWant();
    }
    
    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external updateReward returns (uint balance) {
        require(msg.sender == controller, "!controller");
        
        StakingRewardsPool(rewardsPool).withdrawToken(want, rewards);
        rewards = 0;
        balance = IERC20(want).balanceOf(address(this));
        
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }

    function balanceOfWant() public view returns (uint) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOf() public view returns (uint) {
        return balanceOfWant() + earned();
    }
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }
    
    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }

    function setRewardsPool(address _rewardsPool) external {
        require(msg.sender == governance, "!governance");
        rewardsPool = _rewardsPool;
    }

    function setWithdrawalFee(uint _withdrawalFee) external {
        require(msg.sender == governance, "!governance");
        withdrawalFee = _withdrawalFee;
    }

    function setRewardRate(uint _rewardRate) external {
        require(msg.sender == governance, "!governance");
        rewardRate = _rewardRate;
    }
}