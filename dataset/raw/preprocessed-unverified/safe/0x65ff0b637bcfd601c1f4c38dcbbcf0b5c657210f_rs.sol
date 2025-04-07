/**

 *Submitted for verification at Etherscan.io on 2018-10-18

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */





contract StandardToken is IERC20 {

    using SafeMath for uint256;



    mapping(address => uint256) balances;



    mapping (address => mapping (address => uint256)) internal allowed;



    uint256 totalSupply_;



    /**

    * @dev Total number of tokens in existence

    */

    function totalSupply() public view returns (uint256) {

        return totalSupply_;

    }



    function balanceOf(address _owner) public view returns (uint256) {

        return balances[_owner];

    }



    function allowance(

        address _owner,

        address _spender

    )

        public

        view

        returns (uint256)

    {

        return allowed[_owner][_spender];

    }



    function transfer(address _to, uint256 _value) public returns (bool) {

        require(_value <= balances[msg.sender]);

        require(_to != address(0));



        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;

    }



    function approve(address _spender, uint256 _value) public returns (bool) {

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function transferFrom(

        address _from,

        address _to,

        uint256 _value

    )

        public

        returns (bool)

    {

        require(_value <= balances[_from]);

        require(_value <= allowed[_from][msg.sender]);

        require(_to != address(0));



        balances[_from] = balances[_from].sub(_value);

        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */



contract OleCoin is StandardToken, Ownable {



    event tokenComprado(address comprador);

    

    

    string public constant name = "OleCoin";

    string public constant symbol = "OLE";

    uint8 public constant decimals = 18;

    

    uint256 public constant INITIAL_SUPPLY = 150000000 * (10 ** uint256(decimals));

    

    event tokenBought(address adr);

    

    uint256 tokenPrice;    



    constructor() public payable{

        totalSupply_ = INITIAL_SUPPLY;

        balances[msg.sender] = INITIAL_SUPPLY;

        emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);

        tokenPrice = 100000000000000 wei;

    }

    

    function() public payable {

        emit tokenComprado(msg.sender);

    }



    function getBalance() public view returns(uint256) {

        return address(this).balance;

    }



    function setPrice(uint256 _priceToken) public onlyOwner {

        tokenPrice = _priceToken;

    }

    function saque() public onlyOwner {

        address(owner).transfer(getBalance());

    }

        

    function comprarTokens(uint256 qtd) public payable {

        require(qtd > 0);

        //require(msg.value > 0);

        require(msg.value == (qtd * tokenPrice));

        qtd = qtd * (10 ** uint256(decimals));

        balances[owner] = balances[owner].sub(qtd);

        balances[msg.sender] = balances[msg.sender].add(qtd);

        address(this).transfer(msg.value);

        emit Transfer(owner, msg.sender, qtd);

    }

    

}