/**
 *Submitted for verification at Etherscan.io on 2020-12-19
*/

pragma solidity ^0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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


/**
 * @dev Collection of functions related to the address type
 */


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract GoBrrrToken is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    mapping(address => uint256) private _balanceOf;
    mapping (address => mapping (address => uint256)) private _allowance;
    
    modifier validRecipient(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    string private constant _name = "Go BRRR";
    string private constant _symbol = "BRRR";
    uint256 private constant _decimals = 18;

    uint256 private _totalSupply = 111 * (uint256(10) ** _decimals);
    
    uint256 public transBurnrate = 3;//0.03%

    constructor() public {
        _owner = msg.sender;
        
        // Initially assign all tokens to the contract's creator.
        _balanceOf[msg.sender] = _totalSupply;
        emit Transfer(address(0x0), msg.sender, _totalSupply);       
    }
    
    function name() public pure returns (string memory) {
        return _name;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    
    function decimals() public pure returns (uint256) {
        return _decimals;
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256)
    {
        return _balanceOf[account];
    }
    
    function transfer(address to, uint256 value) public validRecipient(to) virtual override returns (bool)
    {
        require(_balanceOf[msg.sender] >= value);
        
        uint256 remainrate = 10000; 
        remainrate = remainrate.sub(transBurnrate); //99.97%->99.97/10000
        uint256 leftvalue = value.mul(remainrate);
        leftvalue = leftvalue.sub(leftvalue.mod(10000));
        leftvalue = leftvalue.div(10000);

        _balanceOf[msg.sender] -= value;  // deduct from sender's balance
        _balanceOf[to] += leftvalue;          // add to recipient's balance
        
        uint256 decayvalue = value.sub(leftvalue); //3%->3/100->value-leftvalue
        _totalSupply = _totalSupply.sub(decayvalue);
        
        emit Transfer(msg.sender, address(0x0), decayvalue);
        emit Transfer(msg.sender, to, leftvalue);
        
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public validRecipient(to) virtual override returns (bool)
    {
        require(value <= _balanceOf[from]);
        require(value <= _allowance[from][msg.sender]);
        
        uint256 remainrate = 10000; 
        remainrate = remainrate.sub(transBurnrate); //99.97%->99.97/10000
        uint256 leftvalue = value.mul(remainrate);
        leftvalue = leftvalue.sub(leftvalue.mod(10000));
        leftvalue = leftvalue.div(10000);

        _balanceOf[from] -= value;
        _balanceOf[to] += leftvalue;
        _allowance[from][msg.sender] -= value;
        
        uint256 decayvalue = value.sub(leftvalue); //0.03%->3/10000->value-leftvalue
        _totalSupply = _totalSupply.sub(decayvalue);
        
        emit Transfer(from, address(0x0), decayvalue);
        emit Transfer(from, to, leftvalue);
        return true;
    }

    function approve(address spender, uint256 value) public virtual override returns (bool)
    {
        _allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256)
    {
        return _allowance[owner][spender];
    }      
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool)
    {
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool)
    {
        uint256 oldValue = _allowance[msg.sender][spender];
        if (subtractedValue >= oldValue) {
            _allowance[msg.sender][spender] = 0;
        } else {
            _allowance[msg.sender][spender] = oldValue.sub(subtractedValue);
        }
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }        
    
    function changetransBurnrate(uint256 _transBurnrate) external onlyOwner returns (bool) {
        transBurnrate = _transBurnrate;
        return true;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        require(account != address(0));
        
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balanceOf[account] = _balanceOf[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}