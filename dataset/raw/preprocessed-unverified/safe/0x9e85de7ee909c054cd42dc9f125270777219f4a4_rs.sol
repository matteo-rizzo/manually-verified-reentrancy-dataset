/**

 *Submitted for verification at Etherscan.io on 2019-03-19

*/



pragma solidity ^0.5.0;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */













contract BaseToken is IERC20, Ownable

{

    using SafeMath for uint256;



    mapping (address => uint256) public balances;

    mapping (address => mapping ( address => uint256 )) public approvals;



    uint256 public totalTokenSupply;



    function totalSupply() view external returns (uint256)

    {

        return totalTokenSupply;

    }



    function balanceOf(address _who) view external returns (uint256)

    {

        return balances[_who];

    }



    function transfer(address _to, uint256 _value) external onlyWhenNotStopped returns (bool)

    {

        require(balances[msg.sender] >= _value);

        require(_to != address(0));



        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);



        emit Transfer(msg.sender, _to, _value);



        return true;

    }



    function approve(address _spender, uint256 _value) external onlyWhenNotStopped returns (bool)

    {

        require(balances[msg.sender] >= _value);



        approvals[msg.sender][_spender] = _value;



        emit Approval(msg.sender, _spender, _value);



        return true;

    }



    function allowance(address _owner, address _spender) view external returns (uint256)

    {

        return approvals[_owner][_spender];

    }



    function transferFrom(address _from, address _to, uint256 _value) external onlyWhenNotStopped returns (bool)

    {

        require(_from != address(0));

        require(balances[_from] >= _value);

        require(approvals[_from][msg.sender] >= _value);



        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value);

        balances[_from] = balances[_from].sub(_value);

        balances[_to]  = balances[_to].add(_value);



        emit Transfer(_from, _to, _value);



        return true;

    }

}



contract CreetToken is BaseToken

{

    using SafeMath for uint256;



    string public name;

    uint256 public decimals;

    string public symbol;



    uint256 constant private E18 = 1000000000000000000;

    uint256 constant private MAX_TOKEN_SUPPLY = 5000000000;



    event Deposit(address indexed from, address to, uint256 value);

    event ReferralDrop(address indexed from, address indexed to1, uint256 value1, address indexed to2, uint256 value2);



    constructor() public

    {

        name        = 'Creet';

        decimals    = 18;

        symbol      = 'CREET';



        totalTokenSupply = MAX_TOKEN_SUPPLY * E18;



        balances[msg.sender] = totalTokenSupply;

    }



    function deposit(address _to, uint256 _value) external returns (bool)

    {

        require(balances[msg.sender] >= _value);

        require(_to != address(0));



        balances[msg.sender] = balances[msg.sender].sub(_value);

        balances[_to] = balances[_to].add(_value);



        emit Deposit(msg.sender, _to, _value);



        return true;

    }



    function referralDrop2(address _to, uint256 _value, address _sale, uint256 _fee) external onlyWhenNotStopped returns (bool)

    {

        require(balances[msg.sender] >= _value + _fee);

        require(_to != address(0));

        require(_sale != address(0));



        balances[msg.sender] = balances[msg.sender].sub(_value + _fee);

        balances[_to] = balances[_to].add(_value);

        balances[_sale] = balances[_sale].add(_fee);



        emit ReferralDrop(msg.sender, _to, _value, address(0), 0);



        return true;

    }



    function referralDrop3(address _to1, uint256 _value1, address _to2, uint256 _value2, address _sale, uint256 _fee) external onlyWhenNotStopped returns (bool)

    {

        require(balances[msg.sender] >= _value1 + _value2 + _fee);

        require(_to1 != address(0));

        require(_to2 != address(0));

        require(_sale != address(0));



        balances[msg.sender] = balances[msg.sender].sub(_value1 + _value2 + _fee);

        balances[_to1] = balances[_to1].add(_value1);

        balances[_to2] = balances[_to2].add(_value2);

        balances[_sale] = balances[_sale].add(_fee);



        emit ReferralDrop(msg.sender, _to1, _value1, _to2, _value2);



        return true;

    }

}