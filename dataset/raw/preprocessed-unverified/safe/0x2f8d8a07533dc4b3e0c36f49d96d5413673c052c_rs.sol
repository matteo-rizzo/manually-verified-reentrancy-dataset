/**
 *Submitted for verification at Etherscan.io on 2020-11-16
*/

// SPDX-License-Identifier: MIT

/* Keep8r ¨C kp8r.network 2020 */

pragma solidity ^0.6.6;



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
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override returns (bool) {
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

abstract contract ERC20Detailed is IERC20 {
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







/* Keep8r ¨C kp8r.network */
contract Keep8rToken is ERC20, ERC20Detailed {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint;

    address public governance;
    address public governancePending;
    mapping (address => bool) public minters;
    address payable public _owner;
    
    uint _totalSupply=50000e18;
    
    
    
    

    /** @notice The keeper logic and governance token: KP8R (this contract),
      * have been decoupled. Seperating the keeper/jobs logic and governance logic,
      * from the token. Allows greater flexibility and room for further innovation 
      * and improvment on the Keeper/Jobs and democratic protocols. 
     */
    constructor () public ERC20Detailed("Keep8r", "KP8R", 18) {
        governance = msg.sender;
        _mint(msg.sender, _totalSupply); 
        _owner=msg.sender;
    }
    
    
    // function buytoken(uint _amount) public payable{
    //     // transfer(_owner,msg.value);
    //     // k8token.transfer(msg.sender,_amount);
    //     // this.transfer(msg.sender,_amount);
        
    //     this.transferFrom(msg.sender,_owner,_amount);
    //     _owner.transfer(address(this).balance);
    // }
    
    

    /** @notice governance, via token holders, can decide to burn tokens. */
    function burn(uint amount) public {
         require(msg.sender == governance, "only governance");
         // limitation on power:
         // token can only be burnt from the governance account.
        _burn(msg.sender, amount);
    }

    /** @notice safely begin the governance transfer process. The new governance
      * address, must accept the transfer. */
    function transferGovernance(address _governance) public {
        require(msg.sender == governance, "!governance");
        governancePending = _governance;
    }

    /** @notice to complete the governance transfer process new governance
     * address, must accept the transfer. */
    function acceptGovernance() public {
        require(msg.sender == governancePending, "!governancePending");
        governance = governancePending;
    }

}