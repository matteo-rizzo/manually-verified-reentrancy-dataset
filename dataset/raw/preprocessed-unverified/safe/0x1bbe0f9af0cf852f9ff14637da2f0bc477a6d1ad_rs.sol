pragma solidity ^0.5.16;











contract yVaultCheck {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    yVault public constant vault = yVault(0xACd43E627e64355f1861cEC6d3a6688B31a6F952);
    
    constructor () public {}
    
    function withdrawAll() external {
        withdraw(vault.balanceOf(msg.sender));
    }
    
    // No rebalance implementation for lower fees and faster swaps
    function withdraw(uint _shares) public {
        IERC20(address(vault)).safeTransferFrom(msg.sender, address(this), _shares);
        IERC20 _underlying = IERC20(vault.token());
        
        uint _expected = vault.balanceOf(address(this));
        _expected = _expected.mul(vault.getPricePerFullShare()).div(1e18);
        _expected = _expected.mul(9999).div(10000);
        
        uint _before = _underlying.balanceOf(address(this));
        vault.withdrawAll();
        uint _after = _underlying.balanceOf(address(this));
        require(_after.sub(_before) >= _expected, "slippage");
        _underlying.safeTransfer(msg.sender, _underlying.balanceOf(address(this)));
    }
}