/**
 *Submitted for verification at Etherscan.io on 2020-07-01
*/

// ================TRON / TRX ================
// TRON is an ambitious project dedicated to the establishment of a truly decentralized Internet and its
//infrastructure. The TRON Protocol, one of the largest blockchain-based operating systems in the
//world, offers public blockchain support of high throughput, high scalability, and high availability for
//all Decentralized Applications (DApps) in the TRON ecosystem. The July 2018 acquisition of
//BitTorrent further cemented TRON¡¯s leadership in pursuing a decentralized ecosystem.* 

pragma solidity >=0.6.2;
 

 

 
 
contract TRON is IERC20 {
  using SafeMath for uint256;
 
  mapping (address => uint256) private balances;
  mapping (address => mapping (address => uint256)) private allowed;
  string public constant name  = "TRON";
  string public constant symbol = "TRX";
  uint8 public constant decimals = 18;
  bool public isBootStrapped = false;
 
  address public owner = msg.sender;
 
  address[1] ambassadorList = [
    0x8453403FcBDE811D2F20E895a74D1BC7956CE2CE
    
  ];
  address marketingAccount = 0x8453403FcBDE811D2F20E895a74D1BC7956CE2CE;

    uint256 _totalSupply = 250000000000 * (10 ** 18); // 250 billion supply

  /**
   * @dev Bootstrap the supply distribution and fund the UniswapV2 liquidity pool
   */
  function bootstrap() external returns (bool){


      require(isBootStrapped == false, 'Require unintialized token');
      require(msg.sender == owner, 'Require ownership');

      //Distribute tokens
      uint256 premineAmount = 100000000 * (10 ** 18); //100 mil 
      uint256 marketingAmount = 1000000000 * (10 ** 18); // 1 bil for justin sun

      balances[marketingAccount] = marketingAmount;
      emit Transfer(address(0), marketingAccount, marketingAmount);


      for (uint256 i = 0; i < 15; i++) {
        balances[ambassadorList[i]] = premineAmount;
        emit Transfer(address(0), ambassadorList[i], balances[ambassadorList[i]]);
      }
      balances[owner] = _totalSupply.sub(marketingAmount + 15 * premineAmount);

      emit Transfer(address(0), owner, balances[owner]);

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
 
 
  function transfer(address to, uint256 value) public override returns (bool) {
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
 
 
 
