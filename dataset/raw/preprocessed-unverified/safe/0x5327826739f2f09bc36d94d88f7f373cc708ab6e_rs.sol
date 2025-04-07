pragma solidity ^0.4.18;











contract Blin is Ownable {

     using SafeMath for uint256;

    string public  name = "Afonja";

    

    string public  symbol = "GROSH";

    

    uint32 public  decimals = 0;

    

    uint public totalSupply = 0;

    

    mapping (address => uint) balances;

    

  

	uint rate = 100000;

	

	function Blin()public {



	

	

	}

    

    function mint(address _to, uint _value) internal{

        assert(totalSupply + _value >= totalSupply && balances[_to] + _value >= balances[_to]);

        balances[_to] += _value;

        totalSupply += _value;

    }

    

    function balanceOf(address _owner) public constant returns (uint balance) {

        return balances[_owner];

    }



    function transfer(address _to, uint _value) public returns (bool success) {

        if(balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {

            balances[msg.sender] -= _value; 

            balances[_to] += _value;

            Transfer(msg.sender, _to, _value);

            return true;

        } 

        return false;

    }

    



 

    

    event Transfer(address indexed _from, address indexed _to, uint _value);

    



    

	

    function createTokens()  public payable {

     //  transfer(msg.sender,msg.value);

	   owner.transfer(msg.value);

       uint tokens = rate.mul(msg.value).div(1 ether);

        mint(msg.sender, tokens);

    }



    function() external payable {

        createTokens();

    }

	

}