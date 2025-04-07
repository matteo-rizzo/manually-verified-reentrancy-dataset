pragma solidity ^0.4.24;


contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}





contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping(address => uint256) balances;

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(msg.sender != address(0));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

}

contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_from != address(0));

        uint256 _allowance = allowed[_from][msg.sender];

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



contract HiGold is StandardToken, Ownable {

    /*** SAFEMATH ***/
    using SafeMath for uint256;

    /*** EVENTS ***/
    event Deposit(address indexed manager, address indexed user, uint value);
    event Withdrawl(address indexed manager, address indexed user, uint value);

    /*** CONSTANTS ***/
    // ERC20
    string public name = "HiGold Community Token";
    string public symbol = "HIG";
    uint256 public decimals = 18;

    /*** STORAGE ***/
    // HiGold Standard
    uint256 public inVaults;
    address public miner;
    mapping (address => mapping (address => uint256)) inVault;

    /*** MODIFIERS  ***/
    modifier onlyMiner() {
        require(msg.sender == miner);
        _;
    }

    /*** FUNCTIONS ***/
    // Constructor function
    constructor() public {
        totalSupply = 105 * (10 ** 26);
        balances[msg.sender] = totalSupply;
    }

    // Public functions
    function totalInVaults() public constant returns (uint256 amount) {
        return inVaults;
    }

    function balanceOfOwnerInVault
    (
        address _vault,
        address _owner
    )
        public
        constant
        returns (uint256 balance)
    {
        return inVault[_vault][_owner];
    }

    function deposit
    (
        address _vault,
        uint256 _value
    )
        public
        returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        inVaults = inVaults.add(_value);
        inVault[_vault][msg.sender] = inVault[_vault][msg.sender].add(_value);
        emit Deposit(_vault, msg.sender, _value);
        return true;
    }

    function withdraw
    (
        address _vault,
        uint256 _value
    )
        public
        returns (bool)
    {
        inVault[_vault][msg.sender] = inVault[_vault][msg.sender].sub(_value);
        inVaults = inVaults.sub(_value);
        balances[msg.sender] = balances[msg.sender].add(_value);
        emit Withdrawl(_vault, msg.sender, _value);
        return true;
    }

    function accounting
    (
        address _credit, // -
        address _debit, // +
        uint256 _value
    )
        public
        returns (bool)
    {
        inVault[msg.sender][_credit] = inVault[msg.sender][_credit].sub(_value);
        inVault[msg.sender][_debit] = inVault[msg.sender][_debit].add(_value);
        return true;
    }

    /// For Mining
    function startMining(address _minerContract) public  onlyOwner {
        require(miner == address(0));
        miner = _minerContract;
        inVault[miner][miner] = 105 * (10 ** 26);
    }
    //// Update contract overview infomations when new token is mined.
    function updateInfo(uint _value) public onlyMiner returns(bool) {
        totalSupply = totalSupply.add(_value);
        inVaults = inVaults.add(_value);
        return true;
    }
    //// Change miner contract if needed.
    function setNewMiner(address _newMiner) public onlyMiner returns(bool) {
        miner = _newMiner;
        return true;
    }

}