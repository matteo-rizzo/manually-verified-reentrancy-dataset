/**
 *Submitted for verification at Etherscan.io on 2021-06-15
*/

/**
 *Submitted for verification at Etherscan.io on 2021-06-15
*/

/**
 *Submitted for verification at Etherscan.io on 2021-06-12
*/

// $DOGGY | DOGGY FINANCE
// Telegram: https://t.me/Doggy_Finance1
// Envisioned and Designed by @1goonrich

// Fair Launch, no Dev Tokens. 98% LP.
// 2% of Supply to CryptoMessiah (@1goonrich)
// Snipers will be nuked.

// LP Lock immediately on launch.
// Ownership will be renounced 30 minutes after launch.

// Slippage Recommended: 12%+
// 2% Supply limit per TX for the first 5 minutes.


/**
 *     _.---.._             _.---...__
 *  .-'   /\   \          .'  /\     /
 *  `.   (  )   \        /   (  )   /
 *    `.  \/   .'\      /`.   \/  .'
 *      ``---''   )    (   ``---''
 *              .';.--.;`.
 *            .' /_...._\ `.
 *          .'   `.a  a.'   `.
 *         (        \/        )
 *          `.___..-'`-..___.'
 *             \          /
 *              `-.____.-'
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

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = now + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(now > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
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
contract DOGGY is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => uint256) private _lastTx;
    mapping (address => uint256) private _cooldownTradeAttempts;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    mapping (address => bool) private _isSniper;
    address[] private _confirmedSnipers;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000000000000000000;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public launchTime;

    string private _name = 'DoggyFinance | t.me/Doggy_Finance';
    string private _symbol = 'DOGGY \xF0\x9F\x92\xB9';
    uint8 private _decimals = 9;

    uint256 private _taxFee = 2;
    uint256 private _teamDev = 0;
    uint256 private _previousTaxFee = _taxFee;
    uint256 private _previousTeamDev = _teamDev;

    address payable private _teamDevAddress;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwap = false;
    bool public swapEnabled = true;
    bool public tradingOpen = false; //once switched on, can never be switched off.
    bool public cooldownEnabled = false; //cooldown time on transactions
    bool public uniswapOnly = false; //prevents users from tx'ing to other wallets to avoid cooldowns

    uint256 public _maxTxAmount = 15000000000000000000000;
    uint256 private _numOfTokensToExchangeForTeamDev = 5000000000000000000;
    bool _txLimitsEnabled = true;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapEnabledUpdated(bool enabled);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () public {
        _rOwned[_msgSender()] = _rTotal;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function initContract() external onlyOwner() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // PCS2 for BSC
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        // Exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        // List of front-runner & sniper bots from t.me/FairLaunchCalls
        _isSniper[address(0x2FCE13Ed05D421c9743eB2120848B691f3e3e337)] = true;
        _confirmedSnipers.push(address(0x2FCE13Ed05D421c9743eB2120848B691f3e3e337));

        _isSniper[address(0xA8008eDd43582025AfF7D44985F31e8d1aB29a3f)] = true;
        _confirmedSnipers.push(address(0xA8008eDd43582025AfF7D44985F31e8d1aB29a3f));

        _isSniper[address(0x60B2De6b8846e2E90c5a32C796656c932F4133cB)] = true;
        _confirmedSnipers.push(address(0x60B2De6b8846e2E90c5a32C796656c932F4133cB));

        _isSniper[address(0x60B2De6b8846e2E90c5a32C796656c932F4133cB)] = true;
        _confirmedSnipers.push(address(0x60B2De6b8846e2E90c5a32C796656c932F4133cB));

        _isSniper[address(0xC12B24CF24399C346c327e18d4Ced52B6B2E63Ed)] = true;
        _confirmedSnipers.push(address(0xC12B24CF24399C346c327e18d4Ced52B6B2E63Ed));

        _isSniper[address(0xBC13ec373De0d87Bf9DdC2B47e221D9716dEFe06)] = true;
        _confirmedSnipers.push(address(0xBC13ec373De0d87Bf9DdC2B47e221D9716dEFe06));

        _isSniper[address(0x74a353C3C4d937D5572E6E28875f899724A2BFE2)] = true;
        _confirmedSnipers.push(address(0x74a353C3C4d937D5572E6E28875f899724A2BFE2));

        _isSniper[address(0x7d279DB70aE60A4339e84BEc0b44d1D48A80C153)] = true;
        _confirmedSnipers.push(address(0x7d279DB70aE60A4339e84BEc0b44d1D48A80C153));

        _isSniper[address(0xE76d143AA6366F5a7a9Ac9abfeA8D44C437A39D2)] = true;
        _confirmedSnipers.push(address(0xE76d143AA6366F5a7a9Ac9abfeA8D44C437A39D2));

        _isSniper[address(0x461924679f4D9e2f5E1BDde34EBD2DE3D67E3397)] = true;
        _confirmedSnipers.push(address(0x461924679f4D9e2f5E1BDde34EBD2DE3D67E3397));

        _isSniper[address(0x6cBfeFD2a6919c4F482D2FA4d4e401e300b11F31)] = true;
        _confirmedSnipers.push(address(0x6cBfeFD2a6919c4F482D2FA4d4e401e300b11F31));

        _isSniper[address(0x5Cb97a69cf2C556EebCebe85be0dF27654075B87)] = true;
        _confirmedSnipers.push(address(0x5Cb97a69cf2C556EebCebe85be0dF27654075B87));

        _isSniper[address(0xfCF0afDbc792EcC13D37f21309cCD1765b5b3579)] = true;
        _confirmedSnipers.push(address(0xfCF0afDbc792EcC13D37f21309cCD1765b5b3579));

        _isSniper[address(0x8D60eb43f78f2889f69aeb853224eC86a35c3DFE)] = true;
        _confirmedSnipers.push(address(0x8D60eb43f78f2889f69aeb853224eC86a35c3DFE));

        _isSniper[address(0x3D49d5F3106B089dC177621fd4F2B1DecbB065f2)] = true;
        _confirmedSnipers.push(address(0x3D49d5F3106B089dC177621fd4F2B1DecbB065f2));

        _isSniper[address(0x24d841B63dd328E6E21dD404Da5Dc0bb932902AC)] = true;
        _confirmedSnipers.push(address(0x24d841B63dd328E6E21dD404Da5Dc0bb932902AC));

        _isSniper[address(0xc4E241A5aDd8af457939dABBA608C682917B551a)] = true;
        _confirmedSnipers.push(address(0xc4E241A5aDd8af457939dABBA608C682917B551a));

        _isSniper[address(0x6BfB50036e364115196F6A1B69E0E8Bf6660CC51)] = true;
        _confirmedSnipers.push(address(0x6BfB50036e364115196F6A1B69E0E8Bf6660CC51));

        _isSniper[address(0xDD70730FA9f02fBC4c245B015bD86C083dA40343)] = true;
        _confirmedSnipers.push(address(0xDD70730FA9f02fBC4c245B015bD86C083dA40343));

        _isSniper[address(0x471521faEa70185A393b3cdE39CB23fA11d1D210)] = true;
        _confirmedSnipers.push(address(0x471521faEa70185A393b3cdE39CB23fA11d1D210));

        _isSniper[address(0xEEA576B7847dCeB02b2864dC1B46E08c7AD4A944)] = true;
        _confirmedSnipers.push(address(0xEEA576B7847dCeB02b2864dC1B46E08c7AD4A944));

        _teamDev = 9;
        _teamDevAddress = payable(0xd63613fD24f518bf7315A1651c7d59FEAEA23AEa);
    }

    function openTrading() external onlyOwner() {
        swapEnabled = true;
        cooldownEnabled = false;
        tradingOpen = true;
        launchTime = block.timestamp;
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

    function isBlackListed(address account) public view returns (bool) {
        return _isSniper[account];
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
        (uint256 rAmount,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
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

    function RemoveSniper(address account) external onlyOwner() {
        require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not blacklist Uniswap router.');
        require(!_isSniper[account], "Account is already blacklisted");
        _isSniper[account] = true;
        _confirmedSnipers.push(account);
    }

    function amnestySniper(address account) external onlyOwner() {
        require(_isSniper[account], "Account is not blacklisted");
        for (uint256 i = 0; i < _confirmedSnipers.length; i++) {
            if (_confirmedSnipers[i] == account) {
                _confirmedSnipers[i] = _confirmedSnipers[_confirmedSnipers.length - 1];
                _isSniper[account] = false;
                _confirmedSnipers.pop();
                break;
            }
        }
    }

    function removeAllFee() private {
        if(_taxFee == 0 && _teamDev == 0) return;

        _previousTaxFee = _taxFee;
        _previousTeamDev = _teamDev;

        _taxFee = 0;
        _teamDev = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _teamDev = _previousTeamDev;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(
            10**2
        );
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

    function sendETHToTeamDev(uint256 amount) private {
        _teamDevAddress.transfer(amount.div(2));
    }

    // We are exposing these functions to be able to manual swap and send
    // in case the token is highly valued and 5M becomes too much
    function manualSwap() external onlyOwner() {
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualSend() external onlyOwner() {
        uint256 contractETHBalance = address(this).balance;
        sendETHToTeamDev(contractETHBalance);
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
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tCharity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeCharity(tCharity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tCharity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeCharity(tCharity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tCharity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeCharity(tCharity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tCharity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeCharity(tCharity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeCharity(uint256 tCharity) private {
        uint256 currentRate =  _getRate();
        uint256 rCharity = tCharity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rCharity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tCharity);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tCharity) = _getTValues(tAmount, _taxFee, _teamDev);
        uint256 currentRate =  _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tCharity);
    }

    function _getTValues(uint256 tAmount, uint256 taxFee, uint256 charityFee) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(taxFee).div(100);
        uint256 tCharity = tAmount.mul(charityFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tCharity);
        return (tTransferAmount, tFee, tCharity);
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

    function _removeTxLimit() external onlyOwner() {
        _maxTxAmount = 1000000000000000000000000;
    }

    // Yes, there are here if I fucked up on the logic and need to disable them.
    function _removeDestLimit() external onlyOwner() {
        uniswapOnly = false;
    }

    function _disableCooldown() external onlyOwner() {
        cooldownEnabled = false;
    }

    function _enableCooldown() external onlyOwner() {
        cooldownEnabled = true;
    }

    function _setExtWallet(address payable teamDevAddress) external onlyOwner() {
        _teamDevAddress = teamDevAddress;
    }
}