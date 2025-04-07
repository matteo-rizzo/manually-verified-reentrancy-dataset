/**

 *Submitted for verification at Etherscan.io on 2018-12-21

*/



pragma solidity ^0.5.2;



// Kotlo Mordo is a great open source alcoholic board game (yes, a physical board game, 

// not everything has to be online :) This token belongs to players, who are earning it by

// participating on the development of the game. For this token they can buy some cool additional

// stuff as a reward for their great job. Thanks to them, this game can grow itself. 

// more information about this game -> kotlomordo.sk or info[at]kotlomordo.sk

//

// This is not any pump and dump ICO, this is a real exchange token between participation

// and cool rewards. Do not HODL this token, this token will never go MOON. No Lambos here.

// 

// This code was inspired by https://theethereum.wiki/w/index.php/ERC20_Token_Standard







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



contract KotloMordo is ERC20Interface, Owned {

    using SafeMath for uint;



    string public symbol;

    string public  name;

    uint8 public decimals;

    uint _totalSupply;



    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;



    constructor() public {

        symbol = "KM";

        name = "Kotlo Mordo";

        decimals = 2;

        _totalSupply = 10000 * 10**uint(decimals);

        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, _totalSupply);

    }



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



    // Don't accept ETH

    function () external payable {

        revert();

    }



    // Owner can transfer out any accidentally sent ERC20 token

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }

}