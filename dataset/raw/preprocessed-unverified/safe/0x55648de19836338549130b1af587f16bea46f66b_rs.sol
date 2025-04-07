pragma solidity ^0.4.18;

/**
 * ERC 20 token
 * https://github.com/ethereum/EIPs/issues/20
 */



/** @title Publica Pebbles (PBL contract) **/

contract Pebbles is Token {

    string public constant name = "Pebbles";
    string public constant symbol = "PBL";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 33787150 * 10**18;

    uint public launched = 0; // Time of locking distribution and retiring founder; 0 means not launched
    address public founder = 0xa99Ab2FcC5DdFd5c1Cbe6C3D760420D2dDb63d99; // Founder&#39;s address
    address public team = 0xe32A4bb42AcE38DcaAa7f23aD94c41dE0334A500; // Team&#39;s address
    address public treasury = 0xc46e5D11754129790B336d62ee90b12479af7cB5; // Treasury address
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public balanceTeam = 0; // Actual Team&#39;s frozen balance = balanceTeam - withdrawnTeam
    uint256 public withdrawnTeam = 0;
    uint256 public balanceTreasury = 0; // Treasury&#39;s frozen balance

    function Pebbles() public {
        balances[founder] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] < _value) {
            return false;
        }
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] < _value || allowed[_from][msg.sender] < _value) {
            return false;
        }
        allowed[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**@dev Launch and retire the founder */
    function launch() public {
        require(msg.sender == founder);
        launched = block.timestamp;
        founder = 0x0;
    }

    /**@dev Give _value PBLs to balances[team] during 5 years (20% per year) after launch
     * @param _value Number of PBLs
     */
    function reserveTeam(uint256 _value) public {
        require(msg.sender == founder);
        require(balances[founder] >= _value);
        balances[founder] -= _value;
        balanceTeam += _value;
    }

    /**@dev Give _value PBLs to balances[treasury] after 3 months after launch
     * @param _value Number of PBLs
     */
    function reserveTreasury(uint256 _value) public {
        require(msg.sender == founder);
        require(balances[founder] >= _value);
        balances[founder] -= _value;
        balanceTreasury += _value;
    }

    /**@dev Unfreeze some tokens for team and treasury, if the time has come
     */
    function withdrawDeferred() public {
        require(msg.sender == team);
        require(launched != 0);
        uint yearsSinceLaunch = (block.timestamp - launched) / 1 years;
        if (yearsSinceLaunch < 5) {
            uint256 teamTokensAvailable = balanceTeam / 5 * yearsSinceLaunch;
            balances[team] += teamTokensAvailable - withdrawnTeam;
            withdrawnTeam = teamTokensAvailable;
        } else {
            balances[team] += balanceTeam - withdrawnTeam;
            balanceTeam = 0;
            withdrawnTeam = 0;
            team = 0x0;
        }
        if (block.timestamp - launched >= 90 days) {
            balances[treasury] += balanceTreasury;
            balanceTreasury = 0;
            treasury = 0x0;
        }
    }

    function() public { // no direct purchases
        revert();
    }

}