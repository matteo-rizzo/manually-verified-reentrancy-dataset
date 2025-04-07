/**
 *Submitted for verification at Etherscan.io on 2021-06-11
*/

pragma solidity ^0.8.5;
// SPDX-License-Identifier: Unlicensed
// By blocktool.app klair




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
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data; // msg.data is used to handle array, bytes, string 
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


contract CanX is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned; // reflected owned tokens
    mapping (address => uint256) private _tOwned; // total Owned tokens
    mapping (address => mapping (address => uint256)) private _allowances; // allowed allowance for spender
    mapping (address => bool) public _isExcludedFromAntiWhale; // Limits how many tokens can an address hold

    mapping (address => bool) private _isExcludedFromFee; // excluded address from all fee

    mapping (address => bool) private _isExcluded; // address excluded from reflection
    mapping (address => bool) private _isBlacklisted; // blocks an address from buy and selling

    address[] private _excluded; // storing reflection excluded address so, no reflection send to them
   
    address payable public _charityAddress = payable(0xFfE4a1cCDd4b16e1870e1e0C5F405d1C5c7aCd40); // Charity Address
    address public _marketingAddress = 0x86dF3A43D7e411726d977C34062E84F32E357DBA; //marketing Address
    address public _researchAddress = 0xfE45e0420D4f85D6c27d8Bc53469DAF875fddDa5;

    uint256 private constant MAX = ~uint256(0); // maximum possible number uint256 decimal value
    uint256 private _tTotal = 420 * 10**6 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal)); // maximum _rTotal value after subtracting _tTotal remainder
    uint256 private _tFeeTotal; // total fee collected including tax fee and liquidity fee

    string private _name = "CanX"; // token name
    string private _symbol = "CANX"; // token symbol
    uint8 private _decimals = 9; // 1 token can be divided into 10e_decimals parts
    
    // All fees are with one decimal value. so if you want 0.5 set value to 5, for 10 set 100. so on...

    // Below Fees to be deducted and sent as tokens
    uint256 public _burnFee = 10; // burn fee 1%
    uint256 private _previousBurnFee = _burnFee; // burn fee

    uint256 public _reflectionFee = 20; //reflection fee 2%
    uint256 private _previousReflectionFee = _reflectionFee; //reflection fee
    
    uint256 private _totalTaxFee = _burnFee.add(_reflectionFee); // burn+reflection
    uint256 private _previousTaxFee = _totalTaxFee; // restore old tax fee

    // Below Fees to be deducted and sent as ETH
    uint256 public _charityFee = 10; // charity fee 1%
    uint256 private _previousCharityFee = _charityFee; // charity fee

    
    uint256 public _liquidityFee = 20; // actual liquidity fee 2%
    uint256 private _previousLiquidityFee = _liquidityFee; // restore actual liquidity fee

    uint256 private _totalLiquidityFee = _charityFee.add(_liquidityFee); // liquidity + charity fee on each transaction
    uint256 private _previousTLiquidityFee = _totalLiquidityFee; // restore old liquidity fee

    IUniswapV2Router02 public uniswapV2Router; // uniswap router assiged using address
    address public uniswapV2Pair; // for creating WETH pair with our token
    
    bool inSwapAndLiquify; // after each successfull swapandliquify disable the swapandliquify
    bool public swapAndLiquifyEnabled = true; // set auto swap to ETH and liquify collected liquidity fee
    
    uint256 public _maxTxAmount = 6 * 10**6 * 10**_decimals; // max allowed tokens tranfer per transaction
    uint256 public  numTokensSellToAddToLiquidity = 500000 * 10**_decimals; // min token liquidity fee collected before swapandLiquify
    uint256 public _maxTokensPerAddress            = 84 * 10**6 * 10**_decimals; // Max number of tokens that an address can hold

    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap); //event fire min token liquidity fee collected before swapandLiquify 
    event SwapAndLiquifyEnabledUpdated(bool enabled); // event fire set auto swap to ETH and liquify collected liquidity fee
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    ); // fire event how many tokens were swapedandLiquified
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    } // modifier to after each successfull swapandliquify disable the swapandliquify
    
    constructor () {
        _rOwned[_msgSender()] = _rTotal; // assigning the max reflection token to owner's address  

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        
        //exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_charityAddress] = true;

        //Exclude's below addresses from per account tokens limit
        _isExcludedFromAntiWhale[owner()]           = true;
        _isExcludedFromAntiWhale[_marketingAddress] = true;
        _isExcludedFromAntiWhale[_researchAddress]  = true;
        _isExcludedFromAntiWhale[address(this)]     = true;
        _isExcludedFromAntiWhale[_charityAddress]   = true;
        _isExcludedFromAntiWhale[uniswapV2Pair]     = true;
        _isExcludedFromAntiWhale[address(_uniswapV2Router)] = true;

        //Exclude dead address from reflection
        _isExcluded[address(0)] = true;
        
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
    
    /**  
     * @dev approves allowance of a spender
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    /**  
     * @dev transfers from a sender to receipent with subtracting spenders allowance with each successfull transfer
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**  
     * @dev approves allowance of a spender should set it to zero first than increase
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**  
     * @dev decrease allowance of spender that it can spend on behalf of owner
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**  
     * @dev check if an address is excluded from reflection reward or not
     */
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    /**  
     * @dev Total collected Tax fee
     */
    function totalFeesCollected() public view returns (uint256) {
        return _tFeeTotal;
    }

    /**  
     * @dev gives reflected tokens to caller
     */
    function deliver(uint256 tAmount) public {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount,,,,,,) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
    }

    /**  
     * @dev return's reflected amount of an address from given token amount with/without fee deduction
     */
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

    /**  
     * @dev get's exact total tokens of an address from reflected amount
     */
    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    /**  
     * @dev excludes an address from reflection reward can only be set by owner
     */
    function excludeFromReward(address account) public onlyOwner() {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    /**  
     * @dev includes an address for reflection reward which was excluded before
     */
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


    /**  
     * @dev auto burn tokens with each transaction
     */
    function _burn(address account, uint256 amount) internal {
        if(amount > 0)// No need to burn if collected burn fee is zero
        {
            require(account != address(0), "BEP20: burn from the zero address");

            //add the reflections of the token to the address(0) balance.
            //This reduces the supply of reflectedTokens
            //without double altering the reflection/token ratio.
            
            _tOwned[address(0)] = _tOwned[address(0)].add(amount);
            emit Transfer(account, address(0), amount);
        }
    }
    
    /**  
     * @dev exclude an address from fee
     */
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    /**  
     * @dev include an address for fee
     */
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    /**  
     * @dev exclude an address from per address tokens limit
     */
    function excludedFromAntiWhale(address account) public onlyOwner {
        _isExcludedFromAntiWhale[account] = true;
    }

    /**  
     * @dev include an address in per address tokens limit
     */
    function includeInAntiWhale(address account) public onlyOwner {
        _isExcludedFromAntiWhale[account] = false;
    }
    
    /**  
     * @dev set's burn fee percentage
     */
    function setBurnFeePercent(uint256 Fee) external onlyOwner() {
        _burnFee = Fee;
        _totalTaxFee = _burnFee.add(_reflectionFee);
    }
    
    /**  
     * @dev set's charity fee percentage
     */
    function setCharityFeePercent(uint256 Fee) external onlyOwner() {
        _charityFee = Fee;
        _totalLiquidityFee = _liquidityFee.add(_charityFee);
    }

    /**  
     * @dev set's reflection fee percentage
     */
    function setReflectFeePercent(uint256 Fee) external onlyOwner() {
        _reflectionFee = Fee;
        _totalTaxFee = _burnFee.add(_reflectionFee);
    }
    
    /**  
     * @dev set's liquidity fee percentage
     */
    function setLiquidityFeePercent(uint256 Fee) external onlyOwner() {
        _liquidityFee = Fee;
        _totalLiquidityFee = _liquidityFee.add(_charityFee);
    }
   
    /**  
     * @dev set's max amount of tokens percentage 
     * that can be transfered in each transaction from an address
     */
    function setMaxTxTokens(uint256 maxTxTokens) external onlyOwner() {
        _maxTxAmount = maxTxTokens.mul( 10**_decimals );
    }

    /**  
     * @dev set's max amount of tokens
     * that an address can hold
     */
    function setMaxTokenPerAddress(uint256 maxTokens) external onlyOwner {
        _maxTokensPerAddress = maxTokens.mul( 10**_decimals );
    }

    /**  
     * @dev set's charity address
     */
    function setCharityAddress(address payable charityAddress) external onlyOwner() {
        _charityAddress = charityAddress;
    }

    /**  
     * @dev set's auto SwapandLiquify when contract's token balance threshold is reached
     */
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
     //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    /**  
     * @dev reflects to all holders, fee deducted from each transaction
     */
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    /**  
     * @dev get/calculates all values e.g taxfee, 
     * liquidity fee, actual transfer amount to receiver, 
     * deuction amount from sender
     * amount with reward to all holders
     * amount without reward to all holders
     */
    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tFee, uint256 bFee, uint256 tLiquidity) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, bFee, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, bFee, tLiquidity);
    }

    /**  
     * @dev get/calculates taxfee, liquidity fee
     * without reward amount
     */
    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateReflectionFee(tAmount);
        uint256 bFee = calculateBurnFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity).sub(bFee);
        return (tTransferAmount, tFee, bFee, tLiquidity);
    }

    /**  
     * @dev amount with reward, reflection from transaction
     * total deduction amount from sender with reward
     */
    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 bFee, uint256 currentRate) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rbFee = bFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rbFee);
        return (rAmount, rTransferAmount, rFee);
    }

    /**  
     * @dev gets current reflection rate
     */
    function _getRate() private view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    /**  
     * @dev gets total supply with/without deducted 
     * exclude caller's total owned and reflection owned 
     */
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
    
    /**  
     * @dev take's liquidity fee tokens from tansaction and saves in contract
     */
    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }
    
    /**  
     * @dev calculates burn fee tokens to be deducted
     */
    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10**3
        );
    }

    /**  
     * @dev calculates reflection fee tokens to be deducted
     */
    function calculateReflectionFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_reflectionFee).div(
            10**3
        );
    }

    /**  
     * @dev calculates liquidity fee tokens to be deducted
     */
    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_totalLiquidityFee).div(
            10**3
        );
    }
    
    /**  
     * @dev removes all fee from transaction if takefee is set to false
     */
    function removeAllFee() private {
        if(_totalTaxFee == 0 && _totalLiquidityFee == 0 && _burnFee == 0 &&
        _charityFee == 0 && _reflectionFee == 0 && _liquidityFee == 0) return;
        
        _previousLiquidityFee = _liquidityFee; 
        _previousBurnFee = _burnFee;
        _previousCharityFee = _charityFee;
        _previousReflectionFee = _reflectionFee;
        _previousTaxFee = _totalTaxFee;
        _previousTLiquidityFee = _totalLiquidityFee;
        
        _burnFee = 0;
        _charityFee = 0;
        _totalTaxFee = 0;
        _reflectionFee = 0;
        _liquidityFee = 0;
        _totalLiquidityFee = 0;
    }
    
    /**  
     * @dev restores all fee after exclude fee transaction completes
     */
    function restoreAllFee() private {
        _liquidityFee = _previousLiquidityFee;
        _burnFee = _previousBurnFee;
        _charityFee = _previousCharityFee;
        _reflectionFee = _previousReflectionFee;
        _totalTaxFee = _previousTaxFee;
        _totalLiquidityFee = _previousTLiquidityFee;
    }
    
    /**  
     * @dev checks if an address is excluded from fee
     */
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    /**  
     * @dev set's minimmun amount of tokens required 
     * before swaped and ETH send to charity wallet
     * same value will be used for auto swapandliquifiy threshold
     */
    function setMinTokensSendToCharity(uint256 minCharityValue) public onlyOwner()
    {
        numTokensSellToAddToLiquidity = minCharityValue.mul( 10**_decimals );
    }

    /**  
     * @dev approves amount of token spender can spend on behalf of an owner
     */
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**  
     * @dev transfers token from sender to recipient also auto 
     * swapsandliquify if contract's token balance threshold is reached
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_isExcludedFromAntiWhale[to] == true || balanceOf(to) + amount <= _maxTokensPerAddress,
        "Max tokens limit for this account reached. Or try lower amount");
        require(_isBlacklisted[from] == false, "You are banned");
        require(_isBlacklisted[to] == false, "The recipient is banned");
        if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        // is the token balance of this contract address over the min number of
        // tokens that we need to initiate a swap + liquidity lock?
        // also, don't get caught in a circular liquidity event.
        // also, don't swap & liquify if sender is uniswap pair.
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
            //add liquidity
            swapAndLiquify(contractTokenBalance);
        }
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }

    /**  
     * @dev swapsAndLiquify tokens to uniswap if swapandliquify is enabled
     */
    function swapAndLiquify(uint256 tokenBalance) private lockTheSwap {
        // first split contract into charity fee and liquidity fee
        uint256 liquidityAmount = tokenBalance;
        uint256 initialBalance = address(this).balance;

        if(_charityFee > 0)
        {
            uint256 charityAmount = tokenBalance.mul(_charityFee);
            charityAmount = charityAmount.div(_totalLiquidityFee);
            liquidityAmount = tokenBalance.sub(charityAmount);
            // swap charity tokens for ETH
            //swapTokensForEth(charityAmount);

            // send tokens to charity
            swapTokensForEth(_charityAddress, charityAmount);
            
            initialBalance = address(this).balance;
        }
        
        if(_liquidityFee > 0)
        {
            // split the liquidity token balance into halves
            uint256 half = liquidityAmount.div(2);
            uint256 otherHalf = liquidityAmount.sub(half);

            // capture the contract's current ETH balance.
            // this is so that we can capture exactly the amount of ETH that the
            // swap creates, and not make the liquidity event include any ETH that
            // has been manually sent to the contract

            // swap half liquidity tokens for ETH
            swapTokensForEth(address(this), half);
            
            // how much ETH did we just swap into?
            uint256 newBalance = address(this).balance.sub(initialBalance);

            // add liquidity to uniswap
            addLiquidity(owner(), otherHalf, newBalance);
            
            emit SwapAndLiquify(half, newBalance, otherHalf);
        }
    }

    // /**  
    //  * @dev swap charity fee tokens to ETH and send to charity wallet
    //  */
    // function swapToCharityETH(address payable recipient, uint256 tokenAmount) private {
    //     // generate the uniswap pair path of token -> weth
    //     address[] memory path = new address[](2);
    //     path[0] = address(this);
    //     path[1] = uniswapV2Router.WETH();

    //     _approve(address(this), address(uniswapV2Router), tokenAmount);

    //     // make the swap
    //     uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    //         tokenAmount,
    //         0, // accept any amount of ETH
    //         path,
    //         recipient,
    //         block.timestamp
    //     );
    // }

    /**  
     * @dev swap's exact amount of tokens for ETH if swapandliquify is enabled
     */
    function swapTokensForEth(address recipient, uint256 tokenAmount) private {
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
            recipient,
            block.timestamp
        );
    }

    /**  
     * @dev add's liquidy to uniswap if swapandliquify is enabled
     */
    function addLiquidity(address recipient, uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            recipient,
            block.timestamp
        );
    }

    //this method is responsible for taking all fee, if takeFee is true
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

    /**  
     * @dev deducteds balance from sender and 
     * add to recipient with reward for recipient only
     */
    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 bFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _burn(sender, bFee);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    /**  
     * @dev deducteds balance from sender and 
     * add to recipient with reward for sender only
     */
    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 bFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _burn(sender, bFee);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    /**  
     * @dev deducteds balance from sender and 
     * add to recipient with reward for both addresses
     */
    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 bFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _burn(sender, bFee);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    
    /**  
     * @dev Transfer tokens to sender and receiver address with both excluded from reward
     */
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 bFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

        _burn(sender, bFee);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    /**  
     * @dev Blacklist a singel wallet from buying and selling
     */
    function blacklistSingleWallet(address addresses) public onlyOwner(){
        if(_isBlacklisted[addresses] == true) return;
        _isBlacklisted[addresses] = true;
    }

    /**  
     * @dev Blacklist multiple wallets from buying and selling
     */
    function blacklistMultipleWallets(address[] calldata addresses) public onlyOwner(){
        for (uint256 i; i < addresses.length; ++i) {
            _isBlacklisted[addresses[i]] = true;
        }
    }
    
    /**  
     * @dev return's if a address is blacklisted or not
     */
    function isBlacklisted(address addresses) public view returns (bool){
        if(_isBlacklisted[addresses] == true)
            return true;
        return false;
    }
    
    /**  
     * @dev un blacklist a singel wallet from buying and selling
     */
    function unBlacklistSingleWallet(address addresses) external onlyOwner(){
         if(_isBlacklisted[addresses] == false) return;
        _isBlacklisted[addresses] = false;
    }

    /**  
     * @dev un blacklist multiple wallets from buying and selling
     */
    function unBlacklistMultipleWallets(address[] calldata addresses) public onlyOwner(){
        for (uint256 i; i < addresses.length; ++i) {
            _isBlacklisted[addresses[i]] = false;
        }
    }

    /**  
     * @dev recovers any tokens stuck in Contract's balance
     * NOTE! if ownership is renounced then it will not work
     * NOTE! Contract's Address and Owner's address MUST NOT
     * be excluded from reflection reward
     */
    function recoverTokens() public onlyOwner()
    {
        address recipient = _msgSender();
        uint256 tokensToRecover = balanceOf(address(this));
        uint256 currentRate =  _getRate();
        uint256 rtokensToRecover = tokensToRecover.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].sub(rtokensToRecover);
        _rOwned[recipient] = _rOwned[recipient].add(rtokensToRecover);
    }
    
    /**  
     * @dev recovers any ETH stuck in Contract's balance
     * NOTE! if ownership is renounced then it will not work
     */
    function recoverETH() public onlyOwner()
    {
        address payable recipient = _msgSender();
        if(address(this).balance > 0)
            recipient.transfer(address(this).balance);
    }
    
    //New Pancakeswap router version?
    //No problem, just change it!
    function setRouterAddress(address newRouter) public onlyOwner() {
        IUniswapV2Router02 _newPancakeRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newPancakeRouter.factory()).createPair(address(this), _newPancakeRouter.WETH());
        uniswapV2Router = _newPancakeRouter;
    }

}