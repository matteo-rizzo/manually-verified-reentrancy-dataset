/**
 *Submitted for verification at Etherscan.io on 2020-11-09
*/

pragma solidity ^0.6.0;





contract UNYCrowdSale {
    using SafeMath for uint256;

    address private _owner;

    uint256[] private _phaseGoals = [
        8000000000000000000000,
        17000000000000000000000,
        27000000000000000000000
    ];
    uint256[] private _phasePrices = [40, 30, 20];

    uint8 private _phase = 0;
    uint256 private _raisedAmount = 0; // UNY sent
    bool private _isClose = false;

    IERC20 private _token;

    constructor (address tokenAddr) public {
        _owner = msg.sender;
        _token = IERC20(tokenAddr);
    }

    receive() external payable {
        require(_phase <= 2 && !_isClose, "Crowdfunding is closed");

        uint256 expected = msg.value.mul(_phasePrices[_phase]);
        uint256 totalAmount = _raisedAmount.add(expected);
        require(totalAmount <= _phaseGoals[2], "Not enough remaining tokens");

        _token.transfer(msg.sender, expected);

        _raisedAmount = _raisedAmount.add(expected);
        if (_phase < 2 && _raisedAmount >= _phaseGoals[_phase]) {
            _phase = _phase + 1;
        }
    }

    function setClose(bool status) public returns (bool) {
        require(msg.sender == _owner, "sender is not owner");

        _isClose = status;
        return true;
    }

    function withdrawETH(address payable recipient) public returns (bool) {
        require(msg.sender == _owner, "sender is not owner");

        uint256 balance = address(this).balance;
        if (balance > 0) {
            recipient.transfer(balance);
            return true;
        } else {
            return false;
        }
    }

    function withdrawUNY(address recipient) public returns (bool) {
        require(msg.sender == _owner, "sender is not owner");

        uint256 balance = _token.balanceOf(address(this));
        if (balance > 0) {
            _token.transfer(recipient, balance);
            return true;
        } else {
            return false;
        }
    }
}