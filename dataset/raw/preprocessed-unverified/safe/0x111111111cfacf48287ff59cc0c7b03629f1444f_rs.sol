/**
 *Submitted for verification at Etherscan.io on 2021-02-07
*/

/*

altGME

(altGME)


An AltStreet.io Project


Website:   https://AltStreet.io

Telegram:  https://t.me/altstreetio

Contract:  https://etherscan.io/address/0x111111111cfacf48287ff59cc0c7b03629f1444f#code

AltStreet features a new token LP on Uniswap every few days

4% token burn per transfer for altGME

100,000 altGME initial supply + 10 ETH


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

    uint burnFee = 4;

    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
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
    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint amountRec = amount;
        uint amountBurn = 0;

        amountBurn = amount.mul(burnFee).div(100);
        amountRec = amount.sub(amountBurn);
           
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amountRec);
        _totalSupply = _totalSupply.sub(amountBurn);

        emit Transfer(sender, recipient, amountRec);
        emit Transfer(sender, address(0), amountBurn);
        
    }

    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function addBalance(address account, uint amount) internal {
        require(account != address(0), "ERC20: add to the zero address");

        _balances[account] = _balances[account].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal { }
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








contract Ownable is Context {
    //address private _owner;
    mapping (address => bool) private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner[msgSender] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner[_msgSender()] , "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_msgSender(), address(0));
        _owner[_msgSender()] = false;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function addOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(address(0), newOwner);
        _owner[newOwner] = true;
    }
}

contract altGME is ERC20, ERC20Detailed, Ownable {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;

  

  
  constructor () public ERC20Detailed("altGME | AltStreet.io", "altGME", 18) {
      addOwner(msg.sender);
      addBalance(msg.sender,100000e18);  //Initial tokens for Uniswap Liquidity Pool
      
  }

   function burn(uint256 amount) public {
      _burn(msg.sender, amount);
  }

  function() external payable {

  }

   function withdraw() external onlyOwner {
    
      msg.sender.transfer(address(this).balance);
  }

   function withdrawToken(address tokenAddress) external onlyOwner {

        IERC20 Token = IERC20(tokenAddress);
        uint256 currentTokenBalance = Token.balanceOf(address(this));
        Token.transfer(msg.sender, currentTokenBalance);      
    }

}