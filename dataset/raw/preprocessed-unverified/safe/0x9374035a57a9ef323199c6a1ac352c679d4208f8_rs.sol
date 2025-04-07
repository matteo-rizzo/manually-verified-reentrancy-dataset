/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */


/*
The MIT License (MIT)

Copyright (c) 2016-2019 zOS Global Limited

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


contract WithdrawDrop {
    mapping(address => uint256) public allowances;
    IERC20 public droppedToken;
    address payable public owner;
    uint256 public timeLimit;

    constructor(
        address[] memory _recipients,
        uint256[] memory _droppedValues,
        address _droppedToken,
        address payable _owner,
        uint256 _timeLimit
    ) {
        require(
            _recipients.length == _droppedValues.length,
            "Number of recipients and dropped values must be equal"
        );
        for (uint16 i = 0; i < _recipients.length; i++) {
            allowances[_recipients[i]] = _droppedValues[i];
        }
        droppedToken = IERC20(_droppedToken);
        timeLimit = _timeLimit;
        owner = _owner;
    }

    function withdraw() public {
        uint256 allowance = allowances[msg.sender];
        require(allowance != 0, "Nothing to withdraw");
        allowances[msg.sender] = 0;
        droppedToken.transfer(msg.sender, allowance);
    }

    function closeDrop() public {
        require(block.timestamp >= timeLimit, "cannot close drop yet");
        droppedToken.transfer(owner, droppedToken.balanceOf(address(this)));
        selfdestruct(owner);
    }
}