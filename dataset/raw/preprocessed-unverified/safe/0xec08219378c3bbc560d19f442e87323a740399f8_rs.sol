// Dependency file: contracts/libraries/SafeMath.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


// Dependency file: contracts/libraries/TransferHelper.sol

//SPDX-License-Identifier: MIT

// pragma solidity >=0.6.0;







// Dependency file: contracts/interface/IERC20.sol

//SPDX-License-Identifier: MIT
// pragma solidity >=0.5.0;




// Root file: contracts/WasabiToken1to2.sol

//SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

// import 'contracts/libraries/SafeMath.sol';
// import 'contracts/libraries/TransferHelper.sol';
// import 'contracts/interface/IERC20.sol';

contract WasabiToken1to2 {
    using SafeMath for uint;
    address public owner;
    uint public rate;
    address public token1;
    address public token2;

    event Withdrawed(address indexed user, uint amount);
    event Swaped(address indexed user, uint amountIn, uint amountOut);

    modifier onlyOwner() {
        require(msg.sender == owner, 'FORBIDDEN');
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function initialize(address _token1, address _token2, uint _rate) external onlyOwner returns (bool) {
        token1 = _token1;
        token2 = _token2;
        rate = _rate;
        return true;
    }

    function changeOwner(address _new) public onlyOwner {
        require(_new != address(0), 'INVALID_ADDRESS');
        owner = _new;
    }

    function withdraw(uint amount) external onlyOwner returns (bool) {
        require(IERC20(token2).balanceOf(address(this)) >= amount, 'INSUFFICIENT_BALANCE');
        TransferHelper.safeTransfer(token2, msg.sender, amount);
        emit Withdrawed(msg.sender, amount);
        return true;
    }

    function swap(uint amount) external returns (uint) {
        require(amount > 0 && IERC20(token1).balanceOf(msg.sender) >= amount, 'TOKEN1_INSUFFICIENT_BALANCE');
        uint out = amount * rate / 100;
        require(out > 0 && IERC20(token2).balanceOf(address(this)) >= out, 'TOKEN2_INSUFFICIENT_BALANCE');
        TransferHelper.safeTransferFrom(token1, msg.sender, address(0), amount);
        TransferHelper.safeTransfer(token2, msg.sender, out);
        emit Swaped(msg.sender, amount, out);
        return out;
    }
}