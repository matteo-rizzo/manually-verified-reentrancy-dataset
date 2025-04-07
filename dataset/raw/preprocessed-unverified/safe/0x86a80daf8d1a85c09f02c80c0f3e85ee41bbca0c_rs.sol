pragma solidity 0.4.21;



///////////// SAFE MATH FUNCTIONS



contract UserTokensControl is Ownable {
    address contractReserve;
}


///////////// DECLARE ERC223 BASIC INTERFACE

contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint256 _value, bytes _data) public pure {
        _from;
        _value;
        _data;
    }
}

contract ERC223 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
}

contract ERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}


contract BasicToken is ERC20, ERC223, UserTokensControl {
    uint256 public totalSupply;
    using SafeMath for uint256;

    mapping(address => uint256) balances;


  ///////////// TRANSFER ////////////////

    function transferToAddress(address _to, uint256 _value, bytes _data) internal returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    function transferToContract(address _to, uint256 _value, bytes _data) internal returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        emit Transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(_value > 0);

        uint256 codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }
    
        if(codeLength > 0) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }


    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(_value > 0);

        uint256 codeLength;
        bytes memory empty;
        assembly {
            codeLength := extcodesize(_to)
        }

        if(codeLength > 0) {
            return transferToContract(_to, _value, empty);
        } else {
            return transferToAddress(_to, _value, empty);
        }
    }


    function balanceOf(address _address) public constant returns (uint256 balance) {
        return balances[_address];
    }
}


contract StandardToken is BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;
}

contract Airstayz is StandardToken {
    string public constant name = "AIRSTAYZ";
    uint public constant decimals = 18;
    string public constant symbol = "STAY";

    function Airstayz() public {
        totalSupply=155000000 *(10**decimals);
        owner = msg.sender;
        contractReserve = 0xb5AB0c087b9228D584CD4363E3d000187FE69C51;
        balances[msg.sender] = 150350000 * (10**decimals);
        balances[contractReserve] = 4650000 * (10**decimals);
    }

    function() public {
        revert();
    }
}