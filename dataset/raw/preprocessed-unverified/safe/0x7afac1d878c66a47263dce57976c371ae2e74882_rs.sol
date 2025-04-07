pragma solidity 0.6.0;





contract YFMOONBEAMToken is Ownable {
  using SafeMath for uint256;

  string public constant name = "YFMOONBEAM";
  string public constant symbol = "YFMB";
  uint256 public constant decimals = 18;
  // the supply will not exceed 1,000,000 YFMB
  uint256 private constant _maximumSupply = 1000000 * 10 ** decimals;
  uint256 private constant _maximumPresaleBurnAmount = 80000 * 10 ** decimals;
  uint256 public _presaleBurnTotal = 0;
  uint256 public _totalSupply;

  // events
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  // mappings
  mapping(address => uint256) public _balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;

  constructor() public override {
    // transfer the entire supply to contract creator
    _owner = msg.sender;
    _totalSupply = _maximumSupply;
    _balanceOf[msg.sender] = _maximumSupply;
    emit Transfer(address(0x0), msg.sender, _maximumSupply);
  }

  function totalSupply () public view returns (uint256) {
    return _totalSupply; 
  }

  function balanceOf (address who) public view returns (uint256) {
    return _balanceOf[who];
  }

  // checks that the address is valid
  function _transfer(address _from, address _to, uint256 _value) internal {
    _balanceOf[_from] = _balanceOf[_from].sub(_value);
    _balanceOf[_to] = _balanceOf[_to].add(_value);
    emit Transfer(_from, _to, _value);
  }

  // transfer tokens
  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(_balanceOf[msg.sender] >= _value);
    _transfer(msg.sender, _to, _value);
    return true;
  }

  // performs presale burn
  function burn (uint256 _burnAmount, bool _presaleBurn) public onlyOwner returns (bool success) {
    if (_presaleBurn) {
      require(_presaleBurnTotal.add(_burnAmount) <= _maximumPresaleBurnAmount);
      _presaleBurnTotal = _presaleBurnTotal.add(_burnAmount);
      _transfer(_owner, address(0), _burnAmount);
      _totalSupply = _totalSupply.sub(_burnAmount);
    } else {
      _transfer(_owner, address(0), _burnAmount);
      _totalSupply = _totalSupply.sub(_burnAmount);
    }
    return true;
  }

  // approve spend
  function approve(address _spender, uint256 _value) public returns (bool success) {
    require(_spender != address(0));
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  // transfer from
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(_value <= _balanceOf[_from]);
    require(_value <= allowance[_from][msg.sender]);
    allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
    _transfer(_from, _to, _value);
    return true;
  }
}