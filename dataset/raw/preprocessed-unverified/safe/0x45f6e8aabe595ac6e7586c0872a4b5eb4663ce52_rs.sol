/**
 *Submitted for verification at Etherscan.io on 2020-07-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;
















/*

 A strategy must implement the following calls;
 
 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()
 
 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller
 
*/

/*

 Strategy ~ 50% USDC to mUSD
 mUSD+USDC into balancer
 BAL+MTA

*/

contract StrategyBalancerMTA {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address constant public want = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant public mUSD = address(0xe2f2a5C287993345a840Db3B0845fbC70f5935a5);
    address constant public balancer = address(0x72Cd8f4504941Bf8c5a21d1Fd83A96499FD71d2C);
    
    
    address public governance;
    address public controller;
    
    constructor(address _controller) public {
        governance = msg.sender;
        controller = _controller;
    }
    
    function deposit() external {
        uint _balance = IERC20(want).balanceOf(address(this));
        uint _musd = _balance.div(2);
        IERC20(want).safeApprove(mUSD, 0);
        IERC20(want).safeApprove(mUSD, _musd);
        MStable(mUSD).mint(want,_musd);
        uint _total = IERC20(balancer).totalSupply();
        uint _balancerMUSD = IERC20(mUSD).balanceOf(balancer);
        uint _poolAmount = _musd.mul(_total).div(_balancerMUSD);
        IERC20(want).safeApprove(balancer, 0);
        IERC20(want).safeApprove(balancer, _musd);
        IERC20(mUSD).safeApprove(balancer, 0);
        IERC20(mUSD).safeApprove(balancer, _musd);
        Balancer(balancer).joinPool(_poolAmount, [_musd,_musd]);
    }
    
    function inCaseTokensGetStuck(IERC20 _token) external {
        require(msg.sender == governance, "!governance");
        _token.safeTransfer(governance, _token.balanceOf(address(this)));
    }
    
    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(address(_asset) != want, "!c");
        require(address(_asset) != mUSD, "!c");
        require(address(_asset) != balancer, "!c");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }
    
    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint _amount) external {
        require(msg.sender == controller, "!controller");
        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _withdrawSome(_amount.sub(_balance));
        }
        
        IERC20(want).safeTransfer(msg.sender, _amount);
        /*
        address _vault = Controller(controller).vaults(want);
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, _amount);
        */
    }
    
    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();
        balance = IERC20(want).balanceOf(address(this));
        
        
        IERC20(want).safeTransfer(msg.sender, balance);
        /*
        address _vault = Controller(controller).vaults(want);
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
        */
    }
    
    function _withdrawAll() internal {
        uint _bpt = IERC20(balancer).balanceOf(address(this));
        Balancer(balancer).exitPool(_bpt, [uint256(0),0]);
        uint _musd = IERC20(mUSD).balanceOf(address(this));
        MStable(mUSD).redeem(want,_musd);
    }
    
    function _withdrawSome(uint256 _amount) internal {
        uint _usdc = IERC20(want).balanceOf(balancer);
        uint _bpt = IERC20(balancer).balanceOf(address(this));
        uint _redeem = _bpt.mul(_amount).div(_usdc);
        if (_redeem > _bpt) {
            _redeem = _bpt;
        }
        Balancer(balancer).exitPool(_bpt, [uint256(0),0]);
        uint _musd = IERC20(mUSD).balanceOf(address(this));
        MStable(mUSD).redeem(want,_musd);
    }
    
    function balanceOf() public view returns (uint) {
        uint _bpt = IERC20(balancer).balanceOf(address(this));
        uint _totalSupply = IERC20(balancer).totalSupply();
        uint _musd = IERC20(mUSD).balanceOf(balancer);
        uint _usdc = IERC20(want).balanceOf(balancer);
        _usdc = _usdc.mul(_bpt).div(_totalSupply);
        _musd = _musd.mul(_bpt).div(_totalSupply);
        return _usdc.add(_musd)
                    .add(IERC20(want).balanceOf(address(this)))
                    .add(IERC20(mUSD).balanceOf(address(this)));
    }
    
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }
    
    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
}