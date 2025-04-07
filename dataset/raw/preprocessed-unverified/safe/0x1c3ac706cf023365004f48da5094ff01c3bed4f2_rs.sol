/**

 *Submitted for verification at Etherscan.io on 2019-06-28

*/



pragma solidity ^0.5.0;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */





/**

 * @title ERC20 interface

 * @dev see https://eips.ethereum.org/EIPS/eip-20

 */





contract Nutopia is IERC20 {



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    using SafeMath for uint256;



    mapping (address => uint256) private _balance;



    mapping (address => mapping (address => uint256)) private _allowed;



    uint256 private _totalSupply = 10_000_000_000E18;



    string private _name = "Nutopia Coin";

    string private _symbol = "NUCO";

    uint8 private _decimals = 18;



    address public owner;



    bool public frozen;



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    modifier checkFrozen {

        assert(!frozen);

        _;

    }



    constructor() public {

        owner = msg.sender;

        frozen = false;



        // Initial balance

        _balance[owner] = _totalSupply;

    }



    function name() public view returns (string memory) {

        return _name;

    }



    function symbol() public view returns (string memory) {

        return _symbol;

    }



    function decimals() public view returns (uint8) {

        return _decimals;

    }



    function approve(address _spender, uint256 _value) checkFrozen public returns (bool) {

        require(_spender != address(0));



        _allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function transfer(address _to, uint256 _value) checkFrozen public returns (bool) {

        _transfer(msg.sender, _to, _value);

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) checkFrozen public returns (bool) {

        _transfer(_from, _to, _value);

        _allowed[_from][_to] = _allowed[_from][_to].sub(_value);

        return true;

    }



    function _transfer(address from, address to, uint256 value) internal {

        require(value <= balanceOf(from));

        require(to != address(0));



        _balance[from] = _balance[from].sub(value);

        _balance[to] = _balance[to].add(value);

        emit Transfer(from, to, value);

    }



    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    function allowance(address _owner, address _spender) public view returns (uint256) {

        return _allowed[_owner][_spender];

    }



    function balanceOf(address _owner) public view returns (uint256) {

        return _balance[_owner];

    }



    // Contract owner transfer

    function ownerTransfer(address newOwner) public onlyOwner {

        require(newOwner != address(0));

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

    }



    function freeze() public onlyOwner {

        frozen = true;

    }



    function unfreeze() public onlyOwner {

        frozen = false;

    }

}