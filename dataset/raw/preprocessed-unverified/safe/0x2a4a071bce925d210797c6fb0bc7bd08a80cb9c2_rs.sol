/**
 *Submitted for verification at Etherscan.io on 2020-11-13
*/

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

// Dependency file: contracts/modules/Ownable.sol

// pragma solidity >=0.5.16;



// Dependency file: contracts/modules/ERC20Token.sol

// pragma solidity >=0.5.16;

// import '../libraries/SafeMath.sol';

contract ERC20Token {
    using SafeMath for uint;

    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function _transfer(address from, address to, uint value) private {
        require(balanceOf[from] >= value, 'ERC20Token: INSUFFICIENT_BALANCE');
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        if (to == address(0)) { // burn
            totalSupply = totalSupply.sub(value);
        }
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns (bool) {
        require(allowance[from][msg.sender] >= value, 'ERC20Token: INSUFFICIENT_ALLOWANCE');
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

}

pragma solidity >=0.5.16;
// import './modules/ERC20Token.sol';
// import './modules/Ownable.sol';

contract BurgerMainToken is ERC20Token, Ownable {
    uint public maxSupply = 21000000 * 10 ** 18;

    event Minted(address indexed user, uint amount);

	constructor() public {
        name = 'Burger Token';
        symbol = 'BURGER';
        totalSupply = 10000000 * 10 ** 18;
        balanceOf[msg.sender] = totalSupply;
    }

    function mint(uint amount) external onlyOwner returns (uint) {
        require(amount > 0, 'Invalid amount');
        if(amount.add(totalSupply) > maxSupply) {
            amount = maxSupply.sub(totalSupply);
        }
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Minted(msg.sender, amount);
        return amount;
    }

}