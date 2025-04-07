/**
 *Submitted for verification at Etherscan.io on 2019-12-26
*/

pragma solidity 0.5.10;







contract FLARE is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 public _burnRate;
    uint256 private _totalSupply;
    

    string public constant name = "FLARE ETHEREAL";
    string public constant symbol = "FE";
    uint256 public constant decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 999999 * 10**decimals;

  
  constructor() public {
    _totalSupply = INITIAL_SUPPLY;
    _balances[0x386d2dCd61689692eF6C9E47646C2f6ef1aceADD ] = INITIAL_SUPPLY;
    emit Transfer(address(0), 0x386d2dCd61689692eF6C9E47646C2f6ef1aceADD ,_totalSupply);
    
  }


    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }


    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }


    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
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
        
        
        uint256 tokensToBurn = _tokenToBurn(amount);
        uint256 tokensToTransfer = amount.sub(tokensToBurn);
        
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(tokensToTransfer);

        _totalSupply = _totalSupply.sub(tokensToBurn);
        
        emit Transfer(sender, recipient, tokensToTransfer);
        emit Transfer(sender, address(0), tokensToBurn);
    }
    

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    
    function burnRate() public returns(uint256) {
        if (_totalSupply > 888888000000000000000000) {
            _burnRate = 2000000000000000;
        } else if(_totalSupply <= 888888000000000000000000 && _totalSupply > 99999000000000000000000) {
            _burnRate = 2000000000000000;
                        } else if(_totalSupply <= 99999000000000000000000) {
            _burnRate = 1;
        } 
        
        return _burnRate;
    }

    
    function _tokenToBurn(uint256 value) public returns(uint256){ 
        uint256 _burnerRate = burnRate();
        uint256 roundValue = value.ceil(_burnerRate);
        uint256 _myTokensToBurn = roundValue.mul(_burnerRate).div(100000000000000000);
        return _myTokensToBurn;
    }
    
}