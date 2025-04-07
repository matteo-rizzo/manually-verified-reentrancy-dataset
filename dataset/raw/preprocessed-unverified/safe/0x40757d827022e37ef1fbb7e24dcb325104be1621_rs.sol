/**
 *Submitted for verification at Etherscan.io on 2021-08-11
*/

/*
    ___            _       ___  _                          
    | .\ ___  _ _ <_> ___ | __><_>._ _  ___ ._ _  ___  ___ 
    |  _// ._>| '_>| ||___|| _> | || ' |<_> || ' |/ | '/ ._>
    |_|  \___.|_|  |_|     |_|  |_||_|_|<___||_|_|\_|_.\___.
    
* PeriFinance: ExternalRateAggregator.sol
*
* Latest source (may be newer): https://github.com/perifinance/peri-finance/blob/master/contracts/ExternalRateAggregator.sol
* Docs: Will be added in the future. 
* https://docs.peri.finance/contracts/source/contracts/ExternalRateAggregator
*
* Contract Dependencies: 
*	- Owned
* Libraries: (none)
*
* MIT License
* ===========
*
* Copyright (c) 2021 PeriFinance
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/



pragma solidity 0.5.16;

// https://docs.peri.finance/contracts/source/contracts/owned



contract ExternalRateAggregator is Owned {
    address public oracle;

    uint private constant ORACLE_FUTURE_LIMIT = 10 minutes;

    struct RateAndUpdatedTime {
        uint216 rate;
        uint40 time;
    }

    mapping(bytes32 => RateAndUpdatedTime) public rates;

    constructor(address _owner, address _oracle) public Owned(_owner) {
        oracle = _oracle;
    }

    function setOracle(address _oracle) external onlyOwner {
        require(_oracle != address(0), "Address cannot be empty");

        oracle = _oracle;
    }

    function updateRates(
        bytes32[] calldata _currencyKeys,
        uint216[] calldata _newRates,
        uint timeSent
    ) external onlyOracle {
        require(_currencyKeys.length == _newRates.length, "Currency key array length must match rates array length.");
        require(timeSent < (now + ORACLE_FUTURE_LIMIT), "Time is too far into the future");

        for (uint i = 0; i < _currencyKeys.length; i++) {
            bytes32 currencyKey = _currencyKeys[i];
            uint newRate = _newRates[i];

            require(newRate != 0, "Zero is not a valid rate, please call deleteRate instead");
            require(currencyKey != "pUSD", "Rate of pUSD cannot be updated, it's always UNIT");

            if (timeSent < rates[currencyKey].time) {
                continue;
            }

            rates[currencyKey] = RateAndUpdatedTime({rate: uint216(newRate), time: uint40(timeSent)});
        }

        emit RatesUpdated(_currencyKeys, _newRates);
    }

    function deleteRate(bytes32 _currencyKey) external onlyOracle {
        delete rates[_currencyKey];
    }

    function getRateAndUpdatedTime(bytes32 _currencyKey) external view returns (uint, uint) {
        return (rates[_currencyKey].rate, rates[_currencyKey].time);
    }

    modifier onlyOracle {
        _onlyOracle();
        _;
    }

    function _onlyOracle() private view {
        require(msg.sender == oracle, "Only the oracle can perform this action");
    }

    event RatesUpdated(bytes32[] currencyKeys, uint216[] newRates);
}