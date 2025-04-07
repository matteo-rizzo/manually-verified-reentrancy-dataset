/**
 *Submitted for verification at Etherscan.io on 2021-02-11
*/

// SPDX-License-Identifier: GCB

pragma solidity ^0.6.2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


 





abstract contract Ownable is Context {
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

contract GCBN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _gcbOwned;
    mapping (address => uint256) private _gcbtOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _gcbtTotal = 10e21;
    uint256 private _gcbTotal = (MAX - (MAX % _gcbtTotal));
    uint256 private _tFeeTotal;

    string private _name = 'GCBN';
    string private _symbol = 'GCBN';
    uint8 private _decimals = 18;

    constructor () public {
        _gcbOwned[_msgSender()] = _gcbTotal;
        emit Transfer(address(0), _msgSender(), _gcbtTotal);
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
        return _gcbtTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _gcbtOwned[account];
        return tokenFromGCB(_gcbOwned[account]);
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

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function gcb(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 _gcbAmount,,,,) = _getValues(tAmount);
        _gcbOwned[sender] = _gcbOwned[sender].sub(_gcbAmount);
        _gcbTotal = _gcbTotal.sub(_gcbAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function gcbFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _gcbtTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 _gcbAmount,,,,) = _getValues(tAmount);
            return _gcbAmount;
        } else {
            (,uint256 rTransfe_gcbAmount,,,) = _getValues(tAmount);
            return rTransfe_gcbAmount;
        }
    }

    function tokenFromGCB(uint256 _gcbAmount) public view returns(uint256) {
        require(_gcbAmount <= _gcbTotal, "Amount must be less than total tokens");
        uint256 currentRate =  _getRate();
        return _gcbAmount.div(currentRate);
    }

    function excludeAccount(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        if(_gcbOwned[account] > 0) {
            _gcbtOwned[account] = tokenFromGCB(_gcbOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _gcbtOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
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
        (uint256 _gcbAmount, uint256 rTransfe_gcbAmount, uint256 rFee, uint256 tTransfe_gcbAmount, uint256 tFee) = _getValues(tAmount);
        _gcbOwned[sender] = _gcbOwned[sender].sub(_gcbAmount);
        _gcbOwned[recipient] = _gcbOwned[recipient].add(rTransfe_gcbAmount);       
        _gcbFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransfe_gcbAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 _gcbAmount, uint256 rTransfe_gcbAmount, uint256 rFee, uint256 tTransfe_gcbAmount, uint256 tFee) = _getValues(tAmount);
        _gcbOwned[sender] = _gcbOwned[sender].sub(_gcbAmount);
        _gcbtOwned[recipient] = _gcbtOwned[recipient].add(tTransfe_gcbAmount);
        _gcbOwned[recipient] = _gcbOwned[recipient].add(rTransfe_gcbAmount);           
        _gcbFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransfe_gcbAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 _gcbAmount, uint256 rTransfe_gcbAmount, uint256 rFee, uint256 tTransfe_gcbAmount, uint256 tFee) = _getValues(tAmount);
        _gcbtOwned[sender] = _gcbtOwned[sender].sub(tAmount);
        _gcbOwned[sender] = _gcbOwned[sender].sub(_gcbAmount);
        _gcbOwned[recipient] = _gcbOwned[recipient].add(rTransfe_gcbAmount);   
        _gcbFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransfe_gcbAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 _gcbAmount, uint256 rTransfe_gcbAmount, uint256 rFee, uint256 tTransfe_gcbAmount, uint256 tFee) = _getValues(tAmount);
        _gcbtOwned[sender] = _gcbtOwned[sender].sub(tAmount);
        _gcbOwned[sender] = _gcbOwned[sender].sub(_gcbAmount);
        _gcbtOwned[recipient] = _gcbtOwned[recipient].add(tTransfe_gcbAmount);
        _gcbOwned[recipient] = _gcbOwned[recipient].add(rTransfe_gcbAmount);        
        _gcbFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransfe_gcbAmount);
    }

    function _gcbFee(uint256 rFee, uint256 tFee) private {
        _gcbTotal = _gcbTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransfe_gcbAmount, uint256 tFee) = _getTValues(tAmount);
        uint256 currentRate =  _getRate();
        (uint256 _gcbAmount, uint256 rTransfe_gcbAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (_gcbAmount, rTransfe_gcbAmount, rFee, tTransfe_gcbAmount, tFee);
    }

    function _getTValues(uint256 tAmount) private pure returns (uint256, uint256) {
        uint256 tFee = tAmount.div(100).mul(3500).div(1e3);
        uint256 tTransfe_gcbAmount = tAmount.sub(tFee);
        return (tTransfe_gcbAmount, tFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 _gcbAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransfe_gcbAmount = _gcbAmount.sub(rFee);
        return (_gcbAmount, rTransfe_gcbAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _gcbTotal;
        uint256 tSupply = _gcbtTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_gcbOwned[_excluded[i]] > rSupply || _gcbtOwned[_excluded[i]] > tSupply) return (_gcbTotal, _gcbtTotal);
            rSupply = rSupply.sub(_gcbOwned[_excluded[i]]);
            tSupply = tSupply.sub(_gcbtOwned[_excluded[i]]);
        }
        if (rSupply < _gcbTotal.div(_gcbtTotal)) return (_gcbTotal, _gcbtTotal);
        return (rSupply, tSupply);
    }
}