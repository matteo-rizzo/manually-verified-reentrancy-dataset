/**
 *Submitted for verification at Etherscan.io on 2020-07-16
*/

pragma solidity =0.6.6;




// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)




/**
 * @title Ownable contract
 * @dev The Ownable contract has an owner address, and provides basic authorization control functions.
 */
contract Ownable is IOwnable {
    address public override owner;
    mapping(address => bool) public override minable;

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Modifiers
    modifier onlyMinable() {
        require(minable[msg.sender] == true, 'Unioracle: NOT_MINABLE'); // single check is sufficient
        _;
    }

    modifier validAddress(address _address) {
        require(_address != address(0));
        _;
    }

    // Events
    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

    /// @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
    constructor(address _owner) public validAddress(_owner) {
        owner = _owner;
    }

    /// @dev Allows the current owner to transfer control of the contract to a newOwner.
    /// @param _newOwner The address to transfer ownership to.
    function transferOwnership(address _newOwner) public override onlyOwner validAddress(_newOwner) {
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    /// @dev Allows the current owner to update minable permission of the oracle contract.
    /// @param _address The address of the oracle contract.
    function updateMinable(address _address, bool _minable) public override onlyOwner validAddress(_address) {
        minable[_address] = _minable;
    }
}

contract UnioracleToken is IUnioracleToken, Ownable {
    using SafeMath for uint;

    string public override name = 'Unioracle Token';
    string public override symbol = 'UNO';
    uint8 public immutable override decimals = 18;
    uint  public override totalSupply;
    mapping(address => uint) public override balanceOf;
    mapping(address => mapping(address => uint)) public override allowance;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor() Ownable(msg.sender) public {
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

    function mining(address to, uint value) external override onlyMinable returns (bool) {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
        return true;
    }
}