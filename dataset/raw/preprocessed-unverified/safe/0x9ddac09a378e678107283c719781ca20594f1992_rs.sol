/**
 *Submitted for verification at Etherscan.io on 2020-07-25
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

contract StrategyCompoundBasic {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address public want;
    
    Comptroller public constant compound = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B); // Comptroller address for compound.finance
    
    cToken public c;
    IERC20 public underlying;

    address public governance;
    address public controller;
    
    // Claim function is not part of the template, this is additional logic to faster farm COMP instead of needing to withdraw/deposit
    function claim() public {
        compound.claimComp(address(this));
    }
    
    constructor(cToken _cToken, address _controller) public {
        governance = msg.sender;
        controller = _controller;
        c = _cToken;
        
        underlying = IERC20(_cToken.underlying());
        want = address(underlying);
    }
    
    function deposit() external {
        underlying.safeApprove(address(c), 0);
        underlying.safeApprove(address(c), underlying.balanceOf(address(this)));
        require(c.mint(underlying.balanceOf(address(this))) == 0, "COMPOUND: supply failed");
    }
    
    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(address(_asset) != address(c), "!c");
        require(address(_asset) != address(underlying), "!underlying");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }
    
    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint _amount) external {
        require(msg.sender == controller, "!controller");
        uint _balance = underlying.balanceOf(address(this));
        if (_balance < _amount) {
            _withdrawSome(_amount.sub(_balance));
        }
        address _vault = Controller(controller).vaults(address(underlying));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        underlying.safeTransfer(_vault, _amount);
    }
    
    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();
        balance = underlying.balanceOf(address(this));
        address _vault = Controller(controller).vaults(address(underlying));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        underlying.safeTransfer(_vault, balance);
    }
    
    function _withdrawAll() internal {
        uint256 amount = balanceCompound();
        if (amount > 0) {
            _withdrawSome(balanceCompoundInToken().sub(1));
        }
    }
    
    function _withdrawSome(uint256 _amount) internal {
        uint256 b = balanceCompound();
        uint256 bT = balanceCompoundInToken();
        require(bT >= _amount, "insufficient funds");
        // can have unintentional rounding errors
        uint256 amount = (b.mul(_amount)).div(bT).add(1);
        _withdrawCompound(amount);
    }
    
    function balanceOf() public view returns (uint) {
        return balanceCompoundInToken();
    }
    
    function _withdrawCompound(uint amount) internal {
        require(c.redeem(amount) == 0, "COMPOUND: withdraw failed");
    }
    
    function balanceCompoundInToken() public view returns (uint256) {
        // Mantisa 1e18 to decimals
        uint256 b = balanceCompound();
        if (b > 0) {
            b = b.mul(c.exchangeRateStored()).div(1e18);
        }
        return b;
    }
    
    function balanceCompound() public view returns (uint256) {
        return c.balanceOf(address(this));
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