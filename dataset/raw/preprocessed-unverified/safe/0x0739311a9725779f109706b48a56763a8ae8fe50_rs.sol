/**
 *Submitted for verification at Etherscan.io on 2020-07-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.17;















contract RiskOracle {
    using Address for address;
    using SafeMath for uint256;
    
    address constant public usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address constant public usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address constant public tusd = address(0x0000000000085d4780B73119b644AE5ecd22b376);
    address constant public dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    
    address constant public ycrv = address(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
    
    address constant public aave = address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8);
    
    uint constant public id = 7;
    
    constructor() public {
        emit Setup(ycrv, id, getAaveOracle());
    }
    
    event Setup(address, uint, address);
    
    function getToken() external pure returns (address) {
        return ycrv;
    }
    function getPlatformId() external pure returns (uint) {
        return id;
    }
    function getSubTokens() external pure returns(address[4] memory) {
        return [usdt,usdc,tusd,dai];
    }
    
    
    function getReservePriceETHUSDT() public view returns (uint256) {
        return getReservePriceETH(usdt);
    }
    function getReservePriceETHUSDC() public view returns (uint256) {
        return getReservePriceETH(usdc);
    }
    function getReservePriceETHTUSD() public view returns (uint256) {
        return getReservePriceETH(tusd);
    }
    function getReservePriceETHDAI() public view returns (uint256) {
        return getReservePriceETH(dai);
    }
    function getReservePriceMIN() public view returns (uint256) {
        uint _usdt = getReservePriceETH(usdt);
        uint _usdc = getReservePriceETH(usdc);
        uint _tusd = getReservePriceETH(tusd);
        uint _dai = getReservePriceETH(dai);
        uint _min = _usdt;
        if (_min > _usdc) {
            _min = _usdc;
        }
        if (_min > _tusd) {
            _min = _tusd;
        }
        if (_min > _dai) {
            _min = _dai;
        }
        return _min;
    }
    function getAddressMIN() public view returns (address) {
        uint _usdt = getReservePriceETH(usdt);
        uint _usdc = getReservePriceETH(usdc);
        uint _tusd = getReservePriceETH(tusd);
        uint _dai = getReservePriceETH(dai);
        uint _min = _usdt;
        address _address = usdt;
        if (_min > _usdc) {
            _min = _usdc;
            _address = usdc;
        }
        if (_min > _tusd) {
            _min = _tusd;
            _address = tusd;
        }
        if (_min > _dai) {
            _min = _dai;
            _address = dai;
        }
        return _address;
    }
    
    function get_virtual_price() public view returns (uint) {
        return Curve(ycrv).get_virtual_price();
    }
    
    function latestAnswer() public view returns (int256) {
        uint _usdt = getReservePriceETH(usdt);
        uint _usdc = getReservePriceETH(usdc);
        uint _tusd = getReservePriceETH(tusd);
        uint _dai = getReservePriceETH(dai);
        uint _min = _usdt;
        if (_min > _usdc) {
            _min = _usdc;
        }
        if (_min > _tusd) {
            _min = _tusd;
        }
        if (_min > _dai) {
            _min = _dai;
        }
        int256 _ret = int256(_min);
        return _ret;
    }
    
    function getAaveOracle() public view returns (address) {
        return LendingPoolAddressesProvider(aave).getPriceOracle();
    }
    
    function getReservePriceETH(address reserve) public view returns (uint256) {
        return Oracle(getAaveOracle()).getAssetPrice(reserve);
    }
    
    
}