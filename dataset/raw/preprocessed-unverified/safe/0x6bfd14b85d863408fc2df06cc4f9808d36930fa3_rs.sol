pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */


contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes _data);
}

contract ERC223Basic {
    uint public totalSupply;
    function balanceOf(address who) constant returns (uint);
    function transfer(address to, uint value);
    function transfer(address to, uint value, bytes data);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

contract ERC223BasicToken is ERC223Basic {
    using SafeMath for uint;

    mapping(address => uint) balances;

    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address to, uint value, bytes data) {
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(to)
        }

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
            receiver.tokenFallback(msg.sender, value, data);
        }
        Transfer(msg.sender, to, value, data);
    }

    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    function transfer(address to, uint value) {
        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(to)
        }

        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
            bytes memory empty;
            receiver.tokenFallback(msg.sender, value, empty);
        }
        Transfer(msg.sender, to, value, empty);
    }

    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }
}

contract Doge2Token is ERC223BasicToken {

  string public name = "Doge2 Token";
  string public symbol = "DOGE2";
  uint256 public decimals = 8;
  uint256 public INITIAL_SUPPLY = 200000000000000;
  
  address public owner;
  event Buy(address indexed participant, uint tokens, uint eth);

  /**
   * @dev Contructor that gives msg.sender all of existing tokens. 
   */
    function Doge2Token() {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        owner = msg.sender;
    }
    
    function () payable {
        //lastDeposit = msg.sender;
        //uint tokens = msg.value / 100000000;
        uint tokens = msg.value / 10000;
        balances[owner] -= tokens;
        balances[msg.sender] += tokens;
        bytes memory empty;
        Transfer(owner, msg.sender, tokens, empty);
        //bytes memory empty;
        Buy(msg.sender, tokens, msg.value);
        //if (msg.value < 0.01 * 1 ether) throw;
        //doPurchase(msg.sender);
    }
    
}