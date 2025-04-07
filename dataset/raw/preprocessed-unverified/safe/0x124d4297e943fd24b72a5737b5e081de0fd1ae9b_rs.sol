pragma solidity 0.4.24;



/** Contact [emailÂ protected] or visit http://concepts.io for questions about this token contract */



/** 

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */



contract tokenCreator is Ownable{



    string internal _symbol;

    string internal _name;

    uint8 internal _decimals;

    uint internal _totalSupply = 500000000;

    mapping (address => uint256) internal _balanceOf;

    mapping (address => mapping (address => uint256)) internal _allowed;



    constructor(string symbol, string name, uint8 decimals, uint totalSupply) public {

        _symbol = symbol;

        _name = name;

        _decimals = decimals;

        _totalSupply = _calcTokens(decimals,totalSupply);

    }



   function _calcTokens(uint256 decimals, uint256 amount) internal pure returns (uint256){

      uint256 c = amount * 10**decimals;

      return c;

   }



    function name() public constant returns (string) {

        return _name;

    }



    function symbol() public constant returns (string) {

        return _symbol;

    }



    function decimals() public constant returns (uint8) {

        return _decimals;

    }



    function totalSupply() public constant returns (uint) {

        return _totalSupply;

    }



    function balanceOf(address _addr) public constant returns (uint);

    function transfer(address _to, uint _value) public returns (bool);

    event Transfer(address indexed _from, address indexed _to, uint _value);

}

contract supTokenMaker is tokenCreator("REPLY", "True Reply Research Token", 18, 500000000), ERC20 {

    using SafeMath for uint256;



    event TokenTransferRequest(string method,address from, address backer, uint amount);



    constructor() public {

        _balanceOf[msg.sender] = _totalSupply;

    }



    function totalSupply() public constant returns (uint) {

        return _totalSupply;

    }



    function balanceOf(address _addr) public constant returns (uint) {

        return _balanceOf[_addr];

    }



    function transfer(address _to, uint _value) public returns (bool) {

        emit TokenTransferRequest("transfer",msg.sender, _to, _value);

        require(_value > 0 && _value <= _balanceOf[msg.sender]);



        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);

        _balanceOf[_to] = _balanceOf[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;

    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {

        emit TokenTransferRequest("transferFrom",_from, _to, _value);

        require(_to != address(0) && _value <= _balanceOf[_from] && _value <= _allowed[_from][msg.sender] && _value > 0);



        _balanceOf[_from] =  _balanceOf[_from].sub(_value);

        _balanceOf[_to] = _balanceOf[_to].add(_value);

        _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_value);



        emit Transfer(_from, _to, _value);

        return true;

    }



    function approve(address _spender, uint _value) public returns (bool) {

        _allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function allowance(address _owner, address _spender) public constant returns (uint) {

        return _allowed[_owner][_spender];

    }

}