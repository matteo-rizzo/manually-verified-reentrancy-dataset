/**
 *Submitted for verification at Etherscan.io on 2021-04-10
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract IERC20 {
    function totalSupply() external virtual view returns (uint256);
    function balanceOf(address tokenOwner) external virtual view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external virtual view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external virtual returns (bool success);
    function approve(address spender, uint256 tokens) external virtual returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external virtual returns (bool success);
    function burnFrom(address account, uint256 amount) public virtual;
    
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}


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
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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


contract SwapTokens is Ownable {
    using SafeMath for uint256;
    
    address public tokenFrom;
    address public tokenTo;
    
    uint256 public tokenFromTotal;
    uint256 public tokenToTotal;
    
    address[] public swapUsers;
    mapping(address => uint256) public swappedGDAOAmount;
    
    bool public isInitiated = false;

    constructor(address _tokenFrom, address _tokenTo, uint256 _tokenFromTotal, uint256 _tokenToTotal) {
        tokenFrom = _tokenFrom;
        tokenTo = _tokenTo;
        tokenFromTotal = _tokenFromTotal;
        tokenToTotal = _tokenToTotal;
    }
   
    
    function swapTokens(uint256 _amount) public {
        require(_amount > 0, "amount cannot be 0");
        require(isInitiated == true, "Swap has not started yet");
        
        IERC20(tokenFrom).transferFrom(msg.sender, address(0x000000000000000000000000000000000000dEaD), _amount);
        
        uint256 finalAmount = _amount.mul(tokenToTotal).div(tokenFromTotal);
        IERC20(tokenTo).transfer(msg.sender, finalAmount);
        
        if(swappedGDAOAmount[msg.sender] <= 0) {
            swapUsers.push(msg.sender);
        }
        swappedGDAOAmount[msg.sender] = swappedGDAOAmount[msg.sender].add(finalAmount);
    }
    
    function initiateSwap() public onlyOwner {
        require(IERC20(tokenTo).balanceOf(address(this)) >= tokenToTotal, "Target token balance too low");
        require(isInitiated == false, "Swap already initiated");
        isInitiated = true;
    }
    
    
    function withdrawTokens(address _token, address _to, uint256 _amount) public onlyOwner {
        require(isInitiated == false, "Swap already initiated");
        IERC20 token = IERC20(_token);
        token.transfer(_to, _amount);
    }
    
    
    function calculateTokens(uint256 _amount) public view returns(uint256) {
        uint256 receiveAmount = _amount.mul(tokenToTotal).div(tokenFromTotal);
        return receiveAmount;
    }
   
}