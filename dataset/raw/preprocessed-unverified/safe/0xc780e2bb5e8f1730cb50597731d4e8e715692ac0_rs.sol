/**

 *Submitted for verification at Etherscan.io on 2019-05-30

*/



pragma solidity ^0.4.24;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error.

 */





contract ERC20Interface {



    // Getters

    function totalSupply() public view returns (uint);



    function balanceOf(address tokenOwner) public view returns (uint balance);



    function allowance(address tokenOwner, address spender) public view returns (uint remaining);



    // Write the State

    function transfer(address to, uint tokens) public returns (bool success);



    function approve(address spender, uint tokens) public returns (bool success);



    function transferFrom(address from, address to, uint tokens) public returns (bool success);



    // Events

    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);



}



contract ERC20 is ERC20Interface {



    // Link the SafeMath library

    using SafeMath for uint;



    // declare the storage

    mapping(address => mapping(address => uint)) private _allowance;

    mapping(address => uint) internal _balanceOf;



    uint internal _totalSupply;



    uint8 public constant decimals = 18;



    function _transfer(address from, address to, uint tokens) private returns (bool success) {

        _balanceOf[from] = _balanceOf[from].sub(tokens);

        _balanceOf[to] = _balanceOf[to].add(tokens);



        success = true;



        emit Transfer(from, to, tokens);

    }



    // Getters

    function totalSupply() public view returns (uint) {

        return _totalSupply;

    }



    function balanceOf(address tokenOwner) public view returns (uint balance) {

        balance = _balanceOf[tokenOwner];

    }



    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {

        remaining = _allowance[tokenOwner][spender];

        return remaining;

    }



    // Write the State

    function transfer(address to, uint tokens) public returns (bool success) {

        success = _transfer(msg.sender, to, tokens);

    }



    function approve(address spender, uint tokens) public returns (bool success) {

        _allowance[msg.sender][spender] = tokens;



        success = true;



        emit Approval(msg.sender, spender, tokens);

    }



    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        _allowance[from][msg.sender] = _allowance[from][msg.sender].sub(tokens);



        success = _transfer(from, to, tokens);

    }



}



contract Ownerable {

    address public owner;



    constructor () public {

        owner = msg.sender;

    }



    function setOwner(address newOwner) onlyOwner public {

        owner = newOwner;

    }



    modifier onlyOwner {

        require(msg.sender == owner, "Only owner can perform this tx.");

        _;

    }

}



contract CryptoDa is ERC20, Ownerable {

    string public constant name = "CryptoDa";

    string public constant symbol = "CDA";



    address public issuer = address(0);



    constructor (address _issuer) public {

        _totalSupply = 5000000 ether;

        issuer = _issuer;

        _balanceOf[issuer] = _totalSupply;

    }



    function setIssuer(address newIssuer) public onlyOwner returns (bool success){

        require(newIssuer != address(0), "Cannot set 0x0 as a new issuer address.");



        if (issuer != address(0)) {

            _balanceOf[newIssuer] = _balanceOf[issuer];

            _balanceOf[issuer] = 0;

        }



        issuer = newIssuer;



        success = true;

    }

}