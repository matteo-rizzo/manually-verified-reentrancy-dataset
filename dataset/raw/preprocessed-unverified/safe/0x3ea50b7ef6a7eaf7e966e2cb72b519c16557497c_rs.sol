/**
 *Submitted for verification at Etherscan.io on 2021-02-08
*/

/*
    ____                __          __     ____                             
   / __ \ ____   _____ / /__ ___   / /_   / __ ) __  __ ____   ____   __  __
  / /_/ // __ \ / ___// //_// _ \ / __/  / __  |/ / / // __ \ / __ \ / / / /
 / _, _// /_/ // /__ / ,<  /  __// /_   / /_/ // /_/ // / / // / / // /_/ / 
/_/ |_| \____/ \___//_/|_| \___/ \__/  /_____/ \__,_//_/ /_//_/ /_/ \__, /  
                                                                   /____/   

Just for buying Rocket Bunny and holding it in your wallet, you will earn passive income that is deposited
directly into your wallet via frictionless yield on all transactions of Rocket Bunny.No staking required!

Rocket Bunny combines the most sought after tokenomics across DeFi: automatic liquidity adds, 
compounding yield, deflationary supply, liquidity provider rewards, and price shock protection.

Rocket Bunny is a deflationary token with a max circulating supply of 777 Quadrilion. Each transaction 
incurs a 4% tax that is distributed in four equal parts: 1% to holders, 1% burned to The Rabbit's Hole, 
1% locked liquidity, and 1% as a bonus to liquidity providers. As volume increases, the amount burned 
increases logarithmically, eventually leading to an exponential decrease in supply.

The Rabbit Hole burns do not stop, the instant holder rewards do not stop, the 2x rewards for liquidity 
providers do not stop, and the locked liquidity adds do not stop. This means the Rocket Bunny supply will 
become more scarce, your holdings will continue to increase, particularly if you are a liquidty provider 
earning 2x rewards, and the price floor for Rocket Bunny will continue to rise.

- Deflationary supply
- Rewards directly into your wallet
- 2x rewards for LP
- Automatic & locked liquidity adds
- Whale dump protection

web: rocketbunny.io
tg: @RocketBunnyChat

*/

// SPDX-License-Identifier: MIT

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







// pragma solidity >=0.5.0;




// pragma solidity >=0.5.0;






// pragma solidity >=0.6.2;





// pragma solidity >=0.6.2;



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



