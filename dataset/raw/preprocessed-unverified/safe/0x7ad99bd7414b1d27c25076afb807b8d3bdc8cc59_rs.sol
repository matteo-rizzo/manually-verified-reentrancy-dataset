/**
 *Submitted for verification at Etherscan.io on 2021-02-16
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.6.11;







contract HedgehogERC20 is IERC20 {
    using SafeMath for uint;
    
    string public override name;
    string public override symbol;
    uint8 public override decimals;
    uint  public override totalSupply;
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) external override returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }
}

contract Hedgehog is HedgehogERC20{
  using SafeMath for uint256;

  bool public initialized;
  address public asset;

  uint256 public timestamp;
  uint256 public oracle;
  uint256 public oracle_prev;

  event Deposit(address indexed from, uint256 asset_value, uint256 token_value);
  event Withdraw(address indexed from, uint256 asset_value, uint256 token_value);
  event Oracle(uint256 timestamp, uint256 new_price, uint256 old_price);

  uint256 private unlocked = 1;
  modifier lock() {
      require(unlocked == 1, 'Hedgehog: LOCKED');
      unlocked = 0;
      _;
      unlocked = 1;
  }

  function initialize(address _asset) public {
      require(initialized == false, "Hedgehog_initialize: already initialized");
      asset = _asset;
      initialized = true;
      string memory _name = IERC20(asset).name();
      name = append("Hedgehog ", _name);
      string memory _symbol = IERC20(asset).symbol();
      symbol = append("h", _symbol);
      decimals = 5;
  }

  function price() public view returns (uint256) {
      uint256 token_price = calculateAssetIn(1e5);
      return token_price;
  }
  
  function deposit(uint256 token_amount, uint256 expected_assets) public lock {
      uint256 asset_deposit = calculateAssetIn(token_amount);
      require(asset_deposit > 0, "Hedgehog_Deposit: zero asset deposit"); 
      require(asset_deposit <= expected_assets, "Hedgehog_Deposit: deposit assets above expected");
      _oracle();
      TransferHelper.safeTransferFrom(asset, msg.sender, address(this), asset_deposit); 
      _mint(msg.sender, token_amount);
      Deposit(msg.sender, asset_deposit, token_amount);
  }

  function withdraw(uint256 token_amount, uint256 expected_assets) public lock {
      uint256 asset_withdraw = calculateAssetOut(token_amount);
      require(asset_withdraw > 0, "Hedgehog_withdraw: zero asset withdraw"); 
      require(asset_withdraw >= expected_assets, "Hedgehog_Deposit: withdraw assets below expected");
      _oracle();
      _burn(msg.sender, token_amount);
      TransferHelper.safeTransfer(asset, msg.sender, asset_withdraw);
      Withdraw(msg.sender, asset_withdraw, token_amount);
  }

  function calculateAssetIn(uint256 token_amount) public view returns (uint256) {
      uint256 asset_balance = IERC20(asset).balanceOf(address(this));
      uint256 token_balance_new = totalSupply.add(token_amount);
      uint256 asset_balance_new = token_balance_new.mul(token_balance_new);
      return asset_balance_new.sub(asset_balance);
  }

  function calculateAssetOut(uint256 token_amount) public view returns (uint256) {
      uint256 asset_balance = IERC20(asset).balanceOf(address(this));
      uint256 token_balance_new = totalSupply.sub(token_amount);
      uint256 asset_balance_new = token_balance_new.mul(token_balance_new);
      return asset_balance.sub(asset_balance_new);
  }

  function _oracle() internal {
      if (timestamp < block.timestamp && totalSupply > 0){
          timestamp = block.timestamp;
          oracle_prev = oracle;
          oracle = price();
          Oracle(timestamp, oracle, oracle_prev);
      }
  }

  function append(string memory a, string memory b) internal pure returns (string memory) {
      return string(abi.encodePacked(a, b));
  }
}