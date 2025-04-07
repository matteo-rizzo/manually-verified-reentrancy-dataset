/**
 *Submitted for verification at Etherscan.io on 2021-08-16
*/

//SPDX-License-Identifier: GPL-3.0-or-later
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
    address private _previousOwner;
    uint256 private _lockTime;

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







interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// Contract implementation
contract Gami is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded; // excluded from reward
    address[] private _excluded;
    mapping (address => bool) private _isBlackListedBot;
    address[] private _blackListedBots;

    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 10_000_000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tBurnTotal;

    string private _name = 'BezosBlastoff';
    string private _symbol = 'BBB';
    uint8 private _decimals = 9;

    uint256 private _burnFee = 0; // 0% burn

    uint256 private _marketingFee = 5; // 5% marketing
    uint256 private _developmentFee = 3; // 3% developer
    uint256 private _buyBackFee = 7; // 7% buy-back and burn

    uint256 private _swapEth = 5000 * 10**9;
    uint256 private _swapImpact = 10;

    uint256 private _previousBurnFee = _burnFee;

    uint256 private _previousMarketingFee = _marketingFee;
    uint256 private _previousDevelopmentFee = _developmentFee;
    uint256 private _previousBuyBackFee = _buyBackFee;

    address payable private _marketingWalletAddress = payable(0xccA3A312a3A6CD0C627D9b084f255118aAc8b2d8);
    address payable private _developmentWalletAddress = payable(0xf55242492c72C115e968111E7Bd4633b8405b248);
    address private immutable _deadWalletAddress = 0x000000000000000000000000000000000000dEaD;
    address private _ContractAddress = 0xa1ab427451F19dF7445a22dEa7073800Ea3b687f;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify = false;
    bool public swapAndLiquifyEnabled = true;
    bool public tradingOpen = false;

    uint256 private _maxTxAmount = _tTotal;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapETHForTokens(
        uint256 amountIn,
        address[] path
    );

    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () public {
        _rOwned[_msgSender()] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // UniswapV2 for Ethereum network
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;

        // Exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingWalletAddress] = true;
        _isExcludedFromFee[_developmentWalletAddress] = true;


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

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function setExcludeFromFee(address account, bool excluded) external onlyOwner() {
        _isExcludedFromFee[account] = excluded;
    }

    function totalBurn() public view returns (uint256) {
        return _tBurnTotal;
    }

    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,,) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) external onlyOwner() {
        require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
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

    function removeAllFee() private {
        if(_marketingFee == 0 && _developmentFee == 0 && _burnFee == 0 && _buyBackFee == 0) return;

        _previousMarketingFee = _marketingFee;
        _previousDevelopmentFee = _developmentFee;
        _previousBurnFee = _burnFee;
        _previousBuyBackFee = _buyBackFee;

        _marketingFee = 0;
        _developmentFee = 0;
        _burnFee = 0;
        _buyBackFee = 0;
    }

    function restoreAllFee() private {
        _marketingFee = _previousMarketingFee;
        _developmentFee = _previousDevelopmentFee;
        _burnFee = _previousBurnFee;
        _buyBackFee = _previousBuyBackFee;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
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
        require(!_isBlackListedBot[recipient], "You have no power here!");
        require(!_isBlackListedBot[tx.origin], "You have no power here!");

        if(sender != owner() && recipient != owner()) {
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
            // sorry about that, but sniper bots nowadays are buying multiple times, hope I have something more robust to prevent them to nuke the launch :-(
            if (sender == uniswapV2Pair) {
                require(tradingOpen, "Wait for opened trading");
                require(balanceOf(recipient) <= _maxTxAmount, "Already bought maxTxAmount, wait till check off");
                require(balanceOf(tx.origin) <= _maxTxAmount, "Already bought maxTxAmount, wait till check off");
            }
        }

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.

        if (!inSwapAndLiquify && swapAndLiquifyEnabled && sender != uniswapV2Pair) {
            swapTokens(amount, recipient == uniswapV2Pair);
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            takeFee = false;
        }

        //transfer amount, it will take tax and eth fee
        _tokenTransfer(sender, recipient, amount, takeFee);
    }

    event SwapAndLiquifyFailed(bytes failErr);

    function swapTokens(uint256 amount, bool isSell) private lockTheSwap {
        uint256 contractTokenBalance = balanceOf(address(this));
        uint256 contractEthBalance = address(this).balance;
        bool toSwapTokens = contractEthBalance < _swapEth;

        if (toSwapTokens) {
            uint256 maxAddedToSlipPage = amount.mul(_swapImpact).div(100);
            if (isSell && contractTokenBalance > maxAddedToSlipPage) {
                contractTokenBalance = maxAddedToSlipPage;
            }
            swapTokensForEth(contractTokenBalance);
        } else {
            uint256 toTransfer = contractEthBalance.mul(_marketingFee.add(_developmentFee)).div(_marketingFee.add(_developmentFee).add(_buyBackFee));

            sendETHToWallets(toTransfer);
            swapEthForTokens(_ContractAddress, contractEthBalance.sub(toTransfer));
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        try uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        ) {
            emit SwapTokensForETH(tokenAmount, path);
        } catch (bytes memory e) {
            emit SwapAndLiquifyFailed(e);
        }
    }

    function swapEthForTokens(address token, uint256 amount) private {
        // generate the uniswap pair path of weth -> token
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = token;

        _approve(address(this), address(uniswapV2Router), amount);

        // make the swap
        try uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            _deadWalletAddress,
            block.timestamp.add(300)
        ) {
            emit SwapETHForTokens(amount, path);
        } catch (bytes memory e) {
            emit SwapAndLiquifyFailed(e);
        }
    }

    function sendETHToWallets(uint256 amount) private {
        uint256 fees = _marketingFee.add(_developmentFee);
        uint256 marketing = amount.mul(_marketingFee).div(fees);
        _marketingWalletAddress.transfer(marketing);
        _developmentWalletAddress.transfer(amount.sub(marketing));
    }

    function openTrading() public onlyOwner {
        tradingOpen = true;
    }

    // We are exposing these functions to be able to manual swap and send
    // in case the token is highly valued and 5M becomes too much
    function manualSwap() external onlyOwner() {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualSend() public onlyOwner() {
        uint256 contractETHBalance = address(this).balance;
        sendETHToWallets(contractETHBalance);
    }

    function setSwapAndLiquifyEnabled(bool _swapAndLiquifyEnabled) external onlyOwner(){
        swapAndLiquifyEnabled = _swapAndLiquifyEnabled;
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
        (uint256 rAmount, uint256 rTransferAmount, uint256 rBurn, uint256 tTransferAmount, uint256 tBurn, uint256 tMarketingDevelopmentBuyBack) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeAllEthFees(tMarketingDevelopmentBuyBack);
        _reflectFee(rBurn, tBurn);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rBurn, uint256 tTransferAmount, uint256 tBurn, uint256 tMarketingDevelopmentBuyBack) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeAllEthFees(tMarketingDevelopmentBuyBack);
        _reflectFee(rBurn, tBurn);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rBurn, uint256 tTransferAmount, uint256 tBurn, uint256 tMarketingDevelopmentBuyBack) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeAllEthFees(tMarketingDevelopmentBuyBack);
        _reflectFee(rBurn, tBurn);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rBurn, uint256 tTransferAmount, uint256 tBurn, uint256 tMarketingDevelopmentBuyBack) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeAllEthFees(tMarketingDevelopmentBuyBack);
        _reflectFee(rBurn, tBurn);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeAllEthFees(uint256 tMarketingDevelopmentBuyBack) private {
        uint256 currentRate = _getRate();
        uint256 rMarketingDevelopmentBuyBack = tMarketingDevelopmentBuyBack.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarketingDevelopmentBuyBack);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tMarketingDevelopmentBuyBack);
    }

    function _reflectFee(uint256 rBurn, uint256 tBurn) private {
        _rTotal = _rTotal.sub(rBurn);
        _tBurnTotal = _tBurnTotal.add(tBurn);
        _tTotal = _tTotal.sub(tBurn);
    }

    //to recieve ETH from uniswapV2Router when swapping
    receive() external payable {}

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tBurn, uint256 tMarketingLiquidityFee) = _getTValues(tAmount, _burnFee, _marketingFee.add(_developmentFee).add(_buyBackFee));
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rBurn) = _getRValues(tAmount, tBurn, tMarketingLiquidityFee, currentRate);
        return (rAmount, rTransferAmount, rBurn, tTransferAmount, tBurn, tMarketingLiquidityFee);
    }

    function _getTValues(uint256 tAmount, uint256 burnFee, uint256 marketingDevelopmentBuyBack) private pure returns (uint256, uint256, uint256) {
        uint256 tBurn = tAmount.mul(burnFee).div(100);
        uint256 tMarketingDevelopmentBuyBack = tAmount.mul(marketingDevelopmentBuyBack).div(100);
        uint256 tTransferAmount = tAmount.sub(tBurn).sub(marketingDevelopmentBuyBack);
        return (tTransferAmount, tBurn, tMarketingDevelopmentBuyBack);
    }

    function _getRValues(uint256 tAmount, uint256 tBurn, uint256 tMarketingDevelopmentBuyBack, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rBurn = tBurn.mul(currentRate);
        // thanks myobu for finding bug here, now everybody need to deploy new contracts lmao..
        uint256 rMarketingDevelopmentBuyBack = tMarketingDevelopmentBuyBack.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rBurn).sub(rMarketingDevelopmentBuyBack);
        return (rAmount, rTransferAmount, rBurn);
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

    function _getMaxTxAmount() private view returns(uint256) {
        return _maxTxAmount;
    }

    function _getETHBalance() public view returns(uint256 balance) {
        return address(this).balance;
    }

    function _setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {
        require(maxTxAmount >= 10**9 , 'maxTxAmount should be greater than total 1e9');
        _maxTxAmount = maxTxAmount;
    }

    function recoverTokens(uint256 tokenAmount) public virtual onlyOwner() {
        _approve(address(this), owner(), tokenAmount);
        _transfer(address(this), owner(), tokenAmount);
    }

    function _setContractAddress(address ContractAddress) external onlyOwner() {
        _ContractAddress = ContractAddress;
    }

    function _setSwapEthLimit(uint256 swapEthLimit) external onlyOwner() {
        _swapEth = swapEthLimit;
    }

    function _setSwapImpact(uint256 swapImpact) external onlyOwner() {
        _swapImpact = swapImpact;
    }
}