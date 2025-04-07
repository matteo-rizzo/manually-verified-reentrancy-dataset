pragma solidity ^0.4.23;

/**
 * Import SafeMath source from OpenZeppelin
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


/**
 * ERC 20 token
 * https://github.com/ethereum/EIPs/issues/20
 */



/** @title Coinweb (XCOe) contract **/

contract Coinweb is Token {

    using SafeMath for uint256;

    string public constant name = "Coinweb";
    string public constant symbol = "XCOe";
    uint256 public constant decimals = 8;
    uint256 public constant totalSupply = 2400000000 * 10**decimals;
    address public founder = 0x51Db57ABe0Fc0393C0a81c0656C7291aB7Dc0fDe; // Founder's address
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    /**
     * If transfers are locked, only the contract founder can send funds.
     * Contract starts its lifecycle in a locked transfer state.
     */
    bool public transfersAreLocked = true;

    /**
     * Construct Coinweb contract.
     * Set the founder balance as the total supply and emit Transfer event.
     */
    constructor() public {
        balances[founder] = totalSupply;
        emit Transfer(address(0), founder, totalSupply);
    }

    /**
     * Modifier to check whether transfers are unlocked or the
     * founder is sending the funds
     */
    modifier canTransfer() {
        require(msg.sender == founder || !transfersAreLocked);
        _;
    }

    /**
     * Modifier to allow only the founder to perform some contract call.
     */
    modifier onlyFounder() {
        require(msg.sender == founder);
        _;
    }

    function transfer(address _to, uint256 _value) public canTransfer returns (bool) {
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public canTransfer returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * Set transfer locking state. Effectively locks/unlocks token sending.
     * @param _transfersAreLocked Boolean whether transfers are locked or not
     * @return Whether the transaction was successful or not
     */
    function setTransferLock(bool _transfersAreLocked) public onlyFounder returns (bool) {
        transfersAreLocked = _transfersAreLocked;
        return true;
    }

    /**
     * Contract calls revert on public method as it's not supposed to deal with
     * Ether and should not have payable methods.
     */
    function() public {
        revert();
    }
}