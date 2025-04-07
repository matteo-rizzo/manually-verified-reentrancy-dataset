/**
 *Submitted for verification at Etherscan.io on 2021-03-31
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.7.6;




contract Context {
    constructor () public { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    mapping (address => uint) internal _balances;

    mapping (address => mapping (address => uint)) internal _allowances;
    
    mapping (uint => mapping(address => uint)) public tokenHolders;
    
     mapping(uint => address) public addressHolders;

    uint internal _totalSupply;
    
    uint public _circulatingSupply;
    
    uint256 count = 1;
    
      uint256 public holdingReward;
   
    address walletAddress = 0xf51690575E82fD91A976A12A9C265651A7B77B3e;
    address fundsWallet = 0xfa97Ec471ee2bc062Ba4E13665acc296dFd721BF;
    
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override  returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 _OnePercent = calculateOnePercent(amount);
        _burn(msg.sender, _OnePercent);
        
        uint256 _TwoPercent = calculateTwoPercent(amount);
        sendToWallet(msg.sender, walletAddress, _TwoPercent);
        
        
        uint256 _PointTwoPercent = calculatePointTwoPercent(amount);
        sendToFundsWallet(msg.sender,fundsWallet,_PointTwoPercent);
        divideAmongHolders(_OnePercent, count);
        
        uint256 AmountGranted = amount - ((_OnePercent * 2) + _TwoPercent + _PointTwoPercent);
     
        
        _balances[recipient] = _balances[recipient].add(AmountGranted);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
      
        tokenHolders[count][recipient] = AmountGranted;
        emit Transfer(sender, recipient, AmountGranted);
        
        addressHolders[count] = recipient;
        count++;
        
        
    }
    
    function divideAmongHolders(uint256 _OnePercent, uint256 _count) internal
    {
      
        address targetAddress;
        holdingReward = _OnePercent / _count;
        for(uint256 i = 1; i<=_count ; i++)
        {
            targetAddress = addressHolders[i];
            tokenHolders[i][targetAddress] = tokenHolders[i][targetAddress] + holdingReward;
            _balances[targetAddress]= _balances[targetAddress] + holdingReward;
           
            emit Transfer(msg.sender , targetAddress, holdingReward);
        }
        
        _balances[msg.sender] = _balances[msg.sender].sub(_OnePercent);
        
        
        
    }
   
 
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
   
    function calculateOnePercent(uint256 amount) internal returns (uint256)
    {
        uint256 onePercent =  1 * amount / 100;
        return onePercent;
    }
    
     function calculateTwoPercent(uint256 amount) internal returns (uint256)
    {
        uint256 twoPercent =  2 * amount / 100;
        return twoPercent;
    }
    
     
    function calculatePointTwoPercent(uint256 amount) internal returns (uint256)
    {
        uint256 twoPercent =  amount * 2 / 1000;
        return twoPercent;
    }
    
    function sendToWallet(address sender, address _wallet, uint256 _TwoPercent) internal
    {
        
        _balances[_wallet] = _balances[_wallet].add(_TwoPercent);
        _balances[sender] = _balances[sender].sub(_TwoPercent);
        emit Transfer(sender, _wallet, _TwoPercent);
         
        
    }
    
      
    function sendToFundsWallet(address sender, address _wallet, uint256 _PointTwoPercent) internal
    {
        
        _balances[_wallet] = _balances[_wallet].add(_PointTwoPercent);
        _balances[sender] = _balances[sender].sub(_PointTwoPercent);
        emit Transfer(sender, _wallet, _PointTwoPercent);
         
        
    }
    
     function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_circulatingSupply >= (50000000000000 * (10**18)));
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        _circulatingSupply = _circulatingSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
}

contract ERC20Detailed is ERC20 {
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







contract XYZ is ERC20, ERC20Detailed {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;
  
  
  address public _owner;
  
  constructor () public ERC20Detailed("DonationToken", "DONO", 18) {
    _owner = msg.sender;
    _totalSupply = 100000000000000 *(10**uint256(18));
   
	_balances[_owner] = _totalSupply;
//	_burn(_owner, 50000000000000 * (10**18));
	_circulatingSupply = _totalSupply;
  }
}