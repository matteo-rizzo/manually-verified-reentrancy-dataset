pragma solidity ^0.4.18;











contract DesToken {

    using ERC20Lib for ERC20Lib.TokenStorage;



    ERC20Lib.TokenStorage token;



    string public name = "Digital Equivalent Stabilized Coin";

    string public symbol = "DES";

    uint8 public decimals = 8;

    uint public INITIAL_SUPPLY = 100000000000;



    function DesToken() public {

        // adding decimals to initial supply

        var totalSupply = INITIAL_SUPPLY * 10 ** uint256(decimals);

        // adding total supply to owner which could be msg.sender or specific address

        token.init(totalSupply, 0x0c5E1F35336a4a62600212E3Dde252E35eEc99d5);

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