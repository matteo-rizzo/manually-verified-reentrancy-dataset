pragma solidity ^0.4.23;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract BBODServiceRegistry is Ownable {

  //1. Manager
  //2. CustodyStorage
  mapping(uint => address) public registry;

    constructor(address _owner) {
        owner = _owner;
    }

  function setServiceRegistryEntry (uint key, address entry) external onlyOwner {
    registry[key] = entry;
  }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



contract ManagerInterface {
  function createCustody(address) external {}

  function isExchangeAlive() public pure returns (bool) {}

  function isDailySettlementOnGoing() public pure returns (bool) {}
}

contract Custody {

  using SafeMath for uint;

  BBODServiceRegistry public bbodServiceRegistry;
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor(address _serviceRegistryAddress, address _owner) public {
    bbodServiceRegistry = BBODServiceRegistry(_serviceRegistryAddress);
    owner = _owner;
  }

  function() public payable {}

  modifier liveExchangeOrOwner(address _recipient) {
    var manager = ManagerInterface(bbodServiceRegistry.registry(1));

    if (manager.isExchangeAlive()) {

      require(msg.sender == address(manager));

      if (manager.isDailySettlementOnGoing()) {
        require(_recipient == address(manager), "Only manager can do this when the settlement is ongoing");
      } else {
        require(_recipient == owner);
      }

    } else {
      require(msg.sender == owner, "Only owner can do this when exchange is dead");
    }
    _;
  }

  function withdraw(uint _amount, address _recipient) external liveExchangeOrOwner(_recipient) {
    _recipient.transfer(_amount);
  }

  function transferToken(address _erc20Address, address _recipient, uint _amount)
    external liveExchangeOrOwner(_recipient) {

    ERC20 token = ERC20(_erc20Address);

    token.transfer(_recipient, _amount);
  }

  function transferOwnership(address newOwner) public {
    require(msg.sender == owner, "Only the owner can transfer ownership");
    require(newOwner != address(0));

    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


contract Insurance is Custody {

  constructor(address _serviceRegistryAddress, address _owner)
  Custody(_serviceRegistryAddress, _owner) public {}

  function useInsurance (uint _amount) external {
    var manager = ManagerInterface(bbodServiceRegistry.registry(1));
    //Only usable for manager during settlement
    require(manager.isDailySettlementOnGoing() && msg.sender == address(manager));

    address(manager).transfer(_amount);
  }
}