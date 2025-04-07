/**

 *Submitted for verification at Etherscan.io on 2018-10-02

*/



pragma solidity 0.4.18;











contract BpxToken {

    using ERC20Lib for ERC20Lib.TokenStorage;



    ERC20Lib.TokenStorage token;



    string public name = "AsobimoX";

    string public symbol = "ABX";

    uint8 public decimals = 8;

    uint public INITIAL_SUPPLY = 20000000;



    function BpxToken() public {

        // adding decimals to initial supply

        var totalSupply = INITIAL_SUPPLY * 10 ** uint256(decimals);

        // adding total supply to owner which could be msg.sender or specific address

        token.init(totalSupply, 0x7fEDD97be49ba9EfC21acc025Dd29aa7addc82F1);

    }



    function totalSupply() public view returns (uint) {

        return token.totalSupply;

    }



    function balanceOf(address who) public view returns (uint) {

        return token.balanceOf(who);

    }



    function allowance(address owner, address spender) public view returns (uint) {

        return token.allowance(owner, spender);

    }



    function transfer(address to, uint value) public returns (bool ok) {

        return token.transfer(to, value);

    }



    function transferFrom(address from, address to, uint value) public returns (bool ok) {

        return token.transferFrom(from, to, value);

    }



    function approve(address spender, uint value) public returns (bool ok) {

        return token.approve(spender, value);

    }



    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);

}