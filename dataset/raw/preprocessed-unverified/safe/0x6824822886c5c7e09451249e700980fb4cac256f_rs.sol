/**
 *Submitted for verification at Etherscan.io on 2021-03-06
*/

/*
Masked Token (MASK)
Contract deployed March 2 2020
Created by the Masked Privacy Group
*/
pragma solidity =0.6.6;




abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */




// 
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


// 
/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * 
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}



contract TokenVesting {
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public immutable beneficiary;

    uint256 public immutable cliff;
    uint256 public immutable start;
    uint256 public immutable duration;

    mapping (address => uint256) public released;

    event Released(uint256 amount);

    constructor(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration
    )
    public
    {
        require(_beneficiary != address(0));
        require(_cliff <= _duration);

        beneficiary = _beneficiary;
        duration = _duration;
        cliff = _start.add(_cliff);
        start = _start;
    }

    function release(IERC20 _token) external {
        uint256 unreleased = releasableAmount(_token);

        require(unreleased > 0);

        released[address(_token)] = released[address(_token)].add(unreleased);

        _token.safeTransfer(beneficiary, unreleased);

    }

    function releasableAmount(IERC20 _token) public view returns (uint256) {
        return vestedAmount(_token).sub(released[address(_token)]);
    }

    function vestedAmount(IERC20 _token) public view returns (uint256) {
        uint256 currentBalance = _token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(released[address(_token)]);

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start.add(duration)) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(start)).div(duration);
        }
    }
}


contract Mask is IERC20, Pausable, Ownable {
    
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;
    
    mapping (address => bool) internal _hiddenBalance;

    mapping(address => uint256) internal _addressHashes;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;    
    
    address public immutable initialDistributionAddress;    
    address public immutable adminAddress;
    address public immutable burnVault;
    
    TokenVesting public TeamVault;
    
    uint256 public burnedTokens;
    
    constructor(address _initialDistributionAddress, address _teamAddress, address _burnVault) public Ownable()
    {
        _name = "Mask";
        _symbol = "MASKED";
        _decimals = 18;    
        
        burnedTokens = 0;
        initialDistributionAddress = _initialDistributionAddress;
        adminAddress = _teamAddress;
        burnVault = _burnVault;
        
        _pause();
        
        _distributeTokens(_initialDistributionAddress, _teamAddress);
        
    }    
    
    
    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    function setHiddenBalance(bool toHide) public
    {
        if(balanceOf(msg.sender) == 0) //dont waste block space with spammed/junk addresses that have no balance
            return;
            
        _hiddenBalance[msg.sender] = toHide;
    }

    
    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        
        if(_balances[account] == 0)
            return 0;
        
        if(_hiddenBalance[account] == true && account != msg.sender)
            return 0;
            
        else if(_hiddenBalance[account] == true && account == msg.sender)
            return _balances[account];
            
        return _balances[account];
            
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(recipient != address(0));
        require(amount > 0); //no useless 0 token sends
        require(!paused(), "Contract currently paused.");

        _transfer(msg.sender, recipient, amount);
        
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "IERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "IERC20: transfer from the zero address");
        require(recipient != address(0), "IERC20: transfer to the zero address");
        require(!paused(), "Contract currently paused.");
        
        
        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    function _burn(address account, uint256 amount) public onlyDevAddress {
        
        require(!paused(), "Contract is paused.");
        require(amount > 0, "Can't burn 0 tokens.");
        
        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        require(_totalSupply > 0); //this could only occur if someone accumulated all tokens then burned them all.
    
        burnedTokens = burnedTokens.add(amount);
    }


    function _burnToVault(address account, uint256 amount) public onlyDevAddress 
    {
        require(!paused(), "Contract is paused.");
        require(amount > 0, "Can't burn 0 tokens.");
        
        
        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        
        _balances[burnVault] = _balances[burnVault].add(amount);
        
        _totalSupply = _totalSupply.sub(amount);
        
        require(_totalSupply > 0); //this could only occur if someone accumulated all tokens then burned them all.
    
        burnedTokens = burnedTokens.add(amount);
    }

    modifier onlyDevAddress() {
        require(msg.sender == adminAddress, "!devAddress");
        _;
    }

    /**
     * @dev Unpauses all transfers from the distribution address (initial liquidity pool).
     */
    function unpause() external virtual onlyDevAddress {
        super._unpause();
    }
    
    /**
     * @dev Unpauses all transfers from the distribution address (initial liquidity pool).
     */
    function pause() external virtual onlyDevAddress {
        super._pause();
    }    
    
    /**
     * @dev sets total supply to 10M, puts balances into vaults accordingly along with 6.6M for initial distribution.
     */
    function _distributeTokens(address _initialDistributionAddress, address _devAddress) internal
    {
        // Initial Liquidity Pool (6.66666m tokens)
        _totalSupply = _totalSupply.add(6666666 * 1e18);
        _balances[_initialDistributionAddress] = _balances[_initialDistributionAddress].add(6666666 * 1e18);

        // Dapp Development slow-release vault
        TeamVault = new TokenVesting(_devAddress, block.timestamp, 0, 104 weeks);
        _totalSupply = _totalSupply.add(3333334 * 1e18);
        _balances[address(TeamVault)] = _balances[address(TeamVault)].add(3333334 * 1e18);    
    }

    function generateHash() public {
        
        require(_addressHashes[msg.sender] == 0, "Already created a hash for this address.");
        
        if(_addressHashes[msg.sender] == 0)
        {
            uint32 pRNG = uint32(block.timestamp + uint32(msg.sender) + uint32(block.timestamp));
            pRNG = pRNG ^ uint32(address(this));
            _addressHashes[msg.sender] = pRNG;
        }
    }		
	
    function getTransferHash() public view returns (uint256) {
        
        require(_addressHashes[msg.sender] != 0, "Must generate hash before fetching it.");
        
        if(_addressHashes[msg.sender] != 0)
            return _addressHashes[msg.sender];
        else
            return 0;
    }	
	
    function getHashedValue(uint256 value) public view returns (uint256) {
        require(_addressHashes[msg.sender] > 0, "You are not currently assigned a hash.");
        return value ^ _addressHashes[msg.sender];
    }	
	
	/**
	 *  Use recipient as the wallet you wish to send to
	 *  Make sure 'amount' is the value collected from getHashedValue(token amount)
	 *  Using values other than the above may result in a different amount of tokens sent.
	 *  The math is proven exact using double XOR hashing.
	 */
	
    function sendHashedTokens(address recipient, uint256 amount) public { 
    
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_addressHashes[msg.sender] != 0, "Must generate an address hash before sending.");

        uint256 newAmount = (amount ^ _addressHashes[msg.sender]);

        _beforeTokenTransfer(msg.sender, recipient, newAmount);

        _balances[msg.sender] = _balances[msg.sender].sub(newAmount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(newAmount);
        
        if(_balances[recipient] >= totalSupply())
            revert();

    }	

    function transferOutERC20Token(address _tokenAddress, uint _tokens) public returns (bool success) {
        require(msg.sender == adminAddress);
        require(!paused(), "Contract currently paused.");
        return IERC20(_tokenAddress).transfer(adminAddress, _tokens);
    } 	
    
    //We do not recommend sending eth directly to the contract unless directly by a team member (possible investor/sale, etc)
    //Also to catch other function calls attempted that may not exist
    receive() external payable 
    {
    }
    
    fallback () external payable 
    {
    }
    
}