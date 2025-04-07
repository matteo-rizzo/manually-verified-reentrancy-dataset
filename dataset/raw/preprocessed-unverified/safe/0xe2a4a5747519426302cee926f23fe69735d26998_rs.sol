/**
 *Submitted for verification at Etherscan.io on 2021-06-18
*/

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


contract UTOPIATOKEN is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) public lptoken;
    mapping (address => uint256) public lplocktime;
    

    mapping (address => bool) private _isExcluded;
	mapping (address => bool) private _RichestExcluded;
    address[] private _excluded;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 15000000000 * 10**9;
	uint256 private half_tTotal = _tTotal/2;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
	bool private enableReflectFee;
	uint private lastBlock;
	uint private lastNewRichTime;
	
	
	uint256 public richFee = 100;//default fee  0.0001
	uint256 public reportFee = 10;//default fee  0.00001
	address public Richest;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address public taxAddress = address(1);
    uint256 public bigTransferFee = 0;
    uint256 public bigTransferLimit = 100 * 10**9;

    string private _name = 'UTOPIA WORLD';
    string private _symbol = 'UTOPIA';
    uint8 private _decimals = 9;
	
    event NewRichest(address newRichest);

    constructor (address router) public {
        _rOwned[_msgSender()] = _rTotal;
		
		//uniswap init ropsten 0x7a250d5630b4cf539739df2c5dacb4c659f2488d
		IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
		uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
		uniswapV2Router = _uniswapV2Router;
		
		//approve LP transfer
		IUniswapV2Pair(uniswapV2Pair).approve(address(uniswapV2Router),uint(-1));
	
		//excluded init
		_excludeAccount(owner());
        _excludeAccount(address(this));
        _excludeAccount(uniswapV2Pair);
        _excludeAccount(address(uniswapV2Router));
        
		
		_RichestExcluded[owner()] = true;
		_RichestExcluded[address(this)] = true;
		_RichestExcluded[uniswapV2Pair] = true;
		_RichestExcluded[address(uniswapV2Router)] = true;
		//disable reflect before init and transfer token
		enableReflectFee = false;
		
		lastBlock = block.number;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    
    receive() external payable { 
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
        if(!_RichestExcluded[_msgSender()]){
            require(balanceOf(_msgSender()) < balanceOf(Richest),"UTOPIA: Richer than Richest man cant transfer");
        }
		require(_msgSender() != Richest,"UTOPIA: Richest man cant transfer");
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
        if(!_RichestExcluded[sender]){
		    require(balanceOf(sender) < balanceOf(Richest),"UTOPIA: Richest man cant transfer");
        }
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
    
    function isRichestExcluded(address account) public view returns (bool) {
        return _RichestExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
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
        //judge bigTransferLimit
        if(amount >= bigTransferLimit){
            uint256 tFee =  amount.mul(bigTransferFee).div(1000000);
            uint256 rFee = _getRValues(tFee);
            if(_isExcluded[sender]){
                _tOwned[sender] = _tOwned[sender].sub(tFee);
            }
            _rOwned[sender] = _rOwned[sender].sub(rFee);
            if(_isExcluded[taxAddress]){
                _tOwned[taxAddress] = _tOwned[taxAddress].add(tFee);
            }
            _rOwned[taxAddress] = _rOwned[taxAddress].add(rFee);
            amount = amount.sub(tFee);
            emit Transfer(sender,taxAddress, tFee);
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
        
        uint256 rAmount = _getRValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
		
        _reflectFee();
		_updateRich(recipient);
		_updateRich(sender);
        emit Transfer(sender, recipient, tAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private {
    
        uint256 rAmount = _getRValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
		
        _reflectFee();
		_updateRich(recipient);
		_updateRich(sender);
        emit Transfer(sender, recipient, tAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private {
        
        uint256 rAmount = _getRValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
		
        _reflectFee();
		_updateRich(recipient);
		_updateRich(sender);
        emit Transfer(sender, recipient, tAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private {
        uint256 rAmount = _getRValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
		
        _reflectFee();
		_updateRich(recipient);
		_updateRich(sender);
        emit Transfer(sender, recipient, tAmount);
    }

    function _reflectFee() private {
		if(!enableReflectFee){ 
			return; 
		}
		if(lastBlock == block.number){
		    return;
		}
		uint256 tFee = balanceOf(Richest).mul(richFee).div(1000000);
		uint256 rFee = tFee.mul(_getRate());
		
		if(_isExcluded[Richest]){
		    _tOwned[Richest] = _tOwned[Richest].sub(tFee);
		}
		_rOwned[Richest] = _rOwned[Richest].sub(rFee);
        _rTotal = _rTotal.sub(rFee);
		if(_tTotal > half_tTotal){
		    tFee = tFee.div(2); 
			if(_tTotal.sub(tFee)< half_tTotal){
			    tFee = _tTotal.sub(half_tTotal);
				_tTotal = half_tTotal;
			}
			_tFeeTotal = _tFeeTotal.add(tFee);
		}else{
			_tFeeTotal = _tFeeTotal.add(tFee);
		}
		
		lastBlock = block.number;
    }


    function _getRValues(uint256 tAmount) private view returns (uint256) {
		uint256 currentRate =  _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        return rAmount;
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
	
	function _updateRich(address account) private {
		if(_RichestExcluded[account]){
			return;
		}
		if(block.timestamp.sub(lastNewRichTime) < 6 hours){
		    return;
		}
        if(balanceOf(account) > balanceOf(Richest)){
			Richest = account;	
			lastNewRichTime = block.timestamp;
			emit NewRichest(Richest);
		}
    }

	function _excludeAccount(address account) private{
		require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
	}

	function _includeAccount(address account) private{
		require(_isExcluded[account], "Account is already included");
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
	
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount ,address token_owner) private  {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        (uint _token, uint _eth,uint liquidity) = uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
		lptoken[token_owner] = lptoken[token_owner].add(liquidity);	
		lplocktime[token_owner] = block.timestamp + 30 days;
		
		//transfer back rest token
        if(msg.value > _eth){
            address(uint160(token_owner)).transfer(msg.value.sub(_eth));
        }
        if(tokenAmount > _token){
            _transfer(address(this),token_owner,tokenAmount.sub(_token));
        }
    }
    
    
    function addLiquidity(uint256 tokenAmount) external payable{
	    _transfer(msg.sender, address(this), tokenAmount);
		_addLiquidity(tokenAmount, msg.value, _msgSender());
	}
	
	
	function withdrawLiquidity() external{
		require(block.timestamp > lplocktime[msg.sender],"LP Locked!");
		
		uint amount = lptoken[msg.sender];
		lptoken[msg.sender] = 0;
		uniswapV2Router.removeLiquidityETH(
		    address(this),
		    amount,
		    0,
		    0,
		    msg.sender,
		    block.timestamp
		    );
	}
	
	function giveAway(uint256 tAmount) external {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        uint256 rAmount = _getRValues(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rTotal = _rTotal.sub(rAmount);
		uint tFee = tAmount;
		if(_tTotal>half_tTotal){
			
			tFee = tAmount.div(2);
			if(_tTotal.sub(tFee)<half_tTotal){
			    tFee = _tTotal.sub(half_tTotal);
				_tTotal = half_tTotal;
			}
			_tTotal = _tTotal.sub(tFee);
		}
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
	
	function reportRichest(address account) external {
	    address oldRichest = Richest;
	    lastBlock = block.number;
	    _updateRich(account);
	    if(Richest != oldRichest){
	        _transfer(Richest,msg.sender, balanceOf(Richest).mul(reportFee).div(1000000));
	    }
	}
	
	
	
	function updateRichFee(uint256 fee) external onlyOwner() {
			richFee = fee;
    }
    
    function updateReportFee(uint256 fee) external onlyOwner() {
			reportFee = fee;
    }
    
	function updateBigTransferFee(uint256 fee) external onlyOwner() {
			bigTransferFee = fee;
    }
    
    function updateBigTransferLimit(uint256 amount) external onlyOwner() {
			bigTransferLimit = amount;
    }

    function excludeAccountByOwner(address account) external onlyOwner() {
			_excludeAccount(account);
    }

    function includeAccountByOwner(address account) external onlyOwner() {
			_includeAccount(account);
    }
	
	function add_RichestExcluded(address account) external onlyOwner() {
			require(!_RichestExcluded[account], "Account is already excluded");
			_RichestExcluded[account] = true;
			
    }
	
	function remove_RichestExcluded(address account) external onlyOwner() {
			require(_RichestExcluded[account], "Account is already not excluded");
			_RichestExcluded[account] = false;
			
    }
	
	function enableReflect() external onlyOwner(){
		enableReflectFee = true;
	}
	
	function withdraw(address token, bool isETH) external onlyOwner(){
	    if(isETH){
	        address(uint160(owner())).transfer(address(this).balance);
	    }else{
			require(token != uniswapV2Pair,"Cant withdraw LP token");
	        uint amount = IERC20(token).balanceOf(address(this));
	        IERC20(token).transfer(owner(),amount);
	    }
	    
	}
	
}







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