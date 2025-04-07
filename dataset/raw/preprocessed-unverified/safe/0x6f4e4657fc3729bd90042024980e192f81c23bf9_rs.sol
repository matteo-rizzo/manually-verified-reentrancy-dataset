/**
 *Submitted for verification at Etherscan.io on 2021-07-05
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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




contract ElonTerrestrial is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    address constant public burnAddr = 0x000000000000000000000000000000000000dEaD;
    address constant public zeroAddr = address(0);


    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000000 * 10**9; // 1T
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = 'Elon Terrestrial';
    string private _symbol = 'E.T';
    uint8 private _decimals = 9;

    // Tax and team fees will start at 0 so we don't have a big impact when deploying to Uniswap
    // Team wallet address is null but the method to set the address is exposed
    uint256 private _taxFee = 3;
    uint256 private _burnFee = 1;
    uint256 private _teamFee = 10;
    uint256 private _previousTaxFee = _taxFee;
    uint256 private _previousBurnFee = _burnFee;
    uint256 private _previousTeamFee = _teamFee;

    address payable public _tWallet;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwap = false;
    bool public swapEnabled = true;

    uint256 private _maxTxAmount = 200000000 * 10**2 * 10**18; // 20B
    uint256 private _numOfTokensToExchangeForTeam = 5 * 10**6; // 5M

    bool private isCooldownEnabled = true;
    mapping(address => uint256) private buycooldown;
    mapping(address => uint256) private sellcooldown;
    mapping(address => uint256) private firstsell;
    mapping(address => uint256) private sellnumber;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapEnabledUpdated(bool enabled);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address payable tWallet) public {
        _tWallet = tWallet;
        _rOwned[_msgSender()] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // UniswapV2 for Ethereum network

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[tWallet] = true;

        emit Transfer(zeroAddr, _msgSender(), _tTotal);
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

    function setExcludeFromFee(address account, bool excluded) external onlyOwner() {
        _isExcludedFromFee[account] = excluded;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeAccount(address account) external onlyOwner() {
        require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
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

    function removeAllFee() private {
        _previousTaxFee = _taxFee;
        _previousBurnFee = _burnFee;
        _previousTeamFee = _teamFee;

        _taxFee = 0;
        _burnFee = 0;
        _teamFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _burnFee = _previousBurnFee;
        _teamFee = _previousTeamFee;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != zeroAddr, "ERC20: approve from the zero address");
        require(spender != zeroAddr, "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != zeroAddr, "ERC20: transfer from the zero address");
        require(recipient != zeroAddr, "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // Enforce the max transfer amount only if
        //   - the sender/recipient is NOT the contract owner.
        //   - the receipient is NOT the team wallet
        if(sender != owner() && recipient != owner() && recipient != _tWallet) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        // Require buyers to wait at least 30 seconds between transactions.
        if (isCooldownEnabled && sender == uniswapV2Pair && recipient != address(uniswapV2Router) && !_isExcluded[recipient]) {
            require(buycooldown[recipient] < block.timestamp);
            buycooldown[recipient] = block.timestamp + (1 minutes);
        }

        // If this is a sell transaction, index the sell number
        // and cooldown period.
        //
        // NOTE This just enforces cooldown, it does NOT enforce
        // higher fees.
        if (isCooldownEnabled && sender != uniswapV2Pair && sender != address(uniswapV2Router)) {
            require(sellcooldown[sender] < block.timestamp);
            if(firstsell[sender] + (1 days) < block.timestamp){
                sellnumber[sender] = 0;
            }
            if (sellnumber[sender] == 0) {
                sellnumber[sender]++;
                firstsell[sender] = block.timestamp;
                sellcooldown[sender] = block.timestamp + (1 hours);
            }
            else if (sellnumber[sender] == 1) {
                sellnumber[sender]++;
                sellcooldown[sender] = block.timestamp + (2 hours);
            }
            else if (sellnumber[sender] == 2) {
                sellnumber[sender]++;
                sellcooldown[sender] = block.timestamp + (6 hours);
            }
            else if (sellnumber[sender] == 3) {
                sellnumber[sender]++;
                sellcooldown[sender] = firstsell[sender] + (1 days);
            }
        }

        // If the contract holds _enough_ tokens collected from the team fees,
        // then swap them for ETH and transfer to the wallet.
        uint256 contractTokenBalance = balanceOf(address(this));
        if(contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >= _numOfTokensToExchangeForTeam;
        if (!inSwap && swapEnabled && overMinTokenBalance && sender != uniswapV2Pair) {
            // We need to swap the current tokens to ETH and send to the team wallet
            swapTokensForEth(contractTokenBalance);

            uint256 contractETHBalance = address(this).balance;
            if(contractETHBalance > 0) {
                sendETHToTeam(address(this).balance);
            }
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            takeFee = false;
        }

        //transfer amount, it will take tax and team fee
        _tokenTransfer(sender,recipient,amount,takeFee);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap{
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function sendETHToTeam(uint256 amount) private {
        _tWallet.transfer(amount);
    }

    // We are exposing these functions to be able to manual swap and send
    // in case the token is highly valued and 5M becomes too much
    function manualSwap() external onlyOwner() {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualSend() external onlyOwner() {
        uint256 contractETHBalance = address(this).balance;
        sendETHToTeam(contractETHBalance);
    }

    function setSwapEnabled(bool enabled) external onlyOwner(){
        swapEnabled = enabled;
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private {
        if(!takeFee)
            removeAllFee();

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

        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 rBurn, uint256 tTransferAmount, uint256 tFee, uint256 tBurn, uint256 tTeam) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee, rBurn, tBurn);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 rBurn, uint256 tTransferAmount, uint256 tFee, uint256 tBurn, uint256 tTeam) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee, rBurn, tBurn);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 rBurn, uint256 tTransferAmount, uint256 tFee, uint256 tBurn, uint256 tTeam) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee, rBurn, tBurn);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 rBurn, uint256 tTransferAmount, uint256 tFee, uint256 tBurn, uint256 tTeam) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee, rBurn, tBurn);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeTeam(uint256 tTeam) private {
        uint256 currentRate =  _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tTeam);
    }

    function _reflectFee(uint256 rFee, uint256 tFee, uint256 rBurn, uint256 tBurn) private {
        _rTotal = _rTotal.sub(rFee).sub(rBurn);
        _tFeeTotal = _tFeeTotal.add(tFee);
        _rOwned[burnAddr] = _rOwned[burnAddr].add(rBurn);
        _tOwned[burnAddr] = _tOwned[burnAddr].add(tBurn);
    }

        //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tBurn, uint256 tTeam) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount) = _getRValues(tAmount, tFee, tBurn.mul(_getRate()));
        return (rAmount, rTransferAmount, tFee.mul(_getRate()), tBurn.mul(_getRate()), tTransferAmount, tFee, tBurn, tTeam);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(_taxFee).div(100);
        uint256 tBurn = tAmount.mul(_burnFee).div(100);
        uint256 tTeam = tAmount.mul(_teamFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tBurn).sub(tTeam);
        return (tTransferAmount, tFee, tBurn, tTeam);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 rBurn) private view returns (uint256, uint256) {
        uint256 currentRate =  _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(tFee.mul(currentRate)).sub(rBurn);
        return (rAmount, rTransferAmount);
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

    function _getTaxFee() private view returns(uint256) {
        return _taxFee;
    }

    function _getMaxTxAmount() private view returns(uint256) {
        return _maxTxAmount;
    }

    function _getETHBalance() public view returns(uint256 balance) {
        return address(this).balance;
    }

    function _setTaxFee(uint256 taxFee) external onlyOwner() {
        require(taxFee >= 1 && taxFee <= 25, 'taxFee should be in 1 - 25');
        _taxFee = taxFee;
    }

    function _setTeamFee(uint256 teamFee) external onlyOwner() {
        require(teamFee >= 1 && teamFee <= 25, 'teamFee should be in 1 - 25');
        _teamFee = teamFee;
    }

    function _setTeamWallet(address payable tWallet) external onlyOwner() {
        _tWallet = tWallet;
    }

    function _setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        require(maxTxAmount >= 100000000000000e9 , 'maxTxAmount should be greater than 100000000000000e9');
        _maxTxAmount = maxTxAmount;
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _tTotal.div(10**2).mul(maxTxPercent);
    }

    function setCooldown(bool onoff) external onlyOwner() {
    isCooldownEnabled = onoff;
    }
}