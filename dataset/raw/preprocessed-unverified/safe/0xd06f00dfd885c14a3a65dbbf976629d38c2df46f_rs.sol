/**
 *Submitted for verification at Etherscan.io on 2021-05-17
*/

/*
Celestial Shiba, invented by those who dream about an adventure throughout our galaxy. 
Community ran ERC20 meme token, buckle up for a wild ride.

Telegram: https://t.me/CelestialShiba
Twitter: https://twitter.com/Celestial_Shiba
Dextools: https://www.dextools.io/app/uniswap/pair-explorer/0x554778e029880cf61cde3D89d746980C4D51591d
Uniswap: https://app.uniswap.org/#/swap?inputCurrency=ETH&outputCurrency=0xd06F00dFd885c14a3a65dBbf976629D38C2df46f&use=V2

          Tokenomics
Total Supply: 1,000,000,000,000
Burn: 60%
LP: 27%
Team Wallet: 5%
Presale: 8%
LP will be locked before trading gets enabled!

            Fees
7%, redistributed back to all holders
5%, back to liquidity

       Antibot measures
30 second cooldown after buying for each individual buyer, 10 second cooldown after selling, to prevent bots from taking from regular buyers.
Buyer cooldown will be removed completely after 10 minutes or so, seller cooldown will remain.
Max buy limit for the first minute or two will be 0.5% of LP, or 1,350,000,000 tokens
after a few minutes it'll be raised to 1% of LP, or 2,700,000,000 tokens
then 2.5% of LP, or 6,750,000,000 tokens
then after 10 minutes or so it'll be lifted completely.
Known bots are blacklisted in hardcoded address list, their tokens get burnt.

If you prefer the pre-V3 Uniswap interface, they've got it stored on IPFS, links are on their GitHub.
http://bafybeiasnfpt2qtzbkzzqknuasqbydym5n7ym5tnbbjhjfxdyexc5u3i6i.ipfs.dweb.link//#/swap?inputCurrency=ETH&outputCurrency=https://app.uniswap.org/#/swap?inputCurrency=ETH&outputCurrency=0xd06F00dFd885c14a3a65dBbf976629D38C2df46f
is the link for this token if anyone wants to use that instead of the new interface.
*/
// SPDX-License-Identifier: None
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _previousOwner = _owner = msgSender;
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

