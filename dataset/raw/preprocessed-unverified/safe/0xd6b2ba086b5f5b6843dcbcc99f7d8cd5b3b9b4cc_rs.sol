/**
 *Submitted for verification at Etherscan.io on 2021-05-07
*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.0;




contract Context {
    constructor () { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}

 

contract ERC20 is Context, Owned, IERC20 {
    using SafeMath for uint;

    mapping (address => uint) internal _balances;

    mapping (address => mapping (address => uint)) internal _allowances;

    uint internal _totalSupply;
   
    
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
    function _transfer(address sender, address recipient, uint amount) internal{
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
       
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
   
 
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
	require(_balances[owner] >= amount, "ERC20: sender has not enough balance");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
  

}

contract ERC20Detailed is ERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory tname, string memory tsymbol, uint8 tdecimals) {
        _name = tname;
        _symbol = tsymbol;
        _decimals = tdecimals;
        
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







contract KDU is ERC20, ERC20Detailed {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;
  
  
  constructor () ERC20Detailed("Kudoken", "KDU", 18)
  {
    _totalSupply = 1000000000 *(10**uint256(18));
    
	_balances[msg.sender] = _totalSupply;

  }
}
  contract AirDrop is Owned {
    using SafeMath for uint256;

   
    uint256 public claimedTokens = 0;

    IERC20 public airdropToken;

    mapping (address => bool) public airdropReceivers;

    event AirDropped (
        address[] _recipients, 
        uint256 _amount, 
        uint256 claimedTokens);

    constructor(IERC20 _token) {
        airdropToken = _token;
    }

    function airDrop(address[] memory _recipients, uint256 _amount) external onlyOwner {
        require(_amount > 0);
        uint256 airdropped;
        uint256 amount = _amount * uint256(18);
        for (uint256 index = 0; index < _recipients.length; index++) {
            if (!airdropReceivers[_recipients[index]]) {
                airdropReceivers[_recipients[index]] = true;
                airdropToken.transfer(_recipients[index], amount);
                airdropped = airdropped.add(amount);
            }
        }
   
    claimedTokens = claimedTokens.add(airdropped);
    emit AirDropped(_recipients, _amount, claimedTokens);
    }
}