/**

 *Submitted for verification at Etherscan.io on 2019-02-14

*/



pragma solidity ^0.4.25;



contract ERC20Interface{



    function totalSupply() public view returns (uint);

    function balanceOf(address who) public view returns (uint);

    function transfer(address to, uint value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);



}



contract ERC20 is ERC20Interface{



    function allowance(address owner, address spender) public view returns (uint);

    function transferFrom(address from, address to, uint value) public returns (bool);

    function approve (address spender, uint value) public returns (bool);

    event Approval (address indexed owner, address indexed spender, uint value);



}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */





//해당 컨트랙트는 인터페이스에서 선언한 함수들의 기능을 구현해준다.

contract BasicToken is ERC20Interface{

    using SafeMath for uint256;

    //using A for B : B 자료형에 A 라이브러리 함수를 붙여라.

    //dot(.)으로 호출 할수 있게됨.

    //ex) using SafeMath for uint256 이면 uint256자료형에 SafeMath 라이브러리 함수를 .을 이용해 사용가능하다는 뜻 => a.add(1) ,b.sub(2)를 사용가능하게 함.



    mapping (address => uint256) balances;





    uint totalSupply_;



// 토큰의 총 발행량을 구하는 함수.

  function totalSupply() public view returns (uint){

    return totalSupply_;

  }



  function transfer(address _to, uint _value) public returns (bool){

    require (_to != address(0));

    // address(0)은 값이 없다는 것.

    // require란 참이면 실행하는 것.

    require (_value <= balances[msg.sender]);

    // 함수를 호출한 '나'의 토큰 잔고가 보내는 토큰의 개수보다 크거나 같을때 실행.



    balances[msg.sender] = balances[msg.sender].sub(_value);

    //sub는 뺄셈. , 보낸 토큰개수만큼 뺀다.

    balances[_to] = balances[_to].add(_value);

    //add는 덧셈. , 받은 토큰개수 만큼 더한다.



    emit Transfer(msg.sender,_to,_value);

    // Transfer라는 이벤트를 실행하여 이더리움 블록체인상에 거래내역을 기록한다. 물론, 등록됬으므로 검색 가능.

    return true; //모든것이 실행되면 참을 출력.



  }



  function balanceOf(address _owner) public view returns(uint balance){

    return balances[_owner];

  }



}



contract StandardToken is ERC20, BasicToken{

  //ERC20에 선언된 인터페이스를 구현하는 컨트랙트.



  mapping (address => mapping (address => uint)) internal allowed;

  // allowed 매핑은 '누가','누구에게','얼마의' 인출권한을 줄지를 저장하는 것. ex) allowed[누가][누구에게] = 얼마;



  function transferFrom(address _from, address _to, uint _value) public returns (bool){

    require(_to != address(0));

    require(_value <= balances[_from]);

    require(_value <= allowed[_from][msg.sender]);

    //보내려는 토큰개수가 계좌주인 _from이 돈을 빼려는 msg.sender에게 허용한 개수보다 작거나 같으면 참.

    //_fromr에게 인출권한을 받은 msg.sender가 가스비를 소모함.



    balances[_from] = balances[_from].sub(_value);

    balances[_to] = balances[_to].add(_value);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from,_to,_value);

    return true;



  }



  function approve(address _spender, uint _value) public returns (bool){

    allowed[msg.sender][_spender] = _value;

    //msg.sender의 계좌에서 _value 만큼 인출해 갈 수 있는 권리를 _spender 에게 부여한다.

    emit Approval(msg.sender,_spender,_value);

    return true;

  }



  function allowance(address _owner, address _spender) public view returns (uint){

    return allowed[_owner][_spender];

  }



}



contract VIMToken is StandardToken{



  string public constant name = "VIM Token";

  string public constant symbol = "VIM";

  uint8 public constant decimals = 18;



  uint256 public constant INITIAL_SUPPLY = 4000000000 * (10**uint256(decimals));



  constructor() public{

    totalSupply_ = INITIAL_SUPPLY;

    balances[msg.sender] = INITIAL_SUPPLY;

    emit Transfer(0x0,msg.sender,INITIAL_SUPPLY);

  }

}