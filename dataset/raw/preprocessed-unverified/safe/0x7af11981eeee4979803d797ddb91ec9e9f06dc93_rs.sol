/**

 *Submitted for verification at Etherscan.io on 2019-04-19

*/



pragma solidity 0.5.7;



contract InternetCoin {

    using SafeMath for uint256;



    string constant public name = "Internet Coin" ;                               

    string constant public symbol = "ITN";           

    uint8 constant public decimals = 18;            



    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;



    uint256 public constant totalSupply = 200*10**24; //200 million with 18 decimals



    address public owner  = address(0x000000000000000000000000000000000000dEaD);



    modifier validAddress {

        assert(address(0x000000000000000000000000000000000000dEaD) != msg.sender);

        assert(address(0x0) != msg.sender);

        assert(address(this) != msg.sender);

        _;

    }



    constructor (address _addressFounder) validAddress public {

        require(owner == address(0x000000000000000000000000000000000000dEaD), "Owner cannot be re-assigned");

        owner = _addressFounder;

        balanceOf[_addressFounder] = totalSupply;

        emit Transfer(0x000000000000000000000000000000000000dEaD, _addressFounder, totalSupply);

    }



    function transfer(address _to, uint256 _value) validAddress public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);

        require(balanceOf[_to].add(_value) >= balanceOf[_to]);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);

        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) validAddress public returns (bool success) {

        require(balanceOf[_from] >= _value);

        require(balanceOf[_to].add(_value)>= balanceOf[_to]);

        require(allowance[_from][msg.sender] >= _value);

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        balanceOf[_from] = balanceOf[_from].sub(_value);

        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(_from, _to, _value);

        return true;

    }



    function approve(address _spender, uint256 _value) validAddress public returns (bool success) {

        require(_value == 0 || allowance[msg.sender][_spender] == 0);

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error.

 */

