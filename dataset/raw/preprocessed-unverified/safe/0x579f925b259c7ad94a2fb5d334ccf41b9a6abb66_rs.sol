// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;



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




/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}






contract DerivativeFinanceTokenV0 is Ownable {
    using SafeMath for uint256;

    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public  allowance;
    bytes32 public  symbol = "DFT";
    uint256 public  decimals = 8;
    bytes32 public  name = "Derivative Finance Token";
    address public  foodbank;

    constructor(address chef, address _foodbank) Ownable() public {
        // 1000000 DFT
        totalSupply = 1000000*10^8;
        balanceOf[chef] = 1000000*10^8;
        foodbank = _foodbank;
    }

    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Burn(uint256 amount);
    
    function approve(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return transferFrom(msg.sender, to, amount);
    } 

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        
        if (sender != msg.sender && allowance[sender][msg.sender] != uint256(-1)) {
            require(allowance[sender][msg.sender] >= amount, "token-insufficient-approval");
            allowance[sender][msg.sender] = allowance[sender][msg.sender].sub(amount);
        }

        require(balanceOf[sender] >= amount, "token-insufficient-balance");
        balanceOf[sender] = balanceOf[sender].sub(amount);
        uint256 one = amount / 100;
        uint256 half = one / 2;
        uint256 fAmount = amount.sub(one);
        balanceOf[recipient] = balanceOf[recipient].add(fAmount);
        balanceOf[foodbank] = balanceOf[foodbank].add(half);
        burn(half);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function burn(uint256 amount) internal {
        totalSupply = totalSupply.sub(amount);
        emit Burn(amount);
    }

    function setFoodbank(address _foodbank) public onlyOwner {
        foodbank = _foodbank;
    }
}