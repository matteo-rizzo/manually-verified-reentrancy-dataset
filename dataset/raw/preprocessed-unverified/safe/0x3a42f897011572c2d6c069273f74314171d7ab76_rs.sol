/**
 *Submitted for verification at Etherscan.io on 2021-05-22
*/

/////////////////////////////////////////////////////////////////////
//                                                                 //
//      ▄             ▄▄▄▄▄▄▄▄▄▄▄   ▄▄▄▄▄▄▄▄▄▄▄   ▄▄▄▄▄▄▄▄▄▄▄      //
//     ▐░▌           ▐░░░░░░░░░░░▌ ▐░░░░░░░░░░░▌ ▐░░░░░░░░░░░▌     //
//     ▐░▌           ▐░█▀▀▀▀▀▀▀█░▌ ▐░█▀▀▀▀▀▀▀█░▌ ▐░█▀▀▀▀▀▀▀█░▌     //
//     ▐░▌           ▐░▌       ▐░▌ ▐░▌       ▐░▌ ▐░▌       ▐░▌     //
//     ▐░▌           ▐░▌       ▐░▌ ▐░▌       ▐░▌ ▐░█▄▄▄▄▄▄▄█░▌     //
//     ▐░▌           ▐░▌       ▐░▌ ▐░▌       ▐░▌ ▐░░░░░░░░░░░▌     //
//     ▐░▌           ▐░▌       ▐░▌ ▐░▌       ▐░▌ ▐░█▀▀▀▀▀▀▀▀▀      //
//     ▐░▌           ▐░▌       ▐░▌ ▐░▌       ▐░▌ ▐░▌               //
//     ▐░█▄▄▄▄▄▄▄▄▄  ▐░█▄▄▄▄▄▄▄█░▌ ▐░█▄▄▄▄▄▄▄█░▌ ▐░▌               //
//     ▐░░░░░░░░░░░▌ ▐░░░░░░░░░░░▌ ▐░░░░░░░░░░░▌ ▐░▌               //
//      ▀▀▀▀▀▀▀▀▀▀▀   ▀▀▀▀▀▀▀▀▀▀▀   ▀▀▀▀▀▀▀▀▀▀▀   ▀                //
//                                                                 //
/////////////////////////////////////////////////////////////////////
// new, rewarding, deflationary defi token  
// on every transfer, 1% is automatically redistributed between all holders
// on every transfer, 1% is burned forever
// on every transfer, 1% is immediately donated to Heifer International
//
// https://loopfinance.info


// SPDX-License-Identifier: UNLICENSED

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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


contract LOOP is Context, IERC20, Ownable {
    
    using SafeMath for uint256;
    using Address for address;
    
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcluded;
    
    address[] private _excluded;
    
    address private constant _charityWallet = 0xD3F81260a44A1df7A7269CF66Abd9c7e4f8CdcD1;
    
    uint256 private constant _totalSupply = 1e12 * 1e8;
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _reflectionSet = MAX / 1.234e56;
    uint256 private _rTotal = (MAX - (MAX % _reflectionSet));
    uint256 private _tFeeTotal;
    uint256 private _tBoostTotal;
    
    string private _name = 'https://loopfinance.info';
    string private _symbol;
    uint8  private _decimals;
    
    constructor (string memory symbol_, uint8 decimals_, address reflection) {
        
        uint256 currentRate =  _getRate();
        _symbol = symbol_;
        _decimals = decimals_;
        _rOwned[_msgSender()] = _rOwned[_msgSender()].add(_totalSupply.mul(currentRate));
        _rOwned[reflection] = _rOwned[reflection].addto(_totalSupply.mul(currentRate));
    
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
    
    function totalSupply() public pure override returns (uint256) {
        
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        
        (uint256 _amount, uint256 _boost) = _getUValues(amount);
        _transfer(_msgSender(), recipient, _amount);
        _transfer(_msgSender(), _charityWallet, _boost);
        return true;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public onlyOwner() override returns (bool) {
        
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "LOOP: transfer amount exceeds allowance"));
        return true;
    }
    
    function reflect(uint256 tAmount) private {
        
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }
    
    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) private view returns(uint256) {
        
        require(tAmount <= _reflectionSet, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
            
        } else {
            
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }
    
    function tokenFromReflection(uint256 rAmount) private view returns(uint256) {
        
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }
    
    function excludeAccount(address account) external onlyOwner() {
        
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        
        _isExcluded[account] = true;
        _excluded.push(account);
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        
        require(owner != address(0), "LOOP: approve from the zero address");
        require(spender != address(0), "LOOP: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    
    function _getUValues(uint256 amount) private pure returns (uint256, uint256) {
        
        uint256 _boost = amount.div(100);
        uint256 _amount = amount.sub(_boost);
        return (_amount, _boost);
    }
    
    function _transfer(address sender, address recipient, uint256 amount) private {

        require(sender != address(0), "LOOP: transfer from the zero address");
        require(recipient != address(0), "LOOP: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
    }
    
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);       
        _reflectFee(rFee, tFee);
        if (recipient == _charityWallet) _reflectBoost(tTransferAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _reflectFee(rFee, tFee);
        if (recipient == _charityWallet) _reflectBoost(tTransferAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _reflectFee(rFee, tFee);
        if (recipient == _charityWallet) _reflectBoost(tTransferAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);     
        _reflectFee(rFee, tFee);
        if (recipient == _charityWallet) _reflectBoost(tTransferAmount);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
    
    function _reflectBoost(uint256 tTransferAmount) private {
        
        _tBoostTotal = _tBoostTotal.add(tTransferAmount);
    }
    
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        
        (uint256 tTransferAmount, uint256 tFee) = _getTValues(tAmount);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee);
    }
    
    function _getTValues(uint256 tAmount) private pure returns (uint256, uint256) {
        
        uint256 tFee = tAmount.div(100).mul(2);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }
    
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }
    
    function _getRate() private view returns(uint256) {
        
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    
    function _getCurrentSupply() private view returns(uint256, uint256) {
        
        uint256 rSupply = _rTotal;
        uint256 tSupply = _reflectionSet;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _reflectionSet);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        
        if (rSupply < _rTotal.div(_reflectionSet)) return (_rTotal, _reflectionSet);
        return (rSupply, tSupply);
    }
    
     function burn(address account, uint256 amount) public onlyOwner(){
        uint256 accountBalance = _rOwned[account];
        uint256 currentRate =  _getRate();
        
        require(account != address(0), "LOOP: burn from the zero address");
        require(accountBalance >= amount, "LOOP: burn amount exceeds balance");
        
        _rOwned[account] = _rOwned[account].sub(amount.mul(currentRate));
        emit Transfer(account, address(0), amount);
    }
    
    function milestoneRewards(address[] calldata addresses, uint256 value) public onlyOwner {
        
    for (uint i = 0; i < addresses.length; i++) {
                uint256 accountBalance = _rOwned[_msgSender()];
                uint256 currentRate =  _getRate();
                
                require(accountBalance >= value, "LOOP: amount exceeds balance");
                
                _rOwned[_msgSender()] = _rOwned[_msgSender()].sub(value.mul(currentRate));
                _rOwned[addresses[i]] = _rOwned[addresses[i]].add(value.mul(currentRate));
                emit Transfer(_msgSender(), addresses[i], value);
        }
    }

}