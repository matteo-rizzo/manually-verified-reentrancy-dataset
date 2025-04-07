/**
 *Submitted for verification at Etherscan.io on 2021-07-21
*/

/**
 *Submitted for verification at Etherscan.io on 2021-07-18
 * Telegram:https://t.me/BODIINU
 * Twitter:https://twitter.com/bodiinu
*/
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}







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


contract BODI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1000000000 * 10**6 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    
    mapping (address => bool) private _isBlackListedBot;
    address[] private _blackListedBots;

    string private _name = 'Bodi Inu';
    string private _symbol = 'BODI';
    uint8 private _decimals = 9;
    uint256 public transfertimeout = 45 seconds;
    uint256 public _maxTxAmount = 20000000 * 10**6 * 10**9;
    
    address private _charityWalletAddress = 0xc9fA6383e25d81a0cCf643EE166f155e3e86dA65;
    uint256 public _taxFee = 1;
    uint256 private _previousTaxFee = _taxFee;
    
    uint256 public _charityFee = 1;
    uint256 private _previousCharityFee = _charityFee;
    uint256 public _liquidityFee = 1;
    uint256 private _previousLiquidityFee = _liquidityFee;

    address public uniswapPair;
    mapping (address => uint256) public lastBuy; 

    constructor () public {
        _rOwned[_msgSender()] = _rTotal;
        
        _isBlackListedBot[address(0x7589319ED0fD750017159fb4E4d96C63966173C1)] = true;
            _blackListedBots.push(address(0x7589319ED0fD750017159fb4E4d96C63966173C1));
            
            _isBlackListedBot[address(0x65A67DF75CCbF57828185c7C050e34De64d859d0)] = true;
            _blackListedBots.push(address(0x65A67DF75CCbF57828185c7C050e34De64d859d0));
            
            _isBlackListedBot[address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce)] = true;
            _blackListedBots.push(address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce));
            
            _isBlackListedBot[address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce)] = true;
            _blackListedBots.push(address(0xE031b36b53E53a292a20c5F08fd1658CDdf74fce));
    
            _isBlackListedBot[address(0xe516bDeE55b0b4e9bAcaF6285130De15589B1345)] = true;
            _blackListedBots.push(address(0xe516bDeE55b0b4e9bAcaF6285130De15589B1345));
    
            _isBlackListedBot[address(0xa1ceC245c456dD1bd9F2815a6955fEf44Eb4191b)] = true;
            _blackListedBots.push(address(0xa1ceC245c456dD1bd9F2815a6955fEf44Eb4191b));
    
            _isBlackListedBot[address(0xd7d3EE77D35D0a56F91542D4905b1a2b1CD7cF95)] = true;
            _blackListedBots.push(address(0xd7d3EE77D35D0a56F91542D4905b1a2b1CD7cF95));
    
            _isBlackListedBot[address(0xFe76f05dc59fEC04184fA0245AD0C3CF9a57b964)] = true;
            _blackListedBots.push(address(0xFe76f05dc59fEC04184fA0245AD0C3CF9a57b964));
    
            _isBlackListedBot[address(0xDC81a3450817A58D00f45C86d0368290088db848)] = true;
            _blackListedBots.push(address(0xDC81a3450817A58D00f45C86d0368290088db848));
    
            _isBlackListedBot[address(0x45fD07C63e5c316540F14b2002B085aEE78E3881)] = true;
            _blackListedBots.push(address(0x45fD07C63e5c316540F14b2002B085aEE78E3881));
    
            _isBlackListedBot[address(0x27F9Adb26D532a41D97e00206114e429ad58c679)] = true;
            _blackListedBots.push(address(0x27F9Adb26D532a41D97e00206114e429ad58c679));
            
            _isBlackListedBot[address(0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7)] = true;
            _blackListedBots.push(address(0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7));
            
            _isBlackListedBot[address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533)] = true;
            _blackListedBots.push(address(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533));
            
            _isBlackListedBot[address(0x1d6E8BAC6EA3730825bde4B005ed7B2B39A2932d)] = true;
            _blackListedBots.push(address(0x1d6E8BAC6EA3730825bde4B005ed7B2B39A2932d));
            
            _isBlackListedBot[address(0x000000000000084e91743124a982076C59f10084)] = true;
            _blackListedBots.push(address(0x000000000000084e91743124a982076C59f10084));

            _isBlackListedBot[address(0x6dA4bEa09C3aA0761b09b19837D9105a52254303)] = true;
            _blackListedBots.push(address(0x6dA4bEa09C3aA0761b09b19837D9105a52254303));
            
            _isBlackListedBot[address(0x323b7F37d382A68B0195b873aF17CeA5B67cd595)] = true;
            _blackListedBots.push(address(0x323b7F37d382A68B0195b873aF17CeA5B67cd595));
            
            _isBlackListedBot[address(0x000000005804B22091aa9830E50459A15E7C9241)] = true;
            _blackListedBots.push(address(0x000000005804B22091aa9830E50459A15E7C9241));
            
            _isBlackListedBot[address(0xA3b0e79935815730d942A444A84d4Bd14A339553)] = true;
            _blackListedBots.push(address(0xA3b0e79935815730d942A444A84d4Bd14A339553));
            
            _isBlackListedBot[address(0xf6da21E95D74767009acCB145b96897aC3630BaD)] = true;
            _blackListedBots.push(address(0xf6da21E95D74767009acCB145b96897aC3630BaD));
            
            _isBlackListedBot[address(0x0000000000007673393729D5618DC555FD13f9aA)] = true;
            _blackListedBots.push(address(0x0000000000007673393729D5618DC555FD13f9aA));
            
            _isBlackListedBot[address(0x00000000000003441d59DdE9A90BFfb1CD3fABf1)] = true;
            _blackListedBots.push(address(0x00000000000003441d59DdE9A90BFfb1CD3fABf1));
            
            _isBlackListedBot[address(0x59903993Ae67Bf48F10832E9BE28935FEE04d6F6)] = true;
            _blackListedBots.push(address(0x59903993Ae67Bf48F10832E9BE28935FEE04d6F6));
            
            _isBlackListedBot[address(0x000000917de6037d52b1F0a306eeCD208405f7cd)] = true;
            _blackListedBots.push(address(0x000000917de6037d52b1F0a306eeCD208405f7cd));
            
            _isBlackListedBot[address(0x7100e690554B1c2FD01E8648db88bE235C1E6514)] = true;
            _blackListedBots.push(address(0x7100e690554B1c2FD01E8648db88bE235C1E6514));
            
            _isBlackListedBot[address(0x72b30cDc1583224381132D379A052A6B10725415)] = true;
            _blackListedBots.push(address(0x72b30cDc1583224381132D379A052A6B10725415));
            
            _isBlackListedBot[address(0x9eDD647D7d6Eceae6bB61D7785Ef66c5055A9bEE)] = true;
            _blackListedBots.push(address(0x9eDD647D7d6Eceae6bB61D7785Ef66c5055A9bEE));

            _isBlackListedBot[address(0xfe9d99ef02E905127239E85A611c29ad32c31c2F)] = true;
            _blackListedBots.push(address(0xfe9d99ef02E905127239E85A611c29ad32c31c2F));
            
            _isBlackListedBot[address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b)] = true;
            _blackListedBots.push(address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b));
            
            _isBlackListedBot[address(0xc496D84215d5018f6F53E7F6f12E45c9b5e8e8A9)] = true;
            _blackListedBots.push(address(0xc496D84215d5018f6F53E7F6f12E45c9b5e8e8A9));

            _isBlackListedBot[address(0x59341Bc6b4f3Ace878574b05914f43309dd678c7)] = true;
            _blackListedBots.push(address(0x59341Bc6b4f3Ace878574b05914f43309dd678c7));

            _isBlackListedBot[address(0xe986d48EfeE9ec1B8F66CD0b0aE8e3D18F091bDF)] = true;
            _blackListedBots.push(address(0xe986d48EfeE9ec1B8F66CD0b0aE8e3D18F091bDF));

            _isBlackListedBot[address(0x4aEB32e16DcaC00B092596ADc6CD4955EfdEE290)] = true;
            _blackListedBots.push(address(0x4aEB32e16DcaC00B092596ADc6CD4955EfdEE290));
            
            _isBlackListedBot[address(0x136F4B5b6A306091b280E3F251fa0E21b1280Cd5)] = true;
            _blackListedBots.push(address(0x136F4B5b6A306091b280E3F251fa0E21b1280Cd5));
            
            _isBlackListedBot[address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b)] = true;
            _blackListedBots.push(address(0x39608b6f20704889C51C0Ae28b1FCA8F36A5239b));
            
            _isBlackListedBot[address(0x5B83A351500B631cc2a20a665ee17f0dC66e3dB7)] = true;
            _blackListedBots.push(address(0x5B83A351500B631cc2a20a665ee17f0dC66e3dB7));
            
        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
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
    
    
    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**2
        );
    }

    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
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

    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
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
        require(!_isBlackListedBot[sender], "You have no power here!");
 
        if (sender == uniswapPair){
            lastBuy[recipient] = block.timestamp; 
        }

        if (recipient == uniswapPair){
            require(block.timestamp >= lastBuy[sender] + transfertimeout, "lock 45 seconds after purchase");
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }        

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
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCharity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _takeCharity(tCharity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCharity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _takeLiquidity(tLiquidity);
        _takeCharity(tCharity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCharity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _takeLiquidity(tLiquidity);
        _takeCharity(tCharity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

     function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCharity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _takeLiquidity(tLiquidity);
        _takeCharity(tCharity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

     function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCharity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tCharity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity, tCharity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tCharity = calculateCharityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity).sub(tCharity);
        return (tTransferAmount, tFee, tLiquidity, tCharity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 tCharity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rCharity = tCharity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rCharity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function setUniswapPair(address pair) external onlyOwner() {
        uniswapPair = pair;
    }
    
    
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    function _takeCharity(uint256 tCharity) private {
        uint256 currentRate =  _getRate();
        uint256 rCharity = tCharity.mul(currentRate);
        _rOwned[_charityWalletAddress] = _rOwned[_charityWalletAddress].add(rCharity);
        if(_isExcluded[_charityWalletAddress])
            _tOwned[_charityWalletAddress] = _tOwned[_charityWalletAddress].add(tCharity);
    }
    
     function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**2
        );
    }

    function calculateCharityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_charityFee).div(
            10**2
        );
    }
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10**2
        );
    }
    
    function addBotToBlackList(address account) external onlyOwner() {
            require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not blacklist Uniswap router.');
            require(!_isBlackListedBot[account], "Account is already blacklisted");
            _isBlackListedBot[account] = true;
            _blackListedBots.push(account);
        }
    
      function removeBotFromBlackList(address account) external onlyOwner() {
            require(_isBlackListedBot[account], "Account is not blacklisted");
            for (uint256 i = 0; i < _blackListedBots.length; i++) {
                if (_blackListedBots[i] == account) {
                    _blackListedBots[i] = _blackListedBots[_blackListedBots.length - 1];
                    _isBlackListedBot[account] = false;
                    _blackListedBots.pop();
                    break;
                }
            }
        }
        
}