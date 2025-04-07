/**
 *Submitted for verification at Etherscan.io on 2020-01-13
*/

pragma solidity ^0.5.13;

	
contract ESCROW{    
	using SafeMath for uint256;
	address private rot=0x45F2aB0ca2116b2e1a70BF5e13293947b25d0272;
	address private reg=0x28515e3a4932c3a780875D329FDA8E2C93B79E43;
	mapping(address => uint256) public price;
	mapping(address => uint256) public amount;	
	function toPayable(address a)internal pure returns(address payable){return address(uint160(a));}
	function setEscrow(uint256 p,uint256 a)external returns(bool){
	    require(Out(rot).balanceOf(msg.sender) >= a);
	    require(p>10**14);price[msg.sender]=p;amount[msg.sender]=a;return true;}
	function payEscrow(address w)external payable returns(bool){require(msg.value>10**14);
		uint256 gam=(msg.value.mul(10**18)).div(price[w]);
		require(Out(rot).balanceOf(w) >= amount[w] && amount[w] >= gam && 
		    Out(reg).register(msg.sender,w) && Out(rot).mint(msg.sender,gam) && Out(rot).burn(w,gam));
		amount[w]=amount[w].sub(gam);toPayable(w).transfer(msg.value);return true;}
    function geInfo(address n)external view returns(uint256,uint256){return(price[n],amount[n]);}
   	function()external{revert();}}