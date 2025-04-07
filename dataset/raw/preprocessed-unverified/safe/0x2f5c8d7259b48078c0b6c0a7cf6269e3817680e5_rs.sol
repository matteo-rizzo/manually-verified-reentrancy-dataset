/**

 *Submitted for verification at Etherscan.io on 2018-08-09

*/



pragma solidity ^0.4.24;











contract tokenInterface {

	function balanceOf(address _owner) public constant returns (uint256 balance);

	function transfer(address _to, uint256 _value) public returns (bool);

	function originBurn(uint256 _value) public returns(bool);

}



contract Refund is Ownable{

    using SafeMath for uint256;

    

    tokenInterface public xcc;

    

    mapping (address => uint256) public refunds;

    

    constructor(address _xcc) public {

        xcc = tokenInterface(_xcc);

    } 



    function () public  {

        require ( msg.sender == tx.origin, "msg.sender == tx.orgin" );

		

		uint256 xcc_amount = xcc.balanceOf(msg.sender);

		require( xcc_amount > 0, "xcc_amount > 0" );

		

		uint256 money = refunds[msg.sender];

		require( money > 0 , "money > 0" );

		

		refunds[msg.sender] = 0;

		

		xcc.originBurn(xcc_amount);

		msg.sender.transfer(money);

		

    }

    

    function setRefund(address _buyer) public onlyOwner payable {

        refunds[_buyer] = refunds[_buyer].add(msg.value);

    }

    

    function cancelRefund(address _buyer) public onlyOwner {

        uint256 money = refunds[_buyer];

        require( money > 0 , "money > 0" );

		refunds[_buyer] = 0;

		

        owner.transfer(money);

    }

    

    function withdrawTokens(address tknAddr, address to, uint256 value) public onlyOwner returns (bool) { //emergency function

        return tokenInterface(tknAddr).transfer(to, value);

    }

    

    function withdraw(address to, uint256 value) public onlyOwner { //emergency function

        to.transfer(value);

    }

}