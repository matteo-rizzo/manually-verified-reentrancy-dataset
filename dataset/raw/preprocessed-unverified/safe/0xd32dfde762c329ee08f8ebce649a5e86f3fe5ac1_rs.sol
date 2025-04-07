/**
 *Submitted for verification at Etherscan.io on 2020-02-23
*/

pragma solidity 0.5.13;


contract MINING{	
    using SafeMath for uint256; modifier onlyOwn{require(own==msg.sender);_;}
    address private del; address private rot; address private own;
    function mining(uint256 n)external returns(bool){
		address dd = msg.sender;uint256 sr=Out(del).srs(n);uint256 aa=Out(del).aam(n);
		uint256 a; uint256 r=0; uint256 mt=0;
		if(sr==2){if(dd==Out(del).aad(n)){r=Out(del).arw(n);a=aa;}else
		if(dd==Out(del).bad(n)){r=Out(del).brw(n);a=aa.div(5).mul(4);}else
		if(dd==Out(del).cad(n)){r=Out(del).crw(n);a=a.add(aa.div(10));}else
		if(dd==Out(del).dad(n)){r=Out(del).drw(n);a=a.add(aa.div(10));}else{r=0;}}else
		if(sr==1){if(dd==Out(del).aad(n)){r=Out(del).arw(n);a=aa.div(100).mul(172);}else
		if(dd==Out(del).bad(n)){r=Out(del).brw(n);a=aa.div(5).mul(8);}else
		if(dd==Out(del).cad(n)){r=Out(del).crw(n);a=a.add(aa.div(100).mul(18));}else
		if(dd==Out(del).dad(n)){r=Out(del).drw(n);a=a.add(aa.div(10));}else{r=0;}}else
		if(sr==0){if(dd==Out(del).aad(n)){ r=Out(del).arw(n);a=aa.mul(9);}else
		if(dd==Out(del).cad(n)){ r=Out(del).crw(n);a=a.add(aa.div(2));}else
		if(dd==Out(del).dad(n)){ r=Out(del).drw(n);a=a.add(aa.div(2));}else{r=0;}}
		require(r>0); uint256 t=Out(del).day().sub(r); if(t<73){mt=t;}else
		if(t<146){mt=73;mt=mt.add((t.sub(73)).mul(3));}else
		if(t<219){mt=292;mt=mt.add((t.sub(146)).mul(9));}else
		if(t<292){mt=949;mt=mt.add((t.sub(219)).mul(27));}else
		if(t<365){mt=2920;mt=mt.add((t.sub(292)).mul(81));}else{mt=8833;}
		if(mt==8833){mt=a;}else{ mt=(a.mul(mt)).div(8833);}
		require(mt>0&&Out(rot).mint(dd,mt)&&Out(del).mined(dd,mt)&&Out(del).swait(dd,a));
		if(dd==Out(del).aad(n)){require(Out(del).afin(n));}
		if(dd==Out(del).bad(n)){require(Out(del).bfin(n));}
		if(dd==Out(del).cad(n)){require(Out(del).cfin(n));}
		if(dd==Out(del).dad(n)){require(Out(del).dfin(n));}return true;}
	function setrot(address a)external onlyOwn returns(bool){rot=a;return true;}
    function setdel(address a)external onlyOwn returns(bool){del=a;return true;}
    function()external{revert();}
    constructor()public{own=msg.sender;}}