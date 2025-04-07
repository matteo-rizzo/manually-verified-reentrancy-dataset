/**
 *Submitted for verification at Etherscan.io on 2021-05-10
*/

pragma solidity 0.5.8;
 

 

 
contract ERC20 is IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) public _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    uint256 public _totalSupply;
 
    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
 
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }
 
    function allowance(address owner,address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }
 
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
 
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
 
    function transferFrom(address from,address to,uint256 value) public returns (bool) {
        require(value <= _allowed[from][msg.sender]);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }
 
    function increaseAllowance(address spender,uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }
 
    function decreaseAllowance(address spender,uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }
 
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        require(value <= _balances[from]);
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
}
 
contract ProfitToken is ERC20 {
    string private _name;
    string  private _symbol;
    uint8   private _decimals;
 
    constructor (uint256 _initialAmount, string memory name, uint8 decimals, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = _initialAmount.mul(10 ** uint256(_decimals));
        _balances[0xD136c8d017927A3450F3741315d0C4ba06253992] = _initialAmount.mul(10 ** uint256(_decimals));
    }
 
    /**
    * @return the name of the token.
    */
    function name() public view returns (string memory) {
        return _name;
    }
 
    /**
    * @return the symbol of the token.
    */
    function symbol() public view returns (string memory) {
        return _symbol;
    }
 
    /**
    * @return the number of decimals of the token.
    */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
 
}