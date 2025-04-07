/**
 *Submitted for verification at Etherscan.io on 2021-06-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;








/**
 * 
 * Fuck you token
 * 
 * 100% added into uniswap as liquidity, fuck you dogecoin and Shiba Inu
 * 
 */
contract FCKToken is IERC20, Ownable {
    
    using SafeMath for uint256;
    
    //Fuck you token, owner will take 0.6% fee
    address public feeTo = 0xa4f52e498af8b17F29FcF9F45f7250da0023d7CB;

    string public name = "Fuck you Token";
    string public symbol = "FCKT";
    uint256 public decimals = 18;
    uint256 private _totalSupply = 0;
    
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;
    
    constructor() {
       mint(msg.sender, (10 ** decimals) ** 2);
    }

    function mint(address tokenOwner, uint256 amount) public onlyOwner returns (uint256) {
        _totalSupply = _totalSupply.add(amount);
        balances[tokenOwner] = balances[tokenOwner].add(amount);
        emit Transfer(address(0), tokenOwner, amount);
        return balances[tokenOwner];
    }

    function burn(address tokenOwner, uint256 amount) public returns (uint256) {
        require(msg.sender == getOwner() || msg.sender == tokenOwner, "ERC20: permission denied");
        _totalSupply = _totalSupply.sub(amount);
        balances[tokenOwner] = balances[tokenOwner].sub(amount);
        emit Transfer(tokenOwner, address(0), amount);
        return balances[tokenOwner];
    }
    
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];    
    }
    
    function allowance(address tokenOwner, address spender) public override view returns (uint) {
        return allowed[tokenOwner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, allowed[sender][msg.sender].sub(amount));
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        
        uint256 fee = 0;
        if (amount < 1000) {
            fee = 6;
        } else {
            fee = amount * 6 / 1000;
        }
        require(balances[sender] >= amount.add(fee), "ERC20: transfer sender amount exceeds balance");
        
        balances[sender] = balances[sender].sub(amount.add(fee));
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        
        
        // Trigger notification and added fee
        balances[feeTo] = balances[feeTo].add(fee);
        emit Transfer(sender, feeTo, fee);
        
    }
    
    function _approve(address tokenOwner, address spender, uint256 amount) internal {
        allowed[tokenOwner][spender] = amount;
    }
    
}