contract CESHIB is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private bots;
    mapping (address => uint256) private cooldown;
    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1e30;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 private _cooldownBuyerTime = 30 seconds;
    uint256 private _cooldownSellerTime = 10 seconds;

    string private _name = "Celestial Shiba";
    string private _symbol = "CESHIB";
    uint8 private _decimals = 18;

    uint256 public _taxFee = 7;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _liquidityFee = 5;
    uint256 private _previousLiquidityFee = _liquidityFee;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public tradingEnabled = false;
    bool public cooldownBuys = true;
    bool public cooldownSells = true;
    uint256 public _maxTxAmount = 1.35e27; // 0.5% of initial LP, then 1%, then %2.5%, then 100%
    uint256 private numTokensSellToAddToLiquidity = 1.35e10; // liquidate when this reaches 5% of initial LP

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () public {
        _rOwned[_msgSender()] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[_msgSender()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
        addBot(0xfe9d99ef02E905127239E85A611c29ad32c31c2F);
        addBot(0xe2A9C0687d8E9158021D9B63d0E873210cb93036);
        addBot(0x58A85E70A5a179B5Ec13D10cDa5C779D73Db5125);
        addBot(0xec7AC223c27fA967eF79d38fa43A37Eecd9a3401);
        addBot(0xe516bDeE55b0b4e9bAcaF6285130De15589B1345);
        addBot(0x7736c2bec1E3ec01FB82c209Cd3E9f3971C9A011);
        addBot(0x6c8E34793f2b73C80cb225D73CE411B805656992);
        addBot(0x089fA1Cc60a9a370ac5B65ed859Ea63d13f9ffAc);
        addBot(0x0cec4474E6B78e2703dcaAe57De283F96a34614e);
        addBot(0xF080f77fC1BD23dffA7D2340D6673cD2Ee12e12E);
        addBot(0x29a737Ce31dD8a1850F14536fe3bA72805449b55);
        addBot(0x9e64e525DA3eC2b9749a42347AfBFa56F64fB90C);
        addBot(0xfad95B6089c53A0D1d861eabFaadd8901b0F8533);
        addBot(0x575C3a99429352EDa66661fC3857b9F83f58a73f);
        addBot(0x27F9Adb26D532a41D97e00206114e429ad58c679);
        addBot(0xf6da21E95D74767009acCB145b96897aC3630BaD);
        addBot(0x000000005804B22091aa9830E50459A15E7C9241);
        addBot(0x78A55B9b3BBEffB36A43D9905F654d2769dC55e8);
        addBot(0x000000005736775Feb0C8568e7DEe77222a26880);
        addBot(0xFcA8852F7998633524dB884E3076239185793B92);
        addBot(0x9eDD647D7d6Eceae6bB61D7785Ef66c5055A9bEE);
        addBot(0x6dA4bEa09C3aA0761b09b19837D9105a52254303);
        addBot(0x33015Cc952f8423cebCb3D68598792eF97C4a0a8);
        addBot(0x1d6E8BAC6EA3730825bde4B005ed7B2B39A2932d);
        addBot(0x4265D0360d9A1974f6cb9d4c11614f363ddC7753);
        addBot(0xD644C1B56c3F8FAA7beB446C93dA2F190bFaeD9B);
        addBot(0x160de604EE9e6149050731Da33222EfCFff1B5d0);
        addBot(0xF1e4aF05BACC0190BDF14bBf809621fe8E03c095);
        addBot(0x9282dc5c422FA91Ff2F6fF3a0b45B7BF97CF78E7);
        addBot(0xf875C9813BB895A067901B0FF3aACF6b6DFB994B);
        addBot(0x231DC6af3C66741f6Cf618884B953DF0e83C1A2A);
        addBot(0xB6BF45f59B94d31af2b51A5547eF17FF81672743);
        addBot(0xD78A3280085Ee846196cB5fab7D510B279486d44);
        addBot(0x0cCe0Ad23F0238E6c0d6a0f8e3FA7B3F963B10Ca);
        addBot(0x2c5bA68E44fb6CC7f1312E8419102a07112E0916);
    }

    function name() public view override returns (string memory) {
        return _name;
    }
    
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
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

    function excludeFromReward(address account) public onlyOwner() {
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
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
        emit Transfer(sender, address(this), tLiquidity);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function setCooldown(bool buys, bool sells, uint256 buysT, uint256 sellsT) public onlyOwner {
        cooldownBuys = buys;
        cooldownSells = sells;
        _cooldownBuyerTime = buysT;
        _cooldownSellerTime = sellsT;
    }
    
    function addBot(address account) public onlyOwner {
        bots[account] = !bots[account];
    }
    
    function delBot(address account) public onlyOwner {
        bots[account] = false;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setTaxFeePercent(uint256 taxFee) public onlyOwner() {
        _taxFee = taxFee;
    }

    function setnumTokensSellToAddToLiquidity(uint256 num) public onlyOwner() {
        numTokensSellToAddToLiquidity = num;
    }
    
    function setLiquidityFeePercent(uint256 liquidityFee) public onlyOwner() {
        _liquidityFee = liquidityFee;
    }

    function setMaxTx(uint256 amount) external onlyOwner() {
        _maxTxAmount = amount;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function enableTrading(bool _tradingEnabled) external onlyOwner() {
        tradingEnabled = _tradingEnabled;
    }

    receive() external payable {}
	
	function withdraw() onlyOwner public returns(bool success)  {
        uint256 amount = address(this).balance;
        msg.sender.transfer(amount);
        return true;
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
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

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_taxFee).div(
            10**2
        );
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10**2
        );
    }

    function removeAllFee() private {
        if(_taxFee == 0 && _liquidityFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;

        _taxFee = 0;
        _liquidityFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
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

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        if (from != owner()) {
            require(tradingEnabled, "Trading is not enabled yet");
        }
        if ((to != address(uniswapV2Router)) && (to != owner()) && (cooldownBuys)) {
            require(block.timestamp >= cooldown[to] + _cooldownBuyerTime,"cooldown buyer");
            cooldown[to] = block.timestamp;
        }
        if ((from != address(uniswapV2Router)) && (from != owner())) {
            require(!bots[from]);
            if (cooldownSells) {
                require(block.timestamp >= cooldown[from] + _cooldownSellerTime,"cooldown seller");
                cooldown[from] = block.timestamp;
            }
        }
        
        uint256 contractTokenBalance = balanceOf(address(this));

        if(contractTokenBalance >= _maxTxAmount)
        {
            contractTokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance);
        }

        bool takeFee = true;

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
		
        _tokenTransfer(from,to,amount,takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = address(this).balance;
		
        swapTokensForEth(half);

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);
        
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
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
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        require(!bots[sender]);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
        emit Transfer(sender, address(this), tLiquidity);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
        emit Transfer(sender, address(this), tLiquidity);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
        emit Transfer(sender, address(this), tLiquidity);
    }
}