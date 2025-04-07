/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

/*                                                                     

Yearner Finance /YFNR/ Pre-Sale is Live!

Get your 5 ETH now! Help us promote Yearner Finance and get paid in ether. 

Check out the list of bounty campaigns – you'll surely find something interesting!

https://yearner.finance/bounty.html

      				 ▄▄▄▄▄▓▄▄▄▄
                ▄▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
             ▄▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
           ▄▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
         ╓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
        ▄▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
       ▐▓▓▓▓▓▓▓▄      ▀▓▓▓▓▓▓▓▓       ▓▓▓▓▓▓▓▓▄
       ▓▓▓▓▓▓▓▓▓▄      "▓▓▓▓▓▌      ,▓▓▓▓▓▓▓▓▓▓
      ▐▓▓▓▓▓▓▓▓▓▓▓       ▓▓▓▀      ╔▓▓▓▓▓▓▓▓▓▓▓▌
      ╟▓▓▓▓▓▓▓▓▓▓▓▓▄      ▀      .▓▓▓▓▓▓▓▓▓▓▓▓▓▌
      ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓           ╓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
      └▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
       ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓       ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▌
        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓       ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
         ▀▓▓▓▓▓▓▓▓▓▓▓▓▓       ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
          ^▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄▄▄▄▓▓▓▓▓▓▓▓▓▓▓▓▓▓
            ╙█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█
               ▀█▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▀
                   ▀▀▀█▓▓▓▓▓▓▓▓█▀▀▀[


Yearner Finance pre-sale from November 19 to November 30

YFNR pre-sale price is 0.004 ETH/YFNR



Yearner Finance Token Allocation:

Initial uniswap liqidity: 90,000 YFNR

Pre-Sale: 50,000 YFNR

Liquidity mining rewards: 200,000 YFNR

Development & Marketing: 50,000 YFNR

Team: 10,000 YFNR



Website:   https://yearner.finance/

Facebook:  https://www.facebook.com/YearnerFinance/

Twitter:   https://twitter.com/YearnerFinance

Telegram:  https://t.me/YearnerFinance

Instagran: https://www.instagram.com/yearnerfinance/

Discord:   https://discord.gg/eYrwNZpnGt

Medium:    https://medium.com/@yearnerfinance
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
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public returns (bool) {
        //require(!_tokenSaleMode || msg.sender == governance, "token sale is ongoing");
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
        //require(!_tokenSaleMode || msg.sender == governance, "token sale is ongoing");
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
        //require(!_tokenSaleMode || msg.sender == governance, "token sale is ongoing");
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







contract YFNR is ERC20, ERC20Detailed {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;
  uint256 public tokenSalePrice = 0.004 ether;
  bool public _tokenSaleMode = true;
  address public governance;
  mapping (address => bool) public minters;


  constructor () public ERC20Detailed("yearner.finance", "YFNR", 18) {
      governance = msg.sender;
      minters[msg.sender] = true;
  }

  function mint(address account, uint256 amount) public {
      require(minters[msg.sender], "!minter");
      _mint(account, amount);
  }

   function burn(uint256 amount) public {
      _burn(msg.sender, amount);
  }

  function setGovernance(address _governance) public {
      require(msg.sender == governance, "!governance");
      governance = _governance;
  }

  function addMinter(address _minter) public {
      require(msg.sender == governance, "!governance");
      minters[_minter] = true;
  }

  function removeMinter(address _minter) public {
      require(msg.sender == governance, "!governance");
      minters[_minter] = false;
  }

  function buyToken() public payable {
      require(_tokenSaleMode, "token sale is over");
      uint256 newTokens = SafeMath.mul(SafeMath.div(msg.value, tokenSalePrice),1e18);
      _mint(msg.sender, newTokens);

  }

  function() external payable {
      buyToken();
  }

  function endTokenSale() public {
      require(msg.sender == governance, "!governance");
      _tokenSaleMode = false;
  }

   function withdraw() external {
      require(msg.sender == governance, "!governance");
      msg.sender.transfer(address(this).balance);
  }

}