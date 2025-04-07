/**
 *Submitted for verification at Etherscan.io on 2020-07-24
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;














contract StrategyCompoundBasic {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address public want;
    
    cToken public c;
    IERC20 public underlying;

    address public governance;
    address public controller;
    
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
    
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(address(_asset) != address(c), "!c");
        require(address(_asset) != address(underlying), "!underlying");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }
    
    function withdraw(uint _amount) external {
        require(msg.sender == controller, "!controller");
        uint _balance = underlying.balanceOf(address(this));
        if (_balance < _amount) {
            _withdrawSome(_amount.sub(_balance));
        }
        underlying.safeTransfer(Controller(controller).vaults(address(underlying)), _amount);
    }
    
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        _withdrawAll();
        balance = underlying.balanceOf(address(this));
        underlying.safeTransfer(Controller(controller).vaults(address(underlying)), balance);
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