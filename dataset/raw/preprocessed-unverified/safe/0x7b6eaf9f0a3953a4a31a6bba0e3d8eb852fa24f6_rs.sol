/**
 *Submitted for verification at Etherscan.io on 2020-10-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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


// 


// 


// 


// 




// 


// 
// NOTE: Basically an alias for Vaults


// 


contract StrategyCurveGUSDProxy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public constant want = address(0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd); // GUSD
    address public constant gusd3CRV = address(0xD2967f45c4f384DEEa880F807Be904762a3DeA07);
    address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant uni = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // used for crv <> weth <> dai route

    address public constant dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    CurveDeposit public constant curveDeposit = CurveDeposit(0x0aE274c98c0415C0651AF8cF52b010136E4a0082);

    address public constant gauge = address(0xC5cfaDA84E902aD92DD40194f0883ad49639b023);
    address public constant voter = address(0xF147b8125d2ef93FB6965Db97D6746952a133934);
    
    ICurveFi public constant SWAP = ICurveFi(0x4f062658EaAF2C1ccf8C8e36D6824CDf41167956);

    uint256 public keepCRV = 1000;
    uint256 public performanceFee = 450;
    uint256 public strategistReward = 50;
    uint256 public withdrawalFee = 50;
    uint256 public constant FEE_DENOMINATOR = 10000;

    address public proxy;

    address public governance;
    address public controller;
    address public strategist;

    uint256 public earned;  // lifetime strategy earnings denominated in `want` token

    event Harvested(uint wantEarned, uint lifetimeEarned);

    constructor(address _controller, address _governance) public {
        governance = _governance;
        strategist = msg.sender;
        controller = _controller;
    }

    function getName() external pure returns (string memory) {
        return "StrategyCurveGUSDProxy";
    }

    function setStrategist(address _strategist) external {
        require(msg.sender == governance || msg.sender == strategist, "!authorized");
        strategist = _strategist;
    }

    function setKeepCRV(uint256 _keepCRV) external {
        require(msg.sender == governance, "!governance");
        keepCRV = _keepCRV;
    }

    function setWithdrawalFee(uint256 _withdrawalFee) external {
        require(msg.sender == governance, "!governance");
        withdrawalFee = _withdrawalFee;
    }

    function setPerformanceFee(uint256 _performanceFee) external {
        require(msg.sender == governance, "!governance");
        performanceFee = _performanceFee;
    }

    function setStrategistReward(uint _strategistReward) external {
        require(msg.sender == governance, "!governance");
        strategistReward = _strategistReward;
    }

    function setProxy(address _proxy) external {
        require(msg.sender == governance, "!governance");
        proxy = _proxy;
    }

    function deposit() public {
        uint _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            IERC20(want).safeApprove(address(curveDeposit), 0);
            IERC20(want).safeApprove(address(curveDeposit), _want);
            curveDeposit.add_liquidity([_want,0,0,0], 0); // Dangerous to not add a min_mint_amount 
        }
        uint256 _gusd3CRV = IERC20(gusd3CRV).balanceOf(address(this));
        if (_gusd3CRV > 0) {
            IERC20(_gusd3CRV).safeTransfer(proxy, _gusd3CRV);
            VoterProxy(proxy).deposit(gauge, gusd3CRV);
        }
    }

    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        require(gusd3CRV != address(_asset), "gusd3CRV");
        require(crv != address(_asset), "crv");
        require(dai != address(_asset), "dai");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }

    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint256 _amount) external {
        require(msg.sender == controller, "!controller");
        uint256 _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        uint256 _fee = _amount.mul(withdrawalFee).div(FEE_DENOMINATOR);

        IERC20(want).safeTransfer(IController(controller).rewards(), _fee);
        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
    }

    function _withdrawSome(uint256 _amount) internal returns (uint256) {
        uint _withdrawn = VoterProxy(proxy).withdraw(gauge, gusd3CRV, _amount);
        IERC20(gusd3CRV).safeApprove(address(curveDeposit), 0);
        IERC20(gusd3CRV).safeApprove(address(curveDeposit), _withdrawn);
        uint _before = IERC20(want).balanceOf(address(this));
        curveDeposit.remove_liquidity_one_coin(_withdrawn, 0, 0); // Need a withdraw fallback, but GUSD needs more liquidity first
        uint _after = IERC20(want).balanceOf(address(this));
        return _after.sub(_before);
    }

    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint256 balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();

        balance = IERC20(want).balanceOf(address(this));

        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }

    function _withdrawAll() internal {
        VoterProxy(proxy).withdrawAll(gauge, want);
        IERC20(gusd3CRV).safeApprove(address(curveDeposit), 0);
        IERC20(gusd3CRV).safeApprove(address(curveDeposit), IERC20(gusd3CRV).balanceOf(address(this)));
        curveDeposit.remove_liquidity_one_coin(IERC20(gusd3CRV).balanceOf(address(this)), 0, 0); // Can have massive slippage, incredibly dangerous
    }

    function harvest() public {
        require(msg.sender == strategist || msg.sender == governance || msg.sender == tx.origin, "!authorized");
        VoterProxy(proxy).harvest(gauge);
        uint256 _crv = IERC20(crv).balanceOf(address(this));
        if (_crv > 0) {
            uint256 _keepCRV = _crv.mul(keepCRV).div(FEE_DENOMINATOR);
            IERC20(crv).safeTransfer(voter, _keepCRV);
            _crv = _crv.sub(_keepCRV);

            IERC20(crv).safeApprove(uni, 0);
            IERC20(crv).safeApprove(uni, _crv);

            address[] memory path = new address[](3);
            path[0] = crv;
            path[1] = weth;
            path[2] = dai;

            Uni(uni).swapExactTokensForTokens(_crv, uint256(0), path, address(this), now.add(1800));
        }
        uint256 _dai = IERC20(dai).balanceOf(address(this));
        if (_dai > 0) {
            IERC20(dai).safeApprove(address(curveDeposit), 0);
            IERC20(dai).safeApprove(address(curveDeposit), _dai);
            curveDeposit.add_liquidity([0, _dai, 0, 0], 0);
        }
        uint256 _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            uint256 _fee = _want.mul(performanceFee).div(FEE_DENOMINATOR);
            uint256 _reward = _want.mul(strategistReward).div(FEE_DENOMINATOR);
            IERC20(want).safeTransfer(IController(controller).rewards(), _fee);
            IERC20(want).safeTransfer(strategist, _reward);
            deposit();
        }
        VoterProxy(proxy).lock();
        earned = earned.add(_want);
        emit Harvested(_want, earned);
    }

    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    function balanceOfPoolInWant() public view returns (uint256) {
        return balanceOfPool().mul(SWAP.get_virtual_price()).div(1e18);
    }

    function balanceOfPool() public view returns (uint256) {
        return VoterProxy(proxy).balanceOf(gauge);
    }

    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(balanceOfPoolInWant());
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