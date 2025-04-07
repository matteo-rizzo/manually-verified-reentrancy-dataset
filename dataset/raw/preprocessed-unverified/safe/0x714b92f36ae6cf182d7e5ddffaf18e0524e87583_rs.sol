/**
 *Submitted for verification at Etherscan.io on 2021-06-26
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





contract harbour is Context, Ownable, IERC20 {

    // Libraries
	using SafeMath for uint256;
	using SafeMath for uint8;
    using Address for address;
    
    // Attributes for ERC-20 token
    string private _name = "Harbour";
    string private _symbol = "HBR";
    uint8 private _decimals = 9;
    
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    uint256 private _total = 10**15 * 10**9;
    uint256 private maxTxAmount = 3500000 * 10**6 * 10**9;
    uint256 private numTokensSellToAddToLiquidity = 350000 * 10**6 * 10**9;
    uint256 private minHoldingThreshold = 100 * 10**6 * 10**9;
    
    uint8 public tax = 5;
    uint8 public burnableFundRate = 2;
    uint8 public operationalFundRate = 2;
    uint8 public percentOfTheLiquidityStore = 1;
    
    address public addressForTheLiquidityStore;
    address public operationalAddress;
    address[] private _holders;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    IUniswapV2Router02 public immutable uniSwapV2Router;
    address public immutable uniswapV2Pair;

	struct Entity {
		address _key;
		bool _isValid;
		uint256 _createdAt;
	}
	mapping (address => uint256) private addressToIndex;
	mapping (uint256 => Entity) private indexToEntity;
	uint256 private lastIndexUsed = 1;
	uint256 private lastEntryAllowed = 0;
	
	uint32 public perBatchSize = 100;

    constructor () {
	    _balance[_msgSender()] = _total;
	    addEntity(_msgSender());
	    
        inSwapAndLiquify = true;
        addressForTheLiquidityStore = address(0xd0b5636B8939b646181672B36254a6AfC0866779);
        operationalAddress = address(0x6464C435f0a7AE177263748ceF422662839f75A8);
	    
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
    // additional functions
    function changeAddressForTheLiquidityStore(address _newLiquidityStoreAddress) onlyOwner public {
        addressForTheLiquidityStore = _newLiquidityStoreAddress;
    }
    
    function changePercentOfTheLiquidityStore(uint8 _newPercent) onlyOwner public {
        require(_newPercent>=100, "Invalid Percent");
        require(_newPercent<=0, "Invalid Percent");
        percentOfTheLiquidityStore = _newPercent;
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
    

    function burnToken(uint256 amount) public onlyOwner virtual {
        require(amount <= _balance[address(this)], "Cannot burn more than avilable balancec");

        _balance[address(this)] = _balance[address(this)].sub(amount);
        _total = _total.sub(amount);

        emit Transfer(address(this), address(0), amount);
    }
    
    
    function getminHoldingThreshold() public view returns (uint256) {
        return minHoldingThreshold;
    }
    
    function getMaxTxnAmount() public view returns (uint256) {
        return maxTxAmount;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
    	swapAndLiquifyEnabled = _enabled;
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
    

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }
    
    function _transfer(address fromAddress, address toAddress, uint256 amount) private {
        require(fromAddress != address(0) && toAddress != address(0), "ERC20: transfer from/to the zero address");
        require(amount > 0 && amount <= _balance[fromAddress], "Transfer amount invalid");
        if(fromAddress != owner() && toAddress != owner()){
            require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }
        
        
        _balance[fromAddress] = _balance[fromAddress].sub(amount);
        uint256 totalTaxPercent = tax.add(burnableFundRate).add(operationalFundRate).add(percentOfTheLiquidityStore);
        uint256 receivePercent = uint256(100).sub(totalTaxPercent);
        
        uint256 transactionTokenAmount = receivePercent.mul(amount).div(uint256(100));
        _balance[toAddress] = _balance[toAddress].add(transactionTokenAmount);
        
        uint256 transactionLiquidityAmount = percentOfTheLiquidityStore.mul(amount).div(uint256(100));
        _balance[addressForTheLiquidityStore] = _balance[addressForTheLiquidityStore].add(transactionLiquidityAmount);
        
        uint256 transactionOperationalAmount = operationalFundRate.mul(amount).div(uint256(100));
        _balance[operationalAddress] = _balance[operationalAddress].add(transactionOperationalAmount);
        
        uint256 reflectionAmount = tax.mul(amount).div(uint256(100));
        for(uint i=0; i<_holders.length; i++){
            if(_balance[_holders[i]]>=minHoldingThreshold && _holders[i] != address(this)){
                _balance[_holders[i]].add(reflectionAmount/_holders.length);
            }
        }
        
        uint256 transactionBurnAmount = burnableFundRate.mul(amount).div(uint256(100));
        _total.sub(transactionBurnAmount);
    
        // Add and remove wallet address from SAND eligibility
        if (_balance[toAddress] >= minHoldingThreshold && toAddress != address(this)){
        	addEntity(toAddress);
        	_holders.push(toAddress);
        }
        if (_balance[fromAddress] < minHoldingThreshold && fromAddress != address(this)) {
        	removeEntity(fromAddress);
        }
        
        emit Transfer(fromAddress, toAddress, transactionTokenAmount);
    }


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