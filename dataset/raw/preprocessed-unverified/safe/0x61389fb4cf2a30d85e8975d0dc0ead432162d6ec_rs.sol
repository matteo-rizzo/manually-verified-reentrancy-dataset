pragma solidity ^0.4.24;

// Developed by Phenom.Team <[emailÂ protected]>



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */





contract ERC20 {

    uint public totalSupply;



    mapping(address => uint) balances;

    mapping(address => mapping (address => uint)) allowed;



    function balanceOf(address _owner) view returns (uint);

    function transfer(address _to, uint _value) returns (bool);

    function transferFrom(address _from, address _to, uint _value) returns (bool);

    function approve(address _spender, uint _value) returns (bool);

    function allowance(address _owner, address _spender) view returns (uint);



    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);



}







contract BaseTokenVesting is Ownable() {

    using SafeMath for uint;



    address public beneficiary;

    ERC20 public token;



    bool public vestingHasStarted;

    uint public start;

    uint public cliff;

    uint public vestingPeriod;



    uint public released;



    event Released(uint _amount);



    constructor(

		address _benificiary,

		uint _cliff,

		uint _vestingPeriod,

		address _token

	) internal 

	{

        require(_benificiary != address(0), 'can not send to zero-address');



        beneficiary = _benificiary;

        cliff = _cliff;

        vestingPeriod = _vestingPeriod;

        token = ERC20(_token);

    }



    function startVesting() public onlyOwner {

        vestingHasStarted = true;

        start = now;

        cliff = cliff.add(start);

    }



    function sendTokens(address _to, uint _amount) public onlyOwner {

        require(vestingHasStarted == false, 'send tokens only if vesting has not been started');

        require(token.transfer(_to, _amount), 'token.transfer has failed');

    }



    function release() public;



    function releasableAmount() public view returns (uint _amount);



    function vestedAmount() public view returns (uint _amount);

}



contract TokenVestingWithConstantPercent is BaseTokenVesting {



    uint public periodPercent;



    constructor(

        address _benificiary,

        uint _cliff,

        uint _vestingPeriod,

        address _tokenAddress,

        uint _periodPercent

    ) 

        BaseTokenVesting(_benificiary, _cliff, _vestingPeriod, _tokenAddress)

        public 

    {

        periodPercent = _periodPercent;

    }



    function release() public {

        require(vestingHasStarted, 'vesting has not started');

        uint unreleased = releasableAmount();



        require(unreleased > 0, 'released amount has to be greter than zero');

        require(token.transfer(beneficiary, unreleased), 'revert on transfer failure');

        released = released.add(unreleased);

        emit Released(unreleased);

    }





    function releasableAmount() public view returns (uint _amount) {

        _amount = vestedAmount().sub(released);

    }



    function vestedAmount() public view returns (uint _amount) {

        uint currentBalance = token.balanceOf(this);

        uint totalBalance = currentBalance.add(released);



        if (now < cliff || !vestingHasStarted) {

            _amount = 0;

        }

        else if (now.sub(cliff).div(vestingPeriod).mul(periodPercent) > 100) {

            _amount = totalBalance;

        }

        else {

            _amount = totalBalance.mul(now.sub(cliff).div(vestingPeriod).mul(periodPercent)).div(100);

        }

    }



    



}