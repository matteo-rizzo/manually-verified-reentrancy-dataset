/**
 *Submitted for verification at Etherscan.io on 2020-07-17
*/

//CHUDDY
pragma solidity 0.5.16;

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) public view returns (uint);
  function transfer(address to, uint value) public;
  event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint);
  function transferFrom(address from, address to, uint value) public;
  function approve(address spender, uint value) public;
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract BasicToken is ERC20Basic {

  using SafeMath for uint;

  mapping(address => uint) balances;

  function transfer(address _to, uint _value) public{
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}

contract StandardToken is BasicToken, ERC20 {
  mapping (address => mapping (address => uint)) allowed;

  function transferFrom(address _from, address _to, uint _value) public {
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
  }

  function approve(address _spender, uint _value) public{
    require((_value == 0) || (allowed[msg.sender][_spender] == 0)) ;
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
  }

  function allowance(address _owner, address _spender) public view returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}

// File: contracts/multisender/Ownable.sol
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    function isOwner() internal view returns (bool) {
        return _msgSender() == _owner;
    }
        
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract MultiSender is Ownable{
    using SafeMath for uint256;

    uint256 _arrayLimit;
    StandardToken _token;

    event Multisend(uint256 total);
    event ChangeTargetToken(address addr);
    event ChangeArrayLimit(uint256 limit);

    constructor (address token) public{
        setArrayLimit(1000);
        _token = StandardToken(token);
    }

    function arrayLimit() public view returns(uint256) {
        return _arrayLimit;
    }

    function setArrayLimit(uint256 _newLimit) public onlyOwner {
        require(_newLimit != 0);
        _arrayLimit = _newLimit;
        emit ChangeArrayLimit(arrayLimit());
    }
    
    function setNewTokenAddress(address _addr) public onlyOwner {
        _token = StandardToken(_addr);
        emit ChangeTargetToken(_addr);
    }

    function multisendToken(address[] memory _to, uint256[] memory _balances) public onlyOwner{
        uint256 total = 0;
        require(_to.length <= arrayLimit());
        require(_to.length == _balances.length);
        
        for (uint8 i = 0; i < _to.length; i++) {
            _token.transferFrom(msg.sender, _to[i], _balances[i]);
            total += _balances[i];
        }
        emit Multisend(total);
    }
}