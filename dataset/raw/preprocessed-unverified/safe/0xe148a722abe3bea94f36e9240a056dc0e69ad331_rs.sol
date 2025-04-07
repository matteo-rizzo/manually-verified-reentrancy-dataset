/**
 *Submitted for verification at Etherscan.io on 2021-01-26
*/

// SPDX-License-Identifier: GPL-2.0

pragma solidity ^0.7.6;



/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */




contract Splitter is Ownable {
    address public a;
    address public b;

    event SetA(address _a);
    event SetB(address _b);

    constructor(
        address payable _a,
        address payable _b,
        address _owner
    ) Ownable(_owner) {
        a = _a;
        b = _b;
        emit SetA(_a);
        emit SetB(_b);
    }

    function transferA(address _to) external {
        require(_to != address(0), "wrong value");
        require(msg.sender == a || msg.sender == _owner, "not authorized");
        emit SetA(_to);
        a = _to;
    }

    function transferB(address _to) external {
        require(_to != address(0), "wrong value");
        require(msg.sender == b || msg.sender == _owner, "not authorized");
        emit SetB(_to);
        b = _to;
    }

    function withdraw(IERC20 _token, uint256 _amount) external {
        // Split in two and send to the two addresses
        uint256 send = _amount / 2;
        require(SafeERC20.transfer(_token, a, send), "error sending tokens to a");
        require(SafeERC20.transfer(_token, b, send), "error sending tokens to b");
    }

    function execute(address _to, uint256 _val, bytes calldata _data) external onlyOwner {
        _to.call{ value: _val }(_data);
    }

    receive() payable external { }
}