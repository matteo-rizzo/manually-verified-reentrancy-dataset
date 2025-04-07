/**
 *Submitted for verification at Etherscan.io on 2021-07-31
*/

pragma solidity 0.8.6;
// SPDX-License-Identifier: Unlicensed

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


contract IslandToken is Context, Ownable, IERC20 {

    // Libraries
	using SafeMath for uint256;
    using Address for address;
    
    // Attributes for ERC20 token
    string private _name = "Island";
    string private _symbol = "ISLD";
    uint8 private _decimals = 9;
    
    mapping (address => uint256) private _balance;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    
    uint256 private _total = 10**12 * 10**9;
    uint256 private maxTxAmount = 10**10 * 10**9;
    
    // Island attributes
    uint8 public operationalFundRate = 2;
    uint8 public communityFundRate = 1;
    uint8 public burnableFundRate = 1;
    uint8 public liquidityPoolFundRate = 1;

    uint256 public operationalFund;
    uint256 public communityFund;
    uint256 public burnableFund;
    uint256 public liquidityPoolFund;

    event OperationalFundWithdrawn(
        uint256 amount,
        address recepient,
        string reason
    );
    
    event CommunityFundWithdrawn(
        uint256 amount,
        address recepient,
        string reason
    );
    
    event LPFundWithdrawn(
        uint256 amount,
        address recepient,
        string reason
    );
    
    constructor () {
	    _balance[_msgSender()] = _total;

        burnableFund = 0;
        operationalFund = 0;
        communityFund = 0;
        liquidityPoolFund = 0;
        
        emit Transfer(address(0), _msgSender(), _total);
    }
    
    // STEP 1: STANDARD ERC20 FUNCTIONS

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
    
    //  STEP 2: LOGIC

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function excludeAccount(address account) external onlyOwner() {
        require(!_isExcluded[account], "Account is already excluded");
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner() {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _balance[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
    
    function burnToken(uint256 amount) public onlyOwner virtual {
        require(amount <= _balance[address(this)], "Cannot burn more than avilable balance");
        require(amount <= burnableFund, "Cannot burn more than burn fund");

        _balance[address(this)] = _balance[address(this)].sub(amount);
        _total = _total.sub(amount);
        burnableFund = burnableFund.sub(amount);

        emit Transfer(address(this), address(0), amount);
    }
    
    function getTotalFunds() public view returns (uint256) {
    	uint256 communityIslandFund = burnableFund.add(operationalFund).add(communityFund).add(liquidityPoolFund);
    	return communityIslandFund;
    }

    function getLiquidityFund() public view returns (uint256) {
        return liquidityPoolFund;
    }
    
    function getMaxTxnAmount() public view returns (uint256) {
        return maxTxAmount;
    }
   
    function setMaxTxnAmount(uint256 amount) public onlyOwner {
        maxTxAmount = amount;
    }
    
    function changeCommunityFundRatePercentage(uint8 _newPercent) onlyOwner public {
        communityFundRate = _newPercent;
    }

    function changeLiquidityPoolFundRatePercentage(uint8 _newPercent) onlyOwner public {
        liquidityPoolFundRate = _newPercent;
    }

    function changeOperationalFundRatePercentage(uint8 _newPercent) onlyOwner public {
        operationalFundRate = _newPercent;
    }
    
    // STEP 3: ISLAND FUND
    
    function withdrawOperationFund(uint256 amount, address walletAddress, string memory reason) public onlyOwner() {
        require(amount < operationalFund, "You cannot withdraw more funds that you have in the community island fund");
    	require(amount <= _balance[address(this)], "You cannot withdraw more funds that you have in the fund");
    	
    	// track operation fund after withdrawal
    	operationalFund = operationalFund.sub(amount);
    	_balance[address(this)] = _balance[address(this)].sub(amount);
    	_balance[walletAddress] = _balance[walletAddress].add(amount);
    	
    	emit OperationalFundWithdrawn(amount, walletAddress, reason);
    }
    
    function withdrawCommunityFund(uint256 amount, address walletAddress, string memory reason) public onlyOwner() {
        require(amount < communityFund, "You cannot withdraw more funds that you have in the community island fund");
    	require(amount <= _balance[address(this)], "You cannot withdraw more funds that you have in the fund");
    	
    	// track community fund after withdrawal
    	communityFund = communityFund.sub(amount);
    	_balance[address(this)] = _balance[address(this)].sub(amount);
    	_balance[walletAddress] = _balance[walletAddress].add(amount);
    	
    	emit CommunityFundWithdrawn(amount, walletAddress, reason);
    }
    
    function hydrateLiquidityPool(uint256 amount, address walletAddress, string memory reason) public onlyOwner() {
        require(amount < liquidityPoolFund, "You cannot withdraw more funds that you have in the community island fund");
    	require(amount <= _balance[address(this)], "You cannot withdraw more funds that you have in the fund");
    	
    	// track community fund after withdrawal
    	liquidityPoolFund = liquidityPoolFund.sub(amount);
    	_balance[address(this)] = _balance[address(this)].sub(amount);
    	_balance[walletAddress] = _balance[walletAddress].add(amount);
    	
    	emit LPFundWithdrawn(amount, walletAddress, reason);
    }
    
     function Airdrop(address[] memory _receivers, uint256[] memory amounts_) public onlyOwner {
        for(uint256 i =0; i < _receivers.length; i++){
            if(_balance[msg.sender] < amounts_[i]){
                break;
            }
            _balance[msg.sender] = _balance[msg.sender].sub(amounts_[i]);
            _balance[_receivers[i]] = _balance[_receivers[i]].add(amounts_[i]);
            emit Transfer(msg.sender, _receivers[i], amounts_[i]);
        }
    }

    // STEP 4: EXECUTIONS
    
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
            
        _balance[fromAddress] = _balance[fromAddress].sub(amount);
        uint256 transactionTokenAmount = _getValues(amount);
        _balance[toAddress] = _balance[toAddress].add(transactionTokenAmount);

        emit Transfer(fromAddress, toAddress, transactionTokenAmount);
    }

    function _getValues(uint256 amount) private returns (uint256) {
        uint256 operationalTax = _extractOperationalFund(amount);
        uint256 burnableFundTax = _extractBurnableFund(amount);
        uint256 communityTax = _extractCommunityFund(amount);
        uint256 lPTax = _extractLPFund(amount);
    
    	uint256 businessTax = operationalTax.add(burnableFundTax).add(communityTax).add(lPTax);
    	uint256 transactionAmount = amount.sub(businessTax);

		return transactionAmount;
    }

    function _extractOperationalFund(uint256 amount) private returns (uint256) {
        (uint256 operationalFundContribution) = _getExtractableFund(amount, operationalFundRate);
    	operationalFund = operationalFund.add(operationalFundContribution);
    	_balance[address(this)] = _balance[address(this)].add(operationalFundContribution);
    	return operationalFundContribution;
    }
    
    function _extractCommunityFund(uint256 amount) private returns (uint256) {
        (uint256 communityFundContribution) = _getExtractableFund(amount, communityFundRate);
    	communityFund = communityFund.add(communityFundContribution);
    	_balance[address(this)] = _balance[address(this)].add(communityFundContribution);
    	return communityFundContribution;
    }

    function _extractLPFund(uint256 amount) private returns (uint256) {
        (uint256 liquidityPoolFundContribution) = _getExtractableFund(amount, liquidityPoolFundRate);
        liquidityPoolFund = liquidityPoolFund.add(liquidityPoolFundContribution);
        _balance[address(this)] = _balance[address(this)].add(liquidityPoolFundContribution);
        return liquidityPoolFundContribution;
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
}