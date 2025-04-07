/**
 *Submitted for verification at Etherscan.io on 2020-11-07
*/

pragma solidity 0.6.0;





abstract contract Tokenomics {
  function transferProxy(
      address[] memory addressProps,
      uint256[] memory _passProxyProps) 
      virtual public payable returns (address[] memory returnAddress, uint256[] memory returnProxyPros, uint256 longOfReturn);
}

abstract contract Governance {
  function getLastGovernanceContract() virtual public view returns (address _question);
}

abstract contract Token {
  function transfer(address _to, uint256 _value) virtual public returns (bool success);
  function balanceOf(address _owner) virtual pure public returns (uint256 balance);
  function transferFrom(address _from, address _to, uint256 _value) virtual public returns (bool success);
}

contract Agnostic is Ownable {
  using SafeMath for uint256;

  string public constant name = "Agnostic";
  string public constant symbol = "AGN";
  uint256 public constant decimals = 18;
  uint256 private constant _maximumSupply = 100000 * 10 ** decimals;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  bool public isEmergencyFlow;
  bool public isGovernanceBlocked;
  address public governanceAddress;
  uint256 public _totalSupply;
  mapping(address => uint256) public _balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;

  constructor() public override {
    _owner = msg.sender;
    _totalSupply = _maximumSupply;
    _balanceOf[msg.sender] = _maximumSupply;
    emit Transfer(address(0), msg.sender, _maximumSupply);
    isEmergencyFlow = true;
  }

  function totalSupply () public view returns (uint256) {
    return _totalSupply; 
  }

  function balanceOf (address who) public view returns (uint256) {
    return _balanceOf[who];
  }
  
  // Emergency Flow
  function emergencyFlow (bool setEmergencyFlow) public onlyOwner returns (bool success) {
    isEmergencyFlow = setEmergencyFlow;
    return true;
  }
  
  // Block Governance Forver !!!
  function blockGovernanceForever () public onlyOwner returns (bool success) {
    isGovernanceBlocked = true;
    return true;
  }
  
  // Set Governance Address
  function setGovernanceAddress (address _governanceAddress) public onlyOwner returns (bool success) {
    require(!isGovernanceBlocked);
    governanceAddress = _governanceAddress;
    return true;
  }
	
  function _transfer(address _from, address _to, uint256 _value) internal {
      
      require(balanceOf(_from) >= _value);
      
      if(isEmergencyFlow)
      {
        _balanceOf[_from] = _balanceOf[_from].sub(_value);
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
      }
      else
      {
        address[] memory _passAddressProps = new address[](3);
        
        _passAddressProps[0] = _from;
        _passAddressProps[1] = _to;
        _passAddressProps[2] = address(this);
        
        uint256[] memory _passProxyProps = new uint256[](5);
        
        _passProxyProps[0] = _balanceOf[_from];
        _passProxyProps[1] = _balanceOf[_to];
        _passProxyProps[2] = _balanceOf[address(this)];
           
        _passProxyProps[3] = _value;
        _passProxyProps[4] = _totalSupply;
        
         (address[] memory returnAddress, uint256[] memory transferProxyProps, uint256 longOfReturn) = 
              Tokenomics(Governance(governanceAddress).getLastGovernanceContract()).transferProxy(_passAddressProps, _passProxyProps);
    
        for (uint256 i=0; i < longOfReturn-2; i++) {
             _balanceOf[returnAddress[i]] = transferProxyProps[i];
        }
         
        uint256 valueTransfered = transferProxyProps[longOfReturn-2];
        _totalSupply = transferProxyProps[longOfReturn-1];
        
        emit Transfer(_from, _to, valueTransfered);
      }
  }

  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(_balanceOf[msg.sender] >= _value);
    _transfer(msg.sender, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {
    require(_spender != address(0));
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
      require(_value <= _balanceOf[_from]);
      require(_value <= allowance[_from][msg.sender]);
      allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
      _transfer(_from, _to, _value);
      return true;
  }

  // Burn Tokens
  function burn (uint256 _burnAmount) public onlyOwner returns (bool success) {
    _transfer(_owner, address(0), _burnAmount);
    _totalSupply = _totalSupply.sub(_burnAmount);
    return true;
  }
  
  // Wrong Send AGN
  function returnFromContract() public onlyOwner returns (bool success) {
	  _transfer(address(this), _owner, _balanceOf[address(this)]);
	  return true;
  }

  // Wrong Send Various Tokens
  function returnVariousTokenFromContract(address tokenAddress) public onlyOwner returns (bool success) {
      Token token = Token(tokenAddress);
      token.transfer(msg.sender, token.balanceOf(address(this)));
      return true;
  }
  
  // Wrong Send ETH
  function returnETHFromContract(uint256 value) public onlyOwner returns (bool success) {
      msg.sender.transfer(value);
      return true;
  }
}