/**

 *Submitted for verification at Etherscan.io on 2019-03-03

*/



pragma solidity ^0.5.4;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */













contract WOMG is ERC20Interface {

    using SafeMath for uint256;



    string public name     = "Wrapped OMG";

    string public symbol   = "WOMG";

    uint8  public decimals = 18;



    event  Deposit(address indexed _tokenHolder, uint256 _amount);

    event  Withdrawal(address indexed _tokenHolder, uint _amount);



    mapping (address => uint256)                       public  balanceOf;

    mapping (address => mapping (address => uint256))  public  allowance;



    OMGInterface public omg;



    constructor (address _omg) public {

        omg = OMGInterface(_omg);

    }



    function deposit(uint256 _amount) public {

        omg.transferFrom(msg.sender, address(this), _amount);

        balanceOf[msg.sender] = balanceOf[msg.sender].add(_amount);

        emit Deposit(msg.sender, _amount);

    }



    function withdraw(uint256 _amount) public {

        require(balanceOf[msg.sender] >= _amount);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);

        omg.transfer(msg.sender, _amount);

        emit Withdrawal(msg.sender, _amount);

    }



    function totalSupply() public view returns (uint256) {

        return omg.balanceOf(address(this));

    }



    function approve(address _spender, uint256 _amount) public returns (bool) {

        allowance[msg.sender][_spender] = _amount;

        emit Approval(msg.sender, _spender, _amount);

        return true;

    }



    function transfer(address _to, uint256 _amount) public returns (bool) {

        return transferFrom(msg.sender, _to, _amount);

    }



    function transferFrom(address _from, address _to, uint256 _amount)

        public

        returns (bool)

    {

        require(balanceOf[_from] >= _amount);



        if (_from != msg.sender && allowance[_from][msg.sender] != uint(-1)) {

            require(allowance[_from][msg.sender] >= _amount);

            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_amount);

        }



        balanceOf[_from] = balanceOf[_from].sub(_amount);

        balanceOf[_to] = balanceOf[_to].add(_amount);



        emit Transfer(_from, _to, _amount);



        return true;

    }

}