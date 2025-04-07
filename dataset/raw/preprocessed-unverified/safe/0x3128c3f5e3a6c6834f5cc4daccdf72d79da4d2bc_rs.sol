pragma solidity ^0.4.19;







contract ERC20Basic {

    uint256 public totalSupply;



    function balanceOf(address who) constant public returns (uint256);



    function transfer(address to, uint256 value) public returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) constant public returns (uint256);



    function transferFrom(address from, address to, uint256 value) public returns (bool);



    function approve(address spender, uint256 value) public returns (bool);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}







contract Blocked {



    uint public blockedUntil;



    modifier unblocked {

        require(now > blockedUntil);

        _;

    }

}



contract BasicToken is ERC20Basic, Blocked {



    using SafeMath for uint256;



    mapping (address => uint256) balances;



    // Fix for the ERC20 short address attack

    modifier onlyPayloadSize(uint size) {

        require(msg.data.length >= size + 4);

        _;

    }



    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) unblocked public returns (bool) {

        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;

    }



    function balanceOf(address _owner) constant public returns (uint256 balance) {

        return balances[_owner];

    }



}



contract StandardToken is ERC20, BasicToken {



    mapping (address => mapping (address => uint256)) allowed;



    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) unblocked public returns (bool) {

        uint256 _allowance = allowed[_from][msg.sender];



        balances[_to] = balances[_to].add(_value);

        balances[_from] = balances[_from].sub(_value);

        allowed[_from][msg.sender] = _allowance.sub(_value);

        Transfer(_from, _to, _value);

        return true;

    }



    function approve(address _spender, uint256 _value) onlyPayloadSize(2 * 32) unblocked public returns (bool) {



        require((_value == 0) || (allowed[msg.sender][_spender] == 0));



        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) onlyPayloadSize(2 * 32) unblocked constant public returns (uint256 remaining) {

        return allowed[_owner][_spender];

    }



}



contract BurnableToken is StandardToken {



    event Burn(address indexed burner, uint256 value);



    function burn(uint256 _value) unblocked public {

        require(_value > 0);

        require(_value <= balances[msg.sender]);

        // no need to require value <= totalSupply, since that would imply the

        // sender's balance is greater than the totalSupply, which *should* be an assertion failure



        address burner = msg.sender;

        balances[burner] = balances[burner].sub(_value);

        totalSupply = totalSupply.sub(_value);

        Burn(burner, _value);

    }

}



contract DEVCoin is BurnableToken, Owned {



    string public constant name = "Dev Coin";



    string public constant symbol = "DEVC";



    uint32 public constant decimals = 18;



    function DEVCoin(uint256 initialSupply, uint unblockTime) public {

        totalSupply = initialSupply;

        balances[owner] = initialSupply;

        blockedUntil = unblockTime;

    }



    function manualTransfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) onlyOwner public returns (bool) {

        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;

    }

}