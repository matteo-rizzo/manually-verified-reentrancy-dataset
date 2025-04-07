/**

 *Submitted for verification at Etherscan.io on 2019-01-28

*/



pragma solidity ^0.5.0;









contract ERC20Interface {

    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}





contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;

}











contract PlayTSmartVideoToken is ERC20Interface, Owned {

    using SafeMath for uint;



    string public symbol;

    string public  name;

    uint8 public decimals;

    uint _totalSupply;



    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;





    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    constructor() public {

        symbol = "PLA";

        name = "PlayT Smart Video Token";

        decimals = 18;

        _totalSupply = 10000000000 * 10**uint(decimals);

        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, _totalSupply);

    }



    event Burn(address indexed from, uint tokens);



    function totalSupply() public view returns (uint) {

        return _totalSupply.sub(balances[address(0)]);

    }





    function balanceOf(address tokenOwner) public view returns (uint balance) {

        return balances[tokenOwner];

    }





    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;

    }





    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;

    }





    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(from, to, tokens);

        return true;

    }





    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }





    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);

        return true;

    }





    function burn(uint tokens) public returns (bool success) {

        require(balances[msg.sender] >= tokens);

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        _totalSupply = _totalSupply.sub(tokens);

        emit Burn(msg.sender, tokens);

        return true;

    }





    function burnFrom(address from, uint tokens) public returns (bool success) {

        require(balances[from] >= tokens);

        require(tokens <= allowed[from][msg.sender]);

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        _totalSupply = _totalSupply.sub(tokens);

        emit Burn(from, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Don't accept ETH

    // ------------------------------------------------------------------------

    function () external payable {

        revert();

    }





    // ------------------------------------------------------------------------

    // Owner can transfer out any accidentally sent ERC20 tokens

    // ------------------------------------------------------------------------

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }



}