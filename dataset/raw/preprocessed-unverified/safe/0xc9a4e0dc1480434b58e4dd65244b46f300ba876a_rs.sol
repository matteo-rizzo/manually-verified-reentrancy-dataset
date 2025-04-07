/**
 *Submitted for verification at Etherscan.io on 2019-10-08
*/

pragma solidity ^0.5.6;






contract WithdrawalOracle is Ownable, IWithdrawalOracle {
    struct CurrencyProportion {
        bool isEnabled;
        uint currencyAmount;
        uint zangllTokenAmount;
    }

    mapping(address => CurrencyProportion) private currencyProportion;

    function set(address coinAddress, bool _isEnabled, uint _currencyAmount, uint _zangllTokenAmount) public onlyOwner {
        currencyProportion[coinAddress] = CurrencyProportion({
            isEnabled: _isEnabled,
            currencyAmount: _currencyAmount,
            zangllTokenAmount: _zangllTokenAmount
        });
    }

    function get(address coinAddress) external view returns (bool, uint, uint) {
        return (currencyProportion[coinAddress].isEnabled,
                currencyProportion[coinAddress].currencyAmount,
                currencyProportion[coinAddress].zangllTokenAmount);
    }
}