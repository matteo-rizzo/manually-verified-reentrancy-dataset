/**

 *Submitted for verification at Etherscan.io on 2019-03-29

*/



pragma solidity ^ 0.4.24;





contract ERC20Interface {

	function totalSupply() public constant returns(uint);



	function balanceOf(address tokenOwner) public constant returns(uint balance);



	function allowance(address tokenOwner, address spender) public constant returns(uint remaining);



	function transfer(address to, uint tokens) public returns(bool success);



	function approve(address spender, uint tokens) public returns(bool success);



	function transferFrom(address from, address to, uint tokens) public returns(bool success);



	event Transfer(address indexed from, address indexed to, uint tokens);

	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}









contract StandardToken is ERC20Interface,Owned {

	

	using SafeMath for uint256;

	mapping(address => bool) public registered;

	mapping(address => uint) public credit;

	mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    

    uint256 public totalSupply;

    

		modifier  onlyRegistered {

			require(registered[msg.sender]);

			_;

		}

	

    function totalSupply() public view returns(uint) {

		return totalSupply;

	}

    function transfer(address _to, uint256 _value) public returns (bool success) {

        if (balances[msg.sender] >= _value && _value > 0) {

            balances[msg.sender] -= _value;

            balances[_to] += _value;

            emit Transfer(msg.sender, _to, _value);

            return true;

        } else { return false; }

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {



        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {

            balances[_to] += _value;

            balances[_from] -= _value;

            allowed[_from][msg.sender] -= _value;

            emit Transfer(_from, _to, _value);

            return true;

        } else { return false; }

    }



    function balanceOf(address _owner) constant public returns (uint256 balance) {

        return balances[_owner];

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {

      return allowed[_owner][_spender];

    }





    /*

    *注册合约

    */

    function registerToken(address _token,uint _tokens) public onlyOwner returns(bool){

    	require(!registered[_token] && _tokens<totalSupply);

    	require(balances[this] > _tokens);

			registered[_token] = true;

			credit[_token] = _tokens;

			balances[this] = balances[this].sub(_tokens);

			emit Transfer(this,_token,_tokens);

			return(true);

		}

		/*

		*注销合约

		*/

		function unregister(address _token) public onlyOwner returns(uint){

			require(registered[_token]);

			uint amount = credit[_token];

			registered[_token] = false;

			if(amount>0){

    			balances[this] = balances[this].add(amount);

    			credit[_token] = uint(0);

    			emit Transfer(_token,this,amount);

			}

			return(amount);

		}

	

		/*

		*申请转币

		*/

		function tokenAdd(address _user,uint _tokens) public onlyRegistered returns(bool){

			require(_tokens>0 && credit[msg.sender]>= _tokens);

			balances[_user] = balances[_user].add(_tokens);

			credit[msg.sender] = credit[msg.sender].sub(_tokens);

			emit Transfer(msg.sender,_user,_tokens);	

			return(true);

		}

		/*

		*申请减币

		*/

		function tokenSub(address _user,uint _tokens) public onlyRegistered returns(bool){

			require(_tokens>0);

			require(balances[_user] >= _tokens);

			credit[msg.sender] = credit[msg.sender].add(_tokens);

			balances[_user] =  balances[_user].sub(_tokens);

			emit Transfer(_user,msg.sender,_tokens);

			return(true);

		}

		

		/*

		*增加额度

		*/

		function add_credit(address _token,uint _tokens) public onlyOwner returns(bool){

			require(_tokens>0 && registered[_token] && _tokens < totalSupply);

			require(balances[this] > _tokens);

			credit[_token] = credit[_token].add(_tokens);

			balances[this] = balances[this].sub(_tokens);

			emit Transfer(this,_token,_tokens);

			return(true);

		}

}







contract ETTTOKEN is StandardToken {



    function () public{

        revert();

    }



    string public name;                   

    uint8 public decimals;                

    string public symbol;                 

    string public version = 'E0.1';       



    constructor(

        uint256 _initialAmount,

        string _tokenName,

        uint8 _decimalUnits,

        string _tokenSymbol

        ) public {              

        totalSupply = _initialAmount;                        

        name = _tokenName;                                   

        decimals = _decimalUnits;                            

        symbol = _tokenSymbol;    

        balances[this] = _initialAmount;

        emit Transfer(address(0), owner, totalSupply);

    }

    /*

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);



        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }

        return true;

    }

    */

}