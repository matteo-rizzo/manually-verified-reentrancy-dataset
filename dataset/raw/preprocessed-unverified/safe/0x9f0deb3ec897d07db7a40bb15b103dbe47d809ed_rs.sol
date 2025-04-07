pragma solidity 0.6.12;





contract DeWETHer {
    event Unwrapped(
        address account,
        uint256 unwrappedAmount
    );
    
    WETHInterace private _WETH = WETHInterace(
        0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    );

    receive() external payable {}
    
    function unwrapAllWETHFor(address account) external {
        uint256 wethBalance = _WETH.balanceOf(account);
        if (wethBalance > 0) {
            require(
                _WETH.transferFrom(account, address(this), wethBalance),
                "WETH transfer in failed â€” has the allowance been set?"
            );
            _WETH.withdraw(wethBalance);
    
            uint256 ethBalance = address(this).balance;
            
            (bool ok, ) = account.call{value: ethBalance}("");
            if (!ok) {
                assembly {
                    returndatacopy(0, 0, returndatasize())
                    revert(0, returndatasize())
                }
            }
            
            emit Unwrapped(account, ethBalance);
        }
    }
}