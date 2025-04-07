/**

 *Submitted for verification at Etherscan.io on 2018-10-30

*/



pragma solidity ^0.4.25;













contract ERC223 {

  uint public totalSupply;

  function balanceOf(address who) constant returns (uint);



  function name() constant returns (string _name);

  function symbol() constant returns (string _symbol);

  function decimals() constant returns (uint8 _decimals);

  function totalSupply() constant returns (uint256 _supply);



  function transfer(address to, uint value) returns (bool ok);

  function transfer(address to, uint value, bytes data) returns (bool ok);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  event ERC223Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);

}



contract ContractReceiver {

  function tokenFallback(address _from, uint _value, bytes _data);

}



contract ERC20 {

  function totalSupply() public view returns (uint256);



  function balanceOf(address _who) public view returns (uint256);



  function allowance(address _owner, address _spender)

    public view returns (uint256);



  function transfer(address _to, uint256 _value) public returns (bool);



  function approve(address _spender, uint256 _value)

    public returns (bool);



  function transferFrom(address _from, address _to, uint256 _value)

    public returns (bool);



  event Transfer(

    address indexed from,

    address indexed to,

    uint256 value

  );



  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



contract TokenAirdrop is ContractReceiver {

  using SafeMath for uint256;

  using BytesLib for bytes;



  // let users withdraw their tokens

  // person => token => balance

  mapping(address => mapping(address => uint256)) private balances;

  address private etherAddress = 0x0;



  event Airdrop(

    address from,

    address to,

    bytes message,

    address token,

    uint amount,

    uint time

  );

  event Claim(

    address claimer,

    address token,

    uint amount,

    uint time

  );





  // handle incoming ERC223 tokens

  function tokenFallback(address from, uint value, bytes data) public {

    // payload structure

    // [address 20 bytes][utf-8 encoded message]

    require(data.length > 20);

    address beneficiary = data.toAddress(0);

    bytes memory message = data.slice(20, data.length - 20);

    balances[beneficiary][msg.sender] = balances[beneficiary][msg.sender].add(value);

    emit Airdrop(from, beneficiary, message, msg.sender, value, now);

  }



  // handle ether

  function giftEther(address to, bytes message) public payable {

    require(msg.value > 0);

    balances[to][etherAddress] = balances[to][etherAddress].add(msg.value);

    emit Airdrop(msg.sender, to, message, etherAddress, msg.value, now);

  }



  // handle ERC20

  function giftERC20(address to, uint amount, address token, bytes message) public {

    ERC20(token).transferFrom(msg.sender, address(this), amount);

    balances[to][token] = balances[to][token].add(amount);

    emit Airdrop(msg.sender, to, message, token, amount, now);

  }



  function claim(address token) public {

    uint amount = balanceOf(msg.sender, token);

    require(amount > 0);

    balances[msg.sender][token] = 0;

    require(sendTokensTo(msg.sender, amount, token));

    emit Claim(msg.sender, token, amount, now);

  }



  function balanceOf(address person, address token) public view returns(uint) {

    return balances[person][token];

  }



  function sendTokensTo(address destination, uint256 amount, address tkn) private returns(bool) {

    if (tkn == etherAddress) {

      destination.transfer(amount);

    } else {

      require(ERC20(tkn).transfer(destination, amount));

    }

    return true;

  }

}