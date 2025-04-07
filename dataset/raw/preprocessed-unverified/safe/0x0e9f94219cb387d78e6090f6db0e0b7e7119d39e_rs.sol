/**

 *Submitted for verification at Etherscan.io on 2018-11-20

*/



pragma solidity ^0.4.24;



//import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

//import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";











contract DdexAngelToken is IERC20 {

    using SafeMath for uint256;



    string public name = "DDEX Angel Token";

    string public symbol = "DDEXANGEL";

    uint public decimals = 0;

    uint public INITIAL_SUPPLY = 9999;

    address public admin;

    bool public transferEnabled = false;



    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;



    modifier canTransfer() {

        require(transferEnabled || msg.sender == admin);

        _;

    }



    modifier onlyAdmin() {

        require(msg.sender == admin);

        _;

    }



    function enableTransfer() public onlyAdmin {

        transferEnabled = true;

    }



    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;

    }



    function balanceOf(address owner) public view returns (uint256) {

        return _balances[owner];

    }



    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowed[owner][spender];

    }



    function approve(address spender, uint256 value) public returns (bool) {

        require(spender != address(0));



        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;

    }



    function transfer(address to, uint256 value) public canTransfer returns (bool) {

        _transfer(msg.sender, to, value);

        return true;

    }



    function transferFrom(address from, address to, uint256 value) public canTransfer returns (bool) {

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        _transfer(from, to, value);

        return true;

    }



    function _transfer(address from, address to, uint256 value) internal {

        require(to != address(0));



        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);

    }



    constructor() public {

        admin = msg.sender;



        _totalSupply = INITIAL_SUPPLY;

        _balances[msg.sender] = INITIAL_SUPPLY;

        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);

    }

}