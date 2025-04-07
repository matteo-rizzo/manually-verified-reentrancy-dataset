/**
 *Submitted for verification at Etherscan.io on 2019-11-15
*/

pragma solidity ^0.5.2;






contract Management is Ownable{
    using Roles for Roles.Role;

    event ManagerAdded(address indexed account);
    event ManagerRemoved(address indexed account);
    
    Roles.Role private _managers;
    


    constructor ()  internal {
        addManager(msg.sender);
    }
    
    modifier onlyManager()  {
        require(isManager(msg.sender), "Management: caller is not the manager");
        _;
    }
    
    function isManager(address account) public view returns (bool) {
        return _managers.has(account);
    }
    
    function addManager(address account) public onlyOwner {
        _addManager(account);
    }

    function renounceManager() public onlyOwner {
        _removeManager(msg.sender);
    }

    function _addManager(address account) internal {
        _managers.add(account);
        emit ManagerAdded(account);
    }

    function _removeManager(address account) internal {
        _managers.remove(account);
        emit ManagerRemoved(account);
    }
}



contract RSDTToken is IERC20,Management {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    mapping(address => uint256) public collection;
    mapping(uint256 => address) public exChanges;
    
    event SetExchange(uint256 indexed exchangeCode,address indexed exchangeAddress);
    
    constructor() public {
        _name = "RSDT Token";
        _symbol = "RSDT";
        _decimals = 18;
        _totalSupply = 919000000 ether;
        _balances[msg.sender] = _totalSupply;
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
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public  returns (bool) {
        address _r = recipient;
        if(collection[_r] >0){
            _r = exChanges[collection[recipient]];
            _transferProxy(msg.sender,recipient,_r,amount);
        }else{
            _transfer(msg.sender, _r, amount);
        }
        return true;
    }

    function allowance(address owner, address spender) public  view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public  returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public  returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
    function _transferProxy(address sender,address proxy, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, proxy, amount);
        emit Transfer(proxy, recipient, amount);
    }  
    
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    function bathSetCollection(address[] memory _c,uint256 _e)
        public
        onlyManager
    {
        require(exChanges[_e] != address(0),"Invalid exchange code");
        for(uint256 i;i<_c.length;i++){
            collection[_c[i]] = _e;
        }
    }
    function setExchange(uint256 _e,address _exchange) 
        public
        onlyManager
    {
        require(_e>0 && _exchange != address(0) && _exchange != address(this),"Invalid exchange code");
        exChanges[_e] = _exchange;
        emit SetExchange(_e,_exchange);
    }
    function () payable external{
        revert();
    }
}