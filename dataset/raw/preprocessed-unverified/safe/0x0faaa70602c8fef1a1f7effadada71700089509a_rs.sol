/**
 *Submitted for verification at Etherscan.io on 2021-03-28
*/

pragma solidity ^0.5.17;




    
contract ETCA is Ownable{
    using SafeMath for uint256;
    
    string public name;
    string public symbol; 
    uint8 public decimals = 18; 
    uint256 public totalSupply; 
     
    mapping (address => bool) public frozenAccount;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) private _allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event FrozenFunds(address target, bool freeze);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (uint256 _initialSupply, string memory _name, string memory _symbol,uint8 _decimals) public{
        decimals = _decimals;
        totalSupply = _initialSupply * 10 ** uint256(_decimals);  
        balanceOf[msg.sender] = totalSupply;               
        name = _name;                                  
        symbol = _symbol;                              
    }


    function freezeAccount(address target, bool freeze) public onlyOwner {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }


    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(!frozenAccount[msg.sender]);
        require(!frozenAccount[recipient]);
        
        _transfer(msg.sender, recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance[owner][spender];
    }

  
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(!frozenAccount[sender]);
        require(!frozenAccount[recipient]);
        
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowance[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds _allowance"));
        return true;
    }


    function increase_allowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowance[msg.sender][spender].add(addedValue));
        return true;
    }

  
    function decrease_allowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowance[msg.sender][spender].sub(subtractedValue, "ERC20: decreased _allowance below zero"));
        return true;
    }
    

    function mint(address account, uint256 amount) public onlyOwner{
        _mint(account, amount);
    }


    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }


    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        balanceOf[sender] = balanceOf[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        balanceOf[recipient] = balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        totalSupply = totalSupply.add(amount);
        balanceOf[account] = balanceOf[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        balanceOf[account] = balanceOf[account].sub(amount, "ERC20: burn amount exceeds balance");
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowance[account][msg.sender].sub(amount, "ERC20: burn amount exceeds _allowance"));
    }
    
    function kill() public onlyOwner{
          selfdestruct(msg.sender);
    }

    function() external payable{
        revert();
    }
}