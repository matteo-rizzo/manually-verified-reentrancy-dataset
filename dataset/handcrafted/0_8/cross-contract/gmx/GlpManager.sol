// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./BasicERC20.sol";
import "./Vault.sol";
import "./ShortsTracker.sol";
import "./Oracle.sol";

contract ToyGlpManager is ERC20 {
    DummyUSDC public immutable usdc;          // classroom USDC
    ToyVault  public immutable vault;
    ToyShortsTracker public immutable tracker;
    Oracle    public immutable oracle;
    address   public immutable indexToken;    // e.g., dummy WBTC address

    uint256 public poolCashUSDC; // 6 decimals

    constructor(address _usdc, address _vault, address _tracker, address _oracle, address _index)
        ERC20("Toy GLP", "tGLP", 18)
    {
        usdc   = DummyUSDC(_usdc);
        vault  = ToyVault(_vault);
        tracker= ToyShortsTracker(_tracker);
        oracle = Oracle(_oracle);
        indexToken = _index;
    }

    function getAumE18() public view returns (uint256 aumE18) {
        aumE18 = poolCashUSDC * 1e12; // convert 6→18
        uint256 sizeE18 = vault.globalShortSizesE18(indexToken);
        if (sizeE18 > 0) {
            uint256 avgE18 = tracker.globalShortAveragePriceE18(indexToken);
            uint256 pxE18  = oracle.priceE18(indexToken);
            if (pxE18 > avgE18) {
                uint256 shortLossE18 = (pxE18 - avgE18) * sizeE18 / pxE18;
                aumE18 += shortLossE18; // shorts "losing" inflates AUM → GLP price up
            }
        }
    }

    // Simpler mint: 1 USDC => 1e18 GLP units (so price moves only on redeem via AUM)
    function mintAndStakeGlp(uint256 usdcAmt) external {
        usdc.transferFrom(msg.sender, address(this), usdcAmt);
        poolCashUSDC += usdcAmt;
        _mint(msg.sender, usdcAmt * 1e12);
    }

    // Redeem at current AUM-based price
    function redeemGlp(uint256 glpAmt, address to) external {
        require(balanceOf[msg.sender] >= glpAmt, "glp bal");
        uint256 aumE18  = getAumE18();
        uint256 supply  = totalSupply;
        uint256 payoutE18 = glpAmt * aumE18 / supply;   // USD 1e18
        uint256 usdcOut = payoutE18 / 1e12;             // back to 6 decimals
        require(poolCashUSDC >= usdcOut, "pool");
        _burn(msg.sender, glpAmt);
        poolCashUSDC -= usdcOut;
        usdc.transfer(to, usdcOut);
    }
}