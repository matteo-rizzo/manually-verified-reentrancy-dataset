pragma solidity ^0.5.17;









contract StakingRewardsPool {
    using SafeERC20 for IERC20;
    using Address for address;
    
    address public governance;
    address public controller;

    constructor(address _controller) public {
        governance = msg.sender;
        controller = _controller;
    }
    
    function getName() external pure returns (string memory) {
        return "StakingRewardsPool";
    }

    function balanceOf(address _token) public view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }
    
    function withdrawToken(address _token, uint256 _amount) external {
        require(msg.sender == Controller(controller).strategies(_token), "!strategies");
        IERC20(_token).safeTransfer(msg.sender, _amount);
    }

    function withdrawAll(address _token) external {
        require(msg.sender == governance, "!governance");
        uint _balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, _balance);
    }
}