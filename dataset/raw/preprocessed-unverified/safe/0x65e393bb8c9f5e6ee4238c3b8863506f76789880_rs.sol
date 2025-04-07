/**
 *Submitted for verification at Etherscan.io on 2021-07-11
*/

/*
    ___            _       ___  _                          
    | .\ ___  _ _ <_> ___ | __><_>._ _  ___ ._ _  ___  ___ 
    |  _// ._>| '_>| ||___|| _> | || ' |<_> || ' |/ | '/ ._>
    |_|  \___.|_|  |_|     |_|  |_||_|_|<___||_|_|\_|_.\___.
    
* PeriFinance: BlacklistManager.sol
*
* Latest source (may be newer): https://github.com/perifinance/peri-finance/blob/master/contracts/BlacklistManager.sol
* Docs: Will be added in the future. 
* https://docs.peri.finance/contracts/source/contracts/BlacklistManager
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



contract BlacklistManager is Owned {
    mapping(address => bool) public flagged;

    address[] public listedAddresses;

    constructor(address _owner) public Owned(_owner) {}

    function flagAccount(address _account) external onlyOwner {
        flagged[_account] = true;

        bool checker = false;
        for (uint i = 0; i < listedAddresses.length; i++) {
            if (listedAddresses[i] == _account) {
                checker = true;

                break;
            }
        }

        if (!checker) {
            listedAddresses.push(_account);
        }

        emit Blacklisted(_account);
    }

    function unflagAccount(address _account) external onlyOwner {
        flagged[_account] = false;

        emit Unblacklisted(_account);
    }

    function getAddresses() external view returns (address[] memory) {
        return listedAddresses;
    }

    event Blacklisted(address indexed account);
    event Unblacklisted(address indexed account);
}