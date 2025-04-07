/**
 *Submitted for verification at Etherscan.io on 2021-06-04
*/

pragma solidity ^0.8.4;
// SPDX-License-Identifier: Unlicensed




/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
 


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


/**
 * @dev Collection of functions related to the address type
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
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

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
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
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

contract DVT is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isCharity;
    address[] private _excluded;

    string private _NAME = "Darth";
    string private _SYMBOL = "DVT";
    uint256 private _DECIMALS = 18;
 

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    uint256 private numTokensSellToAddToLiquidity = 3000 * 10**18;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    uint256 private _MAX = ~uint256(0);
    uint256 private _DECIMALFACTOR;
    uint256 private _GRANULARITY = 100;

    uint256 private _tTotal;
    uint256 private _rTotal;

    uint256 private _tReflectionTotal;
    uint256 private _tLiquidityTotal;
    uint256 private _tCharityTotal;
   // uint256 private _tMarketingTotal;

    uint256 private _REFLECTION_FEE = 300;
    uint256 private _LIQUIDITY_FEE = 300;
    uint256 private _CHARITY_FEE = 200;
  
    // Track original fees to bypass fees for charity account
    uint256 private ORIG_REFLECTION_FEE;
    uint256 private ORIG_LIQUIDITY_FEE;
    uint256 private ORIG_CHARITY_FEE;
   // uint256 private ORIG_MARKETING_FEE;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    address private tokenOwner = msg.sender;
    
    address private CharityAddress = tokenOwner;

    constructor() {
        _DECIMALFACTOR = 10**uint256(_DECIMALS);
        _tTotal = 500000 * _DECIMALFACTOR;
        _rTotal = (_MAX - (_MAX % _tTotal));
        ORIG_REFLECTION_FEE = _REFLECTION_FEE;
        ORIG_LIQUIDITY_FEE = _LIQUIDITY_FEE;
        ORIG_CHARITY_FEE = _CHARITY_FEE;
      

        _isCharity[CharityAddress] = true;
        _rOwned[tokenOwner] = _rTotal;

      IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());


        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
       
        emit Transfer(address(0), tokenOwner, _tTotal);
    }

    function name() public view returns (string memory) {
        return _NAME;
    }

    function symbol() public view returns (string memory) {
        return _SYMBOL;
    }

    function decimals() public view returns (uint256) {
        return _DECIMALS;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "TOKEN20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "TOKEN20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function isCharity(address account) private view returns (bool) {
        return _isCharity[account];
    }

    function totalCharity() public view returns (uint256) {
        return _tCharityTotal;
    }


    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        Values memory values = _getValues(tAmount);
        uint256 rAmount = values.rAmount;
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tReflectionTotal = _tReflectionTotal.add(tAmount);
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            Values memory values = _getValues(tAmount);
            uint256 rAmount = values.rAmount;
            return rAmount;
        } else {
            Values memory values = _getValues(tAmount);
            uint256 rTransferAmount = values.rTransferAmount;
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    /*
     * @Dev removes the possibility of changing excluded accounts, thus locking in transparency.
     * Function gets changed from external to internal only. Will be called upon construction and never again.
     */
    function excludeAccount(address account) internal {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= _rOwned[_who]);
        _rOwned[_who] = _rOwned[_who].sub(_value);
        _tTotal = _tTotal.sub(_value);
        emit Transfer(_who, address(0), _value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "TOKEN20: approve from the zero address");
        require(spender != address(0), "TOKEN20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(
            sender != address(0),
            "TOKEN20: transfer from the zero address"
        );
        require(
            recipient != address(0),
            "TOKEN20: transfer to the zero address"
        );
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 limiter = (totalSupply() * 1) / 100;
        require(
            amount < limiter,
            "Maximum buy/sell order cannot exceed 1% of the total supply of currency."
        );

        uint256 contractTokenBalance = balanceOf(address(this));

        bool overMinTokenBalance =
            contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            sender != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        // Remove fees for transfers to and from charity account or to excluded account
        bool takeFee = true;
        if (
            _isCharity[sender] ||
            _isCharity[recipient] ||
            _isExcluded[recipient]
        ) {
            takeFee = false;
        }

        if (!takeFee) removeAllFee();

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

        if (!takeFee) restoreAllFee();
    }

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
            tokenOwner,
            block.timestamp
        );
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        Values memory values = _getValues(tAmount);
        uint256 rLiquidity = values.tLiquidity.mul(currentRate);
        uint256 rCharity = values.tCharity.mul(currentRate);
   
        _standardTransferContent(
            sender,
            recipient,
            values.rAmount,
            values.rTransferAmount
        );
        _sendToCharity(values.tCharity, sender);
        _reflectReflection(
            values.rFee,
            rLiquidity,
            rCharity,
            values.tReflection,
            values.tLiquidity,
            values.tCharity
          
        );
        emit Transfer(sender, recipient, values.tTransferAmount);
    }

    function _standardTransferContent(
        address sender,
        address recipient,
        uint256 rAmount,
        uint256 rTransferAmount
    ) private {
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        Values memory values = _getValues(tAmount);
        uint256 rLiquidity = values.tLiquidity.mul(currentRate);
        uint256 rCharity = values.tCharity.mul(currentRate);
  
        _excludedFromTransferContent(
            sender,
            recipient,
            values.tTransferAmount,
            values.rAmount,
            values.rTransferAmount
        );
        _sendToCharity(values.tCharity, sender);
        _reflectReflection(
            values.rFee,
            rLiquidity,
            rCharity,
            values.tReflection,
            values.tLiquidity,
            values.tCharity
      
        );
        emit Transfer(sender, recipient, values.tTransferAmount);
    }

    function _excludedFromTransferContent(
        address sender,
        address recipient,
        uint256 tTransferAmount,
        uint256 rAmount,
        uint256 rTransferAmount
    ) private {
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        Values memory values = _getValues(tAmount);
        uint256 rLiquidity = values.tLiquidity.mul(currentRate);
        uint256 rCharity = values.tCharity.mul(currentRate);
  
        _excludedToTransferContent(
            sender,
            recipient,
            tAmount,
            values.rAmount,
            values.rTransferAmount
        );
        _sendToCharity(values.tCharity, sender);
        _reflectReflection(
            values.rFee,
            rLiquidity,
            rCharity,
            values.tReflection,
            values.tLiquidity,
            values.tCharity
       
        );
        emit Transfer(sender, recipient, values.tTransferAmount);
    }

    function _excludedToTransferContent(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 rAmount,
        uint256 rTransferAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        Values memory values = _getValues(tAmount);
        uint256 rLiquidity = values.tLiquidity.mul(currentRate);
        uint256 rCharity = values.tCharity.mul(currentRate);
   
        _bothTransferContent(
            sender,
            recipient,
            tAmount,
            values.rAmount,
            values.tTransferAmount,
            values.rTransferAmount
        );
        _sendToCharity(values.tCharity, sender);
        _reflectReflection(
            values.rFee,
            rLiquidity,
            rCharity,
            values.tReflection,
            values.tLiquidity,
            values.tCharity
        
        );
        emit Transfer(sender, recipient, values.tTransferAmount);
    }

    function _bothTransferContent(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 rAmount,
        uint256 tTransferAmount,
        uint256 rTransferAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
    }

    function _reflectReflection(
        uint256 rFee,
        uint256 rLiquidity,
        uint256 rCharity,
        uint256 tReflection,
        uint256 tLiquidity,
        uint256 tCharity
      
    ) private {
        _rTotal = _rTotal.sub(rFee).sub(rLiquidity).sub(rCharity);
        _tReflectionTotal = _tReflectionTotal.add(tReflection);
        _tLiquidityTotal = _tLiquidityTotal.add(tLiquidity);
        _tCharityTotal = _tCharityTotal.add(tCharity);
   
        _tTotal = _tTotal.sub(tLiquidity);
        emit Transfer(address(this), address(0), tLiquidity);
    }

    struct Values {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rFee;
        uint256 tTransferAmount;
        uint256 tReflection;
        uint256 tLiquidity;
        uint256 tCharity;
      //  uint256 tMarketing;
    }

    function _getValues(uint256 tAmount) private view returns (Values memory) {
        uint256 tAmount1;
        {
            tAmount1 = tAmount;
        }
        TBasics memory tb =
            _getTBasics(
                tAmount,
                _REFLECTION_FEE,
                _LIQUIDITY_FEE,
                _CHARITY_FEE
             //   _MARKETING_FEE
            );
        uint256 tTransferAmount =
            getTTransferAmount(
                tAmount,
                tb.tReflection,
                tb.tLiquidity,
                tb.tCharity
           
            );
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rFee) =
            _getRBasics(tAmount1, tb.tReflection, currentRate);
        uint256 rTransferAmount =
            _getRTransferAmount(
                rAmount,
                rFee,
                tb.tLiquidity,
                tb.tCharity,
             
                currentRate
            );
        Values memory values =
            Values(
                rAmount,
                rTransferAmount,
                rFee,
                tTransferAmount,
                tb.tReflection,
                tb.tLiquidity,
                tb.tCharity
             
            );
        return values;
    }

    struct TBasics {
        uint256 tReflection;
        uint256 tLiquidity;
        uint256 tCharity;
      //  uint256 tMarketing;
    }

    function _getTBasics(
        uint256 tAmount,
        uint256 reflectionFee,
        uint256 liquidityFee,
        uint256 charityFee
     
    ) private view returns (TBasics memory) {
        uint256 tReflection =
            ((tAmount.mul(reflectionFee)).div(_GRANULARITY)).div(100);
        uint256 tLiquidity =
            ((tAmount.mul(liquidityFee)).div(_GRANULARITY)).div(100);
        uint256 tCharity =
            ((tAmount.mul(charityFee)).div(_GRANULARITY)).div(100);
     
        TBasics memory tb =
            TBasics(tReflection, tLiquidity, tCharity);
        return tb;
    }

    function getTTransferAmount(
        uint256 tAmount,
        uint256 tReflection,
        uint256 tLiquidity,
        uint256 tCharity
      //  uint256 tMarketing
    ) private pure returns (uint256) {
        return
            tAmount.sub(tReflection).sub(tLiquidity).sub(tCharity);
    }

    function _getRBasics(
        uint256 tAmount,
        uint256 tReflection,
        uint256 currentRate
    ) private pure returns (uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tReflection.mul(currentRate);
        return (rAmount, rFee);
    }

    function _getRTransferAmount(
        uint256 rAmount,
        uint256 rFee,
        uint256 tLiquidity,
        uint256 tCharity,
   //     uint256 tMarketing,
        uint256 currentRate
    ) private pure returns (uint256) {
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rCharity = tCharity.mul(currentRate);
        uint256 temp = rAmount.sub(rFee).sub(rLiquidity).sub(rCharity);
        return temp;
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _sendToCharity(
        uint256 tCharity,
        address sender
    ) private {
        uint256 currentRate = _getRate();
        uint256 rCharity = tCharity.mul(currentRate);
   
        _rOwned[CharityAddress] = _rOwned[CharityAddress].add(rCharity);
        _tOwned[CharityAddress] = _tOwned[CharityAddress].add(tCharity);
        emit Transfer(sender, CharityAddress, tCharity);
  
    }

    function removeAllFee() private {
        if (_REFLECTION_FEE == 0 && _LIQUIDITY_FEE == 0 && _CHARITY_FEE == 0)
            return;

        ORIG_REFLECTION_FEE = _REFLECTION_FEE;
        ORIG_LIQUIDITY_FEE = _LIQUIDITY_FEE;
        ORIG_CHARITY_FEE = _CHARITY_FEE;

        _REFLECTION_FEE = 0;
        _LIQUIDITY_FEE = 0;
        _CHARITY_FEE = 0;
    }

    function restoreAllFee() private {
        _REFLECTION_FEE = ORIG_REFLECTION_FEE;
        _LIQUIDITY_FEE = ORIG_LIQUIDITY_FEE;
        _CHARITY_FEE = ORIG_CHARITY_FEE;
    }
}