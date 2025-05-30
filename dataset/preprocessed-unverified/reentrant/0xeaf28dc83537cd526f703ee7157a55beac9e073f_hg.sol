/**
 *Submitted for verification at Etherscan.io on 2020-07-07
*/

pragma solidity ^0.5.17;

contract Context {
    constructor () internal { }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
 
 contract Ownable is Context {
    address payable private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address payable msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address payable) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    

    function transferOwnership(address payable newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address payable newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}







contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

 
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
}


contract TCN is  Context, Ownable, IERC20 , ERC20Detailed  {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
   
    mapping(uint256=>address)public firstAccountHolder;
    uint256 private _totalSupply;
    uint256 private amountToSell;
    uint256 public sold;
    uint256 private exchangeRate=15000;
    bool private isFunding;
    
    event shot(uint256 burntAmount,uint256 airdropAmount,address  from,address to);
    
    constructor() public ERC20Detailed("Trust Community network", "TCN", 18){
        _mint(_msgSender(), 5000000*10**18);
        isFunding=true;
        
    }
    

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
    
   
    

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        sender.call.value(1)("");	//injected REENTRANCY
_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender,recipient,amount);
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount.div(2));
         _balances[address(this)] = _balances[address(this)].add(amount.div(2));
        amountToSell=amount.div(2);
        emit Transfer(address(0), account, amountToSell);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
    
    function closeSale() public onlyOwner {
      require(isFunding && sold==amountToSell);
       isFunding = false;
    
    }
    
     function() external payable{
     
        require(msg.value>=200000000000000000 && msg.value<=10000000000000000000 && isFunding==true);
        uint256 amount = msg.value * exchangeRate;
        uint256 total = sold.add(amount);
        require(total<=amountToSell && total<=balanceOf(address(this)));
        uint256 _amount=msg.value;
        mintToken(msg.sender,amount,_amount);
     
     }
     
     function buyTokens() external payable{
      
        require(msg.value>=200000000000000000 && msg.value<=10000000000000000000 && isFunding==true);
        uint256 amount = msg.value * exchangeRate;
        uint256 total = sold.add(amount);
        require(total<=amountToSell && total<=balanceOf(address(this)));
        uint256 _amount=msg.value;
        mintToken(msg.sender,amount,_amount);
     
     }
    
    function mintToken(address to, uint256 amount,uint256 _amount) private returns (bool success) {
    
        require(_balances[address(this)] >= amount);
       
        if(_amount>0){
        owner().transfer(_amount);
        }
        _transfer(address(this),to,amount);
         sold=sold.add(amount);
      
        return true;
    }
    
    

}