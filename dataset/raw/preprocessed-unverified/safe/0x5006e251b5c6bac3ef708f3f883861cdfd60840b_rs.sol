/**
 *Submitted for verification at Etherscan.io on 2021-04-30
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;


contract BridgeAssistE {
    address public owner;
    IERC20 public TKN;
    IWTKN public WTKN;

    modifier restricted {
        require(msg.sender == owner, "This function is restricted to owner");
        _;
    }

    event Collect(address indexed sender, uint256 wAmount, uint256 amount);
    event Dispense(address indexed sender, uint256 wAmount, uint256 amount);
    event TransferOwnership(address indexed previousOwner, address indexed newOwner);

    function collect(address _sender, uint256 _amount, uint256 _fee) public restricted {
        TKN.transferFrom(_sender, address(this), _amount);
        WTKN.deposit(_amount - _fee);
        emit Collect(_sender, WTKN.rawToWrapAmount(_amount), _amount);
    }

    function dispense(address _sender, uint256 _wAmount, uint256 _fee) public restricted {
        uint256 _amount = WTKN.wrapToRawAmount(_wAmount);
        WTKN.withdraw(_wAmount);
        TKN.transfer(_sender, _amount - _fee);
        emit Dispense(_sender, _wAmount, _amount);
    }

    function transferOwnership(address _newOwner) public restricted {
        require(_newOwner != address(0), "Invalid address: should not be 0x0");
        emit TransferOwnership(owner, _newOwner);
        owner = _newOwner;
    }

    function drain(IERC20 _TKN, uint256 _amount) public restricted {
        _TKN.transfer(msg.sender, _amount);
    }

    function approveMax() public restricted {
        TKN.approve(address(WTKN), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    constructor(IERC20 _TKN, IWTKN _WTKN) {
        TKN = _TKN;
        WTKN = _WTKN;
        owner = msg.sender;
    }
}