// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;













contract SafetyRedundancy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    
    constructor() public {}
    
    Strategy constant public vault = Strategy(0x932fc4fd0eEe66F22f1E23fBA74D7058391c0b15);
    OSMedianizer constant public osm = OSMedianizer(0xCF63089A8aD2a9D8BD6Bb8022f3190EB7e1eD0f1);
    
    function repay() external view returns (uint) {
        uint _eth = vault.balanceOfmVault(); // Total ETH in vault 1e18
        uint _max = _eth.mul(vault.c_base()).div(vault.c()); // Max usable ETH at c/c_base collateral ratio (~200%)
        (uint _read,) = osm.read();
        (uint _foresight,) = osm.foresight();
        uint _p = _foresight < _read ? _foresight : _read;
        uint _debt = _max.mul(_p).div(1e18);
        uint _current = vault.getTotalDebtAmount();
        if (_current > _debt) {
            return _current.sub(_debt);
        }
        return 0;
    }
}