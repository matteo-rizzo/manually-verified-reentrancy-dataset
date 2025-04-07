pragma solidity ^0.4.18;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





contract Permian {

    using SafeMath for uint256;



    string public name;

    string public symbol;

    uint8 public decimals = 2;

    uint256 public totalSupply;



    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);



    function Permian() public {

        totalSupply = 1000000000 * 10 ** uint256(decimals);

        balanceOf[msg.sender] = totalSupply;

        name = "Permian";

        symbol = "PMN";

    }



    function _transfer(address _from, address _to, uint _value) internal {

        require(_to != 0x0);

        require(balanceOf[_from] >= _value);

        balanceOf[_from] = balanceOf[_from].sub(_value);

        balanceOf[_to] = balanceOf[_to].add(_value);

        Transfer(_from, _to, _value);

    }



    function transfer(address _to, uint256 _value) public {

        _transfer(msg.sender, _to, _value);

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);   

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        _transfer(_from, _to, _value);

        return true;

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        return true;

    }



    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);   

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);            

        totalSupply = totalSupply.sub(_value);                      

        Burn(msg.sender, _value);

        return true;

    }



    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        require(balanceOf[_from] >= _value);                

        require(_value <= allowance[_from][msg.sender]);    

        balanceOf[_from] = balanceOf[_from].sub(_value);                         

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);             

        totalSupply = totalSupply.sub(_value);                              

        Burn(_from, _value);

        return true;

    }

}