/**
 *Submitted for verification at Etherscan.io on 2020-12-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;



/**
 * @dev Standard math utilities missing in the Solidity language.
 */


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */















contract StrategyCurveYCRVVoter {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address constant public want = address(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);
    address constant public pool = address(0xFA712EE4788C042e2B7BB55E6cb8ec569C4530c1);
    address constant public mintr = address(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);
    address constant public crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address constant public uni = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // used for crv <> weth <> dai route
    
    address constant public dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant public ydai = address(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01);
    address constant public curve = address(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
    
    uint public keepCRV = 1000;
    uint constant public keepCRVMax = 10000;
    
    uint public performanceFee = 30000;
    uint constant public performanceMax = 30000;
    
    uint public withdrawalFee = 50;
    uint constant public withdrawalMax = 10000;
    
    address public governance;
    address public controller;
    address public strategist;
    
    constructor(address _controller) public {
        governance = msg.sender;
        strategist = msg.sender;
        controller = _controller;
    }
    
    function getName() external pure returns (string memory) {
        return "StrategyCurveYCRVVoter";
    }
    
    function setStrategist(address _strategist) external {
        require(msg.sender == governance, "!governance");
        strategist = _strategist;
    }
    
    function setKeepCRV(uint _keepCRV) external {
        require(msg.sender == governance, "!governance");
        keepCRV = _keepCRV;
    }
    
    function setWithdrawalFee(uint _withdrawalFee) external {
        require(msg.sender == governance, "!governance");
        withdrawalFee = _withdrawalFee;
    }
    
    function setPerformanceFee(uint _performanceFee) external {
        require(msg.sender == governance, "!governance");
        performanceFee = _performanceFee;
    }
    
    function deposit() public {
        uint _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            IERC20(want).safeApprove(pool, 0);
            IERC20(want).safeApprove(pool, _want);
            Gauge(pool).deposit(_want);
        }
        
    }
    
    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        require(crv != address(_asset), "crv");
        require(ydai != address(_asset), "ydai");
        require(dai != address(_asset), "dai");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }
    
    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint _amount) external {
        require(msg.sender == controller, "!controller");
        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
        
        uint _fee = _amount.mul(withdrawalFee).div(withdrawalMax);
        
        IERC20(want).safeTransfer(IController(controller).rewards(), _fee);
        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        
        IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
    }
    
    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();
        
        
        balance = IERC20(want).balanceOf(address(this));
        
        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }
    
    function _withdrawAll() internal {
        Gauge(pool).withdraw(Gauge(pool).balanceOf(address(this)));
    }
    
    function harvest() public {
        require(msg.sender == strategist || msg.sender == governance, "!authorized");
        Mintr(mintr).mint(pool);
        uint _crv = IERC20(crv).balanceOf(address(this));
        if (_crv > 0) {
            
            uint256 _daiBalanceOld = IERC20(dai).balanceOf(address(this));
            IERC20(crv).safeApprove(uni, 0);
            IERC20(crv).safeApprove(uni, _crv);
            
            address[] memory path = new address[](3);
            path[0] = crv;
            path[1] = weth;
            path[2] = dai;
            
            Uni(uni).swapExactTokensForTokens(_crv, 1, path, address(this), block.timestamp);

            // notifyProfit(daiBalanceBefore, IERC20(dai).balanceOf(address(this)));
            uint256 _daiBalanceNew = IERC20(dai).balanceOf(address(this));
            
            if (_daiBalanceNew > _daiBalanceOld) {
                uint256 profit = _daiBalanceNew.sub(_daiBalanceOld);
                
                uint256 feeAmount = profit.mul(3).div(10);
                // emit ProfitLog(oldBalance, _daiBalanceNew, feeAmount, block.timestamp);
                
                IERC20(want).safeTransfer(IController(controller).rewards(), feeAmount);
            } else {
                // emit ProfitLog(oldBalance, _daiBalanceNew, 0, block.timestamp);
            }

            // liquidate if there is any DAI left
            if(IERC20(dai).balanceOf(address(this)) > 0) {
                // yCurveFromDai();
                uint256 daiBalance = IERC20(dai).balanceOf(address(this));
                if (daiBalance > 0) {
                    IERC20(dai).safeApprove(ydai, 0);
                    IERC20(dai).safeApprove(ydai, daiBalance);
                    yERC20(ydai).deposit(daiBalance);
                }
                uint256 yDaiBalance = IERC20(ydai).balanceOf(address(this));
                if (yDaiBalance > 0) {
                    IERC20(ydai).safeApprove(curve, 0);
                    IERC20(ydai).safeApprove(curve, yDaiBalance);
                    // we can accept 0 as minimum, this will be called only by trusted roles
                    uint256 minimum = 0;
                    ICurveFi(curve).add_liquidity([yDaiBalance, 0, 0, 0], minimum);
                }
            }
        }

        uint256 wantBalance = IERC20(want).balanceOf(address(this));
        if (wantBalance > 0) {
            IERC20(want).safeApprove(pool, 0);
            IERC20(want).safeApprove(pool, wantBalance);
            Gauge(pool).deposit(wantBalance);
        }
        // uint _dai = IERC20(dai).balanceOf(address(this));
        // if (_dai > 0) {
        //     IERC20(dai).safeApprove(ydai, 0);
        //     IERC20(dai).safeApprove(ydai, _dai);
        //     yERC20(ydai).deposit(_dai);
        // }
        // uint _ydai = IERC20(ydai).balanceOf(address(this));
        // if (_ydai > 0) {
        //     IERC20(ydai).safeApprove(curve, 0);
        //     IERC20(ydai).safeApprove(curve, _ydai);
        //     ICurveFi(curve).add_liquidity([_ydai,0,0,0],0);
        // }
        // uint _want = IERC20(want).balanceOf(address(this));
        // if (_want > 0) {
        //     uint _fee = _want.mul(performanceFee).div(performanceMax);
        //     IERC20(want).safeTransfer(IController(controller).rewards(), _fee);
        //     deposit();
        // }
    }
    
    function _withdrawSome(uint256 _amount) internal returns (uint) {
        Gauge(pool).withdraw(_amount);
        return _amount;
    }
    
    function balanceOfWant() public view returns (uint) {
        return IERC20(want).balanceOf(address(this));
    }
    
    function balanceOfPool() public view returns (uint) {
        return Gauge(pool).balanceOf(address(this));
    }
    
    function balanceOf() public view returns (uint) {
        return balanceOfWant()
               .add(balanceOfPool());
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