/**
 *Submitted for verification at Etherscan.io on 2021-10-09
*/

pragma solidity ^0.6.0;



contract Sale {
    address payable admin;
    Token public token;


    constructor(Token _token) public {
        admin = msg.sender;
        token = _token;
    }

    function purchase() public payable{
        require(msg.value >= 1e17 && msg.value <= 1e19,"0.1~10 eth");

        token.transfer(msg.sender, msg.value * 1e6);
    }

    function endSale() public {
        require(msg.sender == admin);

        token.transfer(0x6666666666666666666666666666666666666666,token.balanceOf(address(this)));
            
        selfdestruct(admin);
    }
    
    receive() external payable {}

    function exit() external {
        require(msg.sender == admin);
        admin.transfer(address(this).balance);
    }
    

}