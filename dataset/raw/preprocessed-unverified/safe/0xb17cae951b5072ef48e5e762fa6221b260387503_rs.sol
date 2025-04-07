/**
 *Submitted for verification at Etherscan.io on 2020-07-27
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

contract StrategyMStableSavings {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address constant public want = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant public mUSD = address(0xe2f2a5C287993345a840Db3B0845fbC70f5935a5);
    address constant public mSave = address(0xcf3F73290803Fc04425BEE135a4Caeb2BaB2C2A1);

    address public governance;
    address public controller;
    
    constructor(address _controller) public {
        governance = msg.sender;
        controller = _controller;
    }
    
    function deposit() external {
        IERC20(want).safeApprove(address(mUSD), 0);
        IERC20(want).safeApprove(address(mUSD), IERC20(want).balanceOf(address(this)));
        MStable(mUSD).mint(want, IERC20(want).balanceOf(address(this)));
        IERC20(mUSD).safeApprove(address(mSave), 0);
        IERC20(mUSD).safeApprove(address(mSave), IERC20(mUSD).balanceOf(address(this)));
        mSavings(mSave).depositSavings(IERC20(mUSD).balanceOf(address(this)));
    }
    
    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(address(_asset) != address(mUSD), "!musd");
        require(address(_asset) != address(want), "!want");
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
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, _amount);
    }
    
    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();
        balance = IERC20(want).balanceOf(address(this));
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }
    
    function normalize(uint _amount) public view returns (uint) {
        return _amount.mul(10**IERC20(want).decimals()).div(10**IERC20(mUSD).decimals());
    }
    
    function _withdrawAll() internal {
        mSavings(mSave).redeem(mSavings(mSave).creditBalances(address(this)));
        MStable(mUSD).redeem(want, normalize(IERC20(mUSD).balanceOf(address(this))));
    }
    
    function _withdrawSome(uint256 _amount) internal returns (uint) {
        uint256 b = balanceSavings();
        uint256 bT = balanceSavingsInToken();
        require(bT >= _amount, "insufficient funds");
        // can have unintentional rounding errors
        uint256 amount = (b.mul(_amount.mul(1e12))).div(bT).add(1);
        uint _before = IERC20(mUSD).balanceOf(address(this));
        _withdrawSavings(amount);
        uint _after = IERC20(mUSD).balanceOf(address(this));
        uint _wBefore = IERC20(want).balanceOf(address(this));
        MStable(mUSD).redeem(want, normalize(_after.sub(_before)));
        uint _wAfter = IERC20(want).balanceOf(address(this));
        return _wAfter.sub(_wBefore);
    }
    
    function balanceOf() public view returns (uint) {
        return IERC20(want).balanceOf(address(this))
                .add(normalize(IERC20(mUSD).balanceOf(address(this))))
                .add(normalize(balanceSavingsInToken()));
    }
    
    function _withdrawSavings(uint amount) internal {
        mSavings(mSave).redeem(amount);
    }
    
    function balanceSavingsInToken() public view returns (uint256) {
        // Mantisa 1e18 to decimals
        uint256 b = balanceSavings();
        if (b > 0) {
            b = b.mul(mSavings(mSave).exchangeRate()).div(1e18);
        }
        return b;
    }
    
    function balanceSavings() public view returns (uint256) {
        return mSavings(mSave).creditBalances(address(this));
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