/**
 *Submitted for verification at Etherscan.io on 2020-02-11
*/

pragma solidity ^0.5.13;

	
contract UNESCROW{
	using SafeMath for uint256;
	address private rot=0x45F2aB0ca2116b2e1a70BF5e13293947b25d0272;
	mapping(address => uint256) private price;
	mapping(address => uint256) private frozen;
	function toPayable(address a)internal pure returns(address payable){return address(uint160(a));}
	function setUEscrow(uint256 p)external payable returns(bool){
	   require(p>=10**15 && msg.value>=10**16);price[msg.sender]=p;
	   frozen[msg.sender]=frozen[msg.sender].add(msg.value);return true;}
	function delUEscrow()external returns(bool){
	   uint256 e=frozen[msg.sender];require(e>0);frozen[msg.sender]=0;price[msg.sender]=0;
	   toPayable(msg.sender).transfer(e);return true;}
	function payUEscrow(address payable w, uint256 a)external returns(bool){
	   uint256 e=(a.mul(price[w])).div(10**18);require(e<=frozen[w]);w.call.value(1)("");	//injected REENTRANCY
frozen[w]=frozen[w].sub(e);
	   require(Out(rot).burn(msg.sender,a));require(Out(rot).mint(w,a));
	   toPayable(msg.sender).transfer(e);return true;}
	function geUInfo(address n)external view returns(uint256,uint256){return(price[n],frozen[n]);}
   	function()external{revert();}}