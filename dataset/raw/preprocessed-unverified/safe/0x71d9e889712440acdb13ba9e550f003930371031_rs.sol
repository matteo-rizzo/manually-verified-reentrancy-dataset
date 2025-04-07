/**
 *Submitted for verification at Etherscan.io on 2020-07-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.16;
















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
    bool public breaker = false;
    // Supply tracks the number of `want` that we have lent out of other distro's
    uint public supply = 0;
    
    constructor(address _controller) public {
        governance = msg.sender;
        controller = _controller;
    }
    
    function setBreaker(bool _breaker) public {
        require(msg.sender == governance, "!governance");
        breaker = _breaker;
    }
    
    function deposit() external {
        require(breaker == false, "!breaker");
        uint _balance = IERC20(want).balanceOf(address(this));
        uint _usdc = _balance.div(2);
        IERC20(want).safeApprove(mUSD, 0);
        IERC20(want).safeApprove(mUSD, _usdc);
        
        uint _before = _balance;
        MStable(mUSD).mint(want,_usdc);
        uint _after = IERC20(want).balanceOf(address(this));
        supply = supply.add(_before.sub(_after));
        
        uint _musd = IERC20(mUSD).balanceOf(address(this));
        
        uint _total = IERC20(balancer).totalSupply();
        uint _balancerMUSD = IERC20(mUSD).balanceOf(balancer);
        uint _poolAmountMUSD = _musd.mul(_total).div(_balancerMUSD);
        
        uint _balancerUSDC = IERC20(want).balanceOf(balancer);
        uint _poolAmountUSDC = _usdc.mul(_total).div(_balancerUSDC);
        
        uint _poolAmountOut = _poolAmountMUSD;
        if (_poolAmountUSDC < _poolAmountOut) {
            _poolAmountOut = _poolAmountUSDC;
        }
        
        IERC20(want).safeApprove(balancer, 0);
        IERC20(want).safeApprove(balancer, _usdc);
        IERC20(mUSD).safeApprove(balancer, 0);
        IERC20(mUSD).safeApprove(balancer, _musd);
        
        uint[] memory _maxAmountIn = new uint[](2);
        _maxAmountIn[0] = _musd;
        _maxAmountIn[1] = _usdc;
        _before = IERC20(want).balanceOf(address(this));
        Balancer(balancer).joinPool(_poolAmountOut, _maxAmountIn);
        _after = IERC20(want).balanceOf(address(this));
        supply = supply.add(_before.sub(_after));
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
            uint _withdrew = _withdrawSome(_amount.sub(_balance));
            _amount = _withdrew.add(_balance);
        }
        
        /*
        
        
        address _vault = Controller(controller).vaults(want);
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, _amount);
        
        */
        
        IERC20(want).safeTransfer(controller, _amount);
    }
    
    function redeem() external {
        MStable(mUSD).redeem(want, normalize(IERC20(mUSD).balanceOf(address(this))));
    }
    
    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();
        balance = IERC20(want).balanceOf(address(this));
        
        /*
        
        address _vault = Controller(controller).vaults(want);
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
        
        */
        
        IERC20(want).safeTransfer(controller, balance);
    }
    
    function _withdrawAll() internal {
        uint _bpt = IERC20(balancer).balanceOf(address(this));
        uint[] memory _minAmountOut = new uint[](2);
        _minAmountOut[0] = 0;
        _minAmountOut[1] = 0;
        uint _before = IERC20(want).balanceOf(address(this));
        Balancer(balancer).exitPool(_bpt, _minAmountOut);
        uint _after = IERC20(want).balanceOf(address(this));
        uint _diff = _after.sub(_before);
        if (_diff > supply) {
            // Pool made too much profit, so we reset to 0 to avoid revert
            supply = 0;
        } else {
            supply = supply.sub(_after.sub(_before));
        }
        uint _musd = IERC20(mUSD).balanceOf(address(this));
        
        // This one is the exception because it assumes we can redeem 1 USDC
        _diff = normalize(_musd);
        if (_diff > supply) {
            // Pool made too much profit, so we reset to 0 to avoid revert
            supply = 0;
        } else {
            supply = supply.sub(_diff);
        }
        MStable(mUSD).redeem(want, normalize(_musd));
    }
    
    function _withdrawSome(uint256 _amount) internal returns (uint) {
        uint _totalSupply = IERC20(balancer).totalSupply();
        uint _redeem = _totalSupply.mul(_amount.div(2)).div(IERC20(want).balanceOf(balancer));
        if (_redeem > IERC20(balancer).balanceOf(address(this))) {
            _redeem = IERC20(balancer).balanceOf(address(this));
        }
        uint[] memory _minAmountOut = new uint[](2);
        _minAmountOut[0] = 0;
        _minAmountOut[1] = 0;
        uint _before = IERC20(want).balanceOf(address(this));
        uint _mBefore = IERC20(mUSD).balanceOf(address(this));
        Balancer(balancer).exitPool(_redeem, _minAmountOut);
        uint _mAfter = IERC20(mUSD).balanceOf(address(this));
        uint _musd = _mAfter.sub(_mBefore);
        uint _after = IERC20(want).balanceOf(address(this));
        uint _withdrew = _after.sub(_before);
        
        if (_withdrew > supply) {
            // Pool made too much profit, so we reset to 0 to avoid revert
            supply = 0;
        } else {
            supply = supply.sub(_withdrew);
        }
        _before = IERC20(want).balanceOf(address(this));
        if (normalize(_musd) > supply) {
            // Pool made too much profit, so we reset to 0 to avoid revert
            supply = 0;
        } else {
            supply = supply.sub(normalize(_musd));
        }
        MStable(mUSD).redeem(want, normalize(_musd));
        _after = IERC20(want).balanceOf(address(this));
        _withdrew = _withdrew.add(_after.sub(_before));
        uint _fee = _amount.mul(5).div(1000);
        _amount = _amount.sub(_fee);
        if (_withdrew > _amount) {
            _withdrew = _amount;
        }
        return _withdrew;
    }
    
    function normalize(uint _amount) public view returns (uint) {
        return _amount.mul(10**IERC20(want).decimals()).div(10**IERC20(mUSD).decimals());
    }
    
    function balanceOf() public view returns (uint) {
        return IERC20(want).balanceOf(address(this))
                .add(supply);
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