contract RocketBunny is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    //////////////////////////////////////////
    // start liquid variables etc.
    //////////////////////////////////////////

    IUniswapV2Router02 public immutable uniswapV2Router;
    //address public immutable uniswapV2Pair;
    address public uniswapV2Pair;
    address public _burnPool = 0x18159f21D6A2F72Dc97FC1d2ddEbCEcfa614142C;
    

    uint8 public _feeDecimals = 2;
    uint32 public _feePercentage = 200;
    uint128 private _minTokensBeforeSwap;
    
    uint256 public _totalBurnedLpTokens;
    
    bool inSwapAndLiquify;
    bool swappingInProgress;
    bool public _swapAndLiquifyEnabled;

    event FeeUpdated(uint8 _feeDecimals, uint32 _feePercentage);
    event MinTokensBeforeSwapUpdated(uint128 _minTokensBeforeSwap);
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

    //////////////////////////////////////////
    // end liquid variables etc.
    //////////////////////////////////////////

    // anti-dumping mechanism
    bool public _antiDumpToggle = false;
    uint256 public _maxSellAmount = 4;      // sell amount divided by this amount (4 = 25%)

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 777 * 10**15 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private _name = 'Rocket Bunny';
    string private _symbol = 'BUNNY';
    uint8 private _decimals = 9;

    constructor (

        //////////////////////////////////////////
        // start liquid constructor vars etc.
        //////////////////////////////////////////
        IUniswapV2Router02 _uniswapV2Router,
        uint128 minTokensBeforeSwap,
        bool swapAndLiquifyEnabled
        //////////////////////////////////////////
        // end liquid constructor vars etc.
        //////////////////////////////////////////
    ) public {
        _rOwned[_msgSender()] = _rTotal;
        
        emit Transfer(address(0), _msgSender(), _tTotal);

        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        //updateFee(_feeDecimals, _feePercentage);
        updateMinTokensBeforeSwap(minTokensBeforeSwap);
        updateSwapAndLiquifyEnabled(swapAndLiquifyEnabled);
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

    function antiDumpToggle(bool setting) public {
        _antiDumpToggle = setting;
    }

    function antiDumpAmount(uint256 divisor) public {
        _maxSellAmount = divisor;
    }


    function reflect(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) public view returns(uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount,,,,) = _getValues(tAmount);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount);
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

        // check if we're in the middle of liquidity add to avoid unnecessary transactions and save gas
        if(swappingInProgress){
            _transferBothExcluded(sender, recipient, amount);
            swappingInProgress = false;
        } else{
            if(_antiDumpToggle){
                if(recipient == address(uniswapV2Pair) || recipient == address(uniswapV2Router)){
                    uint256 senderBalance = balanceOf(sender);
                    uint256 threshold = (totalSupply().sub(balanceOf(_burnPool))).div(99);
                    if(senderBalance > threshold){
                        require(amount < senderBalance.div(4), "You can only sell 25% at a time if you hold 1% or more of supply!");
                    }
                }
            }

            ////////////////////////////////////////
            // adding liquidity lock mechanism here
            ////////////////////////////////////////

        

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinTokenBalance = contractTokenBalance >= _minTokensBeforeSwap;
            if (
                overMinTokenBalance &&
                !inSwapAndLiquify &&
                msg.sender != uniswapV2Pair &&
                _swapAndLiquifyEnabled
            ) {
                swappingInProgress = true;
                swapAndLiquify(contractTokenBalance);
            }

            // calculate the number of tokens to take as a fee
            uint256 liquidityFee = calculateTokenFee(
                amount,
                _feeDecimals,
                _feePercentage
            );

            // take the fee and send those tokens to this contract address
            // and then send the remainder of tokens to original recipient
            amount = amount.sub(liquidityFee);
            

            uint256 bonusLP = liquidityFee.div(2);
            uint256 tokensToLock = liquidityFee.sub(bonusLP);

            _transferToExcluded(sender, address(this), tokensToLock);
            _transferToExcluded(sender, address(uniswapV2Pair), bonusLP);

            ////////////////////////////////////////////////
            // end liquidity lock mechanism. carry on now...
            ////////////////////////////////////////////////

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
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);       
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);           
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);   
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);        
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
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
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    ////////////////////////////////////////////////
    // start liquidity lock functions
    ////////////////////////////////////////////////

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
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

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    /*
        calculates a percentage of tokens to hold as the fee
    */
    function calculateTokenFee(
        uint256 _amount,
        uint8 feeDecimals,
        uint32 feePercentage
    ) public pure returns (uint256 locked) {
        locked = _amount.mul(feePercentage).div(
            10**(uint256(feeDecimals) + 2)
        );
    }

    ///
    /// Ownership adjustments
    ///

    function updateFee(uint32 feePercentage)
        public
        onlyOwner
    {
        require(feePercentage <= 200, "Can't have a higher fee than 2%!");
        _feePercentage = feePercentage;
        emit FeeUpdated(_feeDecimals, _feePercentage);
    }

    function updateMinTokensBeforeSwap(uint128 minTokensBeforeSwap)
        public
        onlyOwner
    {
        _minTokensBeforeSwap = minTokensBeforeSwap;
        emit MinTokensBeforeSwapUpdated(_minTokensBeforeSwap);
    }

    function updateSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        _swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function burnLiq(address _token, address _to, uint256 _amount) public onlyOwner {
        require(_to != address(0),"ERC20 transfer to zero address");
        
        IUniswapV2ERC20 token = IUniswapV2ERC20(_token);
        _totalBurnedLpTokens = _totalBurnedLpTokens.sub(_amount);
        
        token.transfer(_burnPool, _amount);
    }

    receive() external payable {}

    ////////////////////////////////////////////////
    // end liquidity lock functions
    ////////////////////////////////////////////////
}