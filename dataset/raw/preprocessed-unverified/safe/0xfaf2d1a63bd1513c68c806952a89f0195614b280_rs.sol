pragma solidity ^0.4.24;







contract Tokenlock is Ownable {

    using SafeERC20 for ERC20;



    event LockStarted(uint256 now, uint256 interval);

    event TokenLocked(address indexed buyer, uint256 amount);

    event TokenReleased(address indexed buyer, uint256 amount);



    mapping (address => uint256) public buyers;



    address public locker;

    address public distributor;



    ERC20 public Token;



    bool public started = false;



    uint256 public interval;

    uint256 public releaseTime;



    constructor(address token, uint256 time) public {

        require(token != address(0));

        Token = ERC20(token);

        interval = time;



        locker = owner;

        distributor = owner;

    }



    function setLocker(address addr)

        external

        onlyOwner

    {

        require(addr != address(0));

        locker = addr;

    }



    function setDistributor(address addr)

        external

        onlyOwner

    {

        require(addr != address(0));

        distributor = addr;

    }



    // lock tokens

    function lock(address beneficiary, uint256 amount)

        external

    {

        require(msg.sender == locker);

        require(beneficiary != address(0));

        buyers[beneficiary] += amount;

        emit TokenLocked(beneficiary, buyers[beneficiary]);

    }



    // start timer

    function start()

        external

        onlyOwner

    {

        require(!started);

        started = true;

        releaseTime = block.timestamp + interval;

        emit LockStarted(block.timestamp, interval);

    }



    // release locked tokens

    function release(address beneficiary)

        external

    {

        require(msg.sender == distributor);

        require(started);

        require(block.timestamp >= releaseTime);



        // prevent reentrancy

        uint256 amount = buyers[beneficiary];

        buyers[beneficiary] = 0;



        Token.safeTransfer(beneficiary, amount);

        emit TokenReleased(beneficiary, amount);

    }



    function withdraw() public onlyOwner {

        require(block.timestamp >= releaseTime);

        Token.safeTransfer(owner, Token.balanceOf(address(this)));

    }



    function close() external onlyOwner {

        withdraw();

        selfdestruct(owner);

    }

}



contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



