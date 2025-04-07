/**

 *Submitted for verification at Etherscan.io on 2019-05-05

*/



pragma solidity ^0.4.25;



/**

 * 

 * World War Goo - Competitive Idle Game

 * 

 * https://ethergoo.io

 * 

 */

 

 







contract ClothMaterial is ERC20 {

    using SafeMath for uint;



    string public constant name  = "Goo Material - Cloth";

    string public constant symbol = "CLOTH";

    uint8 public constant decimals = 0;



    uint256 public totalSupply;

    address owner; // Minor management



    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;

    mapping(address => bool) operator;



    constructor() public {

        owner = msg.sender;

    }



    function setOperator(address gameContract, bool isOperator) external {

        require(msg.sender == owner);

        operator[gameContract] = isOperator;

    }



    function totalSupply() external view returns (uint) {

        return totalSupply.sub(balances[address(0)]);

    }



    function balanceOf(address tokenOwner) external view returns (uint256) {

        return balances[tokenOwner];

    }



    function transfer(address to, uint tokens) external returns (bool) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;

    }



    function transferFrom(address from, address to, uint tokens) external returns (bool) {

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(from, to, tokens);

        return true;

    }



    function approve(address spender, uint tokens) external returns (bool) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;

    }



    function approveAndCall(address spender, uint tokens, bytes data) external returns (bool) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);

        return true;

    }



    function allowance(address tokenOwner, address spender) external view returns (uint256) {

        return allowed[tokenOwner][spender];

    }



    function recoverAccidentalTokens(address tokenAddress, uint tokens) external {

        require(msg.sender == owner);

        require(tokenAddress != address(this));

        ERC20(tokenAddress).transfer(owner, tokens);

    }



    function mintCloth(uint256 amount, address player) external {

        require(operator[msg.sender]);

        balances[player] += amount;

        totalSupply += amount;

        emit Transfer(address(0), player, amount);

    }



    function burn(uint256 amount, address player) public {

        require(operator[msg.sender]);

        balances[player] = balances[player].sub(amount);

        totalSupply = totalSupply.sub(amount);

        emit Transfer(player, address(0), amount);

    }

}



