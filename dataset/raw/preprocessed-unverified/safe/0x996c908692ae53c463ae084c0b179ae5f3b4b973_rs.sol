/**
 *Submitted for verification at Etherscan.io on 2019-09-21
*/

pragma solidity ^0.5.0;





contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address _from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);


}






contract Peppergold is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    event CreateTokens(uint tokens);
    event BurnTokens(uint tokens);


    constructor() public {
        symbol = "PPG";
        name = "Pepper Gold";
        decimals = 18;
        _totalSupply = 250000000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }



    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }
    
 
    function createTokens(uint tokens) public onlyOwner returns (bool success) {

        balances[owner] = balances[owner].add(tokens);
        _totalSupply = _totalSupply.add(tokens);

        emit CreateTokens(tokens);
        return true;
    }

    function burnTokens(uint tokens) public onlyOwner returns (bool success) {
        require(balances[owner] >= tokens);

        balances[owner] = balances[owner].sub(tokens);
        _totalSupply = _totalSupply.sub(tokens);

        emit BurnTokens(tokens);
        return true;
    }

    

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }



    function transfer(address to, uint tokens) public returns (bool success) {
        require(balances[msg.sender] >= tokens);
        
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


   
    function transferFrom(address _from, address to, uint tokens) public returns (bool success) {
        require(tokens <= balances[_from]);
        require(tokens <= allowed[_from][msg.sender]);
        
        balances[_from] = balances[_from].sub(tokens);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(_from, to, tokens);
        return true;
    }



    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    
    function transferByOwner(address _from, address to, uint tokens) public returns (bool success){
        require(tokens <= balances[_from]);
        
        balances[_from] = balances[_from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        
        emit Transfer(_from, to, tokens);
        
        return true;
    }


    function () external payable {
        revert();
    }



    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}