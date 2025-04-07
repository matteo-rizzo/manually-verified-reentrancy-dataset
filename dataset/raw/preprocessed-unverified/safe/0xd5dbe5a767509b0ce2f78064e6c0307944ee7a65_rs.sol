pragma solidity ^0.4.24;


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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */




/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */











/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */



contract Lockable is Ownable {

    bool public isLocked = false;

    event Locked();

    /**
     * @dev Must be called after crowdsale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function lock() onlyOwner public {
        require(!isLocked);

        emit Locked();

        isLocked = true;
    }

    modifier notLocked() {
        require(!isLocked);
        _;
    }
}

contract TokenTimelockVault is Ownable, Lockable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Basic;

    event Invested(address owner, uint balance);
    event Released(uint256 amount);

    mapping(address => TimeEnvoy) internal owners;

    struct TimeEnvoy {
        address owner;
        uint releaseTime;
        uint balance;
        bool released;
    }

    function addOwners(address[] _owners, uint[] _releaseTimes, uint[] _balances) public onlyOwner notLocked {
        require(_owners.length > 0);
        require(_owners.length == _releaseTimes.length);
        require(_owners.length == _balances.length);
        for (uint i = 0; i < _owners.length; i++) {
            owners[_owners[i]] = TimeEnvoy({
                owner : _owners[i],
                releaseTime : _releaseTimes[i],
                balance : _balances[i],
                released : false});
            emit Invested(_owners[i], _balances[i]);
        }
    }

    function addOwner(address _owner, uint _releaseTime, uint _balance) public onlyOwner notLocked {
        owners[owner] = TimeEnvoy({
            owner : _owner,
            releaseTime : _releaseTime,
            balance : _balance,
            released : false});

        emit Invested(_owner, _balance);
    }

    function release(ERC20Basic token, address _owner) public {
        TimeEnvoy storage owner = owners[_owner];
        require(!owner.released);

        uint256 unreleased = releasableAmount(_owner);

        require(unreleased > 0);

        owner.released = true;
        token.safeTransfer(owner.owner, owner.balance);

        emit Released(unreleased);
    }

    function releasableAmount(address _owner) public view returns (uint256){
        if (_owner == address(0)) {
            return 0;
        }
        TimeEnvoy storage owner = owners[_owner];
        if (owner.released) {
            return 0;
        } else if (block.timestamp >= owner.releaseTime) {
            return owner.balance;
        } else {
            return 0;
        }
    }

    function ownedBalance(address _owner) public view returns (uint256){
        TimeEnvoy storage owner = owners[_owner];
        return owner.balance;
    }
}