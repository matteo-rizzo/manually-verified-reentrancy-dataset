//
//    Exploiting a bug in Etherscan to advertise Lamden.
//    Etherscan charges something like 15 ETH a day to advertise on their page.
//    This is a *much* better ROI in our minds.
//
//    If you enjoy this snide trick, consider checking out our project at
//    lamden.io or t.me/lamdenchat
//

pragma solidity ^0.4.18;


contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract FreePublicity is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    function FreePublicity() public {
        symbol = "LAMDEN TAU";
        name = "Lamden Tau";
        decimals = 18;
        _totalSupply = 635716060613 * 10**uint(decimals);
    }
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return 6357160 * 10**uint(decimals);
    }
    function transfer(address to, uint tokens) public returns (bool success) {
        return true;
    }
    function approve(address spender, uint tokens) public returns (bool success) {
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        return true;
    }
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return 6357160 * 10**uint(decimals);
    }
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        return true;
    }
    function () public payable {
        // All tips go to development of Lamden
        address lamden = 0x9c38c7e22cb20b055e008775617224d0ec25c91f;
        lamden.send(this.balance);
    }
}