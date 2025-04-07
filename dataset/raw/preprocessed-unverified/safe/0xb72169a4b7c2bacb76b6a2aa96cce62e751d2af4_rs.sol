/**

 *Submitted for verification at Etherscan.io on 2018-08-30

*/



pragma solidity 0.4.18;











contract BpxToken {

    using ERC20Lib for ERC20Lib.TokenStorage;



    ERC20Lib.TokenStorage token;



    string public name = "BPX";

    string public symbol = "BPX";

    uint8 public decimals = 18;

    uint public INITIAL_SUPPLY = 1000000000;



    function BpxToken() public {

        // adding decimals to initial supply

        var totalSupply = INITIAL_SUPPLY * 10 ** uint256(decimals);

        // adding total supply to owner which could be msg.sender or specific address

        token.init(totalSupply, 0xC117Cbb17593aa21f3043FEca20F5CCEA2262d28);

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