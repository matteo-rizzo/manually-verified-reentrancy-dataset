/**
 *Submitted for verification at Etherscan.io on 2020-10-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.2;





abstract contract Pausable is Owned {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
      require(!paused, "all transaction has been paused");
      _;
    }

    modifier whenPaused() {
      require(paused, "transaction is current opened");
      _;
    }

    function pause() onlyOwner whenNotPaused external {
      paused = true;
      emit Pause();
    }

    function unpause() onlyOwner whenPaused external {
      paused = false;
      emit Unpause();
    }
}



abstract contract ERC20 is IERC20, Pausable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
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

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal whenNotPaused returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

}

contract Fast500Token is ERC20 {

    using SafeMath for uint256;
    string  public  name;
    string  public  symbol;
    uint8   public decimals;

    uint256 public totalMinted;
    uint256 public totalBurnt;

    constructor(string memory _name, string memory _symbol) Owned(msg.sender) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        _mint(msg.sender, 500 ether);
        totalMinted = totalSupply();
        totalBurnt = 0;
    }
    
    function burn(uint256 _amount) external whenNotPaused returns (bool) {
       super._burn(msg.sender, _amount);
       totalBurnt = totalBurnt.add(_amount);
       return true;
   }

    function transfer(address _recipient, uint256 _amount) public override whenNotPaused returns (bool) {
        if(totalSupply() <= 100 ether) {
            super._transfer(msg.sender, _recipient, _amount);
            return true;
        }
        
        uint _amountToBurn = _amount.mul(8).div(100);
        _burn(msg.sender, _amountToBurn);
        totalBurnt = totalBurnt.add(_amountToBurn);
        uint _unBurntToken = _amount.sub(_amountToBurn);
        super._transfer(msg.sender, _recipient, _unBurntToken);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) public override whenNotPaused returns (bool) {
        super._transferFrom(_sender, _recipient, _amount);
        return true;
    }
    
  // Removed mint function for onlyOwner
    
    receive() external payable {
        uint _amount = msg.value;
        msg.sender.transfer(_amount);
    }
}