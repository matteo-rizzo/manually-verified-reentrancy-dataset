/**

 *Submitted for verification at Etherscan.io on 2018-08-12

*/



pragma solidity 0.4.23;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */







contract PasswordEscrow {



  using SafeMath for uint256;



  address public owner;

  uint256 public commissionFee;

  uint256 public totalFee;



  uint256 private randSeed = 50;



  //data

  struct Transfer {

    address from;

    uint256 amount;

  }



  mapping(bytes32 => Transfer) private password;

  mapping(address => uint256) private randToAddress;



  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  event LogChangeCommissionFee(uint256 fee);

  event LogChangeOwner(address indexed exOwner, address indexed newOwner);

  event LogDeposit(address indexed from, uint256 amount);

  event LogGetTransfer(address indexed from, address indexed recipient, uint256 amount);





  constructor(uint256 _fee) public {

    commissionFee = _fee;

    owner = msg.sender;

  }



  function changeCommissionFee(uint256 _fee) public onlyOwner {

    commissionFee = _fee;

    emit LogChangeCommissionFee(_fee);

  }



  function changeOwner(address _newOwner) public onlyOwner {

    emit LogChangeOwner(owner, _newOwner);

    owner = _newOwner;

  }



  //escrow

  function deposit(bytes32 _password) public payable {

    require(msg.value > commissionFee);



    uint256 rand = _rand();

    bytes32 pass = sha3(_password, rand);

    randToAddress[msg.sender] = rand;

    password[pass].from = msg.sender;

    password[pass].amount = password[pass].amount.add(msg.value);



    _updateSeed();



    emit LogDeposit(msg.sender, msg.value);

  }



  function _rand() private view returns(uint256) {

    uint256 rand = uint256(sha3(now, block.number, randSeed));

    return rand %= (10 ** 6);

  }



  function _updateSeed() private {

    randSeed = _rand();

  }



  function viewRand() public view returns(uint256) {

    return randToAddress[msg.sender];

  }



  function getTransfer(bytes32 _password, uint256 _number) public {

    require(password[sha3(_password, _number)].amount > 0);



    bytes32 pass = sha3(_password, _number);

    address from = password[pass].from;

    uint256 amount = password[pass].amount;

    amount = amount.sub(commissionFee);

    totalFee = totalFee.add(commissionFee);



    _updateSeed();



    password[pass].amount = 0;



    msg.sender.transfer(amount);



    emit LogGetTransfer(from, msg.sender, amount);

  }



  function withdrawFee() public payable onlyOwner {

    require( totalFee > 0);



    uint256 fee = totalFee;

    totalFee = 0;



    owner.transfer(fee);

  }



  function withdraw() public payable onlyOwner {

    owner.transfer(this.balance);

  }





}