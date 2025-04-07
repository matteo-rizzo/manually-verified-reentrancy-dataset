/**
 *Submitted for verification at Etherscan.io on 2020-06-14
*/

pragma solidity >=0.6.2;




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}






contract PRVToken is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private balances;
  mapping (address => mapping (address => uint256)) private allowed;
  string public constant name  = "Pyrabank Private";
  string public constant symbol = "PRV";
  uint8 public constant decimals = 18;
  bool public isBootStrapped = false; 
  
  IUniswapV2Router02 public router;

  
  address public owner = msg.sender;

  uint256 _totalSupply = 1800000 * (10 ** 18); // 1.8 million supply

  /**
   * @dev Construct a new token linked to a Uniswap environment
   * @param routerAddr Address of IUniswapV2Router
   */
  constructor(address routerAddr) public {
      
    router = IUniswapV2Router02(routerAddr);  
  }
  
  /**
   * @dev Bootstrap the supply distribution and fund the UniswapV2 liquidity pool
   */
  function bootstrap() external payable returns (bool){
      
      
      require(isBootStrapped == false, 'Require unintialized token');
      require(msg.sender == owner, 'Require ownership');
      require(msg.value >= 0.0001 ether, 'Require atleast 0.0001 ETH');
      
      //Distribute tokens 
      // 82% for OTC presale buyers; 7% market making; 11% locked liquidity forever
      address token = address(this);
      balances[owner] = _totalSupply * 89 / 100;
      
      balances[token] = _totalSupply.sub(balances[owner]);
      emit Transfer(address(0), owner, balances[owner]);
      emit Transfer(address(0), token, balances[token]);
      
      //Approve UniswapV2 Router for transfer
      allowed[address(this)][address(router)] = balances[address(this)];
      
      //Create and fund Uniswap V2 liquidity pool
      router.addLiquidityETH.value(msg.value)(
        token,
        balances[token],
        1,
        1,
        token,
        now + 1 hours
        );
      
      //done
      isBootStrapped = true;
      
      return isBootStrapped;
      
  }

  function totalSupply() public override view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address player) public override view returns (uint256) {
    return balances[player];
  }

  function allowance(address player, address spender) public override view returns (uint256) {
    return allowed[player][spender];
  }


  function transfer(address to, uint256 value) override public returns (bool) {
    require(value <= balances[msg.sender]);
    require(to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[to] = balances[to].add(value);

    emit Transfer(msg.sender, to, value);
    return true;
  }

  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
  }

  function approve(address spender, uint256 value) override public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function approveAndCall(address spender, uint256 tokens, bytes calldata data) override external returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

  function transferFrom(address from, address to, uint256 value) override public returns (bool) {
    require(value <= balances[from]);
    require(value <= allowed[from][msg.sender]);
    require(to != address(0));
    
    balances[from] = balances[from].sub(value);
    balances[to] = balances[to].add(value);
    
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
    
    emit Transfer(from, to, value);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = allowed[msg.sender][spender].add(addedValue);
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(subtractedValue);
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  function burn(uint256 amount) external {
    require(amount != 0);
    require(amount <= balances[msg.sender]);
    _totalSupply = _totalSupply.sub(amount);
    balances[msg.sender] = balances[msg.sender].sub(amount);
    emit Transfer(msg.sender, address(0), amount);
  }

}



